import 'package:get/get.dart';
import '../models/auth/role_model.dart';
import '../models/user_role.dart';

class RoleService extends GetxService {
  static final List<RoleModel> defaultRoles = <RoleModel>[
    RoleModel(id: '1', name: 'Employee', description: 'Employee role'),
    RoleModel(id: '2', name: 'Admin', description: 'Administrator role'),
  ];

  final RxList<RoleModel> roles = <RoleModel>[].obs;
  final RxList<RoleModel> employeeRoles = <RoleModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;


  // NO fetchRoles() call in onInit()
  @override
  void onInit() {
    super.onInit();
    roles.assignAll(defaultRoles);
    employeeRoles.assignAll(defaultRoles);
  }

  // Kept for future use, but NOT auto-called
  Future<void> fetchRoles() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      roles.assignAll(defaultRoles);
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      if (roles.isEmpty) {
        roles.assignAll(defaultRoles);
      }
      employeeRoles.assignAll(roles);
      isLoading.value = false;
    }
  }

  RoleModel? getRoleByName(String name) {
    try {
      return roles.firstWhere(
              (r) => r.name.toLowerCase() == name.toLowerCase());
    } catch (_) {
      return null;
    }
  }

  static UserRole parseRoleStatic(String roleName) {
    return roleName.toLowerCase() == 'admin'
        ? UserRole.admin
        : UserRole.employee;
  }

  UserRole parseRole(String roleName) {
    return parseRoleStatic(roleName);
  }
}