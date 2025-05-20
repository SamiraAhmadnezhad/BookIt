// main.dart
import 'package:bookit/pages/authentication_page/auth_service.dart';
import 'package:bookit/pages/authentication_page/authentication_page.dart';
import 'package:bookit/pages/guest_pages/guest_main_screen.dart';
import 'package:bookit/pages/manger_pages/hotel_info_page/add_hotel_info.dart';
import 'package:bookit/pages/guest_pages/hotel_detail_page/hotel_detail_page.dart';
import 'package:bookit/pages/manger_pages/manager_main_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'manager_pages/manager_main_screen.dart'; // اگر صفحه اصلی مدیر دارید

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthService(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bookit App',
      theme: ThemeData(
        // تم برنامه شما
        fontFamily: 'YourAppFont', // اگر فونت دارید
      ),
      home: Consumer<AuthService>(
        builder: (context, authService, _) {
          if (authService.isLoading && authService.token == null) {
            // در حال تلاش برای لاگین خودکار یا اولین بارگذاری
            return SplashScreen(); // یک صفحه اسپلش ساده
          } else if (authService.isAuthenticated) {
            print(authService.userRole);
            // کاربر احراز هویت شده
            if (authService.userRole == 'manager') {
              // return ManagerMainScreen(); // اگر صفحه اصلی مدیر دارید
              return ManagerMainScreen(); // موقتا به همان صفحه اصلی مهمان می‌رود
            } else {
              return GuestMainScreen(); // صفحه اصلی مهمان
            }
          } else {
            // کاربر احراز هویت نشده
            return AuthenticationPage();
          }
        },
      ),
      routes: {
        '/auth': (ctx) => AuthenticationPage(),
        '/main': (ctx) => GuestMainScreen(),
        // مسیرهای دیگر ...
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatelessWidget { // یک صفحه اسپلش ساده
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}