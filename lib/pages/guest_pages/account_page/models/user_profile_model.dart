class UserProfileModel {
  final int id;
  final String email;
  final String name;
  final String lastName;
  final String role;
  final String status;

  UserProfileModel({
    required this.id,
    required this.email,
    required this.name,
    required this.lastName,
    required this.role,
    required this.status,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      lastName: json['last_name'] ?? '',
      role: json['role'] ?? 'Customer',
      status: json['status'] ?? 'Pending',
    );
  }

  Map<String, dynamic> toJsonForUpdate({String? newPassword}) {
    String getRoleApiValue(String displayRole) {
      final roleMap = {
        'customer': 'Customer',
        'hotel manager': 'HotelManager',
        'admin': 'Admin',
      };
      return roleMap[displayRole.toLowerCase()] ?? displayRole;
    }

    final Map<String, dynamic> data = {
      'email': email,
      'name': name,
      'last_name': lastName,
      'role': getRoleApiValue(role),
    };

    if (newPassword != null && newPassword.isNotEmpty) {
      data['password'] = newPassword;
    }
    return data;
  }
}