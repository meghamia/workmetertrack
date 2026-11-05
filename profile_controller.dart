import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_client.dart';
import '../services/app_session.dart';


class ProfileController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();
  final AppSession _appSession = Get.find<AppSession>();

  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final departmentController = TextEditingController();
  final employeeIdController = TextEditingController();
  final designationController = TextEditingController();

  final RxString userRole = ''.obs;

  // Department dropdown properties
  final RxList<String> departments = <String>['All'].obs;
  final RxString selectedDepartment = ''.obs;

  final RxString selectedDepartmentValue = ''.obs;
  final RxString currentUserEmail = ''.obs;
  final RxString currentUserName = ''.obs;
  final RxString currentDepartment = ''.obs;
  final RxString currentUserRole = ''.obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;





  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    departmentController.dispose();
    employeeIdController.dispose();
    designationController.dispose();
    super.onClose();
  }

  // In profile_controller.dart, replace the _fetchDepartments method with this fixed list:

// Fixed list of allowed departments - only these should appear in dropdown
  static const List<String> allowedDepartments = [
    'Finance',
    'Marketing',
    'Testing',
    'Designh',
    'Engineering',
    'Product',
  ];

  Future<void> _initializeDepartments() async {
    // Use current department if available
    final currentDept = departmentController.text.trim();

    departments.assignAll(allowedDepartments);

    if (currentDept.isNotEmpty) {
      selectedDepartment.value = currentDept;
      selectedDepartmentValue.value = currentDept;
    }
  }

  // Future<void> loadProfile() async {
  //   isLoading.value = true;
  //   try {
  //     // 1. Try AppSession (works when rememberMe=true)
  //     final loginResponse = _appSession.loginResponse.value;
  //     if (loginResponse != null) {
  //       nameController.text = loginResponse.employeeName;
  //       emailController.text = loginResponse.loginId;
  //       employeeIdController.text = loginResponse.employeeId;
  //     }
  //
  //     // 2. Fetch profile from backend API
  //     final profile = await _apiClient.fetchProfile();
  //     debugPrint('FETCH PROFILE: $profile');
  //     if (profile != null && profile is Map<String, dynamic>) {
  //       nameController.text = profile['name'] ?? profile['employee_name'] ?? nameController.text;
  //       emailController.text = profile['email'] ?? profile['login_id'] ?? emailController.text;
  //       departmentController.text = profile['department'] ?? '';
  //       employeeIdController.text = profile['employee_id']?.toString() ?? employeeIdController.text;
  //       designationController.text = profile['designation'] ?? '';
  //     }
  //
  //     // 3. Fallback: SharedPreferences (saved by LoginController)
  //     final prefs = await SharedPreferences.getInstance();
  //     userRole.value = prefs.getString('user_role') ?? 'employee';
  //
  //     if (emailController.text.isEmpty) {
  //       emailController.text = prefs.getString('user_email') ?? '';
  //     }
  //
  //     if (emailController.text.isNotEmpty) {
  //       try {
  //         final employees = await _apiClient.getEmployees();
  //         debugPrint('=== EMPLOYEE MATCHING DEBUG ===');
  //         debugPrint('Looking for email: ${emailController.text.toLowerCase()}');
  //         debugPrint('Stored employee_id: ${prefs.getString('employee_id') ?? 'NOT_FOUND'}');
  //         debugPrint('Total employees fetched: ${employees.length}');
  //
  //         bool foundMatch = false;
  //         for (final emp in employees) {
  //           final emailMatch = emp.loginId?.toLowerCase() == emailController.text.toLowerCase();
  //           final idMatch = prefs.getString('employee_id') != null && emp.id == prefs.getString('employee_id');
  //
  //           debugPrint('Checking emp: ID=${emp.id}, loginId=${emp.loginId}, dept=${emp.department}, desig=${emp.designation}');
  //
  //           if (emailMatch || idMatch) {
  //             debugPrint('MATCH FOUND!: ${emailMatch ? "Email match" : "ID match"}');
  //             debugPrint('Employee data: ${emp.displayName}, Dept: ${emp.department}, Desig: ${emp.designation}');
  //
  //             // Fill in empty fields
  //             if (departmentController.text.isEmpty && emp.department != null) {
  //               departmentController.text = emp.department!;
  //               debugPrint('Set department: ${emp.department}');
  //             }
  //             if (designationController.text.isEmpty && emp.designation != null) {
  //               designationController.text = emp.designation!;
  //               debugPrint('Set designation: ${emp.designation}');
  //             }
  //             foundMatch = true;
  //             break;
  //           }
  //         }
  //
  //         if (!foundMatch) {
  //           debugPrint('NO MATCH FOUND - check email/ID storage');
  //         }
  //       } catch (e) {
  //         debugPrint('getEmployees fallback failed: $e');
  //       }
  //     }
  //
  //
  //     if (nameController.text.isEmpty) {
  //       nameController.text = emailController.text.isNotEmpty
  //           ? emailController.text
  //           : userRole.value == 'admin' ? 'Admin' : 'Employee';
  //     }
  //
  //     // FIXED ORDER: Initialize departments FIRST, then set selected department
  //     // 6. Initialize departments list (BEFORE setting selected department)
  //     await _initializeDepartments();
  //
  //     // 7. NOW set selected department from the loaded data
  //     if (departmentController.text.isNotEmpty) {
  //       selectedDepartment.value = departmentController.text;
  //       selectedDepartmentValue.value = departmentController.text;
  //     }
  //
  //     debugPrint('Profile loaded - Name: ${nameController.text}, Email: ${emailController.text}, Dept: ${departmentController.text}, Designation: ${designationController.text}');
  //     debugPrint('Selected Department: ${selectedDepartment.value}');
  //   } catch (e) {
  //     debugPrint('Load profile error: $e');
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }
  Future<void> loadProfile() async {
    isLoading.value = true;
    try {
      // 1. Load AppSession FIRST (fastest)
      final loginResponse = _appSession.loginResponse.value;
      if (loginResponse != null) {
        nameController.text = loginResponse.employeeName;
        emailController.text = loginResponse.loginId;
        employeeIdController.text = loginResponse.employeeId;
      }

      // 2. ONLY fetch from backend API if necessary
      final prefs = await SharedPreferences.getInstance();
      userRole.value = prefs.getString('user_role') ?? 'employee';

      if (emailController.text.isEmpty) {
        emailController.text = prefs.getString('user_email') ?? '';
      }

      if (employeeIdController.text.isEmpty) {
        employeeIdController.text = prefs.getString('employee_id') ?? '';
      }

      // 3. Initialize departments immediately (don't wait)
      await _initializeDepartments();

      // 4. Fetch profile data only if not already complete
      final profile = await _apiClient.fetchProfile();
      debugPrint('FETCH PROFILE: $profile');
      if (profile != null && profile is Map<String, dynamic>) {
        // Only update empty fields
        if (nameController.text.isEmpty)
          nameController.text = profile['name'] ?? profile['employee_name'] ?? '';
        if (emailController.text.isEmpty)
          emailController.text = profile['email'] ?? profile['login_id'] ?? '';
        if (employeeIdController.text.isEmpty)
          employeeIdController.text = profile['employee_id']?.toString() ?? '';

        // Populate department/designation immediately if available
        if (departmentController.text.isEmpty)
          departmentController.text = profile['department'] ?? '';
        if (designationController.text.isEmpty)
          designationController.text = profile['designation'] ?? '';
      }

      // 5. Only lookup employees if we still don't have complete data
      if (nameController.text.isEmpty ||
          departmentController.text.isEmpty ||
          designationController.text.isEmpty) {

        // Try to find matching employee
        if (emailController.text.isNotEmpty || employeeIdController.text.isNotEmpty) {
          try {
            final employees = await _apiClient.getEmployees();
            for (final emp in employees) {
              if (emp.loginId == emailController.text ||
                  emp.id == employeeIdController.text) {
                // Populate missing fields
                if (nameController.text.isEmpty)
                  nameController.text = emp.displayName ?? '';
                if (departmentController.text.isEmpty)
                  departmentController.text = emp.department ?? 'General';
                if (designationController.text.isEmpty)
                  designationController.text = emp.designation ?? '';
                break;
              }
            }
          } catch (e) {
            debugPrint('Employee lookup failed: $e');
          }
        }
      }

      // 6. Final fallbacks
      if (nameController.text.isEmpty) {
        nameController.text = emailController.text.isNotEmpty
            ? emailController.text
            : userRole.value == 'admin' ? 'Admin' : 'Employee';
      }

      // Set selected department after all data is loaded
      if (departmentController.text.isNotEmpty) {
        selectedDepartment.value = departmentController.text;
        selectedDepartmentValue.value = departmentController.text;
      }

      debugPrint('Profile loaded - Name: ${nameController.text}, Email: ${emailController.text}, Dept: ${departmentController.text}, Designation: ${designationController.text}');
    } catch (e) {
      debugPrint('Load profile error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch available departments from backend API
  Future<void> _fetchDepartments() async {
    try {
      final employees = await _apiClient.getEmployees();
      final deptSet = <String>{};

      for (final emp in employees) {
        if (emp.department != null && emp.department!.isNotEmpty) {
          deptSet.add(emp.department!);
        }
      }

      // Add default departments if none found
      if (deptSet.isEmpty) {
        deptSet.addAll(['General', 'Engineering', 'HR', 'Finance']);
      }

      final sortedDepts = deptSet.toList()..sort((a, b) => a.compareTo(b));
      departments.assignAll(sortedDepts);

      debugPrint('Fetched departments: $departments');
    } catch (e) {
      debugPrint('Failed to fetch departments: $e');
      // Use default departments as fallback
      departments.assignAll(['General', 'Engineering', 'HR', 'Finance']);
    }
  }

  Future<void> saveProfile() async {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Name is required', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (emailController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Email is required', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isSaving.value = true;
    try {
      // Get employee ID from multiple sources
      final loginResponse = _appSession.loginResponse.value;

      // Try to get employee ID: from session, then from controller, then from SharedPreferences
      String? employeeId = loginResponse?.employeeId ??
          employeeIdController.text.trim();

      // If still null, try SharedPreferences
      if (employeeId == null || employeeId.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        employeeId = prefs.getString('employee_id') ?? prefs.getString('user_id');
      }

      // If we have an email but no employee ID, try to match from employees list
      if ((employeeId == null || employeeId.isEmpty) && emailController.text.trim().isNotEmpty) {
        try {
          final employees = await _apiClient.getEmployees();
          for (final emp in employees) {
            if (emp.loginId == emailController.text.trim()) {
              employeeId = emp.id;
              break;
            }
          }
        } catch (e) {
          debugPrint('getEmployees fallback for employee ID failed: $e');
        }
      }

      debugPrint('Saving profile with employeeId: $employeeId');

      // Validate employee ID
      if (employeeId == null || employeeId.isEmpty) {
        Get.snackbar('Error', 'Employee ID not found. Cannot update profile.',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      // Call the updated method using ApiConfig for URL
      final result = await _apiClient.updateProfile(
        employeeId: employeeId,
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        department: selectedDepartment.value.isNotEmpty ? selectedDepartment.value : departmentController.text.trim(),
        designation: designationController.text.trim(),
        modifiedBy: userRole.value == 'admin' ? 'Admin' : nameController.text.trim(),
      );

      debugPrint('PROFILE UPDATE RESULT: $result');

      if (result['success'] == true) {
        // Save to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', emailController.text.trim());
        await prefs.setString('user_employee_name', nameController.text.trim());
        await prefs.setString('department', selectedDepartment.value.isNotEmpty ? selectedDepartment.value : departmentController.text.trim());
        await prefs.setString('employee_id', employeeId);
        await prefs.setString('designation', designationController.text.trim());

        // Update AppSession if available
        if (loginResponse != null) {
          final updatedResponse = loginResponse.copyWith(
            employeeName: nameController.text.trim(),
            loginId: emailController.text.trim(),
          );
          await _appSession.saveSession(updatedResponse, true);
        }

        Get.snackbar(
          'Success',
          result['message'] ?? 'Profile updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 2),
        );

        // Navigate back after snackbar duration
        Future.delayed(Duration(seconds: 2), () {
          if (Get.isBottomSheetOpen ?? false) {
            Get.back();
          } else if (Navigator.canPop(Get.context!)) {
            Get.back();
          }
        });
      } else {
        Get.snackbar('Error', result['message'] ?? 'Failed to update profile',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to save: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSaving.value = false;
    }
  }

  String getInitials() {
    final name = nameController.text.trim();
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}