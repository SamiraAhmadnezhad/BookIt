import 'package:bookit/core/theme/app_colors.dart';
import 'package:bookit/features/auth/data/services/auth_service.dart';
import 'package:bookit/features/auth/presentation/widgets/login_form.dart';
import 'package:bookit/features/auth/presentation/widgets/otp_form.dart';
import 'package:bookit/features/auth/presentation/widgets/signup_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum AuthScreen { login, guestSignup, managerSignup, otp }

class AuthFormWrapper extends StatefulWidget {
  const AuthFormWrapper({super.key});

  @override
  State<AuthFormWrapper> createState() => _AuthFormWrapperState();
}

class _AuthFormWrapperState extends State<AuthFormWrapper> {
  AuthScreen _currentScreen = AuthScreen.login;
  String _emailForOtp = '';

  void _showSnackBar(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textDirection: TextDirection.rtl),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ),
    );
  }

  void _handleLogin(String email, String password, bool isManager) async {
    print("salam");
    final authService = context.read<AuthService>();
    final error = await authService.login(email, password, isManager);
    if (!mounted) return;
    if (error == null) {
      _showSnackBar('ورود با موفقیت انجام شد.', isError: false);
    } else {
      _showSnackBar(error);
    }
  }

  void _handleSignup(Map<String, String> data, UserType userType) async {
    final authService = context.read<AuthService>();
    final error = await authService.register(data, userType == UserType.manager);
    if (!mounted) return;
    if (error == null) {
      setState(() {
        _emailForOtp = data['email']!;
        _currentScreen = AuthScreen.otp;
      });
      _showSnackBar('کد تایید به ایمیل شما ارسال شد.', isError: false);
    } else {
      _showSnackBar(error);
    }
  }

  void _handleOtpSubmit(String otp) async {
    final authService = context.read<AuthService>();
    final error = await authService.verifyOtp(_emailForOtp, otp);
    if (!mounted) return;
    if (error == null) {
      _showSnackBar('ثبت‌نام با موفقیت انجام شد. لطفا وارد شوید.', isError: false);
      setState(() => _currentScreen = AuthScreen.login);
    } else {
      _showSnackBar(error);
    }
  }

  void _handleResendOtp() async {
    final authService = context.read<AuthService>();
    final error = await authService.resendOtp(_emailForOtp);
    if (!mounted) return;
    _showSnackBar(error ?? 'کد جدید ارسال شد.', isError: error != null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authService = context.watch<AuthService>();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.formBackgroundGrey,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_currentScreen != AuthScreen.otp) _buildSegmentedControl(theme),
          SizedBox(
            height: 480,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: _buildCurrentForm(authService.isLoading),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentForm(bool isLoading) {
    switch (_currentScreen) {
      case AuthScreen.login:
        return LoginForm(
          key: const ValueKey('login'),
          onLogin: _handleLogin,
          onForgotPassword: () =>
              _showSnackBar('این قابلیت هنوز پیاده‌سازی نشده است.'),
          isLoading: isLoading,
        );
      case AuthScreen.guestSignup:
        return SignupForm(
          key: const ValueKey('guest_signup'),
          userType: UserType.guest,
          onContinue: (data) => _handleSignup(data, UserType.guest),
          isLoading: isLoading,
        );
      case AuthScreen.managerSignup:
        return SignupForm(
          key: const ValueKey('manager_signup'),
          userType: UserType.manager,
          onContinue: (data) => _handleSignup(data, UserType.manager),
          isLoading: isLoading,
        );
      case AuthScreen.otp:
        return OtpForm(
          key: const ValueKey('otp'),
          email: _emailForOtp,
          onSubmit: _handleOtpSubmit,
          onResend: _handleResendOtp,
          isLoading: isLoading,
          isResending: false,
        );
    }
  }

  Widget _buildSegmentedControl(ThemeData theme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildTab('ورود', AuthScreen.login, theme),
          _buildTab('ثبت‌نام مدیر', AuthScreen.managerSignup, theme),
          _buildTab('ثبت‌نام مهمان', AuthScreen.guestSignup, theme),
        ],
      ),
    );
  }

  Widget _buildTab(String text, AuthScreen screen, ThemeData theme) {
    final bool isActive = _currentScreen == screen;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentScreen = screen),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? theme.colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }
}