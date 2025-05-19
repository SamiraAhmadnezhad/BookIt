import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';

/// فراخوانی این متد برای نمایش دیالوگ و دریافت تاریخ انتخاب‌شده
Future<Jalali?> showCustomShamsiDatePickerDialog(
    BuildContext context, {
      required Jalali initialDate,
      required Jalali firstDate,
      Jalali? lastDate,
    }) {
  return showDialog<Jalali>(
    context: context,
    barrierDismissible: false,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: _ShamsiDatePickerContent(
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
      ),
    ),
  );
}

class _ShamsiDatePickerContent extends StatefulWidget {
  final Jalali initialDate;
  final Jalali firstDate;
  final Jalali? lastDate;

  const _ShamsiDatePickerContent({
    required this.initialDate,
    required this.firstDate,
    this.lastDate,
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
  static const List<String> _fullWeekDays = [
    "شنبه", "یکشنبه", "دوشنبه", "سه‌شنبه", "چهارشنبه", "پنجشنبه", "جمعه"
  ];

  @override
  void initState() {
    super.initState();
    _displayedMonth = Jalali(
      widget.initialDate.year,
      widget.initialDate.month,
      1,
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
          // هدر: ماه و ناوبری
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  icon: Icon(Icons.chevron_left, color: Color(0xFF542545)),
                  onPressed: _prevMonth),
              Text(title,
                  style: TextStyle(
                    fontFamily: 'Vazirmatn',
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
              itemCount: monthLength + (firstWeekday - 1),
              itemBuilder: (_, idx) {
                final dayIdx = idx - (firstWeekday - 2);
                if (dayIdx < 1 || dayIdx > monthLength) {
                  return SizedBox(); // خانه خالی برای offset
                }
                final d = Jalali(
                    _displayedMonth.year, _displayedMonth.month, dayIdx);
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
                      "$dayIdx",
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
                child: Text("بیخیال", style: TextStyle(fontFamily: 'Vazirmatn',color: Color(0xFF542545))),
                onPressed: () => Navigator.of(context).pop(null),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                child: Text("انتخاب", style: TextStyle(fontFamily: 'Vazirmatn',color: Color(0xFF542545))),
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
