import 'package:bookit/features/auth/presentation/widgets/custom_button.dart';
import 'package:bookit/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginForm extends StatefulWidget {
  final Function(String email, String password, bool isManager) onLogin;
  final VoidCallback onForgotPassword;
  final bool isLoading;

  const LoginForm({
    super.key,
    required this.onLogin,
    required this.onForgotPassword,
    required this.isLoading,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int _selectedUserType = 0;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onLogin(
        _emailController.text.trim(),
        _passwordController.text,
        _selectedUserType == 1,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Text("ورود به عنوان:", style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: CupertinoSlidingSegmentedControl<int>(
              groupValue: _selectedUserType,
              backgroundColor: theme.colorScheme.surface,
              thumbColor: theme.colorScheme.primary,
              onValueChanged: (value) {
                if (value != null) {
                  setState(() => _selectedUserType = value);
                }
              },
              children: {
                0: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    'مسافر',
                    style: TextStyle(
                      color:
                      _selectedUserType == 0 ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                1: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    'مدیر هتل',
                    style: TextStyle(
                      color:
                      _selectedUserType == 1 ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              },
            ),
          ),
          const SizedBox(height: 24),
          CustomTextField(
            controller: _emailController,
            labelText: 'ایمیل',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty || !value.contains('@')) {
                return 'لطفا ایمیل معتبری وارد کنید';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _passwordController,
            labelText: 'رمز عبور',
            isPassword: true,
            enableVisibilityToggle: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'لطفا رمز عبور را وارد کنید';
              }
              return null;
            },
          ),
          const Spacer(),
          CustomButton(
            text: 'ورود',
            onPressed: _submit,
            isLoading: widget.isLoading,
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.center,
            child: TextButton(
              onPressed: widget.onForgotPassword,
              child: Text(
                'رمز عبور را فراموش کرده‌اید؟',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}