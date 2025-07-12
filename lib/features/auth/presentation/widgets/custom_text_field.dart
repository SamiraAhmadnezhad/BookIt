import 'package:bookit/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final TextInputType keyboardType;
  final bool isPassword;
  final bool enableVisibilityToggle;
  final FormFieldValidator<String>? validator;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.enableVisibilityToggle = false,
    this.validator,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: _isObscured,
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.right,
      cursorColor: AppColors.primary,
      style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.black),
      validator: widget.validator,
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle:
        theme.textTheme.bodyMedium?.copyWith(color: AppColors.darkGrey),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        suffixIcon: widget.enableVisibilityToggle
            ? IconButton(
            icon: Icon(
              _isObscured
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.darkGrey,
            ),
            onPressed: () => setState(() => _isObscured = !_isObscured))
            : null,
      ),
    );
  }
}