/// Station (uplink WiFi) configuration model
class StationConfig {
  final String? ssid;
  final String? password;
  final String? security;
  final bool enabled;

  StationConfig({
    this.ssid,
    this.password,
    this.security,
    this.enabled = false,
  });

  factory StationConfig.fromJson(Map<String, dynamic> json) {
    return StationConfig(
      ssid: json['ssid'],
      password: json['password'],
      security: json['security'],
      enabled: json['enabled'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ssid': ssid,
      'password': password,
      'security': security,
      'enabled': enabled,
    };
  }

  StationConfig copyWith({
    String? ssid,
    String? password,
    String? security,
    bool? enabled,
  }) {
    return StationConfig(
      ssid: ssid ?? this.ssid,
      password: password ?? this.password,
      security: security ?? this.security,
      enabled: enabled ?? this.enabled,
    );
  }
}
