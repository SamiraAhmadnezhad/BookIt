import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileBody;
  final Widget? desktopBody;

  const ResponsiveLayout({
    super.key,
    required this.mobileBody,
    this.desktopBody,
  });

  static const double desktopBreakpoint = 1000.0;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktopBreakpoint;

  @override
  Widget build(BuildContext context) {
    if (isDesktop(context) && desktopBody != null) {
      return desktopBody!;
    } else {
      return mobileBody;
    }
  }
}