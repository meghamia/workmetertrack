import 'package:get/get.dart';
import '../services/app_session.dart';

class AppSessionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AppSession>(() => AppSession());
  }
}
