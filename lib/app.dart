import 'package:bookit/core/theme/app_theme.dart';
import 'package:bookit/pages/splash_screen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // <--- این خط اضافه شد

class BookitApp extends StatelessWidget {
  const BookitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'بوکیت',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      locale: const Locale('fa', 'IR'),
      supportedLocales: const [
        Locale('fa', 'IR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SplashScreen(),
    );
  }
}