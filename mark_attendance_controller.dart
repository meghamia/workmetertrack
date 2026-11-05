import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:track_attendance_app/controllers/records_controller.dart';
import '../models/attendance_model/attendance_response.dart';
import '../services/app_session.dart';
import '../services/attendance_storage.dart';
import '../models/attendance_record.dart';
import 'dashboard_controller.dart';

import '../services/api_client.dart';



enum DayAttendanceState { none, checkedIn, completed }

class MarkAttendanceController extends GetxController {
  final AppSession _appSession = Get.find<AppSession>();
  final AttendanceStorage _storage = Get.find<AttendanceStorage>();
  final ApiClient _apiClient = Get.find<ApiClient>();

  final RxBool isLoading = false.obs;
  final RxBool isSyncing = false.obs;
  final RxString statusMessage = ''.obs;

  final Rx<DayAttendanceState> dayState = DayAttendanceState.none.obs;
  final RxBool isDayStateLoaded = false.obs;

  final RxBool _backendHasCheckedIn = false.obs;
  final RxBool _backendHasCheckedOut = false.obs;

  String _currentUserEmail = '';
  String _currentEmployeeId = '';

  @override
  void onInit() {
    super.onInit();
    _loadAndSync();
  }

  // Keep this public for external calls (e.g., from Dashboard)
  Future<void> refreshDayState() async {
    await _loadAndSync();
  }

  Future<void> _loadAndSync() async {
    await _loadLocalState();
    await syncWithBackend();
  }

