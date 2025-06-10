import 'package:flutter/material.dart';

const double kFieldBorderRadius = 45.0;
const Color kCursorColor = Color(0xFF542545);
const double kFieldHeight = 48.0;
const EdgeInsets kFieldContentPadding = EdgeInsets.symmetric(horizontal: 18, vertical: 14);

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType inputType;
  final Color textColor;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.inputType = TextInputType.text,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6, right: 4),
          child: Text(
            label,
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: textColor),
          ),
        ),
        SizedBox(
          height: kFieldHeight,
          child: TextField(
            controller: controller,
            keyboardType: inputType,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: const TextStyle(color: Colors.black, fontSize: 14),
            cursorColor: kCursorColor,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(kFieldBorderRadius),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(kFieldBorderRadius),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(kFieldBorderRadius),
                borderSide: BorderSide.none,
              ),
              contentPadding: kFieldContentPadding,
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }
}

class CustomPasswordField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final Color textColor;

  const CustomPasswordField({
    super.key,
    required this.label,
    required this.controller,
    required this.textColor,
  });

  @override
  State<CustomPasswordField> createState() => _CustomPasswordFieldState();
}

class _CustomPasswordFieldState extends State<CustomPasswordField> {
  bool _isObscured = true;

  void _toggleVisibility() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6, right: 4),
          child: Text(
            widget.label,
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: widget.textColor),
          ),
        ),
        SizedBox(
          height: kFieldHeight,
          child: TextField(
            controller: widget.controller,
            obscureText: _isObscured,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: const TextStyle(color: Colors.black, fontSize: 14),
            cursorColor: kCursorColor,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(kFieldBorderRadius),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(kFieldBorderRadius),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(kFieldBorderRadius),
                borderSide: BorderSide.none,
              ),
              contentPadding: kFieldContentPadding,
              isDense: true,
              prefixIcon: IconButton(
                icon: Icon(
                  _isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: Colors.grey.shade600,
                ),
                onPressed: _toggleVisibility,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class TermsAndConditionsCheckbox extends StatelessWidget {
  final bool isChecked;
  final ValueChanged<bool?> onChanged;
  final Color textColor;
  final Color checkColor;
  final Color activeColor;

  const TermsAndConditionsCheckbox({
    super.key,
    required this.isChecked,
    required this.onChanged,
    required this.textColor,
    required this.checkColor,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: Text(
            'قوانین و مقررات اپلیکیشن را می‌پذیرم.',
            textDirection: TextDirection.rtl,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: textColor),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(
          width: 40,
          height: 40,
          child: Checkbox(
            value: isChecked,
            onChanged: onChanged,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            activeColor: activeColor,
            checkColor: checkColor,
            side: MaterialStateBorderSide.resolveWith(
                  (states) => BorderSide(width: 1.5, color: textColor),
            ),
            fillColor: MaterialStateProperty.resolveWith<Color>((states) {
              if (states.contains(MaterialState.selected)) {
                return activeColor;
              }
              return Colors.white;
            }),
            materialTapTargetSize: MaterialTapTargetSize.padded,
          ),
        ),
      ],
    );
  }
}