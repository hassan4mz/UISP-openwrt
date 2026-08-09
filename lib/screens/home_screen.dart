import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/services.dart';
import 'device_detail_screen.dart';
import 'add_device_screen.dart';
import 'qr_scan_screen.dart';
import 'troubleshooting_screen.dart';

/// Main home screen showing discovered devices
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DiscoveryService _discoveryService = DiscoveryService();
  List<DeviceInfo> _devices = [];
  bool _isDiscovering = false;

  @override
  void initState() {
    super.initState();
    _startDiscovery();
  }

  @override
  void dispose() {
    _discoveryService.dispose();
    super.dispose();
  }

  Future<void> _startDiscovery() async {
    setState(() => _isDiscovering = true);
    
    // Listen for discovered devices
    _discoveryService.devicesStream.listen((devices) {
      if (mounted) {
        setState(() => _devices = devices);
      }
    });

    await _discoveryService.startDiscovery();
    
    if (mounted) {
      setState(() => _isDiscovering = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OpenWrt Setup'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () => _navigateToQrScan(),
            tooltip: 'Scan QR Code',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToAddDevice(),
            tooltip: 'Add Device Manually',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'troubleshooting') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TroubleshootingScreen()),
                );
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'troubleshooting', child: Text('Troubleshooting')),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _startDiscovery,
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isDiscovering ? null : _startDiscovery,
        icon: _isDiscovering 
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.refresh),
        label: Text(_isDiscovering ? 'Scanning...' : 'Scan for Devices'),
      ),
    );
  }

  Widget _buildBody() {
    if (_devices.isEmpty && !_isDiscovering) {
      return _buildEmptyState();
    }

    return ListView.builder(
      itemCount: _devices.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final device = _devices[index];
        return _buildDeviceCard(device);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.router_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No Devices Found',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Make sure your device is powered on and connected to the same network.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _navigateToAddDevice,
              icon: const Icon(Icons.add),
              label: const Text('Add Device Manually'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceCard(DeviceInfo device) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: device.isSetupComplete
              ? Colors.green
              : Theme.of(context).colorScheme.primary,
          child: Icon(
            device.isSetupComplete ? Icons.check : Icons.settings,
            color: Colors.white,
          ),
        ),
        title: Text(
          device.hostname.isNotEmpty ? device.hostname : 'OpenWrt Device',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (device.model != null && device.model!.isNotEmpty)
              Text(device.model!),
            if (device.ipAddress != null && device.ipAddress!.isNotEmpty)
              Text(device.ipAddress!),
            if (device.macAddress.isNotEmpty)
              Text(device.macAddress, style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
        ),
        onTap: () => _navigateToDeviceDetail(device),
      ),
    );
  }

  void _navigateToDeviceDetail(DeviceInfo device) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DeviceDetailScreen(device: device),
      ),
    );
  }

  void _navigateToAddDevice() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddDeviceScreen()),
    ).then((_) {
      // Refresh devices when returning
      _startDiscovery();
    });
  }

  void _navigateToQrScan() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const QrScanScreen()),
    ).then((_) {
      // Refresh devices when returning
      _startDiscovery();
    });
  }
}
