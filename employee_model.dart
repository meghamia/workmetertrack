// class Employee {
//   final String id;
//   final String loginId;
//   final String employeeName;
//   final String createdBy;
//   final String createdDate;
//   final String? modifiedBy;
//   final String? modifiedDate;
//   final String isActive;
//   final String isDeleted;
//   final String isHidden;
//   final String? profileImage;
//   final String? roleId;
//   final String? roleName;
//
//   Employee({
//     required this.id,
//     required this.loginId,
//     required this.employeeName,
//     required this.createdBy,
//     required this.createdDate,
//     this.modifiedBy,
//     this.modifiedDate,
//     required this.isActive,
//     required this.isDeleted,
//     required this.isHidden,
//     this.profileImage,
//     this.roleId,
//     this.roleName,
//   });
//
//   factory Employee.fromJson(Map<String, dynamic> json) {
//     return Employee(
//       id: json['id']?.toString() ?? '',
//       loginId: json['login_id']?.toString() ?? '',
//       employeeName: json['employee_name']?.toString() ?? '',
//       createdBy: json['created_by']?.toString() ?? '',
//       createdDate: json['created_date']?.toString() ?? '',
//       modifiedBy: json['modified_by']?.toString(),
//       modifiedDate: json['modified_date']?.toString(),
//       isActive: json['is_active']?.toString() ?? 'f',
//       isDeleted: json['is_deleted']?.toString() ?? 'f',
//       isHidden: json['is_hidden']?.toString() ?? 'f',
//       profileImage: json['profile_image']?.toString(),
//       roleId: json['role_id']?.toString(),
//       roleName: json['role_name']?.toString(),
//     );
//   }
//
//   // PostgreSQL sends booleans as the text flags "t" and "f".
//   bool get isActiveFlag => isActive.toLowerCase() == 't';
//   bool get isDeletedFlag => isDeleted.toLowerCase() == 't';
//   bool get isHiddenFlag => isHidden.toLowerCase() == 't';
//
//   String get displayName =>
//       employeeName.trim().isEmpty ? loginId : employeeName;
// }



class Employee {
  final String id;
  final String loginId;
  final String employeeName;
  final String createdBy;
  final String createdDate;
  final String? modifiedBy;
  final String? modifiedDate;
  final String isActive;
  final String isDeleted;
  final String isHidden;
  final String? profileImage;
  final String? roleId;
  final String? roleName;
  final String? department;
  final String? designation;

  Employee({
    required this.id,
    required this.loginId,
    required this.employeeName,
    required this.createdBy,
    required this.createdDate,
    this.modifiedBy,
    this.modifiedDate,
    required this.isActive,
    required this.isDeleted,
    required this.isHidden,
    this.profileImage,
    this.roleId,
    this.roleName,
    this.department,
    this.designation,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id']?.toString() ?? '',
      loginId: json['login_id']?.toString() ?? '',
      employeeName: json['employee_name']?.toString() ?? '',
      createdBy: json['created_by']?.toString() ?? '',
      createdDate: json['created_date']?.toString() ?? '',
      modifiedBy: json['modified_by']?.toString(),
      modifiedDate: json['modified_date']?.toString(),
      isActive: json['is_active']?.toString() ?? 'f',
      isDeleted: json['is_deleted']?.toString() ?? 'f',
      isHidden: json['is_hidden']?.toString() ?? 'f',
      profileImage: json['profile_image']?.toString(),
      roleId: json['role_id']?.toString(),
      roleName: json['role_name']?.toString() ?? json['role']?.toString(),
      department: json['department']?.toString(),
      designation: json['designation']?.toString(),
    );
  }

  // PostgreSQL sends booleans as the text flags "t" and "f".
  bool get isActiveFlag => isActive.toLowerCase() == 't';
  bool get isDeletedFlag => isDeleted.toLowerCase() == 't';
  bool get isHiddenFlag => isHidden.toLowerCase() == 't';

  String get displayName =>
      employeeName.trim().isEmpty ? loginId : employeeName;
}