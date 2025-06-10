import 'dart:async';
import 'package:bookit/pages/authentication_page/authentication_page.dart';
import 'package:bookit/pages/guest_pages/guest_main_screen.dart';
import 'package:bookit/pages/manger_pages/manager_main_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../authentication_page/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // تایمر برای نمایش اسپلش به مدت 3 ثانیه
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        // پس از 3 ثانیه، به صفحه تصمیم‌گیرنده منتقل شو
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
            // لوگوی "بوکیت"
            Text.rich(
              TextSpan(
                text: 'بوکیت',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: primaryColor,
                ),
                children: [
                  TextSpan(
                    text: '.',
                    style: TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.w900,
                      color: primaryColor.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 120),
            // انیمیشن بارگذاری
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

// این ویجت خصوصی، منطق Consumer را از main.dart به اینجا منتقل می‌کند
class _AuthWrapper extends StatelessWidget {
  const _AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // از Consumer برای بررسی وضعیت لاگین استفاده می‌کنیم
    final authService = Provider.of<AuthService>(context);

    // اگر در حال بارگذاری اولیه است، یک لودر ساده نشان بده
    // این حالت خیلی سریع رد می‌شود چون اسپلش 3 ثانیه فرصت داده است.
    if (authService.isLoading && authService.token == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // اگر کاربر لاگین است
    if (authService.isAuthenticated) {
      if (authService.userRole == 'manager') {
        return const ManagerMainScreen();
      } else {
        return const GuestMainScreen();
      }
    }
    // اگر کاربر لاگین نیست
    else {
      return const AuthenticationPage();
    }
  }
}