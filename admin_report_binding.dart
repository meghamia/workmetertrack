import 'package:get/get.dart';
import '../controllers/admin_report_controller.dart';

class AdminReportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminReportController>(() => AdminReportController());
  }
}