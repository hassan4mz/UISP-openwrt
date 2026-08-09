/// Setup status model
class SetupStatus {
  final bool isConfigured;
  final bool needsPassword;
  final bool needsWifiConfig;
  final bool needsAdminConfig;
  final String? currentStep;
  final int progressPercent;

  SetupStatus({
    this.isConfigured = false,
    this.needsPassword = true,
    this.needsWifiConfig = true,
    this.needsAdminConfig = true,
    this.currentStep,
    this.progressPercent = 0,
  });

  factory SetupStatus.fromJson(Map<String, dynamic> json) {
    return SetupStatus(
      isConfigured: json['is_configured'] ?? false,
      needsPassword: json['needs_password'] ?? true,
      needsWifiConfig: json['needs_wifi_config'] ?? true,
      needsAdminConfig: json['needs_admin_config'] ?? true,
      currentStep: json['current_step'],
      progressPercent: json['progress_percent'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_configured': isConfigured,
      'needs_password': needsPassword,
      'needs_wifi_config': needsWifiConfig,
      'needs_admin_config': needsAdminConfig,
      'current_step': currentStep,
      'progress_percent': progressPercent,
    };
  }

  SetupStatus copyWith({
    bool? isConfigured,
    bool? needsPassword,
    bool? needsWifiConfig,
    bool? needsAdminConfig,
    String? currentStep,
    int? progressPercent,
  }) {
    return SetupStatus(
      isConfigured: isConfigured ?? this.isConfigured,
      needsPassword: needsPassword ?? this.needsPassword,
      needsWifiConfig: needsWifiConfig ?? this.needsWifiConfig,
      needsAdminConfig: needsAdminConfig ?? this.needsAdminConfig,
      currentStep: currentStep ?? this.currentStep,
      progressPercent: progressPercent ?? this.progressPercent,
    );
  }
}
