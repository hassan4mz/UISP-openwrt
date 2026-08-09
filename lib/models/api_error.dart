/// API error model
class ApiError {
  final String message;
  final String? code;
  final int? statusCode;
  final Map<String, dynamic>? details;

  ApiError({
    required this.message,
    this.code,
    this.statusCode,
    this.details,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      message: json['message'] ?? json['error'] ?? 'Unknown error',
      code: json['code'],
      statusCode: json['status_code'] ?? json['statusCode'],
      details: json['details'] != null 
          ? Map<String, dynamic>.from(json['details']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'code': code,
      'statusCode': statusCode,
      'details': details,
    };
  }

  @override
  String toString() => 'ApiError(message: $message, code: $code, statusCode: $statusCode)';
}
