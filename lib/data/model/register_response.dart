class RegisterResponse {
  final bool error;
  final String message;

  RegisterResponse({
    required this.error,
    required this.message,
  });

  factory RegisterResponse.fromJson(Map json) {
    return RegisterResponse(
      error: json['error'] ?? false,
      message: json['message'] ?? '',
    );
  }
}