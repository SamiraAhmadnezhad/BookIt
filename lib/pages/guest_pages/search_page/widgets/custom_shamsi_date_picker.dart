import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:shamsi_date/shamsi_date.dart'; // Import for Jalali date

// --- Date Picker Dialog (Provided Code - Minimal Changes) ---
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
    barrierDismissible: false, // As per original
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: _ShamsiDatePickerContent(
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
        titleText: titleText, // Pass the title
      ),
    ),
  );
}

class _ShamsiDatePickerContent extends StatefulWidget {
  final Jalali initialDate;
  final Jalali firstDate;
  final Jalali? lastDate;
  final String? titleText; // Keep this for context

  const _ShamsiDatePickerContent({
    required this.initialDate,
    required this.firstDate,
    this.lastDate,
    this.titleText, // Initialize it
  });

  @override
  State<_ShamsiDatePickerContent> createState() =>
      _ShamsiDatePickerContentState();
}

class _ShamsiDatePickerContentState extends State<_ShamsiDatePickerContent> {
  late Jalali _displayedMonth;
  Jalali? _selectedDate;

  static const List<String> _weekDays = [
    "ش", "ی", "د", "س", "چ", "پ", "ج"
  ];
  // static const List<String> _fullWeekDays = [ // Not used in original
  //   "شنبه", "یکشنبه", "دوشنبه", "سه‌شنبه", "چهارشنبه", "پنجشنبه", "جمعه"
  // ];

  @override
  void initState() {
    super.initState();
    _displayedMonth = Jalali(
      widget.initialDate.year,
      widget.initialDate.month,
      1, // As per original
    );
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

  bool _isBeforeFirst(Jalali d) =>
      d.compareTo(widget.firstDate) < 0;

  bool _isAfterLast(Jalali d) =>
      widget.lastDate != null && d.compareTo(widget.lastDate!) > 0;

  @override
  Widget build(BuildContext context) {
    final title =
        "${_displayedMonth.formatter.mN} ${_displayedMonth.year}";
    // محاسبه روز هفته اولین روز ماه برای تنظیم offset
    final firstWeekday = _displayedMonth.weekDay; // 1 = شنبه
    final monthLength = _displayedMonth.monthLength;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // --- START: Added Title Display ---
          if (widget.titleText != null) ...[
            Text(
              widget.titleText!,
              style: TextStyle(
                fontFamily: 'Vazirmatn', // Or your app's font
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black, // Use a consistent color
              ),
            ),
            const SizedBox(height: 12),
          ],
          // --- END: Added Title Display ---
          // هدر: ماه و ناوبری
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  icon: Icon(Icons.chevron_left, color: Color(0xFF542545)),
                  onPressed: _prevMonth),
              Text(title,
                  style: TextStyle(
                    fontFamily: 'Vazirmatn', // Or your app's font
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  )),
              IconButton(
                  icon: Icon(Icons.chevron_right, color: Color(0xFF542545)),
                  onPressed: _nextMonth),
            ],
          ),

          const SizedBox(height: 8),

          // روزهای هفته
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _weekDays
                .map((d) => Text(d,
                style: TextStyle(fontWeight: FontWeight.w600)))
                .toList(),
          ),

          const SizedBox(height: 4),

          // شبکه روزها
          Flexible(
            child: GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
              // Original calculation for itemCount for RTL (Saturday as first day of week)
              // The (firstWeekday -1) is how many empty cells to put at the start.
              // monthLength is the number of actual day cells.
              itemCount: monthLength + (firstWeekday - 1),
              itemBuilder: (_, idx) {
                // Original calculation for dayIdx
                // If firstWeekday is 1 (Saturday), then for idx=0, dayIdx = 0 - (1-1) = 0
                // To get day number (1-based), we use dayIdx + 1, but we need to map the index to calendar day.
                // Let's stick to your original logic as much as possible for this part
                // original was: final dayIdx = idx - (firstWeekday - 2);
                // This seemed to assume Sunday was 1. If shamsi_date.weekDay has Saturday = 1, then:
                // firstWeekday = 1 (Sat), 2 (Sun), ..., 7 (Fri)
                // Empty cells needed before the first day: firstWeekday - 1
                // Example: if first day is Wednesday (firstWeekday = 4), we need 3 empty cells.
                // idx for first day = firstWeekday - 1
                // day number = idx - (firstWeekday - 1) + 1

                final dayOffset = firstWeekday -1; // Number of empty cells at the start
                if (idx < dayOffset) {
                  return SizedBox(); // خانه خالی برای offset
                }
                final dayNumber = idx - dayOffset + 1; // 1-based day number
                if (dayNumber > monthLength) {
                  return SizedBox(); // خانه خالی بعد از پایان ماه
                }

                final d = Jalali(_displayedMonth.year, _displayedMonth.month, dayNumber);
                final disabled = _isBeforeFirst(d) || _isAfterLast(d);
                final selected = _selectedDate != null &&
                    _selectedDate!.compareTo(d) == 0;

                return GestureDetector(
                  onTap: disabled
                      ? null
                      : () {
                    setState(() {
                      _selectedDate = d;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.all(4),
                    decoration: selected
                        ? BoxDecoration(
                        color: Color(0xFF542545),
                        shape: BoxShape.circle)
                        : null,
                    alignment: Alignment.center,
                    child: Text(
                      "$dayNumber", // Use dayNumber
                      style: TextStyle(
                        fontFamily: 'Vazirmatn', // Or your app's font
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
                child: Text("بیخیال", style: TextStyle(fontFamily: 'Vazirmatn',color: Color(0xFF542545))), // Or your app's font
                onPressed: () => Navigator.of(context).pop(null),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF542545)), // Match button style
                child: Text("انتخاب", style: TextStyle(fontFamily: 'Vazirmatn',color: Colors.white)), // Or your app's font
                onPressed: _selectedDate == null
                    ? null
                    : () => Navigator.of(context).pop(_selectedDate),
              ),
            ],
          ),
        ],
      ),
    );
  }
}