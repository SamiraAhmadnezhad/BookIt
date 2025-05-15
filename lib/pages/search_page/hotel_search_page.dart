// مسیرها را متناسب با پروژه خود تنظیم کنید
import 'package:bookit/pages/search_page/widgets/custom_shamsi_date_picker.dart';
import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../home_page/location_selection_modal.dart';

extension JalaliToDateTime on Jalali {
  DateTime toDateTime() {
    final g = toGregorian();
    return DateTime(g.year, g.month, g.day);
  }
}

class HotelSearchPage extends StatefulWidget {
  const HotelSearchPage({super.key});

  @override
  State<HotelSearchPage> createState() => _HotelSearchPageState();
}

class _HotelSearchPageState extends State<HotelSearchPage> {
  String _selectedCity="";
  Jalali? _checkInDateShamsi;
  Jalali? _checkOutDateShamsi;

  int _numberOfRooms = 1;
  List<int> _guestCounts = [1];

  final List<String> _allCities = [
    "تهران", "مشهد", "اصفهان", "شیراز", "تبریز", "یزد", "کاشان", "کرج", "کاشمر", "رشت", "ساری"
  ];

  final Color _primaryColor = const Color(0xFF542545);
  final Color _textFieldBackgroundColor = Colors.grey.shade100;
  final Color _pageBackgroundColor = const Color(0xFFF8F9FA);

  static const List<String> _shamsiFullWeekDayNames = [
    "شنبه", "یکشنبه", "دوشنبه", "سه‌شنبه", "چهارشنبه", "پنجشنبه", "جمعه"
  ];
  static const List<String> _shamsiMonthNames = [
    "فروردین", "اردیبهشت", "خرداد", "تیر", "مرداد", "شهریور",
    "مهر", "آبان", "آذر", "دی", "بهمن", "اسفند"
  ];

  void _updateGuestCountForRoom(int roomIndex, int change) {
    setState(() {
      int currentGuests = _guestCounts[roomIndex];
      int newGuests = currentGuests + change;
      if (newGuests >= 1 && newGuests <= 5) {
        _guestCounts[roomIndex] = newGuests;
      }
    });
  }

  void _updateNumberOfRooms(int change) {
    setState(() {
      int newRooms = _numberOfRooms + change;
      if (newRooms >= 1 && newRooms <= 5) {
        _numberOfRooms = newRooms;
        if (change > 0) {
          _guestCounts.add(1);
        } else if (_guestCounts.length > _numberOfRooms) {
          _guestCounts.removeLast();
        }
      }
    });
  }

