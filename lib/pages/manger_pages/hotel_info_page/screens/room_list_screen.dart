// فایل: screens/room_list_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../../authentication_page/auth_service.dart';
import '../models/room_model.dart';
import '../widgets/room_card.dart';
import 'add_room_screen.dart';

const String ROOMS_API_ENDPOINT = 'https://newbookit.darkube.app/room-api/room';

class RoomListScreen extends StatefulWidget {
  final String hotelId;
  final String hotelName;

  const RoomListScreen({super.key, required this.hotelId, required this.hotelName});

  @override
  State<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {
  List<Room> _hotelRooms = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchRoomsForHotel();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _fetchRoomsForHotel() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _hotelRooms = [];
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    final String? token = authService.token;
    if (token == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'توکن احراز هویت یافت نشد.';
        });
        _showSnackBar(_errorMessage!, isError: true);
      }
      return;
    }

    final Uri url = Uri.parse('$ROOMS_API_ENDPOINT/${widget.hotelId}/');
    try {
      final response = await http.get(
        url,
        headers: { 'Authorization': 'Bearer $token' },
      ).timeout(const Duration(seconds: 20));

      if (!mounted) return;

      final String responseBody = utf8.decode(response.bodyBytes);

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = jsonDecode(responseBody);
        final List<dynamic>? roomListData = decodedData['data'] as List<dynamic>?;

        if (roomListData != null) {
          setState(() {
            _hotelRooms = roomListData
                .map((data) => Room.fromJson(data as Map<String, dynamic>))
                .toList();
            _isLoading = false;
          });
        } else {
          throw Exception('فرمت پاسخ سرور نامعتبر است.');
        }

      }
      // *** این بخش به درستی خطای 404 را به عنوان لیست خالی مدیریت می‌کند ***
      else if (response.statusCode == 404 && responseBody.contains("هیچ اتاقی برای این هتل یافت نشد")) {
        // چون _errorMessage تنظیم نمی‌شود، UI به درستی حالت لیست خالی را نشان می‌دهد
        setState(() {
          _isLoading = false;
        });
      }
      // *** سایر خطاها در اینجا مدیریت می‌شوند ***
      else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'خطا: $responseBody (کد: ${response.statusCode})';
        });
        _showSnackBar(_errorMessage!, isError: true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'خطا در پردازش اطلاعات: $e';
        });
        _showSnackBar(_errorMessage!, isError: true);
      }
    }
  }

  void _navigateAndRefreshAddRoom(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddRoomScreen(hotelId: widget.hotelId),
      ),
    );
    if (result == true && mounted) {
      _showSnackBar('اتاق جدید با موفقیت اضافه شد.');
      _fetchRoomsForHotel();
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF542545);

    return Scaffold(
      appBar: AppBar(
        title: Text('اتاق‌های ${widget.hotelName}'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _fetchRoomsForHotel,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateAndRefreshAddRoom(context),
        label: const Text('افزودن اتاق'),
        icon: const Icon(Icons.add),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF542545)));
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 60),
              const SizedBox(height: 16),
              Text('خطا در بارگذاری', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text("تلاش مجدد"),
                onPressed: _fetchRoomsForHotel,
              )
            ],
          ),
        ),
      );
    }

    if (_hotelRooms.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.meeting_room_outlined, size: 70, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text('هیچ اتاقی برای این هتل ثبت نشده است', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              const Text('برای افزودن، روی دکمه + پایین صفحه بزنید.', textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchRoomsForHotel,
      color: const Color(0xFF542545),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 80.0),
        itemCount: _hotelRooms.length,
        itemBuilder: (context, index) {
          return RoomCard(room: _hotelRooms[index]);
        },
        separatorBuilder: (context, index) => const SizedBox(height: 16),
      ),
    );
  }
}