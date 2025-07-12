import 'package:bookit/core/theme/app_colors.dart';
import 'package:bookit/core/utils/responsive_layout.dart';
import 'package:bookit/features/auth/data/services/auth_service.dart';
import 'package:bookit/features/auth/presentation/widgets/auth_form_wrapper.dart';
import 'package:bookit/features/auth/presentation/widgets/auth_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthService>().addListener(_onAuthStateChanged);
    });
  }

  @override
  void dispose() {
    try {
      context.read<AuthService>().removeListener(_onAuthStateChanged);
    } catch (e) {
      //
    }
    super.dispose();
  }

  void _onAuthStateChanged() {
    if (!mounted) return;

    final authService = context.read<AuthService>();
    if (authService.isAuthenticated) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AuthWrapper()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: ResponsiveLayout(
        mobileBody: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
              child: _buildTopText(theme),
            ),
            Expanded(
              child: Stack(
                children: [
                  _buildMobileBackground(context),
                  Center(
                    child: SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 450),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.0),
                          child: AuthFormWrapper(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        desktopBody: Row(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text.rich(
                                TextSpan(
                                  text: 'تا وقتی ',
                                  style: theme.textTheme.titleLarge
                                      ?.copyWith(color: theme.textTheme.bodyLarge?.color),
                                  children: [
                                    TextSpan(
                                        text: 'بوکیت ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            color: theme.colorScheme.primary)),
                                    const TextSpan(text: 'هست'),
                                  ],
                                ),
                                textDirection: TextDirection.rtl,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20,),
                          Text(
                            'کجا بمونم سوال نیست!',
                            textDirection: TextDirection.rtl,
                            style: theme.textTheme.titleLarge
                                ?.copyWith(color: theme.textTheme.bodyLarge?.color),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'پلتفرم جامع رزرواسیون هتل',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(color: theme.colorScheme.primary.withOpacity(0.7)),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  _buildDesktopBackground(context),
                  Center(
                    child: SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 450),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.0),
                          child: AuthFormWrapper(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopText(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text.rich(
          TextSpan(
            text: 'تا وقتی ',
            style: theme.textTheme.titleMedium
                ?.copyWith(color: theme.textTheme.bodyLarge?.color),
            children: [
              TextSpan(
                  text: 'بوکیت ',
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.primary)),
              const TextSpan(text: 'هست'),
            ],
          ),
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(width: 20,),
        Text(
          'کجا بمونم سوال نیست!',
          textDirection: TextDirection.rtl,
          style: theme.textTheme.titleMedium
              ?.copyWith(color: theme.textTheme.bodyLarge?.color),
        ),
      ],
    );
  }

  Widget _buildMobileBackground(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: size.height * 0.45,
        width: size.width,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius:
          const BorderRadius.vertical(top: Radius.elliptical(200, 50)),
        ),
      ),
    );
  }

  Widget _buildDesktopBackground(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        height: size.height,
        width: size.width * 0.8,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: const BorderRadius.horizontal(
              right: Radius.elliptical(80, 300)),
        ),
      ),
    );
  }
}