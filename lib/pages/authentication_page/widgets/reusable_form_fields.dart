import 'package:flutter/material.dart';

// --- ثابت‌های مربوط به استایل فیلدها ---
const double kFieldBorderRadius = 45.0; // شعاع گردی برای فیلدهای متنی
const Color kCursorColor = Color(0xFF542545);   // رنگ قرمز برای نشانگر نوشتن
const double kFieldHeight = 48.0;       // ارتفاع استاندارد برای فیلدهای متنی
const EdgeInsets kFieldContentPadding = EdgeInsets.symmetric(horizontal: 18, vertical: 14); // Padding داخلی فیلدها (عمودی کمی بیشتر شد)

// --- Custom Text Field ---
class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType inputType;
  final Color textColor; // رنگ متن برای لیبل بالای فیلد

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
            style: const TextStyle(color: Colors.black, fontSize: 14), // رنگ متن داخل فیلد
            cursorColor: kCursorColor, // تنظیم رنگ نشانگر
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white, // رنگ پس‌زمینه فیلد
              border: OutlineInputBorder( // حاشیه پیش‌فرض
                borderRadius: BorderRadius.circular(kFieldBorderRadius),
                borderSide: BorderSide.none, // بدون خط حاشیه
              ),
              enabledBorder: OutlineInputBorder( // حاشیه وقتی فیلد فعال نیست
                borderRadius: BorderRadius.circular(kFieldBorderRadius),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder( // حاشیه وقتی فیلد فوکوس دارد
                borderRadius: BorderRadius.circular(kFieldBorderRadius),
                borderSide: BorderSide.none, // در صورت تمایل: BorderSide(color: kCursorColor.withOpacity(0.5), width: 1.5)
              ),
              contentPadding: kFieldContentPadding,
              isDense: true, // برای کاهش ارتفاع پیش‌فرض و استفاده از contentPadding
            ),
          ),
        ),
      ],
    );
  }
}

// --- Custom Password Field ---
class CustomPasswordField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final Color textColor; // رنگ متن برای لیبل بالای فیلد

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
            style: const TextStyle(color: Colors.black, fontSize: 14), // رنگ متن داخل فیلد
            cursorColor: kCursorColor, // تنظیم رنگ نشانگر
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
                borderSide: BorderSide.none, // در صورت تمایل: BorderSide(color: kCursorColor.withOpacity(0.5), width: 1.5)
              ),
              contentPadding: kFieldContentPadding,
              isDense: true,
              prefixIcon: IconButton( // آیکون نمایش/عدم نمایش رمز عبور
                icon: Icon(
                  _isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: Colors.grey.shade600, // رنگ آیکون
                ),
                onPressed: _toggleVisibility,
                padding: EdgeInsets.zero, // حذف padding اضافی دور آیکون
                constraints: const BoxConstraints(), // حذف محدودیت‌های اندازه پیش‌فرض آیکون
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// --- Terms and Conditions Checkbox ---
// (این ویجت بدون تغییر نسبت به درخواست‌های اخیر شما باقی می‌ماند)
class TermsAndConditionsCheckbox extends StatelessWidget {
  final bool isChecked;
  final ValueChanged<bool?> onChanged;
  final Color textColor; // رنگ متن برای لیبل کنار چک‌باکس
  final Color checkColor; // رنگ خود علامت تیک
  final Color activeColor; // رنگ پس‌زمینه چک‌باکس وقتی فعال است

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
      mainAxisAlignment: MainAxisAlignment.end, // هم‌راستایی به راست
      children: [
        Flexible( // برای اینکه متن اگر طولانی بود، به خط بعدی برود
          child: Text(
            'قوانین و مقررات اپلیکیشن را می‌پذیرم.',
            textDirection: TextDirection.rtl,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: textColor),
            overflow: TextOverflow.ellipsis, // نمایش ... اگر متن خیلی طولانی باشد
          ),
        ),
        SizedBox( // برای کنترل اندازه و padding چک‌باکس
          width: 40,
          height: 40,
          child: Checkbox(
            value: isChecked,
            onChanged: onChanged,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), // شکل چک‌باکس
            activeColor: activeColor,
            checkColor: checkColor,
            side: MaterialStateBorderSide.resolveWith( // حاشیه چک‌باکس
                  (states) => BorderSide(width: 1.5, color: textColor),
            ),
            fillColor: MaterialStateProperty.resolveWith<Color>((states) { // رنگ پر شدن چک‌باکس
              if (states.contains(MaterialState.selected)) {
                return activeColor;
              }
              return Colors.white; // پس‌زمینه سفید وقتی انتخاب نشده
            }),
            materialTapTargetSize: MaterialTapTargetSize.padded, // افزایش محدوده قابل کلیک
          ),
        ),
      ],
    );
  }
}