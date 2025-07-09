// lib/pages/profile_pages/models/user_profile_model.dart

class UserProfileModel {
  final int id;
  final String email;
  final String name;
  final String lastName;
  final String role;
  final String status;
  // فیلدهای 'password' و 'avatarUrl' از این API نمی‌آیند.

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

  // متدی برای ارسال داده‌ها به سرور هنگام ویرایش
  Map<String, dynamic> toJsonForUpdate({String? newPassword}) {
    final Map<String, dynamic> data = {
      'email': email,
      'name': name,
      'last_name': lastName,
      'role': role,
    };
    // فقط در صورتی که رمز جدیدی وارد شده باشد، آن را به درخواست اضافه کن
    if (newPassword != null && newPassword.isNotEmpty) {
      data['password'] = newPassword;
    }
    return data;
  }
}