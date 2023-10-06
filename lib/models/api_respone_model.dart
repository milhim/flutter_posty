class ApiResponse {
  String code = '';
  String message = '';
  Map<String, dynamic>? data = <String, dynamic>{};

  ApiResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  factory ApiResponse.fromJson(dynamic json) {
    return ApiResponse(
        code: json['code'], message: json['message'], data: json['data']);
  }
}
