import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../../../features/auth/data/services/auth_service.dart';
import '../models/hotel_model.dart';
import '../widgets/hotel_card.dart';
import 'add_hotel_screen.dart';
import 'room_list_screen.dart';

const String HOTELS_API_ENDPOINT = 'https://fbookit.darkube.app/hotel-api/hotel/';

class HotelListScreen extends StatefulWidget {
  const HotelListScreen({super.key});

  @override
  State<HotelListScreen> createState() => _HotelListScreenState();
}

class _HotelListScreenState extends State<HotelListScreen> {
  // --- مرحله ۱: ایجاد ScrollController ---
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

  // --- مرحله ۳: آزادسازی (Dispose) کنترلر ---
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ... (متدهای _showSnackBar, _fetchHotelsFromBackend, _navigateAndHandleAddEditHotel, _navigateToManageRooms بدون تغییر باقی می‌مانند)
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _fetchHotelsFromBackend() async {
    if (!mounted) return;
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
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 20));

      if (!mounted) return;
      final String responseBodyString = utf8.decode(response.bodyBytes);

      if (response.statusCode == 200) {
        final dynamic decodedData = jsonDecode(responseBodyString);
        List<dynamic>? hotelListData;
        if (decodedData is Map<String, dynamic> &&
            decodedData.containsKey('data') &&
            decodedData['data'] is List) {
          hotelListData = decodedData['data'] as List<dynamic>;
        } else if (decodedData is List) {
          hotelListData = decodedData;
        }

        if (hotelListData != null) {
          setState(() {
            _hotels = hotelListData!
                .map((data) => Hotel.fromJson(data as Map<String, dynamic>))
                .toList();
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = 'فرمت پاسخ دریافتی از سرور برای لیست هتل‌ها نامعتبر است.';
          });
          _showSnackBar(_errorMessage!, isError: true);
        }
      } else {
        // ... (بخش مدیریت خطا بدون تغییر)
        String serverErrorMessage = 'خطا در دریافت اطلاعات از سرور.';
        if (response.headers['content-type']?.contains('application/json') ?? false) {
          try {
            final errorData = jsonDecode(responseBodyString);
            if (errorData is Map) {
              serverErrorMessage = errorData['detail']?.toString() ?? errorData.toString();
            } else if (errorData is String) {
              serverErrorMessage = errorData;
            }
          } catch (e) {
            serverErrorMessage = responseBodyString;
          }
        }
        setState(() {
          _isLoading = false;
          _errorMessage = '$serverErrorMessage (کد: ${response.statusCode})';
        });
        _showSnackBar(_errorMessage!, isError: true);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'خطا در برقراری ارتباط با سرور. لطفاً اتصال اینترنت خود را بررسی کنید.';
      });
      _showSnackBar(_errorMessage!, isError: true);
    }
  }

  void _navigateAndHandleAddEditHotel(BuildContext context, {Hotel? hotelToEdit}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddHotelScreen(hotel: hotelToEdit),
      ),
    );
    if (result == true && mounted) {
      _fetchHotelsFromBackend();
      _showSnackBar(hotelToEdit == null ? 'هتل جدید با موفقیت اضافه شد.' : 'هتل با موفقیت ویرایش شد.');
    }
  }

  void _navigateToManageRooms(BuildContext context, Hotel hotel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoomListScreen(hotelId: hotel.id.toString(), hotelName: hotel.name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('لیست هتل‌ها', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF542545),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _fetchHotelsFromBackend,
            tooltip: 'بارگذاری مجدد',
          ),
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
        backgroundColor: theme.colorScheme.secondary,
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
            children: [
              Icon(Icons.error_outline, color: theme.colorScheme.error, size: 60),
              const SizedBox(height: 16),
              Text('خطا در بارگذاری هتل‌ها', style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.error), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text(_errorMessage!, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7))),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary, foregroundColor: theme.colorScheme.onPrimary),
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
            children: [
              Icon(Icons.hotel_rounded, size: 70, color: theme.colorScheme.secondary.withOpacity(0.7)),
              const SizedBox(height: 16),
              Text('هیچ هتلی برای نمایش وجود ندارد.', textAlign: TextAlign.center, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text('برای افزودن هتل جدید، روی دکمه + پایین صفحه بزنید.', textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7))),
              const SizedBox(height: 24),
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
      color: const Color(0xFF542545),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 80.0),
        itemCount: _hotels.length,
        itemBuilder: (context, index) {
          final hotel = _hotels[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
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