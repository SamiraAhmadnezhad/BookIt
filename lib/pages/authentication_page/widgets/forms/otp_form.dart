import 'package:flutter/material.dart';
import '../../otp_fields.dart'; // Assuming OtpFields is in the parent directory of 'forms'

class OtpForm extends StatelessWidget {
  final String otpLabel;
  final TextEditingController otp1Controller;
  final TextEditingController otp2Controller;
  final TextEditingController otp3Controller;
  final TextEditingController otp4Controller;
  final VoidCallback onResendOtp;
  final Color textColor;
  final bool isLoadingResend; // <<< NEW: To show loading indicator on resend button

  const OtpForm({
    super.key,
    required this.otpLabel,
    required this.otp1Controller,
    required this.otp2Controller,
    required this.otp3Controller,
    required this.otp4Controller,
    required this.onResendOtp,
    required this.textColor,
    required this.isLoadingResend, // <<< NEW
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
            textAlign: TextAlign.center, // Added for better centering if label is long
          ),
        ),
        const SizedBox(height: 20),
        Text(
          "کد ارسال شده را وارد کنید:",
          textDirection: TextDirection.rtl,
          style: TextStyle(fontSize: 12, color: textColor),
        ),
        const SizedBox(height: 15),
        OtpFields(
          otp1Controller: otp1Controller,
          otp2Controller: otp2Controller,
          otp3Controller: otp3Controller,
          otp4Controller: otp4Controller,
          // اگر OtpFields شما پارامتر رنگ می‌پذیرد، می‌توانید آن را پاس دهید:
          // fieldBackgroundColor: Colors.white.withOpacity(0.1),
          // borderColor: textColor.withOpacity(0.5),
          // textColor: textColor,
        ),
        const SizedBox(height: 25), // Increased spacing
        InkWell(
          onTap: isLoadingResend ? null : onResendOtp, // Disable tap when loading
          borderRadius: BorderRadius.circular(8), // For better tap feedback
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0), // Add padding for larger tap area
            child: isLoadingResend
                ? SizedBox(
              height: 16, // Consistent height with text
              width: 16,  // Consistent width with text
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                color: textColor, // Or a specific color for the loader
              ),
            )
                : Text(
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
        ),
      ],
    );
  }
}