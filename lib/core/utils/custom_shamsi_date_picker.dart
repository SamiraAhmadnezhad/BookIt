// lib/your_path/custom_shamsi_date_picker.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:shamsi_date/shamsi_date.dart';

// ====================== شروع اصلاحیه اصلی ======================
/// فراخوانی این متد برای نمایش دیالوگ و دریافت تاریخ انتخاب‌شده
Future<Jalali?> showCustomShamsiDatePickerDialog(
    BuildContext context, {
      required Jalali initialDate,
      required Jalali firstDate,
      Jalali? lastDate,
      String? titleText, // Optional title for the dialog
    }) {
  return showDialog<Jalali>(
    context: context,
    barrierDismissible: false,
    builder: (_) {
      // 1. دیالوگ را در یک Center قرار می‌دهیم تا در وسط صفحه قرار گیرد.
      return Center(
        // 2. از ConstrainedBox برای تعیین حداکثر عرض استفاده می‌کنیم.
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 400, // حداکثر عرض دیالوگ، مثلا 400 پیکسل.
          ),
          child: Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            // محتوای دیالوگ بدون تغییر باقی می‌ماند.
            child: _ShamsiDatePickerContent(
              initialDate: initialDate,
              firstDate: firstDate,
              lastDate: lastDate,
              titleText: titleText,
            ),
          ),
        ),
      );
    },
  );
}
// ======================= پایان اصلاحیه اصلی =======================

class _ShamsiDatePickerContent extends StatefulWidget {
  final Jalali initialDate;
  final Jalali firstDate;
  final Jalali? lastDate;
  final String? titleText;

  const _ShamsiDatePickerContent({
    required this.initialDate,
    required this.firstDate,
    this.lastDate,
    this.titleText,
  });

  @override
  State<_ShamsiDatePickerContent> createState() =>
      _ShamsiDatePickerContentState();
}

class _ShamsiDatePickerContentState extends State<_ShamsiDatePickerContent> {
  late Jalali _displayedMonth;
  Jalali? _selectedDate;

  static const List<String> _weekDays = ["ش", "ی", "د", "س", "چ", "پ", "ج"];

  @override
  void initState() {
    super.initState();
    _displayedMonth = Jalali(widget.initialDate.year, widget.initialDate.month, 1);
    _selectedDate = widget.initialDate;
  }

  void _prevMonth() {
    setState(() {
      _displayedMonth = _displayedMonth.addMonths(-1);
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth = _displayedMonth.addMonths(1);
    });
  }

  bool _isBeforeFirst(Jalali d) => d.compareTo(widget.firstDate) < 0;
  bool _isAfterLast(Jalali d) => widget.lastDate != null && d.compareTo(widget.lastDate!) > 0;

  @override
  Widget build(BuildContext context) {
    final title = "${_displayedMonth.formatter.mN} ${_displayedMonth.year}";
    final firstWeekday = _displayedMonth.weekDay;
    final monthLength = _displayedMonth.monthLength;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.titleText != null) ...[
            Text(
              widget.titleText!,
              style: const TextStyle(
                fontFamily: 'Vazirmatn',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(icon: const Icon(Icons.chevron_left, color: Color(0xFF542545)), onPressed: _prevMonth),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(icon: const Icon(Icons.chevron_right, color: Color(0xFF542545)), onPressed: _nextMonth),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _weekDays
                .map((d) => Text(d, style: const TextStyle(fontWeight: FontWeight.w600)))
                .toList(),
          ),
          const SizedBox(height: 4),
          Flexible(
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
              itemCount: monthLength + (firstWeekday - 1),
              itemBuilder: (_, idx) {
                final dayOffset = firstWeekday - 1;
                if (idx < dayOffset) {
                  return const SizedBox();
                }
                final dayNumber = idx - dayOffset + 1;
                if (dayNumber > monthLength) {
                  return const SizedBox();
                }
                final d = Jalali(_displayedMonth.year, _displayedMonth.month, dayNumber);
                final disabled = _isBeforeFirst(d) || _isAfterLast(d);
                final selected = _selectedDate != null && _selectedDate!.compareTo(d) == 0;
                return GestureDetector(
                  onTap: disabled ? null : () {
                    setState(() {
                      _selectedDate = d;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: selected
                        ? const BoxDecoration(color: Color(0xFF542545), shape: BoxShape.circle)
                        : null,
                    alignment: Alignment.center,
                    child: Text(
                      "$dayNumber",
                      style: TextStyle(
                        fontFamily: 'Vazirmatn',
                        color: disabled
                            ? Colors.grey.shade400
                            : selected
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                child: const Text("بیخیال", style: TextStyle(fontFamily: 'Vazirmatn', color: Color(0xFF542545))),
                onPressed: () => Navigator.of(context).pop(null),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF542545)),
                child: const Text("انتخاب", style: TextStyle(fontFamily: 'Vazirmatn', color: Colors.white)),
                onPressed: _selectedDate == null ? null : () => Navigator.of(context).pop(_selectedDate),
              ),
            ],
          ),
        ],
      ),
    );
  }
}