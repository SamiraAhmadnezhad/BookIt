import 'package:flutter/material.dart';
import '../constants.dart';
import 'auth_tab_bar.dart';
import 'forms/login_form.dart';
import 'forms/manager_signup_form.dart';
import 'forms/guest_signup_form.dart';
import 'forms/otp_form.dart';

class AuthCard extends StatelessWidget {
  final int selectedTab;
  final bool isLoginAsManager;
  final ValueChanged<bool?> onLoginUserTypeBoolChanged;
  final bool otpSend;
  final String otpTabLabel;
  final bool isChecked;
  final bool isLoading;
  final bool isLoadingResendOtp;

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

  final ValueChanged<int> onTabChanged;
  final ValueChanged<bool?> onTermsChanged;
  final VoidCallback onLoginPressed;
  final VoidCallback onForgotPasswordPressed;
  final VoidCallback onContinuePressed;
  final VoidCallback onSignupSubmitPressed;
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
    required this.isLoadingResendOtp,
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
    const double formContentHeight = 330.0;

    String buttonText = '';
    VoidCallback? buttonAction;
    Widget formContent;

    if (otpSend && (selectedTab == 1 || selectedTab == 2)) {
      buttonText = 'تایید و ثبت نام';
      buttonAction = onSignupSubmitPressed;
      formContent = OtpForm(
        otpLabel: otpTabLabel,
        otp1Controller: otp1Controller,
        otp2Controller: otp2Controller,
        otp3Controller: otp3Controller,
        otp4Controller: otp4Controller,
        onResendOtp: onResendOtpPressed,
        textColor: primaryTextColor,
        isLoadingResend: isLoadingResendOtp,
      );
    } else {
      switch (selectedTab) {
        case 0:
          buttonText = 'ورود';
          buttonAction = onLoginPressed;
          formContent = LoginForm(
            isManager: isLoginAsManager,
            onUserTypeChanged: onLoginUserTypeBoolChanged,
            usernameController: loginUsernameController,
            passwordController: loginPasswordController,
            onForgotPassword: onForgotPasswordPressed,
            textColor: primaryTextColor,
          );
          break;
        case 1:
          buttonText = 'ادامه';
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
            formHeight: formContentHeight,
          );
          break;
        case 2:
          buttonText = 'ادامه';
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
            formHeight: formContentHeight,
          );
          break;
        default:
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
          SizedBox(
            height: formContentHeight,
            child: formContent,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonBackgroundColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(45)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 3,
              ),
              onPressed: isLoading ? null : buttonAction,
              child: isLoading
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