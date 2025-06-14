import 'package:bookit/pages/authentication_page/auth_service.dart';
import 'package:bookit/pages/splash_screen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bookit App',
      theme: ThemeData(
        fontFamily: 'Vazirmatn',
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}