import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:multicast_dns/multicast_dns.dart';
import '../models/device_info.dart';

/// Service for discovering OpenWrt devices via mDNS/DNS-SD
class DiscoveryService {
  static const String serviceType = '_openwrt-setup._tcp';
  static const String localDomain = 'local.';

  final MDnsClient _client = MDnsClient();
  final List<DeviceInfo> _discoveredDevices = [];
  final _devicesStreamController = StreamController<List<DeviceInfo>>.broadcast();
  bool _isDiscovering = false;

  /// Stream of discovered devices
  Stream<List<DeviceInfo>> get devicesStream => _devicesStreamController.stream;

  /// List of currently discovered devices
  List<DeviceInfo> get discoveredDevices => List.unmodifiable(_discoveredDevices);

  /// Check if currently discovering
  bool get isDiscovering => _isDiscovering;

  /// Start mDNS discovery
  Future<void> startDiscovery({Duration timeout = const Duration(seconds: 10)}) async {
    if (_isDiscovering) return;

    _isDiscovering = true;
    _discoveredDevices.clear();

    try {
      await _client.start();

      // Query for PTR records to find services
      final ptrRecords = await _client.lookup('_openwrt-setup._tcp.local').toList();

      for (final ptrRecord in ptrRecords) {
        // Extract domain name from PTR record data
        final domainName = ptrRecord.data.toString();
        
        // Query for SRV records to get host and port
        final srvRecords = await _client.lookup(domainName).toList();

        for (final srvRecord in srvRecords) {
          // Extract target from SRV record data
          final srvData = srvRecord.data.toString();
          final parts = srvData.split(' ');
          if (parts.length >= 4) {
            final target = parts[3];
            
            // Query for A records to get IP address
            final aRecords = await _client.lookup(target).toList();

            String? ipAddress;
            for (final aRecord in aRecords) {
              ipAddress = aRecord.data.toString();
              break;
            }

            // Query for TXT records to get device info
            final txtRecords = await _client.lookup(domainName).toList();

            Map<String, String> txtData = {};
            for (final txtRecord in txtRecords) {
              final text = txtRecord.data.toString();
              final eqIndex = text.indexOf('=');
              if (eqIndex > 0) {
                txtData[text.substring(0, eqIndex)] = text.substring(eqIndex + 1);
              }
            }

            final device = DeviceInfo(
              hostname: target.replaceAll('.$localDomain', '').replaceAll('.', ''),
              macAddress: txtData['mac'] ?? txtData['MAC'] ?? '',
              model: txtData['model'],
              openwrtVersion: txtData['version'] ?? txtData['openwrt_version'],
              ipAddress: ipAddress,
              serviceType: 'mdns',
            );

            if (!_discoveredDevices.any((d) => d.macAddress == device.macAddress)) {
              _discoveredDevices.add(device);
              _devicesStreamController.add(List.from(_discoveredDevices));
            }
          }
        }
      }
    } catch (e) {
      // Log error but don't crash
      _logError('mDNS discovery error', e);
    } finally {
      _isDiscovering = false;
    }
  }

  /// Stop discovery
  void stopDiscovery() {
    _client.stop();
    _isDiscovering = false;
  }

