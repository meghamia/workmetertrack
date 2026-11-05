import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_role.dart';

import '../services/auth_service.dart';

// class LoginController extends GetxController {
//   final AuthService _authService = Get.find<AuthService>();
//   final RxBool rememberMe = false.obs;
//   // ROLE
//
//   final Rx<UserRole> selectedRole = UserRole.employee.obs;
//
//   final List<UserRole> roleOptions = <UserRole>[
//     UserRole.employee,
//     UserRole.admin,
//   ];
//
//   RxBool get isLoading => _authService.isLoading;
//
//   RxString get errorMessage => _authService.errorMessage;
//
//   void setRole(UserRole role) {
//     selectedRole.value = role;
//   }
//
//   bool validateEmail(String email) {
//     final String value = email.trim().toLowerCase();
//
//     if (value.isEmpty || value.contains(' ')) {
//       return false;
//     }
//
//     return value.contains('.');
//   }
//
//   Future<void> login({
//     required String email,
//     required String password,
//     required bool rememberMe,
//   }) async {
//     print('1. LOGIN BUTTON CALLED');
//
//     errorMessage.value = '';
//
//     final String loginId = email.trim();
//
//     if (loginId.isEmpty) {
//       errorMessage.value = 'Login ID is required';
//       print('2. Login ID is empty');
//       return;
//     }
//
//     if (!validateEmail(loginId)) {
//       errorMessage.value = 'Enter a valid login ID or email';
//       print('2. Login ID validation failed');
//       return;
//     }
//
//     final String cleanPassword = password.trim();
//
//     if (cleanPassword.isEmpty) {
//       errorMessage.value = 'Password is required';
//       print('3. Password is empty');
//       return;
//     }
//
//     print('4. Calling AuthService.login');
//
//     final bool success = await _authService.login(
//       loginId: loginId,
//       password: cleanPassword,
//       role: selectedRole.value == UserRole.admin ? 'admin' : 'employee',
//       rememberMe: true,
//     );
//
//     print('5. AuthService returned: $success');
//     print('6. Error message: ${errorMessage.value}');
//
//     if (!success) {
//       return;
//     }
//
//     print('7. Saving login preferences');
//
//     final SharedPreferences prefs =
//     await SharedPreferences.getInstance();
//
//     await prefs.setString('user_email', loginId);
//     await prefs.setString(
//       'user_role',
//       selectedRole.value == UserRole.admin ? 'admin' : 'employee',
//     );
//     await prefs.setBool('remember_me', rememberMe);
//     await prefs.setBool('is_logged_in', true);
//
//     print('8. Navigating to dashboard');
//
//     Get.offAllNamed('/dashboard');
//   }
//
//   // CLEAR ERROR
//
//   void clearError() {
//     _authService.clearError();
//   }
//
//
//   void setRememberMe(bool value) {
//     rememberMe.value = value;
//   }
// }


import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_role.dart';
import '../services/auth_service.dart';

class LoginController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
// Text controllers
  final TextEditingController emailController =
  TextEditingController();

  final TextEditingController passwordController =
  TextEditingController();

// // Focus nodes
//   final FocusNode emailFocusNode = FocusNode();
//
//   final FocusNode passwordFocusNode = FocusNode();

// Password visibility
  final RxBool obscurePassword = true.obs;
  // ROLE
  final Rx<UserRole> selectedRole = UserRole.employee.obs;
  final List<UserRole> roleOptions = <UserRole>[
    UserRole.employee,
    UserRole.admin,
  ];

  // REMEMBER ME
  final RxBool rememberMe = false.obs;

  RxBool get isLoading => _authService.isLoading;
  RxString get errorMessage => _authService.errorMessage;

  void setRole(UserRole role) {
    selectedRole.value = role;
  }

  void setRememberMe(bool value) {
    rememberMe.value = value;
  }

  bool validateEmail(String email) {
    final String value = email.trim().toLowerCase();
    if (value.isEmpty || value.contains(' ')) {
      return false;
    }
    return value.contains('.');
  }

  @override
  void onInit() {
    super.onInit();
    _loadRememberMe();
  }

  Future<void> _loadRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    rememberMe.value = prefs.getBool('remember_me') ?? false;
  }

  Future<void> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    print('1. LOGIN BUTTON CALLED');

    errorMessage.value = '';

    final String loginId = email.trim();

    if (loginId.isEmpty) {
      errorMessage.value = 'Login ID is required';
      print('2. Login ID is empty');
      return;
    }

    if (!validateEmail(loginId)) {
      errorMessage.value = 'Enter a valid login ID or email';
      print('2. Login ID validation failed');
      return;
    }

    final String cleanPassword = password.trim();

    if (cleanPassword.isEmpty) {
      errorMessage.value = 'Password is required';
      print('3. Password is empty');
      return;
    }

    print('4. Calling AuthService.login');

    final bool success = await _authService.login(
      loginId: loginId,
      password: cleanPassword,
      role: selectedRole.value == UserRole.admin ? 'admin' : 'employee',
      rememberMe: rememberMe,
    );

    print('5. AuthService returned: $success');
    print('6. Error message: ${errorMessage.value}');

    if (!success) {
      return;
    }
    TextInput.finishAutofillContext(shouldSave: true);
    print('7. Saving login preferences');

    final SharedPreferences prefs =
    await SharedPreferences.getInstance();

    await prefs.setString('user_email', loginId);
    await prefs.setString(
      'user_role',
      selectedRole.value == UserRole.admin ? 'admin' : 'employee',
    );
    await prefs.setBool('is_logged_in', true);
    await prefs.setBool('remember_me', rememberMe);

    print('8. Navigating to dashboard');

    Get.offAllNamed('/dashboard');
  }

  // CLEAR ERROR
  void clearError() {
    _authService.clearError();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    //emailFocusNode.dispose();
    //passwordFocusNode.dispose();
    super.onClose();
  }
}