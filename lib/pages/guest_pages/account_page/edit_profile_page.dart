// lib/pages/profile_pages/edit_profile_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../authentication_page/auth_service.dart';
import 'models/user_profile_model.dart';

class EditProfilePage extends StatefulWidget {
  final UserProfileModel initialProfileData;
  const EditProfilePage({super.key, required this.initialProfileData});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final Color primaryPurple = const Color(0xFF542545);
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _lastNameController;
  late TextEditingController _passwordController;
  late TextEditingController _emailController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialProfileData.name);
    _lastNameController = TextEditingController(text: widget.initialProfileData.lastName);
    _emailController = TextEditingController(text: widget.initialProfileData.email);
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveProfileChanges() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);
    final token = authService.token;

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.red, content: Text('خطای احراز هویت')));
      setState(() => _isLoading = false);
      return;
    }

    final updatedProfile = UserProfileModel(
      id: widget.initialProfileData.id,
      name: _nameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      role: widget.initialProfileData.role,
      status: widget.initialProfileData.status,
    );

    try {
      final response = await http.put(
        Uri.parse('https://fbookit.darkube.app/auth/users/profile/'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(updatedProfile.toJsonForUpdate(
          newPassword: _passwordController.text.trim(),
        )),
      );

      if (!mounted) return;
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تغییرات با موفقیت ذخیره شد.'), backgroundColor: Colors.green));
        Navigator.of(context).pop(true);
      } else {
        final errorData = jsonDecode(utf8.decode(response.bodyBytes));
        final errorMessage = errorData.toString();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطا: $errorMessage'), backgroundColor: Colors.red));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطا در ارتباط با سرور: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildTextField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        readOnly: readOnly,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[700]),
          prefixIcon: Icon(icon, color: primaryPurple.withOpacity(0.7), size: 22),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: primaryPurple, width: 1.5),
          ),
        ),
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: primaryPurple, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'ویرایش اطلاعات',
            style: TextStyle(color: primaryPurple, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30.0),
              topRight: Radius.circular(30.0),
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 24.0),
                  _buildTextField(
                    icon: Icons.person_outline,
                    label: 'نام',
                    controller: _nameController,
                    validator: (value) => (value?.isEmpty ?? true) ? 'نام نمی‌تواند خالی باشد' : null,
                  ),
                  _buildTextField(
                    icon: Icons.person_outline,
                    label: 'نام خانوادگی',
                    controller: _lastNameController,
                    validator: (value) => (value?.isEmpty ?? true) ? 'نام خانوادگی نمی‌تواند خالی باشد' : null,
                  ),
                  _buildTextField(
                    icon: Icons.email_outlined,
                    label: 'ایمیل',
                    controller: _emailController,
                    readOnly: true,
                  ),
                  _buildTextField(
                    icon: Icons.lock_outline,
                    label: 'رمز عبور جدید (اختیاری)',
                    controller: _passwordController,
                    obscureText: true,
                  ),
                  const SizedBox(height: 24.0),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfileChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryPurple,
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.0))
                          : const Text(
                        'ذخیره‌ی تغییرات',
                        style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}