  Future<void> _selectDateWithCustomPicker(BuildContext context, bool isCheckIn) async {
    Jalali? initialSelection = isCheckIn ? _checkInDateShamsi : _checkOutDateShamsi;
    Jalali firstValidDateForPicker = Jalali.now(); // تاریخ شروع پیش‌فرض برای انتخابگر
    Jalali? lastValidDateForPicker; // تاریخ پایان پیش‌فرض برای انتخابگر (بدون محدودیت)

    if (!isCheckIn) { // انتخاب تاریخ خروج
      if (_checkInDateShamsi != null) {
        firstValidDateForPicker = _checkInDateShamsi!.addDays(1);
      }
      // initialSelection (یعنی _checkOutDateShamsi) باید بعد از firstValidDateForPicker باشد
      if (initialSelection != null && initialSelection.compareTo(firstValidDateForPicker) < 0) {
        initialSelection = firstValidDateForPicker;
      } else if (initialSelection == null && _checkInDateShamsi != null) {
        initialSelection = firstValidDateForPicker; // پیشنهاد تاریخ خروج، روز بعد از ورود
      }

    } else { // انتخاب تاریخ ورود
      if (_checkOutDateShamsi != null) {
        lastValidDateForPicker = _checkOutDateShamsi!.addDays(-1);
        // initialSelection (یعنی _checkInDateShamsi) باید قبل از lastValidDateForPicker باشد
        if (initialSelection != null && lastValidDateForPicker.compareTo(initialSelection) < 0) {
          initialSelection = lastValidDateForPicker; // یا null اگر نمیخواهیم تاریخ را تغییر دهیم
        }
      }
    }

    // اطمینان از اینکه initialSelection از firstValidDateForPicker عقب‌تر نیست
    // و اگر lastValidDateForPicker وجود دارد، از آن جلوتر هم نیست.
    Jalali effectiveInitialDate;
    if (initialSelection != null) {
      if (initialSelection.compareTo(firstValidDateForPicker) < 0) {
        effectiveInitialDate = firstValidDateForPicker;
      } else if (lastValidDateForPicker != null && initialSelection.compareTo(lastValidDateForPicker) > 0) {
        effectiveInitialDate = lastValidDateForPicker;
      } else {
        effectiveInitialDate = initialSelection;
      }
    } else {
      effectiveInitialDate = firstValidDateForPicker;
    }


    final Jalali? pickedShamsiDate = await showCustomShamsiDatePickerDialog(
      context,
      initialDate: effectiveInitialDate, // استفاده از تاریخ اولیه موثر و معتبر
      firstDate: firstValidDateForPicker,
      lastDate: lastValidDateForPicker,
    );

    if (pickedShamsiDate != null) {
      setState(() {
        if (isCheckIn) {
          _checkInDateShamsi = pickedShamsiDate;
          if (_checkOutDateShamsi != null && _checkInDateShamsi!.compareTo(_checkOutDateShamsi!) >= 0) {
            _checkOutDateShamsi = null;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تاریخ خروج شما بازنشانی شد. لطفاً مجدد انتخاب کنید.', textAlign: TextAlign.right, style: TextStyle(fontFamily: 'Vazirmatn')),
                backgroundColor: Colors.orange,
              ),
            );
          }
        } else { // انتخاب تاریخ خروج
          // در اینجا firstValidDateForPicker (که روز بعد از ورود است) قبلا در بالا محاسبه شده
          // و به date picker پاس داده شده، پس pickedShamsiDate حتما بعد از تاریخ ورود خواهد بود (اگر تاریخ ورود موجود باشد).
          // تنها حالتی که نیاز به بررسی دارد این است که آیا تاریخ ورود اصلا انتخاب شده یا نه.
          if (_checkInDateShamsi == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('لطفاً ابتدا تاریخ ورود را انتخاب کنید.', textAlign: TextAlign.right, style: TextStyle(fontFamily: 'Vazirmatn')),
                backgroundColor: Colors.orange,
              ),
            );
          } else {
            // چون firstDate در پیکر برای تاریخ خروج، روز بعد از ورود تنظیم شده، این شرط همیشه برقرار است
            // if (pickedShamsiDate.compareTo(_checkInDateShamsi!) > 0)
            _checkOutDateShamsi = pickedShamsiDate;
          }
        }
      });
    }
  }

  void _showCitySelectionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // مهم برای نمایش borderRadius کانتینر داخلی
      // shape: const RoundedRectangleBorder( // دیگر نیازی نیست، چون کانتینر داخلی borderRadius دارد
      // borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      // ),
      builder: (BuildContext context) {
        return LocationSelectionModal(
          allCities: _allCities,
          currentCity: _selectedCity, // پاس دادن مقدار null اگر انتخاب نشده باشد
          onCitySelected: (city) {
            setState(() {
              _selectedCity = city;
            });
            // Navigator.pop(context); // <<< این خط حذف شد >>>
          },
        );
      },
    );
  }

  String _formatShamsiDateToString(Jalali? shamsiDate) {
    if (shamsiDate == null) return "";
    String weekDayName = _shamsiFullWeekDayNames[shamsiDate.weekDay - 1];
    String monthName = _shamsiMonthNames[shamsiDate.month - 1];
    return "$weekDayName، ${shamsiDate.day} $monthName ${shamsiDate.year}";
  }

  int _calculateNights() {
    if (_checkInDateShamsi != null && _checkOutDateShamsi != null) {
      final DateTime checkIn = _checkInDateShamsi!.toDateTime();
      final DateTime checkOut = _checkOutDateShamsi!.toDateTime();
      final int nights = checkOut.difference(checkIn).inDays;
      return nights > 0 ? nights : 0;
    }
    return 0;
  }

  Widget _buildTextFieldContainer({
    required String label,
    String? valueText,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0, bottom: 6.0),
          child: Text(
            label,
            style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 14, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
          ),
        ),
        Material(
          color: _textFieldBackgroundColor,
          borderRadius: BorderRadius.circular(12.0),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      (valueText == null || valueText.isEmpty) ? "انتخاب کنید" : valueText,
                      style: TextStyle(
                        fontFamily: 'Vazirmatn',
                        fontSize: 15,
                        color: (valueText == null || valueText.isEmpty) ? Colors.grey.shade600 : Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (icon != null) Icon(icon, color: Colors.grey.shade600, size: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepper({
    required String label,
    required int count,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
    String unit = "",
    int minCount = 1, // اضافه کردن حداقل تعداد
    int maxCount = 5, // اضافه کردن حداکثر تعداد
  }) {
    bool decrementEnabled = count > minCount;
    bool incrementEnabled = count < maxCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0, bottom: 6.0),
          child: Text(
            label,
            style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 14, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: _textFieldBackgroundColor,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStepperButton(Icons.remove, onDecrement, decrementEnabled),
              Expanded(
                child: Text(
                  '$count ${unit.isNotEmpty ? unit : ""}'.trim(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              _buildStepperButton(Icons.add, onIncrement, incrementEnabled),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepperButton(IconData icon, VoidCallback onPressed, bool enabled) {
    return InkWell(
      onTap: enabled ? onPressed : null,
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(icon, size: 22, color: enabled ? _primaryColor : Colors.grey.shade400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.05 > 20 ? screenWidth * 0.05 : 20.0;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _pageBackgroundColor,
        appBar: AppBar(
          title: const Text('جستجو رزرو هتل', style: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.bold, fontSize: 19)),
          backgroundColor: _pageBackgroundColor,
          elevation: 0.5,
          centerTitle: true,
          foregroundColor: Colors.grey.shade800,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextFieldContainer(
                  label: 'نام شهر',
                  valueText: _selectedCity,
                  onTap: _showCitySelectionModal,
                  icon: Icons.location_city_outlined,
                ),
                const SizedBox(height: 18),
                _buildTextFieldContainer(
                  label: 'تاریخ ورود',
                  valueText: _formatShamsiDateToString(_checkInDateShamsi),
                  onTap: () => _selectDateWithCustomPicker(context, true),
                  icon: Icons.calendar_today_outlined,
                ),
                const SizedBox(height: 18),
                _buildTextFieldContainer(
                  label: 'تاریخ خروج',
                  valueText: _formatShamsiDateToString(_checkOutDateShamsi),
                  onTap: () => _selectDateWithCustomPicker(context, false),
                  icon: Icons.calendar_today_outlined,
                ),
                const SizedBox(height: 20),
                _buildStepper(
                  label: 'تعداد اتاق ها',
                  count: _numberOfRooms,
                  unit: "اتاق",
                  onDecrement: () => _updateNumberOfRooms(-1),
                  onIncrement: () => _updateNumberOfRooms(1),
                  minCount: 1,
                  maxCount: 5,
                ),
                const SizedBox(height: 18.0),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _numberOfRooms,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 18.0),
                      child: _buildStepper(
                        label: 'تعداد مسافران اتاق ${index + 1}',
                        count: _guestCounts[index],
                        unit: "مسافر",
                        onDecrement: () => _updateGuestCountForRoom(index, -1),
                        onIncrement: () => _updateGuestCountForRoom(index, 1),
                        minCount: 1,
                        maxCount: 5,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10.0),
                Center(
                  child: Text(
                    _calculateNights() > 0 ? 'به مدت ${_calculateNights()} شب' : 'به مدت ---- شب',
                    style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 15, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                    onPressed: () {
                      if (_selectedCity == null || _selectedCity!.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لطفا شهر را انتخاب کنید.', textAlign: TextAlign.right, style: TextStyle(fontFamily: 'Vazirmatn')))); return;
                      }
                      if (_checkInDateShamsi == null) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لطفا تاریخ ورود را انتخاب کنید.', textAlign: TextAlign.right, style: TextStyle(fontFamily: 'Vazirmatn')))); return;
                      }
                      if (_checkOutDateShamsi == null) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لطفا تاریخ خروج را انتخاب کنید.', textAlign: TextAlign.right, style: TextStyle(fontFamily: 'Vazirmatn')))); return;
                      }
                      if (_calculateNights() <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تاریخ خروج باید بعد از تاریخ ورود باشد.', textAlign: TextAlign.right, style: TextStyle(fontFamily: 'Vazirmatn')))); return;
                      }
                      String guestSummary = _guestCounts.asMap().entries.map((entry) {
                        return "اتاق ${entry.key + 1}: ${entry.value} مسافر";
                      }).join('، ');

                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(duration: const Duration(seconds: 5), content: Text('جستجو برای: $_selectedCity\nورود: ${_formatShamsiDateToString(_checkInDateShamsi)}\nخروج: ${_formatShamsiDateToString(_checkOutDateShamsi)}\n$_numberOfRooms اتاق، مسافران: $guestSummary', textAlign: TextAlign.right, style: TextStyle(fontFamily: 'Vazirmatn', height: 1.5))));
                    },
                    child: const Text('جستجو و رزرو هتل', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}