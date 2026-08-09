/// WiFi configuration model
class WifiConfig {
  final String ssid;
  final String password;
  final String security; // WPA2, WPA3, WPA2/WPA3
  final bool hiddenSsid;
  final String countryCode;
  final int? channel;
  final String? channelWidth;

  WifiConfig({
    required this.ssid,
    required this.password,
    this.security = 'WPA2',
    this.hiddenSsid = false,
    this.countryCode = 'US',
    this.channel,
    this.channelWidth,
  });

  factory WifiConfig.fromJson(Map<String, dynamic> json) {
    return WifiConfig(
      ssid: json['ssid'] ?? '',
      password: json['password'] ?? '',
      security: json['security'] ?? 'WPA2',
      hiddenSsid: json['hidden_ssid'] ?? false,
      countryCode: json['country_code'] ?? 'US',
      channel: json['channel'],
      channelWidth: json['channel_width'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ssid': ssid,
      'password': password,
      'security': security,
      'hidden_ssid': hiddenSsid,
      'country_code': countryCode,
      'channel': channel,
      'channel_width': channelWidth,
    };
  }

  WifiConfig copyWith({
    String? ssid,
    String? password,
    String? security,
    bool? hiddenSsid,
    String? countryCode,
    int? channel,
    String? channelWidth,
  }) {
    return WifiConfig(
      ssid: ssid ?? this.ssid,
      password: password ?? this.password,
      security: security ?? this.security,
      hiddenSsid: hiddenSsid ?? this.hiddenSsid,
      countryCode: countryCode ?? this.countryCode,
      channel: channel ?? this.channel,
      channelWidth: channelWidth ?? this.channelWidth,
    );
  }
}
