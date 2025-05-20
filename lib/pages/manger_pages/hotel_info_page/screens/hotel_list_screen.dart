import 'dart:convert'; // برای jsonDecode
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // برای ارسال درخواست HTTP
import 'package:provider/provider.dart';
import '../../../authentication_page/auth_service.dart'; // مسیر AuthService
import '../models/hotel_model.dart';
import '../widgets/hotel_card.dart';
import 'add_hotel_screen.dart';
import 'room_list_screen.dart';

const String HOTELS_API_ENDPOINT = 'https://bookit.darkube.app/hotel-api/hotel/';

class HotelListScreen extends StatefulWidget {
  const HotelListScreen({super.key});

  @override
  State<HotelListScreen> createState() => _HotelListScreenState();
}

class _HotelListScreenState extends State<HotelListScreen> {
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

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating, // اضافه کردن این خط برای ظاهر بهتر
      ),
    );
  }

  Future<void> _fetchHotelsFromBackend() async {
    if (!mounted) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    final String? token = authService.token;
    print('Token for fetching hotels: $token');

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
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 20)); // افزایش تایم‌اوت در صورت نیاز

      if (!mounted) return;

      final String responseBodyString = utf8.decode(response.bodyBytes);
      print('API Response Status: ${response.statusCode}');
      // print('API Response Body for Hotels: $responseBodyString'); // برای دیباگ می‌توانید فعال کنید

      if (response.statusCode == 200) {
        try {
          final dynamic decodedData = jsonDecode(responseBodyString);
          List<dynamic>? hotelListData;

          // بررسی اینکه آیا پاسخ یک Map است و کلید 'data' را دارد و مقدار آن لیست است
          if (decodedData is Map<String, dynamic> &&
              decodedData.containsKey('data') &&
              decodedData['data'] is List) {
            hotelListData = decodedData['data'] as List<dynamic>;
          } else if (decodedData is List) {
            // اگر API مستقیما لیست برگرداند (برای兼容یت)
            hotelListData = decodedData;
          }

          if (hotelListData != null) {
            setState(() {
              _hotels = hotelListData!
                  .map((data) => Hotel.fromJson(data as Map<String, dynamic>))
                  .toList();
              _isLoading = false;
            });
            if (_hotels.isEmpty) {
              _showSnackBar('هتلی برای نمایش یافت نشد.');
            } else {
              print("لیست هتل‌ها با موفقیت از سرور دریافت شد: ${_hotels.length} هتل");
            }
          } else {
            print('Error: "data" key not found or is not a List in API response.');
            print('Decoded API Response: $decodedData');
            if (mounted) {
              setState(() {
                _isLoading = false;
                _errorMessage = 'فرمت پاسخ دریافتی از سرور برای لیست هتل‌ها نامعتبر است.';
              });
              _showSnackBar(_errorMessage!, isError: true);
            }
          }
        } catch (e) {
          print('Error decoding JSON or processing hotel list: $e');
          print('Original Response Body: $responseBodyString');
          if (mounted) {
            setState(() {
              _isLoading = false;
              _errorMessage = 'خطا در پردازش اطلاعات دریافتی از سرور.';
            });
            _showSnackBar(_errorMessage!, isError: true);
          }
        }
      } else {
        String serverErrorMessage = 'خطا در دریافت اطلاعات از سرور.';
        if (response.headers['content-type']?.contains('application/json') ?? false) {
          try {
            final errorData = jsonDecode(responseBodyString);
            if (errorData is Map) {
              if (errorData['detail'] != null) {
                serverErrorMessage = errorData['detail'].toString();
              } else if (errorData['message'] != null) {
                serverErrorMessage = errorData['message'].toString();
              } else {
                serverErrorMessage = errorData.toString();
              }
            } else if (errorData is String) {
              serverErrorMessage = errorData;
            }
          } catch (e) {
            serverErrorMessage = responseBodyString;
          }
        } else {
          serverErrorMessage = responseBodyString;
        }

        print('Failed to load hotels: ${response.statusCode}');
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = '$serverErrorMessage (کد: ${response.statusCode})';
          });
          _showSnackBar(_errorMessage!, isError: true);
        }
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

    if (result == true && mounted) { // اگر نتیجه true بود (یعنی ذخیره موفق بوده)
      _fetchHotelsFromBackend(); // لیست را مجدداً بارگذاری کن
      _showSnackBar(hotelToEdit == null ? 'هتل جدید با موفقیت اضافه شد.' : 'هتل با موفقیت ویرایش شد.');
    } else if (result is Hotel && mounted) { // اگر شیء هتل برگشت داده شد (سازگاری با کد قبلی)
      _fetchHotelsFromBackend();
      _showSnackBar(hotelToEdit == null ? 'هتل جدید با موفقیت اضافه شد.' : 'هتل با موفقیت ویرایش شد.');
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
    final theme = Theme.of(context); // برای استفاده از رنگ‌های تم

    return Scaffold(
      backgroundColor: theme.colorScheme.surface, // رنگ پس‌زمینه صفحه
      appBar: AppBar(
        title: Text('لیست هتل‌ها', style: TextStyle(color: theme.colorScheme.onPrimary)),
        backgroundColor: Color(0xFF542545),
        iconTheme: IconThemeData(color: Color(0xFF542545)), // رنگ آیکون‌های AppBar
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh,color: Colors.white,),
            onPressed: _isLoading ? null : _fetchHotelsFromBackend,
            tooltip: 'بارگذاری مجدد',
          ),
          // دکمه خروج از حساب اگر نیاز دارید
          // IconButton(
          //   icon: const Icon(Icons.logout),
          //   onPressed: () async {
          //     final authService = Provider.of<AuthService>(context, listen: false);
          //     await authService.logout();
          //     if (mounted) {
          //       Navigator.of(context).pushAndRemoveUntil(
          //         MaterialPageRoute(builder: (context) => AuthenticationPage()),
          //         (Route<dynamic> route) => false,
          //       );
          //     }
          //   },
          //   tooltip: 'خروج از حساب',
          // )
        ],
      ),
      body: _buildBody(theme),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _navigateAndHandleAddEditHotel(context);
        },
        label: const Text('افزودن هتل'),
        icon: const Icon(Icons.add),
        backgroundColor: theme.colorScheme.secondary, // رنگ دکمه شناور
        foregroundColor: theme.colorScheme.onSecondary,
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: theme.colorScheme.primary));
    }

    if (_errorMessage != null) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: theme.colorScheme.error, size: 60),
              const SizedBox(height: 16),
              Text(
                'خطا در بارگذاری هتل‌ها',
                style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)
                ),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.hotel_rounded, size: 70, color: theme.colorScheme.secondary.withOpacity(0.7)),
              const SizedBox(height: 16),
              Text(
                'هیچ هتلی برای نمایش وجود ندارد.',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.9)),
              ),
              const SizedBox(height: 8),
              Text(
                'برای افزودن هتل جدید، روی دکمه + پایین صفحه بزنید.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF542545),
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)
                ),
                icon: const Icon(Icons.refresh,color: Colors.white,),
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
      color: Color(0xFF542545), // رنگ RefreshIndicator
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 80.0), // فاصله از پایین برای FAB
        itemCount: _hotels.length,
        itemBuilder: (context, index) {
          final hotel = _hotels[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0), // فاصله بین کارت‌ها
            child: HotelCard(
              hotel: hotel,
              onHotelUpdated: () {
                _navigateAndHandleAddEditHotel(context, hotelToEdit: hotel);
              },
              onManageRooms: () {
                _navigateToManageRooms(context, hotel);
              },
            ),
          );
        },
      ),
    );
  }
}