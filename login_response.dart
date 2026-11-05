// class LoginResponse {
//   final bool status;
//   final String message;
//   final String employeeId;
//   final String loginId;
//   final String employeeName;
//   final String sessionToken;
//   final String expiryTime;
//   final String role;
//   LoginResponse({
//     required this.status,
//     required this.message,
//     required this.employeeId,
//     required this.loginId,
//     required this.employeeName,
//     required this.sessionToken,
//     required this.expiryTime,
//     required this.role,
//   });
//
//   factory LoginResponse.fromJson(Map<String, dynamic> json) {
//
//     final rawRole = json['role']?.toString() ?? 'employee';
//     final normalizedRole = rawRole.toLowerCase();
//
//     return LoginResponse(
//       status: json['status'] == true,
//       message: json['message']?.toString() ?? '',
//       employeeId: json['employee_id']?.toString() ?? '',
//       loginId: json['login_id']?.toString() ?? '',
//       employeeName: json['employee_name']?.toString() ?? '',
//       sessionToken: json['session_token']?.toString() ?? '',
//       expiryTime: json['expiry_time']?.toString() ?? '',
//       role: normalizedRole,
//     );
//   }
//
//   LoginResponse copyWith({
//     bool? status,
//     String? message,
//     String? employeeId,
//     String? loginId,
//     String? employeeName,
//     String? sessionToken,
//     String? expiryTime,
//     String? role,
//   }) {
//     return LoginResponse(
//       status: status ?? this.status,
//       message: message ?? this.message,
//       employeeId: employeeId ?? this.employeeId,
//       loginId: loginId ?? this.loginId,
//       employeeName: employeeName ?? this.employeeName,
//       sessionToken: sessionToken ?? this.sessionToken,
//       expiryTime: expiryTime ?? this.expiryTime,
//       role: role ?? this.role,
//     );
//   }
//
//   bool get isTokenValid {
//     return status && sessionToken.isNotEmpty;
//   }
// }
import 'package:flutter/cupertino.dart';

class LoginResponse {
  final bool status;
  final String message;
  final String employeeId;
  final String loginId;
  final String employeeName;
  final String sessionToken;
  final String expiryTime;
  final String role;
  final String designation;
  final String department;
  LoginResponse({
    required this.status,
    required this.message,
    required this.employeeId,
    required this.loginId,
    required this.employeeName,
    required this.sessionToken,
    required this.expiryTime,
    required this.role,
    required this.designation,
    required this.department,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {

    final Map<String, dynamic> data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;

    final rawRole = data['role']?.toString() ?? 'employee';
    final normalizedRole = rawRole.toLowerCase();

    return LoginResponse(
      status: _parseStatus(json['status']),
      message: json['message']?.toString() ?? '',
      employeeId: data['employee_id']?.toString() ?? '',        // ← changed json → data
      loginId: data['login_id']?.toString() ?? '',              // ← changed json → data
      employeeName: data['employee_name']?.toString() ?? '',    // ← changed json → data
      sessionToken: data['session_token']?.toString() ?? '',    // ← changed json → data
      expiryTime: data['expiry_time']?.toString() ?? '',        // ← changed json → data
      role: normalizedRole,
      designation: data['designation']?.toString() ?? '',
      department: data['department']?.toString() ?? '',
    );
  }

  static bool _parseStatus(dynamic value) {
    if (value is bool) return value;
    if (value is String) {
      final lower = value.toLowerCase().trim();
      return lower == 'true' || lower == 'success' || lower == '1' || lower == 'ok';
    }
    if (value is num) return value != 0;
    return false;
  }


  LoginResponse copyWith({
    bool? status,
    String? message,
    String? employeeId,
    String? loginId,
    String? employeeName,
    String? sessionToken,
    String? expiryTime,
    String? role,
    String? designation,
    String? department,
  }) {

    return LoginResponse(
      status: status ?? this.status,
      message: message ?? this.message,
      employeeId: employeeId ?? this.employeeId,
      loginId: loginId ?? this.loginId,
      employeeName: employeeName ?? this.employeeName,
      sessionToken: sessionToken ?? this.sessionToken,
      expiryTime: expiryTime ?? this.expiryTime,
      role: role ?? this.role,
      designation: designation ?? this.designation,
      department: department ?? this.department,

    );

  }

  bool get isTokenValid {
    return status && sessionToken.isNotEmpty;
  }
}
