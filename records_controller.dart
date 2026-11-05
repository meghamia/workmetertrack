import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth/employee_model.dart';
import '../services/attendance_storage.dart';
import '../models/attendance_record.dart';

import '../services/api_client.dart';

import 'dashboard_controller.dart';

enum RecordFilter { day, week, month }

class PunchPair {
  final AttendanceRecord? inRecord;
  final AttendanceRecord? outRecord;

  PunchPair({this.inRecord, this.outRecord});

  String get loginId => inRecord?.loginId ?? outRecord?.loginId ?? '';
  String get formattedDate =>
      inRecord?.formattedDate ?? outRecord?.formattedDate ?? '';
  String get inTime => inRecord?.formattedTime ?? '-';
  String get outTime => outRecord?.formattedTime ?? '-';
  String get location => inRecord?.location ?? outRecord?.location ?? '';
  String? get inPhotoPath => inRecord?.photoPath;
  String? get outPhotoPath => outRecord?.photoPath;
  double get latitude => inRecord?.latitude ?? outRecord?.latitude ?? 0.0;
  double get longitude => inRecord?.longitude ?? outRecord?.longitude ?? 0.0;
}

class RecordsController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();
  final AttendanceStorage _storage = Get.find<AttendanceStorage>();

  final Rx<RecordFilter> currentFilter = RecordFilter.day.obs;
  final RxList<AttendanceRecord> filteredRecords = <AttendanceRecord>[].obs;
  final RxList<AttendanceRecord> allRecords = <AttendanceRecord>[].obs;
  final RxBool isLoading = false.obs;

  // Search
  final RxString searchQuery = ''.obs;

  // User info loaded from SharedPreferences
  late String _currentUserEmail;
  late String _currentEmployeeId;
  late bool _isAdmin;
  final RxBool isAdmin = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadRecords();
    ever(currentFilter, (_) => _applyFilters());
    ever(searchQuery, (_) => _applyFilters());
  }

  Future<void> refresh() async {
    await _loadRecords();
  }

  // Future<void> _loadRecords() async {
  //   if (isLoading.value) return;
  //
  //   isLoading.value = true;
  //
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //
  //     _currentUserEmail = prefs.getString('user_email') ?? '';
  //     _currentEmployeeId = prefs.getString('employee_id') ?? '';
  //
  //     final savedRole =
  //         prefs.getString('user_role') ?? 'employee';
  //
  //     _isAdmin = savedRole.toLowerCase() == 'admin';
  //     isAdmin.value = _isAdmin;
  //     debugPrint('=== RECORDS LOAD ===');
  //     debugPrint('Role: $savedRole');
  //     debugPrint('Employee ID: "$_currentEmployeeId"');
  //     debugPrint('Email: "$_currentUserEmail"');
  //
  //     final List<AttendanceRecord> fetchedRecords = [];
  //
  //     if (_isAdmin) {
  //       if (!Get.isRegistered<DashboardController>()) {
  //         throw Exception('DashboardController is not registered');
  //       }
  //
  //       final dashboardController =
  //       Get.find<DashboardController>();
  //
  //       final employees = dashboardController.employees.toList();
  //
  //       for (final employee in employees) {
  //         if (employee.roleName?.toLowerCase() == 'admin') {
  //           continue;
  //         }
  //
  //         final employeeId = employee.id.toString().trim();
  //
  //         if (employeeId.isEmpty) continue;
  //
  //         try {
  //           final records =
  //           await _apiClient.fetchAttendanceHistory(
  //             employeeId: employeeId,
  //             startDate: DateTime.now(),
  //             endDate: DateTime.now(),
  //           );
  //
  //           fetchedRecords.addAll(records);
  //
  //           debugPrint(
  //             'Employee $employeeId: ${records.length} records',
  //           );
  //         } catch (e) {
  //           debugPrint(
  //             'Failed to load employee $employeeId: $e',
  //           );
  //         }
  //       }
  //     } else {
  //       // IMPORTANT: Do not use email as the employee ID.
  //       final employeeId = _currentEmployeeId.trim();
  //
  //       if (employeeId.isEmpty) {
  //         debugPrint(
  //           'ERROR: employee_id is missing from SharedPreferences.',
  //         );
  //         debugPrint(
  //           'Save the actual employee ID from the login response.',
  //         );
  //       } else {
  //         final records =
  //         await _apiClient.fetchAttendanceHistory(
  //           employeeId: employeeId,
  //           startDate: DateTime.now(),
  //           endDate: DateTime.now(),
  //         );
  //
  //         fetchedRecords.addAll(records);
  //
  //         debugPrint(
  //           'Fetched ${records.length} records for employee $employeeId',
  //         );
  //       }
  //     }
  //
  //     allRecords.assignAll(fetchedRecords);
  //
  //     debugPrint('ALL RECORDS: ${allRecords.length}');
  //
  //     _applyFilters();
  //   } catch (e, stackTrace) {
  //     debugPrint('RecordsController error: $e');
  //     debugPrint('$stackTrace');
  //
  //     allRecords.clear();
  //     filteredRecords.clear();
  //   } finally {
  //     isLoading.value = false;
  //
  //     debugPrint('FILTERED RECORDS: ${filteredRecords.length}');
  //     debugPrint('GROUPED RECORDS: ${groupedRecords.length}');
  //   }
  // }

  Future<void> _loadRecords() async {
    // Prevent overlapping requests
    if (isLoading.value) return;

    isLoading.value = true;

    try {
      final prefs = await SharedPreferences.getInstance();

      _currentUserEmail = prefs.getString('user_email') ?? '';
      _currentEmployeeId = prefs.getString('employee_id') ?? '';

      final savedRole = prefs.getString('user_role') ?? 'employee';

      _isAdmin = savedRole.toLowerCase() == 'admin';
      isAdmin.value = _isAdmin;

      debugPrint('=== RECORDS LOAD ===');
      debugPrint('Role: $savedRole');
      debugPrint('Employee ID: "$_currentEmployeeId"');
      debugPrint('Email: "$_currentUserEmail"');

      final List<AttendanceRecord> fetchedRecords = [];

      if (_isAdmin) {
        if (!Get.isRegistered<DashboardController>()) {
          throw Exception('DashboardController is not registered');
        }

        final dashboardController = Get.find<DashboardController>();

        // Ensure employee list is loaded before fetching attendance.
        await dashboardController.fetchEmployees();

        final employees = dashboardController.employees.toList();

        debugPrint('ADMIN EMPLOYEES: ${employees.length}');

        // Fetch attendance for all employees in parallel.
        final employeeRequests = employees
            .where(
          (employee) => employee.roleName?.toLowerCase() != 'admin',
        )
            .map((employee) async {
          final employeeId = employee.id.toString().trim();

          if (employeeId.isEmpty) {
            return <AttendanceRecord>[];
          }

          try {
            final records = await _apiClient.fetchAttendanceHistory(
              employeeId: employeeId,
              startDate: DateTime.now(),
              endDate: DateTime.now(),
            );

            debugPrint(
              'Employee $employeeId: ${records.length} records',
            );

            return records;
          } catch (e) {
            debugPrint(
              'Failed to load employee $employeeId: $e',
            );

            return <AttendanceRecord>[];
          }
        }).toList();

        final results = await Future.wait(employeeRequests);

        for (final records in results) {
          fetchedRecords.addAll(records);
        }
      } else {
        // Existing employee login logic preserved.
        // Do not use email as employee ID.
        final employeeId = _currentEmployeeId.trim();

        if (employeeId.isEmpty) {
          debugPrint(
            'ERROR: employee_id is missing from SharedPreferences.',
          );
          debugPrint(
            'Save the actual employee ID from the login response.',
          );
        } else {
          final records = await _apiClient.fetchAttendanceHistory(
            employeeId: employeeId,
            startDate: DateTime.now(),
            endDate: DateTime.now(),
          );

          fetchedRecords.addAll(records);

          debugPrint(
            'Fetched ${records.length} records for employee $employeeId',
          );
        }
      }

      // Update records only after fetching is complete.
      allRecords.assignAll(fetchedRecords);

      debugPrint('ALL RECORDS: ${allRecords.length}');

      _applyFilters();
    } catch (e, stackTrace) {
      debugPrint('RecordsController error: $e');
      debugPrint('$stackTrace');

      allRecords.clear();
      filteredRecords.clear();
    } finally {
      isLoading.value = false;

      debugPrint('FILTERED RECORDS: ${filteredRecords.length}');
      debugPrint('GROUPED RECORDS: ${groupedRecords.length}');
    }
  }

  void _applyFilters() {
    List<AttendanceRecord> records = allRecords.toList();

    //  Time filter (day/week/month)
    final now = DateTime.now();
    DateTime startDate;
    switch (currentFilter.value) {
      case RecordFilter.day:
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case RecordFilter.week:
        startDate = now.subtract(Duration(days: now.weekday - 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        break;
      case RecordFilter.month:
        startDate = DateTime(now.year, now.month, 1);
        break;
    }
    records = records.where((r) => !r.timestamp.isBefore(startDate)).toList();
    // records = records
    //     .where((r) => r.timestamp.isAfter(startDate.subtract(const Duration(days: 1))))
    //     .toList();

    //  Search query filter
    final query = searchQuery.value.toLowerCase().trim();
    if (query.isNotEmpty) {
      records = records.where((r) {
        final loginId = r.loginId.toLowerCase();
        final employeeId = r.employeeId.toLowerCase();
        final dateStr = r.formattedDate.toLowerCase();
        final timeStr = r.formattedTime.toLowerCase();
        final location = r.location.toLowerCase();
        return loginId.contains(query) ||
            employeeId.contains(query) ||
            dateStr.contains(query) ||
            timeStr.contains(query) ||
            location.contains(query);
      }).toList();
    }

    filteredRecords.assignAll(records);
  }

  void setFilter(RecordFilter filter) {
    currentFilter.value = filter;
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  void clearSearch() {
    searchQuery.value = '';
  }

  List<AttendanceRecord> getRecordsForAdmin(String loginId) {
    return _storage.getRecordsForUser(loginId);
  }

  List<PunchPair> get groupedRecords {
    final Map<String, PunchPair> pairs = {};

    for (final record in filteredRecords) {
      // Each employee must have a separate pair for each date.
      final employeeKey =
          record.employeeId.isNotEmpty ? record.employeeId : record.loginId;

      final key = '$employeeKey|${record.formattedDate}';

      final existing = pairs[key] ?? PunchPair();

      if (record.type.toUpperCase() == 'IN') {
        pairs[key] = PunchPair(
          inRecord: record,
          outRecord: existing.outRecord,
        );
      } else if (record.type.toUpperCase() == 'OUT') {
        pairs[key] = PunchPair(
          inRecord: existing.inRecord,
          outRecord: record,
        );
      }
    }

    return pairs.values.toList();
  }

  Map<String, List<AttendanceRecord>> getRecordsGroupedByDate() {
    final Map<String, List<AttendanceRecord>> grouped = {};
    for (final record in filteredRecords) {
      final dateKey = record.formattedDate;
      grouped.putIfAbsent(dateKey, () => []).add(record);
    }
    return grouped;
  }
}
