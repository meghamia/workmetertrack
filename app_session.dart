import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth/login_response.dart';


class AppSession extends GetxService {
  static const String _keyToken = 'auth_token';
  static const String _keyExpiryTime = 'expiry_time';
  static const String _keyLoginId = 'login_id';
  static const String _keyEmployeeId = 'employee_id';
  static const String _keyEmployeeName = 'employee_name';
  static const String _keyRememberMe = 'remember_me';

  final Rxn<LoginResponse> loginResponse =
  Rxn<LoginResponse>();

  final RxString token = ''.obs;
  final RxString expiryTime = ''.obs;
  final RxString loginId = ''.obs;
  final RxString employeeId = ''.obs;
  final RxString employeeName = ''.obs;
  final RxBool rememberMe = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSession();
  }

  // ============================================================
  // LOAD SAVED SESSION
  // ============================================================

  Future<void> _loadSession() async {
    final SharedPreferences prefs =
    await SharedPreferences.getInstance();

    final String? savedToken =
    prefs.getString(_keyToken);

    if (savedToken == null ||
        savedToken.isEmpty) {
      return;
    }

    token.value = savedToken;

    expiryTime.value =
        prefs.getString(_keyExpiryTime) ?? '';

    loginId.value =
        prefs.getString(_keyLoginId) ?? '';

    employeeId.value =
        prefs.getString(_keyEmployeeId) ?? '';

    employeeName.value =
        prefs.getString(_keyEmployeeName) ?? '';

    rememberMe.value =
        prefs.getBool(_keyRememberMe) ?? false;
  }

  // ============================================================
  // SAVE LOGIN SESSION
  // ============================================================

  Future<void> saveSession(
      LoginResponse response,
      bool remember,
      ) async {
    final SharedPreferences prefs =
    await SharedPreferences.getInstance();

    token.value = response.sessionToken;
    expiryTime.value = response.expiryTime;
    loginId.value = response.loginId;
    employeeId.value = response.employeeId;
    employeeName.value = response.employeeName;
    rememberMe.value = remember;
    loginResponse.value = response;

    if (remember) {
      await prefs.setString(
        _keyToken,
        response.sessionToken,
      );

      await prefs.setString(
        _keyExpiryTime,
        response.expiryTime,
      );

      await prefs.setString(
        _keyLoginId,
        response.loginId,
      );

      await prefs.setString(
        _keyEmployeeId,
        response.employeeId,
      );

      await prefs.setString(
        _keyEmployeeName,
        response.employeeName,
      );

      await prefs.setBool(
        _keyRememberMe,
        true,
      );
    } else {
      await prefs.remove(_keyToken);
      await prefs.remove(_keyExpiryTime);
      await prefs.remove(_keyLoginId);
      await prefs.remove(_keyEmployeeId);
      await prefs.remove(_keyEmployeeName);

      await prefs.setBool(
        _keyRememberMe,
        false,
      );
    }
  }

  // ============================================================
  // CLEAR SESSION
  // ============================================================

  Future<void> clearSession() async {
    final SharedPreferences prefs =
    await SharedPreferences.getInstance();

    await prefs.remove(_keyToken);
    await prefs.remove(_keyExpiryTime);
    await prefs.remove(_keyLoginId);
    await prefs.remove(_keyEmployeeId);
    await prefs.remove(_keyEmployeeName);
    await prefs.remove(_keyRememberMe);

    await prefs.remove('is_logged_in');
    await prefs.remove('user_email');

    token.value = '';
    expiryTime.value = '';
    loginId.value = '';
    employeeId.value = '';
    employeeName.value = '';
    rememberMe.value = false;
    loginResponse.value = null;
  }

  // ============================================================
  // LOGIN STATUS
  // ============================================================

  bool get isLoggedIn {
    return token.value.isNotEmpty;
  }
}