  /// Add device manually by IP address
  Future<DeviceInfo?> addDeviceByIp(String ipAddress, {String? setupToken}) async {
    try {
      // Validate IP address format
      final ipValid = InternetAddress.tryParse(ipAddress) != null;
      if (!ipValid) {
        throw ArgumentError('Invalid IP address format');
      }

      // Try to fetch device info from the API
      final client = HttpClient();
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      
      try {
        final request = await client.getUrl(Uri.parse('https://$ipAddress/api/v1/info'));
        request.headers.set('Accept', 'application/json');
        
        if (setupToken != null && setupToken.isNotEmpty) {
          request.headers.set('Authorization', 'Bearer $setupToken');
        }
        
        final response = await request.close();
        
        if (response.statusCode == 200) {
          final body = await response.transform(utf8.decoder).join();
          final json = jsonDecode(body);
          
          final device = DeviceInfo(
            hostname: json['hostname'] ?? 'openwrt',
            macAddress: json['mac'] ?? json['mac_address'] ?? '',
            model: json['model'],
            openwrtVersion: json['openwrt_version'] ?? json['version'],
            ipAddress: ipAddress,
            serviceType: 'manual',
          );

          if (!_discoveredDevices.any((d) => d.ipAddress == ipAddress)) {
            _discoveredDevices.add(device);
            _devicesStreamController.add(List.from(_discoveredDevices));
          }

          return device;
        }
      } finally {
        client.close();
      }
    } catch (e) {
      _logError('Manual device addition error', e);
      // Return a minimal device info even if API call fails
      final device = DeviceInfo(
        hostname: 'openwrt',
        macAddress: '',
        ipAddress: ipAddress,
        serviceType: 'manual',
      );
      
      if (!_discoveredDevices.any((d) => d.ipAddress == ipAddress)) {
        _discoveredDevices.add(device);
        _devicesStreamController.add(List.from(_discoveredDevices));
      }
      
      return device;
    }
    return null;
  }

  /// Add device by MAC address
  Future<DeviceInfo?> addDeviceByMac(String macAddress) async {
    // Normalize MAC address
    final normalizedMac = macAddress.replaceAll(':', '').toUpperCase();
    
    if (normalizedMac.length != 12) {
      throw ArgumentError('Invalid MAC address format');
    }

    // Generate potential hostnames based on MAC
    final potentialHostnames = [
      'openwrt-$normalizedMac',
      'owrt-$normalizedMac',
      'device-$normalizedMac',
    ];

    // Try to resolve via mDNS
    for (final hostname in potentialHostnames) {
      try {
        final aRecords = await _client.lookup('$hostname.$localDomain').toList();

        for (final aRecord in aRecords) {
          final ipAddress = aRecord.data.toString();
          return await addDeviceByIp(ipAddress);
        }
      } catch (e) {
        continue;
      }
    }

    // If not found, create a placeholder device
    final device = DeviceInfo(
      hostname: 'openwrt-$normalizedMac',
      macAddress: macAddress,
      serviceType: 'manual',
    );

    if (!_discoveredDevices.any((d) => d.macAddress == macAddress)) {
      _discoveredDevices.add(device);
      _devicesStreamController.add(List.from(_discoveredDevices));
    }

    return device;
  }

  /// Parse device info from QR code data
  DeviceInfo? parseQrCodeData(String qrData) {
    try {
      // Try parsing as JSON first
      final json = jsonDecode(qrData);
      return DeviceInfo(
        hostname: json['hostname'] ?? 'openwrt',
        macAddress: json['mac'] ?? json['mac_address'] ?? '',
        model: json['model'],
        openwrtVersion: json['openwrt_version'],
        ipAddress: json['ip'] ?? json['ip_address'],
        serviceType: 'qr',
      );
    } catch (e) {
      // Try parsing as URL
      if (qrData.startsWith('http')) {
        final uri = Uri.parse(qrData);
        return DeviceInfo(
          hostname: uri.host,
          macAddress: uri.queryParameters['mac'] ?? '',
          ipAddress: uri.host,
          serviceType: 'qr',
        );
      }

      // Try parsing as SSID:password format
      if (qrData.contains(':')) {
        final parts = qrData.split(':');
        return DeviceInfo(
          hostname: parts[0],
          macAddress: '',
          serviceType: 'qr',
        );
      }
    }
    return null;
  }

  /// Clear discovered devices
  void clearDevices() {
    _discoveredDevices.clear();
    _devicesStreamController.add([]);
  }

  /// Remove a device from the list
  void removeDevice(String macAddress) {
    _discoveredDevices.removeWhere((d) => d.macAddress == macAddress);
    _devicesStreamController.add(List.from(_discoveredDevices));
  }

  /// Dispose resources
  void dispose() {
    stopDiscovery();
    _devicesStreamController.close();
  }

  /// Log error (in production, use proper logging)
  void _logError(String message, Object error) {
    // In production, use a proper logging service
    // For now, just skip logging during production builds
  }
}
