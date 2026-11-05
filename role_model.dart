class RoleModel {
  final String id;
  final String name;
  final String description;

  RoleModel({
    required this.id,
    required this.name,
    required this.description,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id']?.toString() ?? '',
      name: json['role_name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role_name': name,
      'description': description,
    };
  }

  @override
  String toString() => name;
}