class LoginRequest {
  final String loginId;
  final String password;
  final String role;
  final bool rememberMe;

  LoginRequest({
    required this.loginId,
    required this.password,
    this.role = 'employee',
    required this.rememberMe,
  });

  Map<String, dynamic> toJson() {
    return {
      'login_id': loginId,
      'password': password,
      'role': role,
      'remember_me': rememberMe,
    };
  }
}