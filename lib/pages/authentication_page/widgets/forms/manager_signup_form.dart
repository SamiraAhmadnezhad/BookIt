import 'package:flutter/material.dart';
import '../reusable_form_fields.dart';
import '../../constants.dart';

class ManagerSignupForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController nameController;
  final TextEditingController lastNameController;
  final TextEditingController nationalIdController;
  final TextEditingController hotelNameController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool isChecked;
  final ValueChanged<bool?> onTermsChanged;
  final Color textColor;
  final int selectedTab;

  static const double _approximateRowHeight = 50.0;
  static const int _visibleFieldsCount = 5;
  static const double _scrollbarThickness = 4.0;
  static const double _contentHorizontalPadding = 12.0;

  const ManagerSignupForm({
    super.key,
    required this.emailController,
    required this.nameController,
    required this.lastNameController,
    required this.nationalIdController,
    required this.hotelNameController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.isChecked,
    required this.onTermsChanged,
    required this.textColor,
    required this.selectedTab,
  });

  @override
  Widget build(BuildContext context) {
    const double checkboxAreaHeight = 12.0 + 40.0 + 10.0;
    final double scrollableAreaMaxHeight = (_visibleFieldsCount * _approximateRowHeight) + checkboxAreaHeight;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: scrollableAreaMaxHeight,
      ),
      child: Scrollbar(
        thumbVisibility: true,
        thickness: _scrollbarThickness, // <--- استفاده از ضخامت جدید
        radius: const Radius.circular(_scrollbarThickness / 2), // شعاع گردی متناسب با ضخامت
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
              _contentHorizontalPadding, // فاصله از چپ
              0,
              _contentHorizontalPadding, // فاصله از راست
              8
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(label: 'ایمیل', controller: emailController, textColor: textColor),
              const SizedBox(height: 12),
              CustomTextField(label: 'نام', controller: nameController, textColor: textColor),
              const SizedBox(height: 12),
              CustomTextField(label: 'نام خانوادگی', controller: lastNameController, textColor: textColor),
              const SizedBox(height: 12),
              CustomTextField(label: 'کد ملی', controller: nationalIdController, inputType: TextInputType.number, textColor: textColor),
              const SizedBox(height: 12),
              CustomPasswordField(label: 'رمز عبور', controller: passwordController, textColor: textColor),
              const SizedBox(height: 12),
              CustomPasswordField(label: 'تکرار رمزعبور', controller: confirmPasswordController, textColor: textColor),
              const SizedBox(height: 10),
              TermsAndConditionsCheckbox(
                isChecked: isChecked,
                onChanged: onTermsChanged,
                textColor: textColor,
                checkColor: getSecondaryColor(selectedTab),
                activeColor: getPrimaryColor(selectedTab),
              ),
            ],
          ),
        ),
      ),
    );
  }
}