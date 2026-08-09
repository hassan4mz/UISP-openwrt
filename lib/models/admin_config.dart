/// Admin configuration model
class AdminConfig {
  final String? adminPassword;
  final String? hostname;

  AdminConfig({
    this.adminPassword,
    this.hostname,
  });

  factory AdminConfig.fromJson(Map<String, dynamic> json) {
    return AdminConfig(
      adminPassword: json['admin_password'],
      hostname: json['hostname'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'admin_password': adminPassword,
      'hostname': hostname,
    };
  }

  AdminConfig copyWith({
    String? adminPassword,
    String? hostname,
  }) {
    return AdminConfig(
      adminPassword: adminPassword ?? this.adminPassword,
      hostname: hostname ?? this.hostname,
    );
  }
}
