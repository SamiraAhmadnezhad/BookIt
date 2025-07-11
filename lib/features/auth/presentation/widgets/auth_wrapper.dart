import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../guest/presentation/pages/guest_main_wrapper.dart';
import '../../../manager/presentation/pages/manager_main_wrapper.dart';
import '../../data/services/auth_service.dart';
import '../pages/authentication_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    if (authService.isLoading && authService.token == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (authService.isAuthenticated) {
      if (authService.userRole == 'manager') {
        return const ManagerMainWrapper();
      } else {
        return const GuestMainWrapper();
      }
    } else {
      return const AuthenticationScreen();
    }
  }
}