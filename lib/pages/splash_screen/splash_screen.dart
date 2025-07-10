import 'dart:async';
import 'package:bookit/features/auth/presentation/pages/authentication_screen.dart';
import 'package:bookit/pages/guest_pages/guest_main_screen.dart';
import 'package:bookit/pages/manger_pages/manager_main_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/data/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const _AuthWrapper(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF542545);
    const Color backgroundColor = Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text.rich(
              TextSpan(
                text: 'بوکیت',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: primaryColor,
                ),
              ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 120),
            SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor.withOpacity(0.8)),
                backgroundColor: primaryColor.withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ... (کدهای بالای فایل splash_screen.dart بدون تغییر باقی می‌مانند) ...

// این ویجت خصوصی، منطق Consumer را از main.dart به اینجا منتقل می‌کند
class _AuthWrapper extends StatelessWidget {
  const _AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // --- برای تست، مستقیما به صفحه اصلی بروید ---
    // شما می‌توانید بین GuestMainScreen و ManagerMainScreen انتخاب کنید
    //return const GuestMainScreen();
    // یا اگر می‌خواهید صفحه مدیر را تست کنید:
    // return const ManagerMainScreen();



    // --- منطق اصلی که موقتا کامنت شده است ---
    final authService = Provider.of<AuthService>(context);

    if (authService.isLoading && authService.token == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (authService.isAuthenticated) {
      if (authService.userRole == 'manager') {
        return const ManagerMainScreen();
      } else {
        return const GuestMainScreen();
      }
    }
    else {
      return const AuthenticationScreen();
    }

  }
}