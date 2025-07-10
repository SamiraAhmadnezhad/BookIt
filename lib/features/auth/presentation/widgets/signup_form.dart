
import 'package:bookit/features/auth/presentation/widgets/custom_button.dart';
import 'package:bookit/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';

enum UserType { guest, manager }

class SignupForm extends StatefulWidget {
  final UserType userType;
  final Function(Map<String, String> data) onContinue;
  final bool isLoading;

  const SignupForm({
    super.key,
    required this.userType,
    required this.onContinue,
    required this.isLoading,
  });

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nationalIdController = TextEditingController();
  bool _termsAccepted = false;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nationalIdController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('لطفا قوانین و مقررات را بپذیرید.'),
            backgroundColor: Colors.red),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final data = {
        'email': _emailController.text.trim(),
        'name': _nameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'password': _passwordController.text,
        if (widget.userType == UserType.manager)
          'national_code': _nationalIdController.text.trim(),
        if (widget.userType == UserType.guest)
          'password2': _confirmPasswordController.text,
        if (widget.userType == UserType.guest) 'role': 'Customer',
      };
      widget.onContinue(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isManager = widget.userType == UserType.manager;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
                controller: _emailController,
                labelText: 'ایمیل',
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                (v!.isEmpty || !v.contains('@')) ? 'ایمیل نامعتبر است' : null),
            const SizedBox(height: 16),
            CustomTextField(
                controller: _nameController,
                labelText: 'نام',
                validator: (v) => v!.isEmpty ? 'نام الزامی است' : null),
            const SizedBox(height: 16),
            CustomTextField(
                controller: _lastNameController,
                labelText: 'نام خانوادگی',
                validator: (v) => v!.isEmpty ? 'نام خانوادگی الزامی است' : null),
            const SizedBox(height: 16),
            if (isManager) ...[
              CustomTextField(
                  controller: _nationalIdController,
                  labelText: 'کد ملی',
                  keyboardType: TextInputType.number,
                  enableVisibilityToggle: true,
                  validator: (v) => v!.isEmpty ? 'کد ملی الزامی است' : null),
              const SizedBox(height: 16),
            ],
            CustomTextField(
                controller: _passwordController,
                labelText: 'رمز عبور',
                isPassword: true,
                enableVisibilityToggle: true,
                validator: (v) =>
                v!.length < 6 ? 'رمز عبور باید حداقل ۶ کاراکتر باشد' : null),
            const SizedBox(height: 16),
            CustomTextField(
                controller: _confirmPasswordController,
                labelText: 'تکرار رمز عبور',
                isPassword: true,
                enableVisibilityToggle: true,
                validator: (v) {
                  if (v != _passwordController.text)
                    return 'رمزهای عبور یکسان نیستند';
                  return null;
                }),
            const SizedBox(height: 24),
            CheckboxListTile(
              value: _termsAccepted,
              onChanged: (value) => setState(() => _termsAccepted = value!),
              title: Text('قوانین و مقررات را می‌پذیرم',
                  style: theme.textTheme.bodySmall),
              controlAffinity: ListTileControlAffinity.trailing,
              activeColor: theme.colorScheme.primary,
            ),
            const SizedBox(height: 24),
            CustomButton(
                text: 'ادامه', onPressed: _submit, isLoading: widget.isLoading),
          ],
        ),
      ),
    );
  }
}