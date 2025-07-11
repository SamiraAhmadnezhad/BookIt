
import 'package:bookit/features/auth/data/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fa_IR', null);
  await initializeDateFormatting('en_US', null);

  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthService(),
      child: const BookitApp(),
    ),
  );
}