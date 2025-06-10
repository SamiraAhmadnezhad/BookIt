import 'package:flutter/material.dart';
import '../reusable_form_fields.dart';
import '../../constants.dart';

class GuestSignupForm extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool isChecked;
  final ValueChanged<bool?> onTermsChanged;
  final Color textColor;
  final int selectedTab;
  final double formHeight;

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
    required this.formHeight,
  });

  @override
  State<GuestSignupForm> createState() => _GuestSignupFormState();
}

class _GuestSignupFormState extends State<GuestSignupForm> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double scrollbarThickness = 4.0;
    const double contentHorizontalPadding = 12.0;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: widget.formHeight),
      child: Scrollbar(
        controller: _scrollController, // <--- اتصال کنترلر به اسکرول بار
        thumbVisibility: true,
        thickness: scrollbarThickness,
        radius: const Radius.circular(scrollbarThickness / 2),
        child: SingleChildScrollView(
          controller: _scrollController, // <--- اتصال همان کنترلر به ویجت اسکرول
          padding: const EdgeInsets.fromLTRB(
            contentHorizontalPadding,
            0,
            contentHorizontalPadding,
            8,
          ),
          child: Column(
            children: [
              CustomTextField(label: 'ایمیل', controller: widget.emailController, inputType: TextInputType.emailAddress, textColor: widget.textColor),
              const SizedBox(height: 12),
              CustomTextField(label: 'نام', controller: widget.nameController, textColor: widget.textColor),
              const SizedBox(height: 12),
              CustomTextField(label: 'نام خانوادگی', controller: widget.lastNameController, textColor: widget.textColor),
              const SizedBox(height: 12),
              CustomPasswordField(label: 'رمز عبور', controller: widget.passwordController, textColor: widget.textColor),
              const SizedBox(height: 12),
              CustomPasswordField(label: 'تکرار رمزعبور', controller: widget.confirmPasswordController, textColor: widget.textColor),
              const SizedBox(height: 10),
              TermsAndConditionsCheckbox(
                isChecked: widget.isChecked,
                onChanged: widget.onTermsChanged,
                textColor: widget.textColor,
                checkColor: getSecondaryColor(widget.selectedTab),
                activeColor: getPrimaryColor(widget.selectedTab),
              ),
            ],
          ),
        ),
      ),
    );
  }
}