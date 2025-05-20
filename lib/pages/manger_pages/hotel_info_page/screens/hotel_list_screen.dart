import 'dart:convert'; // برای jsonDecode
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // برای ارسال درخواست HTTP
import 'package:provider/provider.dart';

import '../../../authentication_page/auth_service.dart';
import '../models/hotel_model.dart';
import '../models/facility_enum.dart';
import '../widgets/hotel_card.dart';
import 'add_hotel_screen.dart';
import 'room_list_screen.dart';

// TODO: آدرس واقعی API خود را اینجا قرار دهید
const String HOTELS_API_ENDPOINT = 'https://bookit.darkube.app/hotel-api/hotel/';

class HotelListScreen extends StatefulWidget {
  const HotelListScreen({super.key});

  @override
  State<HotelListScreen> createState() => _HotelListScreenState();
}

class _HotelListScreenState extends State<HotelListScreen> {
  List<Hotel> _hotels = [];
  bool _isLoading = false;
  String? _errorMessage; // برای نمایش پیام خطا

  @override
  void initState() {
    super.initState();
    _fetchHotelsFromBackend(); // فراخوانی تابع جدید
  }

  // تابع برای نمایش SnackBar
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _fetchHotelsFromBackend() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null; // پاک کردن خطای قبلی
    });
    final authService = Provider.of<AuthService>(context, listen: false);
    final String? token = authService.token;
    print ("data");
    try {
      final response = await http.get(
        Uri.parse(HOTELS_API_ENDPOINT),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
          // اگر نیاز به توکن احراز هویت دارید، آن را اینجا اضافه کنید
          // 'Authorization': 'Bearer YOUR_ACCESS_TOKEN',
        },
      ).timeout(const Duration(seconds: 15)); // اضافه کردن تایم اوت برای درخواست

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(utf8.decode(response.bodyBytes)); // برای پشتیبانی از کاراکترهای فارسی در پاسخ
        setState(() {
          _hotels = responseData.map((data) => Hotel.fromJson(data as Map<String, dynamic>)).toList();
          _isLoading = false;
        });
        if (_hotels.isEmpty) {
          _showSnackBar('هتلی برای نمایش یافت نشد.');
        } else {
          print("لیست هتل‌ها با موفقیت از سرور دریافت شد: ${_hotels.length} هتل");
        }
      } else {
        // تلاش برای خواندن پیام خطا از پاسخ سرور
        String serverErrorMessage = 'خطا در دریافت اطلاعات از سرور.';
        try {
          final errorData = jsonDecode(utf8.decode(response.bodyBytes));
          if (errorData['detail'] != null) {
            serverErrorMessage = errorData['detail'];
          } else if (errorData['message'] != null) {
            serverErrorMessage = errorData['message'];
          }
        } catch (e) {
          // اگر پاسخ خطا JSON معتبر نباشد
          serverErrorMessage = response.body;
        }
        print('Failed to load hotels: ${response.statusCode} - Body: ${response.body}');
        setState(() {
          _isLoading = false;
          _errorMessage = '$serverErrorMessage (کد: ${response.statusCode})';
        });
        _showSnackBar(_errorMessage!, isError: true);
      }
    } catch (e) {
      print('Error fetching hotels: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'خطا در برقراری ارتباط با سرور. لطفاً اتصال اینترنت خود را بررسی کنید.';
        });
        _showSnackBar(_errorMessage!, isError: true);
      }
    }
  }

  void _navigateAndHandleAddEditHotel(BuildContext context, {Hotel? hotelToEdit}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddHotelScreen(hotel: hotelToEdit),
      ),
    );

    if (result != null && result is Hotel && mounted) {
      // اگر هتل اضافه یا ویرایش شد، لیست را مجدداً از سرور بگیرید
      // تا از هماهنگی داده‌ها اطمینان حاصل شود.
      // یا اگر API اضافه/ویرایش، خود هتل به‌روز شده را برمی‌گرداند،
      // می‌توانید لیست محلی را مستقیماً آپدیت کنید (که پیچیده‌تر است).
      // ساده‌ترین راه، بارگذاری مجدد لیست است:
      _fetchHotelsFromBackend();
      _showSnackBar(hotelToEdit == null ? 'هتل جدید با موفقیت اضافه شد.' : 'هتل با موفقیت ویرایش شد.');

      // کد قبلی برای آپدیت محلی:
      // setState(() {
      //   if (hotelToEdit != null) {
      //     final index = _hotels.indexWhere((h) => h.id == result.id);
      //     if (index != -1) {
      //       _hotels[index] = result;
      //     }
      //   } else {
      //     _hotels.add(result);
      //   }
      // });
    }
  }

  void _navigateToManageRooms(BuildContext context, Hotel hotel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoomListScreen(hotelId: hotel.id, hotelName: hotel.name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لیست هتل‌ها'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _fetchHotelsFromBackend,
            tooltip: 'بارگذاری مجدد',
          )
        ],
      ),
      body: _buildBody(),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _navigateAndHandleAddEditHotel(context);
        },
        label: const Text('افزودن هتل'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 50),
              const SizedBox(height: 10),
              Text(
                'خطا در بارگذاری هتل‌ها:',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text("تلاش مجدد"),
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'هیچ هتلی ثبت نشده است.\n برای افزودن، روی دکمه + پایین صفحه بزنید.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text("بارگذاری مجدد"),
                onPressed: _fetchHotelsFromBackend,
              )
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchHotelsFromBackend,
      child: ListView.builder(
        padding: const EdgeInsets.all(12.0),
        itemCount: _hotels.length,
        itemBuilder: (context, index) {
          final hotel = _hotels[index];
          return HotelCard(
            hotel: hotel,
            onHotelUpdated: () {
              _navigateAndHandleAddEditHotel(context, hotelToEdit: hotel);
            },
            onManageRooms: () {
              _navigateToManageRooms(context, hotel);
            },
          );
        },
      ),
    );
  }
}