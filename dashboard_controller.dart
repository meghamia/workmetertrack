import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/attendance_storage.dart';
import '../models/attendance_record.dart';


import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth/employee_model.dart';


import '../services/api_client.dart';
import '../services/attendance_storage.dart';
import '../models/attendance_record.dart';

class DashboardController extends GetxController {
  final AttendanceStorage _storage = Get.find<AttendanceStorage>();
  final ApiClient _apiClient = Get.find<ApiClient>();

  final RxBool isAdmin = false.obs;
  final RxString currentUserEmail = ''.obs;
  final RxInt totalPresent = 0.obs;
  final RxInt todayIn = 0.obs;
  final RxInt todayOut = 0.obs;


  // Employees, fetched from the backend


  final RxList<Employee> employees = <Employee>[].obs;
  final RxBool isLoadingEmployees = false.obs;
  final RxString employeeError = ''.obs;
  final RxInt presentToday = 0.obs;
  final RxBool isLoadingPresentToday = false.obs;
  int get totalEmployees => employees.length;


  final RxList<Employee> presentEmployeesToday = <Employee>[].obs;

  final RxMap<String, String> todayPunchInTimes =
      <String, String>{}.obs;

  final RxMap<String, String> todayPunchOutTimes = <String, String>{}.obs;
  final RxMap<String, String> todayAttendanceStatus = <String, String>{}.obs;
  // final RxList<Map<String, dynamic>> todayAttendanceRecords = <Map<String, dynamic>>[].obs;
  // final RxBool isLoadingTodayRecords = false.obs;

  /// Visible employees only - the API can return
  /// soft-deleted or hidden rows.
  List<Employee> get visibleEmployees => employees
      .where((Employee e) => !e.isDeletedFlag && !e.isHiddenFlag)
      .toList();

  @override
  void onInit() {
    super.onInit();
    _loadRoleAndEmailFromPrefs();
    loadStats();

  //  fetchEmployees();
    fetchEmployees().then((_) {
      fetchPresentToday();
    });
    //if (isAdmin.value) {
    //  fetchPresentToday();
    //}
  }

  Future<void> _loadRoleAndEmailFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedRole = prefs.getString('user_role') ?? 'employee';
    final savedEmail = prefs.getString('user_email') ?? '';

    isAdmin.value = savedRole == 'admin';
    currentUserEmail.value = savedEmail;
  }

  // ──────────────────────────────────────────────
  // Fetch the employee directory
  // ──────────────────────────────────────────────

  Future<void> fetchEmployees() async {
    isLoadingEmployees.value = true;
    employeeError.value = '';

    try {
      final List<Employee> result = await _apiClient.getEmployees();

      employees.assignAll(result);
    } catch (e) {
      // Keep the previous list rather than blanking the
      // dashboard on a transient failure.
      employeeError.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoadingEmployees.value = false;
    }
  }

  // Future<void> fetchPresentToday() async {
  //   isLoadingPresentToday.value = true;
  //   try {
  //     final List<String> ids = await _apiClient.fetchPresentToday();
  //     presentToday.value = ids.length;
  //   } catch (e) {
  //     presentToday.value = 0;
  //   } finally {
  //     isLoadingPresentToday.value = false;
  //   }
  // }



  Future<void> fetchPresentToday() async {
    isLoadingPresentToday.value = true;

    try {
      final now = DateTime.now();

      final List<Employee> presentEmployees = [];

      final Map<String, String> punchInTimes = {};
      final Map<String, String> punchOutTimes = {};
      final Map<String, String> attendanceStatuses = {};

      for (final employee in visibleEmployees) {
        final employeeId = employee.id.toString();

        final records = await _apiClient.fetchAttendanceHistory(
          employeeId: employeeId,
        );

        final todayRecords = records.where((record) {
          final time = record.timestamp;

          return time.year == now.year &&
              time.month == now.month &&
              time.day == now.day;
        }).toList();

        final inRecords = todayRecords
            .where((record) => record.type.toUpperCase() == 'IN')
            .toList();

        final outRecords = todayRecords
            .where((record) => record.type.toUpperCase() == 'OUT')
            .toList();

        if (inRecords.isEmpty) {
          continue;
        }

        inRecords.sort(
              (a, b) => a.timestamp.compareTo(b.timestamp),
        );

        outRecords.sort(
              (a, b) => a.timestamp.compareTo(b.timestamp),
        );

        presentEmployees.add(employee);

        punchInTimes[employeeId] =
            _formatAttendanceTime(inRecords.first.timestamp);

        if (outRecords.isNotEmpty) {
          punchOutTimes[employeeId] =
              _formatAttendanceTime(outRecords.last.timestamp);

          attendanceStatuses[employeeId] = 'Punched Out';
        } else {
          punchOutTimes[employeeId] = '--:--';
          attendanceStatuses[employeeId] = 'Punched In';
        }

        print(
          'TODAY STATUS: ${employee.loginId} | '
              'IN: ${punchInTimes[employeeId]} | '
              'OUT: ${punchOutTimes[employeeId]} | '
              'STATUS: ${attendanceStatuses[employeeId]}',
        );
      }

      presentEmployeesToday.assignAll(presentEmployees);
      todayPunchInTimes.assignAll(punchInTimes);
      todayPunchOutTimes.assignAll(punchOutTimes);
      todayAttendanceStatus.assignAll(attendanceStatuses);

      presentToday.value = presentEmployees.length;
    } catch (e, stackTrace) {
      print('fetchPresentToday ERROR: $e');
      print(stackTrace);
    } finally {
      isLoadingPresentToday.value = false;
    }
  }

  String _formatAttendanceTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }




  void loadStats() {
    final records = _storage.getRecords();
    final today = DateTime.now();
    final todayStr = today.day.toString().padLeft(2, '0') + '/' +
        today.month.toString().padLeft(2, '0') + '/' +
        today.year.toString();

    totalPresent.value = records.where((r) => r.type == 'IN').length;
    todayIn.value = records
        .where((r) => r.type == 'IN' && r.formattedDate == todayStr)
        .length;
    todayOut.value = records
        .where((r) => r.type == 'OUT' && r.formattedDate == todayStr)
        .length;
  }

  Future<void> refreshDashboard() async {
    loadStats();

    await fetchEmployees();
    await fetchPresentToday();
  }

  List<AttendanceRecord> getTodayRecords() {
    final records = _storage.getRecords();
    final today = DateTime.now();
    final todayStr = today.day.toString().padLeft(2, '0') + '/' +
        today.month.toString().padLeft(2, '0') + '/' +
        today.year.toString();
    return records.where((r) => r.formattedDate == todayStr).toList();
  }


  void refreshState() {
    // Trigger reactive updates
    currentUserEmail.refresh();
    isAdmin.refresh();
    totalPresent.refresh();
    todayIn.refresh();
    todayOut.refresh();
  }


  // Future<void> fetchTodayAttendanceRecords() async {
  //   isLoadingTodayRecords.value = true;
  //   try {
  //     final List<Map<String, dynamic>> records =
  //     await _apiClient.fetchTodayAttendanceRecords();
  //     todayAttendanceRecords.assignAll(records);
  //   } catch (e) {
  //     todayAttendanceRecords.assignAll([]);
  //   } finally {
  //     isLoadingTodayRecords.value = false;
  //   }
  // }
}