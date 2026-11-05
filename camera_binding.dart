import 'package:get/get.dart';
import '../controllers/location_controller.dart';
import '../controllers/camera_controller.dart';

class CameraBinding extends Bindings {
  @override
  void dependencies() {
    // LocationController pehlan, kyunki CameraController ohnu find karda hai
    Get.lazyPut<LocationController>(() => LocationController(), fenix: true);
    Get.lazyPut<CameraController>(() => CameraController());
  }
}