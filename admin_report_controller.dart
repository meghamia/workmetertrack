import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/attendance_record.dart';
import '../services/api_client.dart';
import '../models/auth/employee_model.dart';

class AdminReportController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();

  final RxBool isLoading = false.obs;
  final RxList<Map<String, dynamic>> allRecords = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> filteredRecords = <Map<String, dynamic>>[].obs;

  final RxString searchText = ''.obs;
  final RxString selectedDept = 'All'.obs;
  final RxString selectedStatus = 'All'.obs;

  final RxList<String> departments = <String>['All'].obs;
  final RxList<String> statuses = <String>['All'].obs;

  final searchController = TextEditingController();
  final employeesById = <String, Employee>{}.obs;

  // Add these properties after line 23:
  final RxString currentUserEmail = ''.obs;
  final RxString currentUserName = ''.obs;
  final RxString currentDepartment = ''.obs;
  final RxString currentUserRole = ''.obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  @override
  void onInit() {
    super.onInit();
    _loadReportData();
    ever(searchText, (_) => _applyFilters());
    ever(selectedDept, (_) => _applyFilters());
    ever(selectedStatus, (_) => _applyFilters());
  }

  // Future<void> _loadReportData() async {
  //   isLoading.value = true;
  //   try {
  //     // Fetch all employees
  //     final List<Employee> employees = await _apiClient.getEmployees();
  //     for (final emp in employees) {
  //       employeesById[emp.id] = emp;
  //     }
  //
  //     // Build a map of employee_id -> attendance records
  //     final Map<String, List<AttendanceRecord>> attendanceByEmployee = {};
  //     final List<Map<String, dynamic>> records = [];
  //
  //     // Fetch attendance for each employee (non-admin only)
  //     for (final employee in employees) {
  //       final empId = employee.id;
  //       if (empId.isEmpty) continue;
  //
  //       // Skip admins - they don't have punch-in/out functionality
  //       if (employee.roleName?.toLowerCase() == 'admin') continue;
  //
  //       try {
  //         // final attendanceRecords = await _apiClient.fetchAttendanceHistory(
  //         //   employeeId: empId,
  //         // );
  //         // No changes needed here - fetchAttendanceHistory without dates returns all
  //         final attendanceRecords = await _apiClient.fetchAttendanceHistory(
  //           employeeId: empId,
  //         );
  //         attendanceByEmployee[empId] = attendanceRecords;
  //       } catch (e) {
  //         debugPrint('Fetch attendance for $empId failed: $e');
  //         attendanceByEmployee[empId] = [];
  //       }
  //     }
  //
  //     // Build records list - show ALL employees, not just those with attendance
  //     for (final employee in employees) {
  //       // Skip admins
  //       if (employee.roleName?.toLowerCase() == 'admin') continue;
  //
  //       final empId = employee.id;
  //       final empAttendance = attendanceByEmployee[empId] ?? [];
  //
  //       if (empAttendance.isEmpty) {
  //         // Employee has no attendance records - show as Absent
  //         records.add({
  //           'id': empId,
  //           'employee': employee,
  //           'name': employee.displayName,
  //           'department': employee.department ?? 'General',
  //           'role': employee.roleName ?? 'Employee',
  //           'date': '--',
  //           'punchIn': '--',
  //           'punchOut': '--',
  //           'workHours': '--',
  //           'status': 'Absent',
  //           'checkInLat': null,
  //           'checkInLng': null,
  //           'checkOutLat': null,
  //           'checkOutLng': null,
  //           'hasRecords': false,
  //         });
  //       } else {
  //         // Pair IN/OUT records by date
  //         final Map<String, Map<String, dynamic>> paired = {};
  //
  //         for (final record in empAttendance) {
  //           final dateKey = record.formattedDate;
  //           if (!paired.containsKey(dateKey)) {
  //             paired[dateKey] = {
  //               'id': empId,
  //               'employee': employee,
  //               'name': employee.displayName,
  //               'department': employee.department ?? 'General',
  //               'role': employee.roleName ?? 'Employee',
  //               'date': dateKey,
  //               'punchIn': '--',
  //               'punchOut': '--',
  //               'workHours': '--',
  //               'status': 'Present',
  //               'checkInLat': null,
  //               'checkInLng': null,
  //               'checkOutLat': null,
  //               'checkOutLng': null,
  //               'hasRecords': true,
  //             };
  //           }
  //
  //           final existing = paired[dateKey]!;
  //           if (record.type == 'IN') {
  //             existing['punchIn'] = record.formattedTime;
  //             existing['inTimestamp'] = record.timestamp;
  //             existing['checkInLat'] = record.latitude;
  //             existing['checkInLng'] = record.longitude;
  //           } else if (record.type == 'OUT') {
  //             existing['punchOut'] = record.formattedTime;
  //             existing['outTimestamp'] = record.timestamp;
  //             existing['checkOutLat'] = record.latitude;
  //             existing['checkOutLng'] = record.longitude;
  //           }
  //         }
  //
  //         // Calculate work hours from IN and OUT timestamps
  //         for (final pair in paired.values) {
  //           final inTime = pair['inTimestamp'] as DateTime?;
  //           final outTime = pair['outTimestamp'] as DateTime?;
  //           if (inTime != null && outTime != null) {
  //             final diff = outTime.difference(inTime);
  //             final hours = diff.inHours;
  //             final minutes = diff.inMinutes % 60;
  //             pair['workHours'] = '${hours}h ${minutes}m';
  //           }
  //         }
  //         records.addAll(paired.values);
  //       }
  //     }
  //
  //     allRecords.assignAll(records);
  //
  //     // Build department list
  //     final deptSet = <String>{'All'};
  //     for (final r in records) {
  //       deptSet.add(r['department'] ?? 'General');
  //     }
  //     departments.assignAll(deptSet.toList());
  //
  //     // Build status list
  //     final statusSet = <String>{'All', 'Present', 'Absent'};
  //     statuses.assignAll(statusSet.toList());
  //
  //     _applyFilters();
  //   } catch (e) {
  //     debugPrint('Admin report load error: $e');
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }



  Future<void> _loadReportData() async {
    isLoading.value = true;
    try {
      // Fetch all employees
      final List<Employee> employees = await _apiClient.getEmployees();
      for (final emp in employees) {
        employeesById[emp.id] = emp;
      }

      // Load current user profile from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      currentUserEmail.value = prefs.getString('user_email') ?? '';
      currentUserRole.value = prefs.getString('user_role') ?? 'employee';

      // Find matching employee for full profile
      for (final emp in employees) {
        if (emp.loginId == currentUserEmail.value ||
            emp.id == prefs.getString('employee_id')) {
          currentUserName.value = emp.displayName;
          currentDepartment.value = emp.department ?? 'General';
          break;
        }
      }
      if (currentUserName.isEmpty) {
        currentUserName.value =
        currentUserEmail.value.isNotEmpty ? currentUserEmail.value : 'Admin';
        currentDepartment.value = 'General';
      }

      // Build a map of employee_id -> attendance records
      final Map<String, List<AttendanceRecord>> attendanceByEmployee = {};
      final List<Map<String, dynamic>> records = [];

      // Fetch attendance for each employee IN PARALLEL (not sequential)
      final nonAdminEmployees = employees
          .where((e) =>
      e.id.isNotEmpty && e.roleName?.toLowerCase() != 'admin')
          .toList();

      final results = await Future.wait(
        nonAdminEmployees.map((employee) async {
          final empId = employee.id;
          try {
            // final attendanceRecords =
            // await _apiClient.fetchAttendanceHistory(employeeId: empId);
            final attendanceRecords =
            await _apiClient.fetchAttendanceHistory(
              employeeId: empId,
              startDate: DateTime.now(),
              endDate: DateTime.now(),
            );
            return MapEntry<String, List<AttendanceRecord>>(empId, attendanceRecords);
          } catch (e) {
            debugPrint('Fetch attendance for $empId failed: $e');
            return MapEntry<String, List<AttendanceRecord>>(empId, []);
          }
        }),
      );

      for (final entry in results) {
        attendanceByEmployee[entry.key] = entry.value;
      }

      // Build records list - show ALL employees, not just those with attendance
      for (final employee in employees) {
        // Skip admins
        if (employee.roleName?.toLowerCase() == 'admin') continue;

        final empId = employee.id;
        final empAttendance = attendanceByEmployee[empId] ?? [];

        if (empAttendance.isEmpty) {
          // Employee has no attendance records - show as Absent
          records.add({
            'id': empId,
            'employee': employee,
            'name': employee.displayName,
            'department': employee.department ?? 'General',
            'role': employee.roleName ?? 'Employee',
            'date': '--',
            'punchIn': '--',
            'punchOut': '--',
            'workHours': '--',
            'status': 'Absent',
            'checkInLat': null,
            'checkInLng': null,
            'checkOutLat': null,
            'checkOutLng': null,
            'hasRecords': false,
          });
        } else {
          // Pair IN/OUT records by date
          final Map<String, Map<String, dynamic>> paired = {};

          for (final record in empAttendance) {
            final dateKey = record.formattedDate;
            if (!paired.containsKey(dateKey)) {
              paired[dateKey] = {
                'id': empId,
                'employee': employee,
                'name': employee.displayName,
                'department': employee.department ?? 'General',
                'role': employee.roleName ?? 'Employee',
                'date': dateKey,
                'punchIn': '--',
                'punchOut': '--',
                'workHours': '--',
                'status': 'Present',
                'checkInLat': null,
                'checkInLng': null,
                'checkOutLat': null,
                'checkOutLng': null,
                'hasRecords': true,
              };
            }

            final existing = paired[dateKey]!;
            if (record.type == 'IN') {
              existing['punchIn'] = record.formattedTime;
              existing['inTimestamp'] = record.timestamp;
              existing['inPhotoPath'] = record.photoPath;
              existing['checkInLat'] = record.latitude;
              existing['checkInLng'] = record.longitude;
            } else if (record.type == 'OUT') {
              existing['punchOut'] = record.formattedTime;
              existing['outTimestamp'] = record.timestamp;
              existing['outPhotoPath'] = record.photoPath;
              existing['checkOutLat'] = record.latitude;
              existing['checkOutLng'] = record.longitude;
            }
          }

          // Calculate work hours from IN and OUT timestamps
          for (final pair in paired.values) {
            final inTime = pair['inTimestamp'] as DateTime?;
            final outTime = pair['outTimestamp'] as DateTime?;
            if (inTime != null && outTime != null) {
              final diff = outTime.difference(inTime);
              final hours = diff.inHours;
              final minutes = diff.inMinutes % 60;
              pair['workHours'] = '${hours}h ${minutes}m';
            }
          }
          records.addAll(paired.values);
        }
      }

      allRecords.assignAll(records);

      // Build department list
      final deptSet = <String>{'All'};
      for (final r in records) {
        deptSet.add(r['department'] ?? 'General');
      }
      departments.assignAll(deptSet.toList());

      // Build status list
      final statusSet = <String>{'All', 'Present', 'Absent'};
      statuses.assignAll(statusSet.toList());

      _applyFilters();
    } catch (e) {
      debugPrint('Admin report load error: $e');
    } finally {
      isLoading.value = false;
    }
  }


  void _applyFilters() {
    final query = searchText.value.trim().toLowerCase();
    final dept = selectedDept.value;
    final status = selectedStatus.value;

    var filtered = allRecords.where((r) {
      final matchesSearch = query.isEmpty ||
          (r['name'] ?? '').toLowerCase().contains(query) ||
          (r['id'] ?? '').toLowerCase().contains(query) ||
          (r['date'] ?? '').toLowerCase().contains(query);
      final matchesDept = dept == 'All' || (r['department'] ?? 'General') == dept;
      final matchesStatus = status == 'All' || (r['status'] ?? 'Unknown') == status;
      return matchesSearch && matchesDept && matchesStatus;
    }).toList();

    filteredRecords.assignAll(filtered);
  }

  void setSearchQuery(String query) => searchText.value = query;
  void setDeptFilter(String? dept) => selectedDept.value = dept ?? 'All';
  void setStatusFilter(String? status) => selectedStatus.value = status ?? 'All';
}