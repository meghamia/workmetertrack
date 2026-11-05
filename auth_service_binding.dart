import 'package:get/get.dart';
import '../services/auth_service.dart';

class AuthServiceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthService>(() => AuthService());
  }
}
