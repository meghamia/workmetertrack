import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_client.dart';
import '../services/app_session.dart';
//
// class AddEmployeeController extends GetxController {
//   final ApiClient _apiClient = Get.find<ApiClient>();
//
//   final RxBool isLoading = false.obs;
//   final RxBool isSuccess = false.obs;
//   final RxString errorMessage = ''.obs;
//
//   final formKey = GlobalKey<FormState>();
//
//   final nameController = TextEditingController();
//   final loginIdController = TextEditingController();
//   final passwordController = TextEditingController();
//   final designationController = TextEditingController();
//   final departmentController = TextEditingController();
//
//   final RxString selectedRoleId = '2'.obs;
//
//   void setRoleId(String? value) {
//     selectedRoleId.value = value ?? '2';
//   }
//
//   String? validateName(String? value) {
//     if (value == null || value.trim().isEmpty) {
//       return 'Employee name is required';
//     }
//     return null;
//   }
//
//   String? validateLoginId(String? value) {
//     if (value == null || value.trim().isEmpty) {
//       return 'Login ID is required';
//     }
//     if (!value.contains('@')) {
//       return 'Enter a valid email address';
//     }
//     return null;
//   }
//
//   String? validatePassword(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Password is required';
//     }
//     if (value.length < 6) {
//       return 'Password must be at least 6 characters';
//     }
//     return null;
//   }
//
//   Future<void> submit() async {
//     if (!(formKey.currentState?.validate() ?? false)) return;
//
//     isLoading.value = true;
//     errorMessage.value = '';
//
//     // Check for auth token first
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('auth_token') ?? '';
//
//     if (token.isEmpty) {
//       isLoading.value = false;
//       errorMessage.value = 'Session token is required. Please login again.';
//       Get.snackbar(
//         'Authentication Error',
//         'Session token is required. Please login again.',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//       // Navigate back to login screen
//       Get.offAllNamed('/login');
//       return;
//     }
//
//     try {
//       // Store token in AppSession so API client can use it
//       final appSession = Get.find<AppSession>();
//       appSession.token.value = token; // Ensure token is available in session
//
//       final response = await _apiClient.addEmployee(
//         loginId: loginIdController.text.trim(),
//         password: passwordController.text,
//         employeeName: nameController.text.trim(),
//         role: selectedRoleId.value,
//         designation: designationController.text.trim(),
//         department: departmentController.text.trim(),
//       );
//
//       if (response) {
//         isSuccess.value = true;
//         Get.snackbar(
//           'Success',
//           'Employee added successfully',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.green,
//           colorText: Colors.white,
//         );
//         await Future.delayed(const Duration(seconds: 1));
//         Get.back();
//       } else {
//         errorMessage.value = 'Failed to add employee';
//         Get.snackbar(
//           'Error',
//           'Failed to add employee',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//         );
//       }
//     } catch (e) {
//       errorMessage.value = e.toString();
//       Get.snackbar(
//         'Error',
//         e.toString(),
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   @override
//   void onClose() {
//     nameController.dispose();
//     loginIdController.dispose();
//     passwordController.dispose();
//     designationController.dispose();
//     departmentController.dispose();
//     super.onClose();
//   }
// }


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_client.dart';
import '../services/app_session.dart';

class AddEmployeeController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();

  final RxBool isLoading = false.obs;
  final RxBool isSuccess = false.obs;
  final RxString errorMessage = ''.obs;

  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final loginIdController = TextEditingController();
  final passwordController = TextEditingController();
  final designationController = TextEditingController();
  final departmentController = TextEditingController();

  final RxString selectedRoleId = '2'.obs;
  final RxString selectedDepartment = ''.obs; // For dropdown selection

  // Fixed list of allowed departments - same as profile
  static const List<String> allowedDepartments = [
    'Finance',
    'Marketing',
    'Testing',
    'Designh',
    'Engineering',
  ];

  void setRoleId(String? value) {
    selectedRoleId.value = value ?? '2';
  }

  void setDepartment(String? value) {
    selectedDepartment.value = value ?? '';
    departmentController.text = value ?? '';
  }

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Employee name is required';
    }
    return null;
  }

  String? validateLoginId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Login ID is required';
    }
    if (!value.contains('@')) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    isLoading.value = true;
    errorMessage.value = '';

    // Check for auth token first
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    if (token.isEmpty) {
      isLoading.value = false;
      errorMessage.value = 'Session token is required. Please login again.';
      Get.snackbar(
        'Authentication Error',
        'Session token is required. Please login again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      // Navigate back to login screen
      Get.offAllNamed('/login');
      return;
    }

    try {
      // Store token in AppSession so API client can use it
      final appSession = Get.find<AppSession>();
      appSession.token.value = token; // Ensure token is available in session

      final response = await _apiClient.addEmployee(
        loginId: loginIdController.text.trim(),
        password: passwordController.text,
        employeeName: nameController.text.trim(),
        role: selectedRoleId.value,
        designation: designationController.text.trim(),
        department: selectedDepartment.value.isNotEmpty
            ? selectedDepartment.value
            : departmentController.text.trim(),
      );

      debugPrint('ADD EMPLOYEE RESPONSE: $response');
      debugPrint('ADD EMPLOYEE DEPARTMENT: ${selectedDepartment.value}');

      if (response) {
        isSuccess.value = true;
        Get.snackbar(
          'Success',
          'Employee added successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        await Future.delayed(const Duration(seconds: 1));
        Get.back();
      } else {
        errorMessage.value = 'Failed to add employee';
        Get.snackbar(
          'Error',
          'Failed to add employee',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    loginIdController.dispose();
    passwordController.dispose();
    designationController.dispose();
    departmentController.dispose();
    super.onClose();
  }
}