  Future<void> _loadLocalState() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserEmail = prefs.getString('user_email') ?? '';
    _currentEmployeeId = _appSession.employeeId.value;
    await _storage.loadRecords();
    dayState.value = _computeDayState();
    isDayStateLoaded.value = true;
  }

  Future<void> syncWithBackend() async {
    isSyncing.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('user_email') ?? '';
      final employeeId = _appSession.employeeId.value.isNotEmpty
          ? _appSession.employeeId.value
          : email;

      final response =
          await _apiClient.fetchTodayAttendance(employeeId: employeeId);

      if (response != null) {
        _backendHasCheckedIn.value = response.checkInTime != null;
        _backendHasCheckedOut.value = response.checkOutTime != null;
        await _updateLocalFromBackend(response);
      } else {
        _backendHasCheckedIn.value = false;
        _backendHasCheckedOut.value = false;
        await _clearTodayLocalRecords();
      }
    } catch (e) {
      debugPrint('Sync failed: $e');
      Get.snackbar('Sync Failed', 'Using cached data. Pull to retry.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSyncing.value = false;
      dayState.value = _computeDayState();
      isDayStateLoaded.value = true;
      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().refreshState();
      }
    }
  }

  // Future<void> _updateLocalFromBackend(
  //     AttendanceResponse response, {
  //       String? photoPath,  // ← ADD THIS
  //     }) async {
  //   await _clearTodayLocalRecords();
  //
  //   final loginId = _currentUserEmail;
  //   final employeeId = _currentEmployeeId;
  //   final location = response.remarks ?? response.location ?? '';
  //   final latitude = response.checkInLatitude ?? 0.0;
  //   final longitude = response.checkInLongitude ?? 0.0;
  //
  //   // Use the LOCAL camera path if available, otherwise fall back to backend path
  //   final String? localPhotoPath = (photoPath != null && photoPath.isNotEmpty)
  //       ? photoPath
  //       : response.checkInImage;
  //
  //   if (response.checkInTime != null) {
  //     await _storage.addRecord(AttendanceRecord(
  //       id: response.attendanceId.isNotEmpty ? '${response.attendanceId}_in' : 'in_${DateTime.now().millisecondsSinceEpoch}',
  //       loginId: loginId,
  //       employeeId: employeeId,
  //       timestamp: response.checkInTime!,
  //       type: 'IN',
  //       location: location,
  //       photoPath: localPhotoPath,  // ← Use local path
  //       latitude: latitude,
  //       longitude: longitude,
  //     ));
  //   }
  //
  //   if (response.checkOutTime != null) {
  //     await _storage.addRecord(AttendanceRecord(
  //       id: response.attendanceId.isNotEmpty ? '${response.attendanceId}_out' : 'out_${DateTime.now().millisecondsSinceEpoch}',
  //       loginId: loginId,
  //       employeeId: employeeId,
  //       timestamp: response.checkOutTime!,
  //       type: 'OUT',
  //       location: location,
  //       photoPath: response.checkOutImage,
  //       latitude: response.checkOutLatitude ?? 0.0,
  //       longitude: response.checkOutLongitude ?? 0.0,
  //     ));
  //   }
  // }
  // Future<void> _clearTodayLocalRecords() async {
  //   final now = DateTime.now();
  //   final allRecords = await _storage.loadRecords();
  //   final remaining = allRecords.where((r) {
  //     final isToday = r.timestamp.year == now.year && r.timestamp.month == now.month && r.timestamp.day == now.day;
  //     final isMine = r.loginId == _currentUserEmail || r.employeeId == _currentUserEmail || (_currentEmployeeId.isNotEmpty && r.employeeId == _currentEmployeeId);
  //     return !(isToday && isMine);
  //   }).toList();
  //   // Use public method to save
  //   await _storage.saveAllRecords(remaining);
  // }

  Future<void> _updateLocalFromBackend(
      AttendanceResponse response, {
        String? photoPath,  // Local camera photo for current punch
      }) async {
    // ── PRESERVE EXISTING RECORDS ──
    final today = _todayRecords();
    final existingIn = today.where((r) => r.type == 'IN').toList();
    final existingOut = today.where((r) => r.type == 'OUT').toList();

    await _clearTodayLocalRecords();

    final loginId = _currentUserEmail;
    final employeeId = _currentEmployeeId;
    final location = response.remarks ?? response.location ?? '';
    final latitude = response.checkInLatitude ?? 0.0;
    final longitude = response.checkInLongitude ?? 0.0;

    // ── SAVE IN RECORD ──
    // Priority: 1) Backend response checkInImage, 2) Local photoPath (if checking IN), 3) Existing local record
    String? inPhotoPath;
    if (response.checkInImage != null && response.checkInImage!.isNotEmpty) {
      inPhotoPath = response.checkInImage;  // Backend returned it
    } else if (photoPath != null && photoPath.isNotEmpty) {
      inPhotoPath = photoPath;  // Current punch is IN - use local photo
    } else if (existingIn.isNotEmpty) {
      inPhotoPath = existingIn.first.photoPath;  // Preserve existing
    }

    if (response.checkInTime != null) {
      await _storage.addRecord(AttendanceRecord(
        id: response.attendanceId.isNotEmpty ? '${response.attendanceId}_in' : 'in_${DateTime.now().millisecondsSinceEpoch}',
        loginId: loginId,
        employeeId: employeeId,
        timestamp: response.checkInTime!,
        type: 'IN',
        location: location,
        photoPath: inPhotoPath,  // ← Uses best available
        latitude: latitude,
        longitude: longitude,
      ));
    } else if (existingIn.isNotEmpty) {
      // Preserve existing IN record with its photo
      await _storage.addRecord(existingIn.first);
    }

    // ── SAVE OUT RECORD ──
    // Priority: 1) Backend response checkOutImage, 2) Local photoPath (if checking OUT), 3) Existing local record
    String? outPhotoPath;
    if (response.checkOutImage != null && response.checkOutImage!.isNotEmpty) {
      outPhotoPath = response.checkOutImage;  // Backend returned it
    } else if (photoPath != null && photoPath.isNotEmpty) {
      outPhotoPath = photoPath;  // Current punch is OUT - use local photo
    } else if (existingOut.isNotEmpty) {
      outPhotoPath = existingOut.first.photoPath;  // Preserve existing
    }

    if (response.checkOutTime != null) {
      await _storage.addRecord(AttendanceRecord(
        id: response.attendanceId.isNotEmpty ? '${response.attendanceId}_out' : 'out_${DateTime.now().millisecondsSinceEpoch}',
        loginId: loginId,
        employeeId: employeeId,
        timestamp: response.checkOutTime!,
        type: 'OUT',
        location: location,
        photoPath: outPhotoPath,  // ← Uses best available
        latitude: response.checkOutLatitude ?? 0.0,
        longitude: response.checkOutLongitude ?? 0.0,
      ));
    } else if (existingOut.isNotEmpty) {
      // Preserve existing OUT record with its photo
      await _storage.addRecord(existingOut.first);
    }
  }

  Future<void> _clearTodayLocalRecords() async {
    final now = DateTime.now();
    final allRecords = await _storage.loadRecords();
    final remaining = allRecords.where((r) {
      final isToday = r.timestamp.year == now.year &&
          r.timestamp.month == now.month &&
          r.timestamp.day == now.day;
      final isMine = r.loginId == _currentUserEmail ||
          r.employeeId == _currentUserEmail ||
          (_currentEmployeeId.isNotEmpty && r.employeeId == _currentEmployeeId);
      return !(isToday && isMine);
    }).toList();
    await _storage.saveAllRecords(remaining);
  }

  // Keep for CameraScreen or other callers
  Future<void> openCameraOrShowAlreadyMarked() async {
    await refreshDayState();
    if (isAttendanceCompleteToday) {
      Get.snackbar(
          'Already Marked', 'You have already marked your attendance today.',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16));
      return;
    }
    if (!canMarkAttendance) return;
    await Get.toNamed('/camera', arguments: {'type': nextAction});
  }

  // Keep for RecordDetailScreen or other callers
  AttendanceRecord? get lastTodayRecord {
    final today = _todayRecords();
    if (today.isEmpty) return null;
    today.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return today.first;
  }

  List<AttendanceRecord> _todayRecords() {
    final now = DateTime.now();
    return _storage.getRecords().where((r) {
      final isToday = r.timestamp.year == now.year &&
          r.timestamp.month == now.month &&
          r.timestamp.day == now.day;
      final isMine = r.loginId == _currentUserEmail ||
          r.employeeId == _currentUserEmail ||
          (_currentEmployeeId.isNotEmpty && r.employeeId == _currentEmployeeId);
      return isToday && isMine;
    }).toList();
  }

  DayAttendanceState _computeDayState() {
    final today = _todayRecords();
    final hasIn = today.any((r) => r.type == 'IN');
    final hasOut = today.any((r) => r.type == 'OUT');
    if (hasOut) return DayAttendanceState.completed;
    if (hasIn) return DayAttendanceState.checkedIn;
    return DayAttendanceState.none;
  }

  bool get isAttendanceCompleteToday =>
      _backendHasCheckedOut.value ||
      dayState.value == DayAttendanceState.completed;

  bool get hasCheckedInToday =>
      _backendHasCheckedIn.value || dayState.value != DayAttendanceState.none;

  bool get hasCheckedOutToday =>
      _backendHasCheckedOut.value ||
      dayState.value == DayAttendanceState.completed;

  String get nextAction {
    switch (dayState.value) {
      case DayAttendanceState.checkedIn:
        return 'OUT';
      case DayAttendanceState.completed:
        return 'DONE';
      default:
        return 'IN';
    }
  }

  bool get canMarkAttendance => !isLoading.value;
  bool _alreadyPunched(String type) {
    if (type == 'IN' && hasCheckedInToday) {
      Get.snackbar('Already punched in', 'You have already punched in today.',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16));
      return true;
    }
    if (type == 'OUT' && hasCheckedOutToday) {
      Get.snackbar('Already punched out', 'You have already punched out today.',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16));
      return true;
    }
    return false;
  }

  Future<void> startAttendance(String type) async {
    debugPrint('========== STEP 1: START ATTENDANCE ==========');

    debugPrint('STEP A: startAttendance entered');

    debugPrint('STEP B: before refreshDayState');
    await refreshDayState();
    debugPrint('STEP C: after refreshDayState');

    final result = await Get.toNamed(
      '/camera',
      arguments: {'type': type},
    );

    debugPrint('STEP D: camera returned');
    debugPrint('Camera result type: ${result.runtimeType}');

    if (result == null || result is! Map) {
      debugPrint('STOPPED: camera result is null or not a Map');
      return;
    }

    debugPrint('STEP E: before Save Image dialog');

    final yes = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Save Image'),
        content: const Text('Are you sure you want to save the image?'),
        actions: [
          TextButton(
            onPressed: () {
              debugPrint('SAVE IMAGE: NO CLICKED');
              Get.back(result: false);
            },
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              debugPrint('SAVE IMAGE: YES CLICKED');
              Get.back(result: true);
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    debugPrint('STEP F: dialog returned yes=$yes');

    if (yes != true) {
      debugPrint('STOPPED: user did not confirm image');
      return;
    }

    debugPrint('STEP G: about to call markAttendance');

    final ok = await markAttendance(
      type: type,
      latitude: (result['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (result['longitude'] as num?)?.toDouble() ?? 0,
      location: result['location']?.toString() ?? '',
      photoPath: result['imagePath']?.toString(),
    );

    debugPrint('STEP H: markAttendance returned ok=$ok');

    debugPrint('PHOTO PATH FROM CAMERA: ${result['imagePath']}');
    if (ok) {
      await syncWithBackend();
      if (Get.isRegistered<DashboardController>()) {
        await Get.find<DashboardController>().refreshDashboard();
        //Get.find<DashboardController>().loadStats();
      }
      // Refresh Records screen immediately
      if (Get.isRegistered<RecordsController>()) {
        await Get.find<RecordsController>().refresh();
      }
      //await refreshDayState();
      Get.snackbar('Saved', statusMessage.value);
    } else {
      Get.snackbar('Error', statusMessage.value);
    }
  }

  // Future<bool> markAttendance({
  //   required String type,
  //   required double latitude,
  //   required double longitude,
  //   required String location,
  //   String? photoPath,
  // }) async {
  //   isLoading.value = true;
  //   statusMessage.value = 'Marking attendance...';
  //
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final email = prefs.getString('user_email') ?? '';
  //     final loginId = email;
  //     final employeeId = _appSession.employeeId.value.isNotEmpty ? _appSession.employeeId.value : email;
  //
  //     final AttendanceResponse response = type == 'IN'
  //         ? await _apiClient.checkIn(employeeId: employeeId, latitude: latitude, longitude: longitude, location: location, photoPath: photoPath)
  //         : await _apiClient.checkOut(employeeId: employeeId, latitude: latitude, longitude: longitude, location: location, photoPath: photoPath);
  //
  //     if (!response.isSuccessful) {
  //       statusMessage.value = response.message.isEmpty ? 'Attendance rejected' : response.message;
  //       // await syncWithBackend();
  //       return false;
  //     }
  //
  //     await _updateLocalFromBackend(response, photoPath: photoPath);
  //     statusMessage.value = response.message;
  //     return true;
  //   } catch (e) {
  //     statusMessage.value = 'Failed: $e';
  //     return false;
  //   }
  //
  //   finally {
  //     isLoading.value = false;
  //   }
  // }
  Future<bool> markAttendance({
    required String type,
    required double latitude,
    required double longitude,
    required String location,
    String? photoPath,
  }) async {
    isLoading.value = true;
    statusMessage.value = 'Marking attendance...';

    try {
      debugPrint('MARK ATTENDANCE METHOD ENTERED');
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('user_email') ?? '';
      final loginId = email;

      // Get employeeId with multiple fallbacks
      String employeeId = _appSession.employeeId.value;
      if (employeeId.isEmpty) {
        employeeId = _appSession.loginId.value; // Try loginId from session
      }
      if (employeeId.isEmpty) {
        employeeId = email; // Fallback to email
      }

      debugPrint('=== MARK ATTENDANCE DEBUG ===');
      debugPrint('Type: $type');
      debugPrint('employeeId: $employeeId');
      debugPrint('loginId: $loginId');
      debugPrint('email: $email');
      debugPrint('AppSession employeeId: ${_appSession.employeeId.value}');
      debugPrint('AppSession loginId: ${_appSession.loginId.value}');

      if (employeeId.isEmpty) {
        statusMessage.value = 'Employee ID not found. Please login again.';
        return false;
      }

      final AttendanceResponse response = type == 'IN'
          ? await _apiClient.checkIn(
              employeeId: employeeId,
              latitude: latitude,
              longitude: longitude,
              location: location,
              photoPath: photoPath)
          : await _apiClient.checkOut(
              employeeId: employeeId,
              latitude: latitude,
              longitude: longitude,
              location: location,
              photoPath: photoPath);

      if (!response.isSuccessful) {
        statusMessage.value =
            response.message.isEmpty ? 'Attendance rejected' : response.message;
        return false;
      }

      await _updateLocalFromBackend(response, photoPath: photoPath);
      statusMessage.value = response.message;
      return true;
    } catch (e) {
      statusMessage.value = 'Failed: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void clearStatus() => statusMessage.value = '';
}
