import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/attendance_record.dart';


class AttendanceStorage extends GetxService {
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _sharedPrefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  String get _storageKey => 'attendance_records';

  @override
  void onInit() {
    super.onInit();
    _sharedPrefs;
  }

  Future<List<AttendanceRecord>> loadRecords() async {
    final prefs = await _sharedPrefs;
    final String? data = prefs.getString(_storageKey);
    if (data == null || data.isEmpty) return [];
    try {
      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList.map((e) => AttendanceRecord.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  List<AttendanceRecord> getRecords() {
    if (_prefs == null) return [];
    final String? data = _prefs!.getString(_storageKey);
    if (data == null || data.isEmpty) return [];
    try {
      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList.map((e) => AttendanceRecord.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  List<AttendanceRecord> getRecordsForUser(String loginId) {
    if (_prefs == null) return [];
    final allRecords = getRecords();
    return allRecords.where((r) => r.loginId == loginId).toList();
  }

  Future<void> addRecord(AttendanceRecord record) async {
    final prefs = await _sharedPrefs;
    final records = getRecords();
    records.insert(0, record);
    final jsonList = records.map((r) => r.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  // NEW: Public method to save all records (used for clearing/syncing)
  Future<void> saveAllRecords(List<AttendanceRecord> records) async {
    final prefs = await _sharedPrefs;
    final jsonList = records.map((r) => r.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  Future<void> clearRecords() async {
    final prefs = await _sharedPrefs;
    await prefs.remove(_storageKey);
  }

  static AttendanceStorage forCurrentUser() => Get.find<AttendanceStorage>();
}