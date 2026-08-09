/// Device information model
class DeviceInfo {
  final String hostname;
  final String macAddress;
  final String? model;
  final String? openwrtVersion;
  final String? ipAddress;
  final int? signalStrength;
  final bool isSetupComplete;
  final String? serviceType; // 'mdns', 'manual', 'qr'

  DeviceInfo({
    required this.hostname,
    required this.macAddress,
    this.model,
    this.openwrtVersion,
    this.ipAddress,
    this.signalStrength,
    this.isSetupComplete = false,
    this.serviceType,
  });

  factory DeviceInfo.fromJson(Map<String, dynamic> json) {
    return DeviceInfo(
      hostname: json['hostname'] ?? 'unknown',
      macAddress: json['mac'] ?? json['mac_address'] ?? '',
      model: json['model'],
      openwrtVersion: json['openwrt_version'] ?? json['version'],
      ipAddress: json['ip_address'] ?? json['ip'],
      signalStrength: json['signal_strength'],
      isSetupComplete: json['is_setup_complete'] ?? false,
      serviceType: json['service_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hostname': hostname,
      'mac': macAddress,
      'model': model,
      'openwrt_version': openwrtVersion,
      'ip_address': ipAddress,
      'signal_strength': signalStrength,
      'is_setup_complete': isSetupComplete,
      'service_type': serviceType,
    };
  }

  DeviceInfo copyWith({
    String? hostname,
    String? macAddress,
    String? model,
    String? openwrtVersion,
    String? ipAddress,
    int? signalStrength,
    bool? isSetupComplete,
    String? serviceType,
  }) {
    return DeviceInfo(
      hostname: hostname ?? this.hostname,
      macAddress: macAddress ?? this.macAddress,
      model: model ?? this.model,
      openwrtVersion: openwrtVersion ?? this.openwrtVersion,
      ipAddress: ipAddress ?? this.ipAddress,
      signalStrength: signalStrength ?? this.signalStrength,
      isSetupComplete: isSetupComplete ?? this.isSetupComplete,
      serviceType: serviceType ?? this.serviceType,
    );
  }
}
