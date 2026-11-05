class LogoutResponse {
  final bool status;
  final String message;
  final String employeeId;
  final String loginId;
  final String logoutTime;

  LogoutResponse({
    required this.status,
    required this.message,
    required this.employeeId,
    required this.loginId,
    required this.logoutTime,
  });

  factory LogoutResponse.fromJson(Map<String, dynamic> json) {
    return LogoutResponse(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      employeeId: json['employee_id']?.toString() ?? '',
      loginId: json['login_id']?.toString() ?? '',
      logoutTime: json['logout_time']?.toString() ?? '',
    );
  }
}