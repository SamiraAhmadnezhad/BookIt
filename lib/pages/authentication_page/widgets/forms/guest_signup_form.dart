import 'package:flutter/material.dart';
import '../reusable_form_fields.dart';
import '../../constants.dart'; // To get colors for checkbox

class GuestSignupForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool isChecked;
  final ValueChanged<bool?> onTermsChanged;
  final Color textColor;
  final int selectedTab; // Needed to determine checkbox colors

  const GuestSignupForm({
    super.key,
    required this.nameController,
    required this.lastNameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.isChecked,
    required this.onTermsChanged,
    required this.textColor,
    required this.selectedTab,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(label: 'ایمیل', controller: emailController, inputType: TextInputType.emailAddress, textColor: textColor),
        const SizedBox(height: 12),
        CustomTextField(label: 'نام', controller: nameController, textColor: textColor),
        const SizedBox(height: 12),
        CustomTextField(label: 'نام خانوادگی', controller: lastNameController, textColor: textColor),
        const SizedBox(height: 12),
        CustomPasswordField(label: 'رمز عبور', controller: passwordController, textColor: textColor),
        const SizedBox(height: 12),
        CustomPasswordField(label: 'تکرار رمزعبور', controller: confirmPasswordController, textColor: textColor),
        const SizedBox(height: 10),
        TermsAndConditionsCheckbox(
          isChecked: isChecked,
          onChanged: onTermsChanged,
          textColor: textColor,
          // Checkbox colors depend on the main theme (signup theme)
          checkColor: getSecondaryColor(selectedTab), // Checkmark uses the background color of the card
          activeColor: getPrimaryColor(selectedTab), // Box uses the contrasting color
        ),
      ],
    );
  }
}