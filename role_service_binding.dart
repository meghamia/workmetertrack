import 'package:get/get.dart';
import '../services/role_service.dart';

class RoleServiceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RoleService>(() => RoleService());
  }
}
