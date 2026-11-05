import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/mark_attendance_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<MarkAttendanceController>(
          () => MarkAttendanceController(),
      fenix: true,
    );
  }
}