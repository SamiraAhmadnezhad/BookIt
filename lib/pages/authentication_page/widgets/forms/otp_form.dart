import 'package:flutter/material.dart';
import '../../otp_fields.dart'; // Assuming OtpFields is in the parent directory

class OtpForm extends StatelessWidget {
  final String otpLabel;
  final TextEditingController otp1Controller;
  final TextEditingController otp2Controller;
  final TextEditingController otp3Controller;
  final TextEditingController otp4Controller;
  final VoidCallback onResendOtp;
  final Color textColor;

  const OtpForm({
    super.key,
    required this.otpLabel,
    required this.otp1Controller,
    required this.otp2Controller,
    required this.otp3Controller,
    required this.otp4Controller,
    required this.onResendOtp,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.center,
          child: Text(
            otpLabel,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textColor),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          "کد ارسال شده را وارد کنید:",
          textDirection: TextDirection.rtl,
          style: TextStyle(fontSize: 12, color: textColor),
        ),
        const SizedBox(height: 15),
        // Assuming OtpFields handles its own internal styling or you pass colors to it
        OtpFields(
          otp1Controller: otp1Controller,
          otp2Controller: otp2Controller,
          otp3Controller: otp3Controller,
          otp4Controller: otp4Controller,
          // Pass text color if OtpFields accepts it:
          // textColor: textColor,
        ),
        const SizedBox(height: 20),
        InkWell(
          onTap: onResendOtp,
          child: Text(
            "ارسال مجدد کد",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: textColor,
              decoration: TextDecoration.underline,
              decorationColor: textColor,
            ),
          ),
        ),
      ],
    );
  }
}