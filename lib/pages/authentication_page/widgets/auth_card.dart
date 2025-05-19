import 'package:flutter/material.dart';
import '../constants.dart';
import 'auth_tab_bar.dart';
import 'forms/login_form.dart';
import 'forms/manager_signup_form.dart';
import 'forms/guest_signup_form.dart';
import 'forms/otp_form.dart'; // Make sure OtpForm accepts isLoadingResend

class AuthCard extends StatelessWidget {
  // State Variables passed down
  final int selectedTab;
  final bool isLoginAsManager;
  final ValueChanged<bool?> onLoginUserTypeBoolChanged;
  final bool otpSend;
  final String otpTabLabel;
  final bool isChecked; // For terms checkbox
  final bool isLoading; // For main action button
  final bool isLoadingResendOtp; // <<< NEW: For OTP resend button

  // Controllers passed down
  final TextEditingController loginUsernameController;
  final TextEditingController loginPasswordController;
  final TextEditingController managerUsernameController;
  final TextEditingController managerNameController;
  final TextEditingController managerLastNameController;
  final TextEditingController managerNationalIdController;
  final TextEditingController managerHotelNameController;
  final TextEditingController managerPasswordController;
  final TextEditingController managerConfirmPasswordController;
  final TextEditingController guestNameController;
  final TextEditingController guestLastNameController;
  final TextEditingController guestEmailController;
  final TextEditingController guestPasswordController;
  final TextEditingController guestConfirmPasswordController;
  final TextEditingController otp1Controller;
  final TextEditingController otp2Controller;
  final TextEditingController otp3Controller;
  final TextEditingController otp4Controller;

  // Callbacks passed down
  final ValueChanged<int> onTabChanged;
  final ValueChanged<bool?> onTermsChanged;
  final VoidCallback onLoginPressed;
  final VoidCallback onForgotPasswordPressed;
  final VoidCallback onContinuePressed; // For Manager/Guest signup initial step
  final VoidCallback onSignupSubmitPressed; // For final OTP submission
  final VoidCallback onResendOtpPressed;

  const AuthCard({
    super.key,
    required this.selectedTab,
    required this.isLoginAsManager,
    required this.onLoginUserTypeBoolChanged,
    required this.otpSend,
    required this.otpTabLabel,
    required this.isChecked,
    required this.isLoading,
    required this.isLoadingResendOtp, // <<< NEW
    required this.loginUsernameController,
    required this.loginPasswordController,
    required this.managerUsernameController,
    required this.managerNameController,
    required this.managerLastNameController,
    required this.managerNationalIdController,
    required this.managerHotelNameController,
    required this.managerPasswordController,
    required this.managerConfirmPasswordController,
    required this.guestNameController,
    required this.guestLastNameController,
    required this.guestEmailController,
    required this.guestPasswordController,
    required this.guestConfirmPasswordController,
    required this.otp1Controller,
    required this.otp2Controller,
    required this.otp3Controller,
    required this.otp4Controller,
    required this.onTabChanged,
    required this.onTermsChanged,
    required this.onLoginPressed,
    required this.onForgotPasswordPressed,
    required this.onContinuePressed,
    required this.onSignupSubmitPressed,
    required this.onResendOtpPressed,
  });

  @override
  Widget build(BuildContext context) {
    final Color cardBackgroundColor = getSecondaryColor(selectedTab);
    final Color primaryTextColor = getPrimaryTextColorInsideCard(selectedTab);
    final Color buttonBackgroundColor = getPrimaryColor(selectedTab);
    final Color buttonTextColor = getSecondaryTextColorForButton(selectedTab);

    String buttonText = '';
    VoidCallback? buttonAction;
    Widget formContent;

    if (otpSend && (selectedTab == 1 || selectedTab == 2)) {
      // OTP Stage for Manager or Guest Signup
      buttonText = 'تایید و ثبت نام'; // Or "تایید کد" or similar
      buttonAction = onSignupSubmitPressed; // Final signup action (verify OTP)
      formContent = OtpForm(
        otpLabel: otpTabLabel,
        otp1Controller: otp1Controller,
        otp2Controller: otp2Controller,
        otp3Controller: otp3Controller,
        otp4Controller: otp4Controller,
        onResendOtp: onResendOtpPressed,
        textColor: primaryTextColor,
        isLoadingResend: isLoadingResendOtp, // <<< Pass specific loading state for resend
      );
    } else {
      // Initial Login or Signup Stage
      switch (selectedTab) {
        case 0: // Login
          buttonText = 'ورود';
          buttonAction = onLoginPressed;
          formContent = LoginForm(
            isManager: isLoginAsManager,
            onUserTypeChanged: (bool? val) {
              onLoginUserTypeBoolChanged(val);
            },
            usernameController: loginUsernameController,
            passwordController: loginPasswordController,
            onForgotPassword: onForgotPasswordPressed,
            textColor: primaryTextColor,
          );
          break;
        case 1: // Manager Signup (Initial)
          buttonText = 'ادامه'; // This button now triggers initial registration and then OTP request
          buttonAction = onContinuePressed;
          formContent = ManagerSignupForm(
            emailController: managerUsernameController,
            nameController: managerNameController,
            lastNameController: managerLastNameController,
            nationalIdController: managerNationalIdController,
            hotelNameController: managerHotelNameController,
            passwordController: managerPasswordController,
            confirmPasswordController: managerConfirmPasswordController,
            isChecked: isChecked,
            onTermsChanged: onTermsChanged,
            textColor: primaryTextColor,
            selectedTab: selectedTab,
          );
          break;
        case 2: // Guest Signup (Initial)
          buttonText = 'ادامه'; // This button now triggers initial registration and then OTP request
          buttonAction = onContinuePressed;
          formContent = GuestSignupForm(
            nameController: guestNameController,
            lastNameController: guestLastNameController,
            emailController: guestEmailController,
            passwordController: guestPasswordController,
            confirmPasswordController: guestConfirmPasswordController,
            isChecked: isChecked,
            onTermsChanged: onTermsChanged,
            textColor: primaryTextColor,
            selectedTab: selectedTab,
          );
          break;
        default: // Should not happen
          formContent = const Text('خطای داخلی');
          buttonText = 'خطا';
          buttonAction = null;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AuthTabBar(
            selectedTab: selectedTab,
            onTabChanged: onTabChanged,
          ),
          const SizedBox(height: 24),
          formContent, // Display the relevant form widget
          const SizedBox(height: 20),
          SizedBox( // Action Button
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonBackgroundColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(45)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 3,
              ),
              onPressed: isLoading ? null : buttonAction, // Main button uses 'isLoading'
              child: isLoading // Main button uses 'isLoading'
                  ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: buttonTextColor,
                  strokeWidth: 2.0,
                ),
              )
                  : Text(
                buttonText,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: buttonTextColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}