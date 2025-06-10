import 'package:flutter/material.dart';
import '../reusable_form_fields.dart';

class LoginForm extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final VoidCallback onForgotPassword;
  final Color textColor;
  final bool isManager;
  final ValueChanged<bool> onUserTypeChanged;

  static const Color _activeSegmentColor = Color(0xFF542545);
  static const Color _inactiveSegmentColor = Colors.white;
  static const Color _activeTextColor = Colors.white;
  static const double _segmentControlHeight = 38.0;
  static const double _segmentControlBorderRadius = 18.0;
  static const double _segmentFontSize = 12.5;

  const LoginForm({
    super.key,
    required this.usernameController,
    required this.passwordController,
    required this.onForgotPassword,
    required this.textColor,
    required this.isManager,
    required this.onUserTypeChanged,
  });

  Widget _buildSegment(
      BuildContext context,
      String text,
      bool isActive,
      VoidCallback onTap,
      {required bool isFirst, required bool isLast}
      ) {
    BorderRadius borderRadius;
    if (isFirst && !isLast) {
      borderRadius = const BorderRadius.only(
        topRight: Radius.circular(_segmentControlBorderRadius),
        bottomRight: Radius.circular(_segmentControlBorderRadius),
        topLeft: Radius.circular(4),
        bottomLeft: Radius.circular(4),
      );
    } else if (isLast && !isFirst) {
      borderRadius = const BorderRadius.only(
        topLeft: Radius.circular(_segmentControlBorderRadius),
        bottomLeft: Radius.circular(_segmentControlBorderRadius),
        topRight: Radius.circular(4),
        bottomRight: Radius.circular(4),
      );
    } else {
      borderRadius = BorderRadius.circular(_segmentControlBorderRadius);
    }

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isActive ? _activeSegmentColor : _inactiveSegmentColor,
            borderRadius: borderRadius,
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isActive ? _activeTextColor : Colors.black,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                fontSize: _segmentFontSize,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Text(
            'ورود به عنوان:',
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 20.0),
          height: _segmentControlHeight,
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              _buildSegment(
                context,
                'مدیر هتل',
                isManager,
                    () => onUserTypeChanged(true),
                isFirst: true,
                isLast: false,
              ),
              const SizedBox(width: 4),
              _buildSegment(
                context,
                'مسافر',
                !isManager,
                    () => onUserTypeChanged(false),
                isFirst: false,
                isLast: true,
              ),
            ],
          ),
        ),
        CustomTextField(
          label: 'ایمیل',
          controller: usernameController,
          textColor: textColor,
        ),
        const SizedBox(height: 12),
        CustomPasswordField(
          label: 'رمز عبور',
          controller: passwordController,
          textColor: textColor,
        ),
        const Spacer(),
        Align(
          alignment: Alignment.centerRight,
          child: InkWell(
            onTap: onForgotPassword,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'رمز عبورت رو فراموش کردی؟',
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                  decoration: TextDecoration.underline,
                  decorationColor: textColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}