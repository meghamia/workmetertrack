import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth/login_request.dart';
import '../services/app_session.dart';
import 'api_client.dart';


class AuthService extends GetxService {
  final ApiClient _apiClient = Get.find<ApiClient>();
  final AppSession _appSession = Get.find<AppSession>();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // LOGIN
  Future<bool> login({
    required String loginId,
    required String password,
    required String role,
    bool rememberMe = true,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final LoginRequest request = LoginRequest(
        loginId: loginId,
        password: password,
        rememberMe: rememberMe,
        role: role,
      );

      final response = await _apiClient.login(request);
      print('LOGIN RESPONSE MESSAGE: ${response.message}');
      print('TOKEN VALID: ${response.isTokenValid}');
      print('BACKEND ROLE: ${response.role}');

      if (response.status) {
        final backendRole = response.role.toLowerCase();
        final requestedRole = role.toLowerCase();

        if (backendRole != requestedRole) {
          errorMessage.value =
          'This account is for $backendRole role, not $requestedRole.';
          return false;
        }

        // Save initial session
        await _appSession.saveSession(response, rememberMe);

        // Fetch additional employee details (designation, department)
        try {
          if (response.employeeId.isNotEmpty) {
            final employeeDetails = await _apiClient.fetchEmployeeDetails(
              employeeId: response.employeeId,
            );

            if (employeeDetails != null && employeeDetails['data'] != null) {
              final employeeData = employeeDetails['data'];

              // Update session with complete employee details
              final updatedResponse = response.copyWith(
                employeeName: employeeData['employee_name'] ?? response.employeeName,
                designation: employeeData['designation'] ?? '',
                department: employeeData['department'] ?? '',
              );

              await _appSession.saveSession(updatedResponse, rememberMe);

              // Also save to SharedPreferences for profile loading
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('designation', employeeData['designation'] ?? '');
              await prefs.setString('department', employeeData['department'] ?? '');

              print('EMPLOYEE DETAILS FETCHED: ${employeeData['employee_name']}, Designation: ${employeeData['designation']}, Department: ${employeeData['department']}');
            }
          }
        } catch (e) {
          print('Failed to fetch employee details after login: $e');
          // Don't fail login if we can't fetch details
        }

        return true;
      }

      String errorMsg =
      response.message.isNotEmpty ? response.message : 'Login failed';
      final lowerMsg = errorMsg.toLowerCase();
      if (lowerMsg.contains('user not found') ||
          lowerMsg.contains('invalid') ||
          lowerMsg.contains('unauthorized')) {
        errorMsg = 'User not found. Contact admin to create account.';
      } else if (lowerMsg.contains('password')) {
        errorMsg = 'Incorrect password. Try again.';
      } else if (lowerMsg.contains('role')) {
        errorMsg = 'Role mismatch. Select correct role.';
      }
      errorMessage.value = errorMsg;
      return false;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst(
        'Exception: ',
        '',
      );

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> logout() async {
    bool serverConfirmed = false;
    try {
      await _apiClient.logout();
      serverConfirmed = true;
    } catch (_) {
      serverConfirmed = false;
    } finally {
      await _appSession.clearSession();
    }
    return serverConfirmed;
  }

  void clearError() {
    errorMessage.value = '';
  }
}