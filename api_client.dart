import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import '../config/api_config.dart';
import '../models/attendance_model/attendance_response.dart';
import '../models/attendance_record.dart';
import '../models/auth/employee_model.dart';
import '../models/auth/login_request.dart';
import '../models/auth/login_response.dart';
import '../models/auth/logout_response.dart';
import '../models/auth/role_model.dart';
import '../services/app_session.dart';

import 'package:http/http.dart' as http;


class ApiClient extends GetxService {
  static const Duration requestTimeout = Duration(seconds: 15);

  final AppSession _appSession = Get.find<AppSession>();

  String get baseUrl => ApiConfig.baseUrl;

  String? _authToken;

  @override
  void onInit() {
    super.onInit();

    _authToken = _appSession.token.value;

    ever<String>(
      _appSession.token,
      (String newToken) {
        _authToken = newToken;
      },
    );
  }

  // HEADERS

  Map<String, String> get _headers {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-API-Key': 'ATTENDANCE_API_2026_ABC123XYZ',
      if (_authToken != null && _authToken!.isNotEmpty)
        'Authorization': 'Bearer $_authToken',
    };
  }

  // SEND REQUEST

  Future<http.Response> _send(
    Future<http.Response> Function() action,
  ) async {
    try {
      return await action().timeout(
        requestTimeout,
      );
    } on TimeoutException {
      throw Exception(
        'Server did not respond in time.\n'
        'Check the API address:\n$baseUrl',
      );
    } on SocketException {
      throw Exception(
        'Cannot reach the server at:\n$baseUrl\n\n'
        'Make sure the server is running and '
        'the device is connected to the same network.',
      );
    } on http.ClientException catch (e) {
      throw Exception(
        'Network error: ${e.message}',
      );
    } on HandshakeException {
      throw Exception(
        'Secure connection to the server failed.',
      );
    } on FormatException {
      throw Exception(
        'Server returned an invalid response.',
      );
    }
  }

  // ERROR RESPONSE

  Map<String, dynamic> _errorBody(
    http.Response response,
    String fallback,
  ) {
    try {
      final dynamic decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {
      // Ignore invalid JSON
    }

    return {
      'message': fallback,
    };
  }

  Future<LoginResponse> login(
    LoginRequest request,
  ) async {
    print('=== FLUTTER LOGIN REQUEST ===');
    print('URL: ${ApiConfig.loginUrl}');
    print('Payload: ${jsonEncode(request.toJson())}');
    final http.Response response = await _send(
      () => http.post(
        Uri.parse(ApiConfig.loginUrl),
        headers: _headers,
        body: jsonEncode(
          request.toJson(),
        ),
      ),
    );

    dynamic decoded;

    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      throw Exception(
        'Invalid JSON response from login API.',
      );
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (decoded is! Map<String, dynamic>) {
        throw Exception(
          'Invalid login response format.',
        );
      }

      return LoginResponse.fromJson(decoded);
    }

    final Map<String, dynamic> error = _errorBody(
      response,
      'Login failed',
    );

    throw Exception(
      error['message']?.toString() ?? 'Login failed',
    );
  }

  Future<List<RoleModel>> getRoles() async {
    final http.Response response = await _send(
      () => http.get(
        Uri.parse(ApiConfig.rolesUrl),
        headers: _headers,
      ),
    );

    if (response.statusCode != 200) {
      final Map<String, dynamic> error = _errorBody(
        response,
        'Failed to fetch roles',
      );

      throw Exception(
        error['message']?.toString() ?? 'Failed to fetch roles',
      );
    }

    final dynamic decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception(
        'Invalid roles response format.',
      );
    }

    return decoded
        .map(
          (dynamic item) => RoleModel.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<List<Employee>> getEmployees() async {
    debugPrint('=== FETCH EMPLOYEES ===');
    debugPrint('URL: ${ApiConfig.employeesUrl}');
    debugPrint('Headers: $_headers');

    final http.Response response = await _send(
      () => http.post(
        Uri.parse(ApiConfig.employeesUrl),
        headers: _headers,
        body: jsonEncode({'page': 1, 'limit': 100}),
      ),
    );

    debugPrint('Status: ${response.statusCode}');
  //  debugPrint('Body: ${response.body}');

    if (response.statusCode != 200) {
      final Map<String, dynamic> error =
          _errorBody(response, 'Failed to fetch employees');
      debugPrint('Error: $error');
      throw Exception(error['message']?.toString() ??
          'Failed to fetch employees: ${response.statusCode}');
    }

    final dynamic decoded = jsonDecode(response.body);
    debugPrint('Decoded: $decoded');

    final List<dynamic> data;

    if (decoded is List) {
      data = decoded;
    } else if (decoded is Map<String, dynamic>) {
      data = _extractEmployeeList(decoded);
    } else {
      throw Exception('Invalid employees response format.');
    }

    debugPrint('Extracted ${data.length} employees');
    return data
        .whereType<Map<String, dynamic>>()
        .map((Map<String, dynamic> item) => Employee.fromJson(item))
        .toList();
  }
  // Handles a wrapped response

  List<dynamic> _extractEmployeeList(Map<String, dynamic> json) {
    const List<String> keys = <String>[
      'employees',
      'data',
      'result',
      'employee_list',
    ];

    for (final String key in keys) {
      final dynamic value = json[key];

      if (value is List) {
        return value;
      }
    }

    throw Exception('Invalid employees response format.');
  }

  Future<Map<String, dynamic>> markAttendance({
    required String loginId,
    required String type,
    required double latitude,
    required double longitude,
    required String location,
    String? photoPath,
  }) async {
    final Map<String, dynamic> body = {
      'loginId': loginId,
      'type': type,
      'latitude': latitude,
      'longitude': longitude,
      'location': location,
      if (photoPath != null && photoPath.isNotEmpty) 'photoPath': photoPath,
    };

    final http.Response response = await _send(
      () => http.post(
        Uri.parse(
          ApiConfig.attendanceUrl,
        ),
        headers: _headers,
        body: jsonEncode(body),
      ),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dynamic decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      throw Exception(
        'Invalid attendance response.',
      );
    }

    final Map<String, dynamic> error = _errorBody(
      response,
      'Failed to mark attendance',
    );

    throw Exception(
      error['message']?.toString() ?? 'Failed to mark attendance',
    );
  }


  Future<AttendanceResponse> checkIn({
    required String employeeId,
    required double latitude,
    required double longitude,
    required String location,
    String? photoPath,
  }) async {
    return _postAttendance(
      ApiConfig.checkInUrl,
      fields: {
        'employee_id': employeeId, // Already string
        'attendance_date': _todayDate(),
        'remarks': location,
        'check_in_latitude': latitude.toString(),
        'check_in_longitude': longitude.toString(),
      },
      photoPath: photoPath,
      imageFieldName: 'check_in_image',
    );
  }


  Future<AttendanceResponse> checkOut({
    required String employeeId,
    required double latitude,
    required double longitude,
    required String location,
    String? photoPath,
  }) async {
    return _postAttendance(
      ApiConfig.checkOutUrl,
      fields: {
        'employee_id': employeeId, // Already string from parameter
        'attendance_date': _todayDate(),
        'check_out_latitude': latitude.toString(),
        'check_out_longitude': longitude.toString(),
        'remarks': location,
      },
      photoPath: photoPath,
      imageFieldName: 'check_out_image',
    );
  }

  Future<AttendanceResponse> _postAttendance(
    String url, {
    required Map<String, String> fields,
    String? photoPath,
    required String imageFieldName,
  }) async {
    debugPrint('=== REQUEST DEBUG ===');
    debugPrint('URL: $url');
    debugPrint('METHOD: POST');
    debugPrint('HEADERS: $_headers');
    debugPrint('CONTENT-TYPE: ${_headers['Content-Type']}');
    debugPrint('FIELDS: $fields');
    final request = http.MultipartRequest('POST', Uri.parse(url));

    request.headers['Authorization'] = 'Bearer $_authToken';
    request.headers['Accept'] = 'application/json';
    request.headers['X-API-Key'] = 'ATTENDANCE_API_2026_ABC123XYZ';

    // Add all fields as form-data
    request.fields.addAll(fields);

    // Attach image as file (not base64)
    if (photoPath != null && photoPath.isNotEmpty) {
      final file = File(photoPath);
      debugPrint('PHOTO EXISTS: ${await file.exists()}');
      debugPrint('PHOTO SIZE: ${await file.length()} bytes');
      debugPrint('PHOTO PATH: $photoPath');
      if (await file.exists()) {
        try {
          final multipartFile =
              await http.MultipartFile.fromPath(imageFieldName, photoPath);
          request.files.add(multipartFile);
          debugPrint('ATTACHED FILE: $imageFieldName → $photoPath');
        } catch (e) {
          debugPrint('FAILED TO ATTACH FILE: $e');
        }
      } else {
        debugPrint('WARNING: Image file not found: $photoPath');
      }
    }

    debugPrint('=== ATTENDANCE REQUEST (MULTIPART) ===');
    debugPrint('URL: $url');
    debugPrint('FIELDS: $fields');
    debugPrint('FILES: ${request.files.map((f) => f.field).toList()}');

    late final http.StreamedResponse streamed;
    try {
      streamed = await request.send().timeout(requestTimeout);
    } on TimeoutException {
      throw Exception(
          'Server did not respond in time.\nCheck the API address:\n$baseUrl');
    } on SocketException {
      throw Exception(
          'Cannot reach the server at:\n$baseUrl\n\nMake sure the server is running and the device is connected to the same network.');
    }

    final http.Response response = await http.Response.fromStream(streamed);
    debugPrint('=== RESPONSE DEBUG ===');
    debugPrint('STATUS: ${response.statusCode}');
    debugPrint('HEADERS: ${response.headers}');
    debugPrint('CONTENT-TYPE: ${response.headers['content-type']}');
  //  debugPrint('BODY LENGTH: ${response.body.length}');
    debugPrint(
        'BODY (first 500): ${response.body.length > 500 ? response.body.substring(0, 500) : response.body}');

    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      throw Exception(
          'Invalid JSON response from attendance API. Body: ${response.body}');
    }

    if (response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 409) {
      debugPrint(' PARSING ${response.statusCode} RESPONSE ');
      if (decoded is! Map<String, dynamic>) {
        throw Exception('Invalid attendance response format.');
      }
      final attendanceResponse = AttendanceResponse.fromJson(decoded);
      debugPrint(
          'Parsed response: status=${attendanceResponse.status}, message=${attendanceResponse.message}');
      return attendanceResponse;
    }

    final Map<String, dynamic> error =
        _errorBody(response, 'Failed to mark attendance');
    throw Exception(
        error['message']?.toString() ?? 'Failed to mark attendance');
  }

  static String _todayDate() {
    return DateTime.now().toIso8601String().substring(0, 10);
  }

  Future<LogoutResponse> logout() async {
    final http.Response response = await _send(
      () => http.post(
        Uri.parse(ApiConfig.logoutUrl),
        headers: _headers,
      ),
    );

    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      throw Exception('Invalid JSON response from logout API.');
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (decoded is! Map<String, dynamic>) {
        throw Exception('Invalid logout response format.');
      }
      return LogoutResponse.fromJson(decoded);
    }

    final Map<String, dynamic> error = _errorBody(response, 'Logout failed');
    throw Exception(error['message']?.toString() ?? 'Logout failed');
  }

  Future<AttendanceResponse?> fetchTodayAttendance({required String employeeId}) async {
    final url = '${ApiConfig.baseUrl}/attendance/employee/$employeeId';
    try {
      final response = await _send(() => http.post(
        Uri.parse(url),
        headers: _headers,
        body: jsonEncode({'attendance_date': _todayDate()}),
      ));

      debugPrint('TODAY STATUS: ${response.statusCode}');
  //    debugPrint('TODAY BODY: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          // Backend returns attendance in array, extract today's record to top-level
          final attendanceList = decoded['attendance'] as List?;
          final today = _todayDate();

          // Find today's record from attendance array and merge to top-level
          for (final item in attendanceList ?? []) {
            if (item is Map<String, dynamic>) {
              final attDate = item['attendance_date']?.toString() ?? '';
              if (attDate == today) {
                final merged = Map<String, dynamic>.from(decoded);
                merged.addAll(item);
                return AttendanceResponse.fromJson(merged);
              }
            }
          }

          return AttendanceResponse.fromJson(decoded);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Fetch today attendance error: $e');
      return null;
    }
  }


  Future<List<AttendanceRecord>> fetchAttendanceHistory({
    required String employeeId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final url = '${ApiConfig.baseUrl}/attendance/employee/$employeeId';
    try {
      final body = <String, dynamic>{};
      if (startDate != null) {
        body['start_date'] = startDate.toIso8601String().substring(0, 10);
      }
      if (endDate != null) {
        body['end_date'] = endDate.toIso8601String().substring(0, 10);
      }
      final response = await _send(() => http.post(
        Uri.parse(url),
        headers: {
          // No 'Content-Type' - http auto-sets to x-www-form-urlencoded
          'Accept': 'application/json',
          'X-API-Key': 'ATTENDANCE_API_2026_ABC123XYZ',
          if (_authToken != null && _authToken!.isNotEmpty)
            'Authorization': 'Bearer $_authToken',
        },
        body: body,
      ));


      debugPrint('HISTORY STATUS: ${response.statusCode}');
     // debugPrint('HISTORY BODY: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          final attendanceList = decoded['attendance'] as List?;
          if (attendanceList == null) return [];

          final List<AttendanceRecord> records = [];

          for (final item in attendanceList.whereType<Map<String, dynamic>>()) {
            final checkIn = item['check_in']?.toString();
            final checkOut = item['check_out']?.toString();

            if (checkIn != null && checkIn.isNotEmpty) {
              records.add(AttendanceRecord(
                id: item['id']?.toString() ?? '',
                loginId: item['created_by']?.toString() ?? '',
                employeeId: item['employee_id']?.toString() ?? '',
                timestamp: _parseBackendTime(checkIn),
                type: 'IN',
                location: item['remarks']?.toString() ?? '',
                photoPath: item['check_in_image']?.toString(),
                latitude: double.tryParse(
                        item['check_in_latitude']?.toString() ?? '0') ??
                    0.0,
                longitude: double.tryParse(
                        item['check_in_longitude']?.toString() ?? '0') ??
                    0.0,
              ));
            }

            if (checkOut != null && checkOut.isNotEmpty) {
              records.add(AttendanceRecord(
                id: item['id']?.toString() ?? '',
                loginId: item['created_by']?.toString() ?? '',
                employeeId: item['employee_id']?.toString() ?? '',
                timestamp: _parseBackendTime(checkOut),
                type: 'OUT',
                location: item['remarks']?.toString() ?? '',
                photoPath: item['check_out_image']?.toString(),
                latitude: double.tryParse(
                        item['check_out_latitude']?.toString() ?? '0') ??
                    0.0,
                longitude: double.tryParse(
                        item['check_out_longitude']?.toString() ?? '0') ??
                    0.0,
              ));
            }
          }

          return records;
        }
      }
      return [];
    } catch (e) {
      debugPrint('Fetch history error: $e');
      return [];
    }
  }

  static DateTime _parseBackendTime(String? value) {
    if (value == null || value.isEmpty) return DateTime.now();
    try {
      return DateTime.parse(value.replaceAll(' ', 'T'));
    } catch (_) {
      return DateTime.now();
    }
  }

  /// Fetch all employees who have checked in today.
  /// Returns a list of employee IDs (strings) who punched today.
  Future<List<String>> fetchPresentToday() async {
    final url = '${ApiConfig.baseUrl}/attendance/today';
    try {
      final response = await _send(() => http.post(
            Uri.parse(url),
            headers: _headers,
            body: jsonEncode({'attendance_date': _todayDate()}),
          ));

      debugPrint('PRESENT TODAY STATUS: ${response.statusCode}');
      debugPrint('PRESENT TODAY BODY: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded
              .whereType<Map<String, dynamic>>()
              .map((e) => e['employee_id']?.toString() ?? '')
              .where((s) => s.isNotEmpty)
              .toList();
        }
        if (decoded is Map<String, dynamic>) {
          final list =
              decoded['employees'] ?? decoded['data'] ?? decoded['result'];
          if (list is List) {
            return list
                .whereType<Map<String, dynamic>>()
                .map((e) => e['employee_id']?.toString() ?? '')
                .where((s) => s.isNotEmpty)
                .toList();
          }
        }
      }
      return [];
    } catch (e) {
      debugPrint('Fetch present today error: $e');
      return [];
    }
  }


  /// Fetch user profile from backend
  Future<Map<String, dynamic>?> fetchProfile() async {
    try {
      final http.Response response = await _send(
        () => http.get(
          Uri.parse('${ApiConfig.baseUrl}/user/profile'),
          headers: _headers,
        ),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Fetch profile error: $e');
      return null;
    }
  }



  Future<Map<String, dynamic>> updateProfile({
    String? employeeId,
    String? name,
    String? email,
    String? department,
    String? designation,
    String? modifiedBy,
  }) async {
    try {
      if (employeeId == null || employeeId.isEmpty) {
        return {
          'success': false,
          'message': 'Employee ID is required',
        };
      }

      // Use ApiConfig for URL construction
      String url = '${ApiConfig.updateEmployeeUrl}/$employeeId';
      String apiKey = ApiConfig.apiKey.isNotEmpty ? ApiConfig.apiKey : 'ATTENDANCE_API_2026_ABC123XYZ';

      // Get session token from AppSession
      final appSession = Get.find<AppSession>();
      String sessionToken = appSession.token.value;

      debugPrint('Session token available: ${sessionToken.isNotEmpty}');
      debugPrint('Updating profile for employee ID: $employeeId');

      // Build request body matching backend expectations
      Map<String, dynamic> requestBody = {};
      if (name != null && name.isNotEmpty) requestBody['employee_name'] = name;
      if (email != null && email.isNotEmpty) requestBody['login_id'] = email;
      if (department != null && department.isNotEmpty) requestBody['department'] = department;
      if (designation != null && designation.isNotEmpty) requestBody['designation'] = designation; // NEW FIELD
      if (modifiedBy != null && modifiedBy.isNotEmpty) requestBody['modified_by'] = modifiedBy;

      debugPrint('Request URL: $url');
      debugPrint('Request method: POST');
      debugPrint('Request body: $requestBody');

      // Send request as JSON using POST method with authentication
      var response = await http.post(
        Uri.parse(url),
        body: jsonEncode(requestBody),
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': apiKey,
          'Authorization': 'Bearer $sessionToken', // Add session token for authentication
        },
      );

      debugPrint('Update profile HTTP status: ${response.statusCode}');
      debugPrint('Update profile response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          var responseBody = jsonDecode(response.body);
          if (responseBody['status'] == true) {
            return {
              'success': true,
              'message': responseBody['message'] ?? 'Profile updated successfully',
              'data': responseBody['employee'] ?? responseBody['data'],
            };
          } else {
            return {
              'success': false,
              'message': responseBody['message'] ?? 'Failed to update profile',
            };
          }
        } catch (jsonError) {
          return {
            'success': false,
            'message': 'Failed to parse response: ${jsonError.toString()}',
            'rawResponse': response.body,
          };
        }
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Session token is required. Please login again.',
          'statusCode': response.statusCode,
          'requiresLogin': true,
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'message': 'Endpoint not found. Check URL: $url',
          'statusCode': response.statusCode,
          'url': url,
        };
      } else {
        return {
          'success': false,
          'message': 'HTTP ${response.statusCode}: ${response.body}',
          'statusCode': response.statusCode,
          'url': url,
        };
      }
    } catch (e) {
      debugPrint('Update profile exception: ${e.toString()}');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
        'error': e.toString(),
      };
    }
  }



  Future<String?> fetchAttendanceImage(String imagePath) async {
    final filename = imagePath.split('/').last;
    if (filename.isEmpty) return null;


    final url =
        '${ApiConfig.baseUrl}/attendance/image/${Uri.encodeComponent(filename)}';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/$filename');
        await file.writeAsBytes(response.bodyBytes);
        return file.path;
      }
      debugPrint('Image fetch failed: ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('Image fetch error: $e');
      return null;
    }
  }


  Future<bool> addEmployee({
    required String loginId,
    required String password,
    required String employeeName,
    required String role,
    required String designation,
    required String department,
  }) async {
    final url = ApiConfig.addEmployeeUrl;
    try {
      debugPrint('=== ADD EMPLOYEE REQUEST ===');
      debugPrint('URL: $url');
      debugPrint('Auth Token: ${_authToken?.isNotEmpty == true ? 'Present' : 'MISSING'}');
      debugPrint('Headers: $_headers');

      final response = await _send(() => http.post(
        Uri.parse(url),
        headers: _headers, // This includes Authorization: Bearer $_authToken if _authToken is set
        body: jsonEncode({
          'login_id': loginId,
          'password': password,
          'employee_name': employeeName,
          'role_id': role,
          if (designation.isNotEmpty) 'designation': designation,
          if (department.isNotEmpty) 'department': department,
        }),
      ));

      debugPrint('ADD EMPLOYEE STATUS: ${response.statusCode}');
      debugPrint('ADD EMPLOYEE RESPONSE: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        return decoded is Map<String, dynamic> &&
            (decoded['status'] == true || decoded['status'] == 'true');
      }

      debugPrint('ADD EMPLOYEE ERROR: ${response.statusCode} - ${response.body}');
      return false;
    } catch (e) {
      debugPrint('Add employee error: $e');
      return false;
    }
  }

  /// Fetch individual employee details from the backend.
  /// Endpoint: POST /employee_details
  /// Returns employee data map, or null if not found.
  Future<Map<String, dynamic>?> fetchEmployeeDetails({
    required String employeeId,
  }) async {
    final url = ApiConfig.employeeDetailsUrl;
    try {
      // Send form-data without Content-Type header - let http package set it
      final response = await _send(() => http.post(
        Uri.parse(url),
        headers: {
          // No 'Content-Type' - http auto-sets to application/x-www-form-urlencoded
          'Accept': 'application/json',
          'X-API-Key': 'ATTENDANCE_API_2026_ABC123XYZ',
          if (_authToken != null && _authToken!.isNotEmpty)
            'Authorization': 'Bearer $_authToken',
        },
        body: {'employee_id': employeeId},
      ));

      debugPrint('EMPLOYEE DETAILS STATUS: ${response.statusCode}');
     // debugPrint('EMPLOYEE DETAILS BODY: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          final data = decoded['data'];
          if (data is Map<String, dynamic>) {
            return data;
          }
          return decoded;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Fetch employee details error: $e');
      return null;
    }
  }
}
