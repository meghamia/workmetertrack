import 'package:get/get.dart';
import '../services/api_client.dart';

class ApiClientBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiClient>(() => ApiClient());
  }
}
