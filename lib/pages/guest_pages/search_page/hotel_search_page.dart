// lib/pages/guest_pages/search_page/hotel_search_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // برای فرمت کردن تاریخ
import 'package:shamsi_date/shamsi_date.dart';

import '../../../features/guest/home/presentation/widgets/location_selection_modal.dart';
import 'model/search_params_model.dart';
import 'search_list_page.dart';
import '../../../core/utils/custom_shamsi_date_picker.dart';

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
  String _selectedCity = "تهران";
  Jalali? _checkInDateShamsi;
  Jalali? _checkOutDateShamsi;
  String _selectedRoomType = 'Double';

  final List<String> _allCities = [
    "تهران", "مشهد", "اصفهان", "شیراز", "تبریز", "یزد", "کاشان", "کرج", "رشت", "ساری"
  ];
  final List<String> _roomTypes = ['Single', 'Double', 'Triple'];

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

  Future<void> _selectDateWithCustomPicker(BuildContext context, bool isCheckIn) async {
    Jalali? initialSelection = isCheckIn ? _checkInDateShamsi : _checkOutDateShamsi;
    Jalali firstValidDateForPicker = Jalali.now();
    Jalali? lastValidDateForPicker;

    if (!isCheckIn) {
      if (_checkInDateShamsi != null) {
        firstValidDateForPicker = _checkInDateShamsi!.addDays(1);
      }
      if (initialSelection != null && initialSelection.compareTo(firstValidDateForPicker) < 0) {
        initialSelection = firstValidDateForPicker;
      } else if (initialSelection == null && _checkInDateShamsi != null) {
        initialSelection = firstValidDateForPicker;
      }
    } else {
      if (_checkOutDateShamsi != null) {
        lastValidDateForPicker = _checkOutDateShamsi!.addDays(-1);
        if (initialSelection != null && lastValidDateForPicker.compareTo(initialSelection) < 0) {
          initialSelection = lastValidDateForPicker;
        }
      }
    }

    Jalali effectiveInitialDate = initialSelection ?? firstValidDateForPicker;
    if (effectiveInitialDate.compareTo(firstValidDateForPicker) < 0) {
      effectiveInitialDate = firstValidDateForPicker;
    }
    if (lastValidDateForPicker != null && effectiveInitialDate.compareTo(lastValidDateForPicker) > 0) {
      effectiveInitialDate = lastValidDateForPicker;
    }

    final Jalali? pickedShamsiDate = await showCustomShamsiDatePickerDialog(
      context,
      initialDate: effectiveInitialDate,
      firstDate: firstValidDateForPicker,
      lastDate: lastValidDateForPicker,
    );

    if (pickedShamsiDate != null) {
      setState(() {
        if (isCheckIn) {
          _checkInDateShamsi = pickedShamsiDate;
          if (_checkOutDateShamsi != null && _checkInDateShamsi!.compareTo(_checkOutDateShamsi!) >= 0) {
            _checkOutDateShamsi = null;
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تاریخ خروج بازنشانی شد.', textAlign: TextAlign.right, style: TextStyle(fontFamily: 'Vazirmatn'))));
          }
        } else {
          if (_checkInDateShamsi == null) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لطفاً ابتدا تاریخ ورود را انتخاب کنید.', textAlign: TextAlign.right, style: TextStyle(fontFamily: 'Vazirmatn'))));
          } else {
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
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return LocationSelectionModal(
          allCities: _allCities,
          currentCity: _selectedCity,
          onCitySelected: (city) => setState(() => _selectedCity = city),
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
      final int nights = _checkOutDateShamsi!.toDateTime().difference(_checkInDateShamsi!.toDateTime()).inDays;
      return nights > 0 ? nights : 0;
    }
    return 0;
  }

  Widget _buildTextFieldContainer({required String label, String? valueText, required VoidCallback onTap, IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0, bottom: 6.0),
          child: Text(label, style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 14, color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
        ),
        Material(
          color: _textFieldBackgroundColor, borderRadius: BorderRadius.circular(12.0),
          child: InkWell(
            onTap: onTap, borderRadius: BorderRadius.circular(12.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
              child: Row(
                children: [
                  Expanded(child: Text((valueText == null || valueText.isEmpty) ? "انتخاب کنید" : valueText, style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 15, color: (valueText == null || valueText.isEmpty) ? Colors.grey.shade600 : Colors.black87))),
                  if (icon != null) Icon(icon, color: Colors.grey.shade600, size: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoomTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0, bottom: 6.0),
          child: Text(
            'نوع اتاق',
            style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 14, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
          ),
        ),
        Container(
          height: 55,
          decoration: BoxDecoration(
            color: _textFieldBackgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _roomTypes.map((type) {
              final bool isSelected = (_selectedRoomType == type);
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedRoomType = type),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isSelected ? _primaryColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: isSelected
                          ? [BoxShadow(color: _primaryColor.withOpacity(0.3), blurRadius: 4, spreadRadius: 1)]
                          : [],
                    ),
                    child: Center(
                      child: Text(
                        type,
                        style: TextStyle(
                          fontFamily: 'Vazirmatn',
                          fontSize: 15,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackgroundColor,
      appBar: AppBar(
        title: const Text('جستجو رزرو هتل', style: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.bold, fontSize: 19,color: Colors.black)),
        backgroundColor: _pageBackgroundColor, elevation: 0.5, centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextFieldContainer(label: 'نام شهر', valueText: _selectedCity, onTap: _showCitySelectionModal, icon: Icons.location_city_outlined),
                  const SizedBox(height: 18),
                  _buildTextFieldContainer(label: 'تاریخ ورود', valueText: _formatShamsiDateToString(_checkInDateShamsi), onTap: () => _selectDateWithCustomPicker(context, true), icon: Icons.calendar_today_outlined),
                  const SizedBox(height: 18),
                  _buildTextFieldContainer(label: 'تاریخ خروج', valueText: _formatShamsiDateToString(_checkOutDateShamsi), onTap: () => _selectDateWithCustomPicker(context, false), icon: Icons.calendar_today_outlined),
                  const SizedBox(height: 20),
                  _buildRoomTypeSelector(),
                  const SizedBox(height: 25.0),
                  Center(child: Text(_calculateNights() > 0 ? 'به مدت ${_calculateNights()} شب' : 'به مدت ---- شب', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 15, color: Colors.grey.shade700, fontWeight: FontWeight.w600))),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: _primaryColor, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      onPressed: () {
                        if (_selectedCity.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لطفا شهر را انتخاب کنید.', textAlign: TextAlign.right, style: TextStyle(fontFamily: 'Vazirmatn')))); return; }
                        if (_checkInDateShamsi == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لطفا تاریخ ورود را انتخاب کنید.', textAlign: TextAlign.right, style: TextStyle(fontFamily: 'Vazirmatn')))); return; }
                        if (_checkOutDateShamsi == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لطفا تاریخ خروج را انتخاب کنید.', textAlign: TextAlign.right, style: TextStyle(fontFamily: 'Vazirmatn')))); return; }

                        final DateFormat formatter = DateFormat('yyyy-MM-dd');
                        final String checkInDateStr = formatter.format(_checkInDateShamsi!.toDateTime());
                        final String checkOutDateStr = formatter.format(_checkOutDateShamsi!.toDateTime());

                        final searchParams = SearchParams(
                          city: _selectedCity,
                          checkInDate: checkInDateStr,
                          checkOutDate: checkOutDateStr,
                          roomType: _selectedRoomType,
                        );

                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SearchListPage(searchParams: searchParams)),
                        );
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
      ),
    );
  }
}