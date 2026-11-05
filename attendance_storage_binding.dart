import 'package:get/get.dart';
import '../services/attendance_storage.dart';

class AttendanceStorageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AttendanceStorage>(() => AttendanceStorage());
  }
}
