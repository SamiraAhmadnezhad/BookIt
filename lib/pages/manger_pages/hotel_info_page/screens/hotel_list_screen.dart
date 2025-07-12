import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../../../core/models/hotel_model.dart';
import '../../../../core/utils/custom_shamsi_date_picker.dart';
import '../../../../features/auth/data/services/auth_service.dart';
import '../widgets/hotel_card.dart';
import 'add_hotel_screen.dart';
import 'room_list_screen.dart';

const String HOTELS_API_ENDPOINT = 'https://fbookit.darkube.app/hotel-api/hotel/';
const String DISCOUNT_API_ENDPOINT = 'https://fbookit.darkube.app/hotelManager-api/hotel_manager/activate_discount/';

class HotelListScreen extends StatefulWidget {
  const HotelListScreen({super.key});

  @override
  State<HotelListScreen> createState() => _HotelListScreenState();
}

class _HotelListScreenState extends State<HotelListScreen> {
  static const Color _primaryColor = Color(0xFF542545);

  final ScrollController _scrollController = ScrollController();
  List<Hotel> _hotels = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fetchHotelsFromBackend();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Vazirmatn')),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  Future<void> _fetchHotelsFromBackend() async {
    if (!mounted || _isLoading) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    final String? token = authService.token;

    if (token == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'توکن احراز هویت یافت نشد. لطفاً مجددا وارد شوید.';
        });
        _showSnackBar(_errorMessage!, isError: true);
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse(HOTELS_API_ENDPOINT),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 20));

      if (!mounted) return;

      final String responseBodyString = utf8.decode(response.bodyBytes);

      if (response.statusCode == 200) {
        final dynamic decodedData = jsonDecode(responseBodyString);
        final hotelListData = (decodedData is Map<String, dynamic> && decodedData.containsKey('data'))
            ? decodedData['data'] as List<dynamic>
            : decodedData as List<dynamic>;

        setState(() {
          _hotels = hotelListData.map((data) => Hotel.fromJson(data)).toList();
        });
      } else {
        String serverErrorMessage = 'خطا در دریافت اطلاعات از سرور.';
        try {
          final errorData = jsonDecode(responseBodyString);
          serverErrorMessage = errorData['detail']?.toString() ?? errorData.toString();
        } catch (_) {
          serverErrorMessage = responseBodyString;
        }
        _errorMessage = '$serverErrorMessage (کد: ${response.statusCode})';
        _showSnackBar(_errorMessage!, isError: true);
      }
    } catch (e) {
      _errorMessage = 'خطا در ارتباط با سرور. لطفاً اتصال اینترنت خود را بررسی کنید.';
      _showSnackBar(_errorMessage!, isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _applyDiscount(Hotel hotel, Jalali startDate, Jalali endDate, int discount) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final String? token = authService.token;

    if (token == null) {
      _showSnackBar('توکن احراز هویت یافت نشد. لطفاً مجدداً وارد شوید.', isError: true);
      return;
    }

    _showSnackBar('در حال اعمال تخفیف...');

    final String startDateStr = startDate.toGregorian().toDateTime().toIso8601String().split('T').first;
    final String endDateStr = endDate.toGregorian().toDateTime().toIso8601String().split('T').first;

    try {
      final response = await http.post(
        Uri.parse(DISCOUNT_API_ENDPOINT),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'hotel_id': hotel.id,
          'discount': discount,
          'discount_start_date': startDateStr,
          'discount_end_date': endDateStr,
        }),
      ).timeout(const Duration(seconds: 20));

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnackBar('تخفیف با موفقیت برای هتل ${hotel.name} اعمال شد.');
        _fetchHotelsFromBackend();
      } else {
        final String responseBodyString = utf8.decode(response.bodyBytes);
        String serverErrorMessage = 'خطا در اعمال تخفیف.';
        try {
          final errorData = jsonDecode(responseBodyString);
          serverErrorMessage = errorData['detail']?.toString() ?? errorData.toString();
        } catch (_) {
          serverErrorMessage = responseBodyString;
        }
        _showSnackBar('$serverErrorMessage (کد: ${response.statusCode})', isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('خطا در ارتباط با سرور. لطفاً اتصال اینترنت خود را بررسی کنید.', isError: true);
    }
  }

  void _showDiscountDialog(Hotel hotel) {
    Jalali? startDate;
    Jalali? endDate;
    final discountController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text("اعمال تخفیف برای ${hotel.name}", style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 18, fontWeight: FontWeight.bold, color: _primaryColor)),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.calendar_today_outlined, color: _primaryColor),
                      title: Text(startDate == null ? "تاریخ شروع تخفیف" : "شروع: ${startDate!.formatter.y}/${startDate!.formatter.m}/${startDate!.formatter.d}", style: const TextStyle(fontFamily: 'Vazirmatn')),
                      onTap: () async {
                        final pickedDate = await showCustomShamsiDatePickerDialog(
                          context,
                          titleText: 'انتخاب تاریخ شروع',
                          initialDate: Jalali.now(),
                          firstDate: Jalali.now(),
                        );
                        if (pickedDate != null) {
                          setStateDialog(() {
                            startDate = pickedDate;
                            if (endDate != null && endDate!.compareTo(startDate!) < 0) {
                              endDate = null;
                            }
                          });
                        }
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.event_available_outlined, color: _primaryColor),
                      title: Text(endDate == null ? "تاریخ پایان تخفیف" : "پایان: ${endDate!.formatter.y}/${endDate!.formatter.m}/${endDate!.formatter.d}", style: const TextStyle(fontFamily: 'Vazirmatn')),
                      enabled: startDate != null,
                      onTap: () async {
                        if (startDate == null) return;
                        final pickedDate = await showCustomShamsiDatePickerDialog(
                          context,
                          titleText: 'انتخاب تاریخ پایان',
                          initialDate: startDate ?? Jalali.now(),
                          firstDate: startDate ?? Jalali.now(),
                        );
                        if (pickedDate != null) {
                          setStateDialog(() => endDate = pickedDate);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: discountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "درصد تخفیف",
                        hintText: "مثلاً: 20",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: _primaryColor, width: 2), borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.percent_rounded),
                      ),
                      style: const TextStyle(fontFamily: 'Vazirmatn'),
                      validator: (value) {
                        if (value == null || value.isEmpty) return "لطفا درصد تخفیف را وارد کنید.";
                        final n = int.tryParse(value);
                        if (n == null || n <= 0 || n > 100) return "یک عدد صحیح بین ۱ تا ۱۰۰ وارد کنید.";
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text("لغو", style: TextStyle(fontFamily: 'Vazirmatn', color: Colors.grey[600])),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: _primaryColor, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  child: const Text("اعمال تخفیف", style: TextStyle(fontFamily: 'Vazirmatn')),
                  onPressed: () {
                    if (startDate == null || endDate == null) {
                      _showSnackBar("لطفاً بازه تاریخ شروع و پایان را مشخص کنید.", isError: true);
                      return;
                    }
                    if (formKey.currentState?.validate() ?? false) {
                      final discountValue = int.parse(discountController.text);
                      Navigator.of(dialogContext).pop();
                      _applyDiscount(hotel, startDate!, endDate!, discountValue);
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _navigateAndHandleAddEditHotel(BuildContext context, {Hotel? hotelToEdit}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddHotelScreen(hotel: hotelToEdit)),
    );
    if (result == true && mounted) {
      _fetchHotelsFromBackend();
      _showSnackBar(hotelToEdit == null ? 'هتل جدید با موفقیت اضافه شد.' : 'هتل با موفقیت ویرایش شد.');
    }
  }

  void _navigateToManageRooms(BuildContext context, Hotel hotel) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RoomListScreen(hotelId: hotel.id.toString(), hotelName: hotel.name)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('مدیریت هتل‌ها', style: TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.bold)),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _fetchHotelsFromBackend,
            tooltip: 'بارگذاری مجدد',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateAndHandleAddEditHotel(context),
        label: const Text('افزودن هتل', style: TextStyle(fontFamily: 'Vazirmatn')),
        icon: const Icon(Icons.add),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _hotels.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: _primaryColor));
    }

    if (_errorMessage != null && _hotels.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off_rounded, color: Colors.grey[400], size: 80),
              const SizedBox(height: 20),
              Text('خطا در بارگذاری', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[700])),
              const SizedBox(height: 12),
              Text(_errorMessage!, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Vazirmatn', color: Colors.grey[600], height: 1.6)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: _primaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                icon: const Icon(Icons.refresh),
                label: const Text("تلاش مجدد", style: TextStyle(fontFamily: 'Vazirmatn')),
                onPressed: _fetchHotelsFromBackend,
              )
            ],
          ),
        ),
      );
    }

    if (_hotels.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.hotel_class_outlined, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 20),
              Text('هتلی یافت نشد', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[700])),
              const SizedBox(height: 12),
              Text('برای افزودن هتل جدید، روی دکمه + پایین صفحه بزنید.', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Vazirmatn', color: Colors.grey[600], height: 1.6)),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchHotelsFromBackend,
      color: _primaryColor,
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 88),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 420, // عرض کمتر برای هر کارت
          mainAxisSpacing: 24,
          crossAxisSpacing: 24,
          childAspectRatio: 420 / 490, // نسبت عرض به ارتفاع کارت
        ),
        itemCount: _hotels.length,
        itemBuilder: (context, index) {
          final hotel = _hotels[index];
          return HotelCard(
            hotel: hotel,
            onHotelUpdated: () => _navigateAndHandleAddEditHotel(context, hotelToEdit: hotel),
            onManageRooms: () => _navigateToManageRooms(context, hotel),
            onApplyDiscount: () => _showDiscountDialog(hotel),
          );
        },
      ),
    );
  }
}