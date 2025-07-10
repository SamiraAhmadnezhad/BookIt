import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../../authentication_page/auth_service.dart';
import '../models/room_model.dart';
import '../widgets/room_card.dart';
import 'add_room_screen.dart';

const String ROOMS_API_ENDPOINT = 'https://fbookit.darkube.app/room-api/room';

class RoomListScreen extends StatefulWidget {
  final String hotelId;
  final String hotelName;

  const RoomListScreen({super.key, required this.hotelId, required this.hotelName});

  @override
  State<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {
  static const Color _primaryColor = Color(0xFF542545);

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
        content: Text(message, style: const TextStyle(fontFamily: 'Vazirmatn')),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  Future<void> _fetchRoomsForHotel() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

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

    final Uri url = Uri.parse('$ROOMS_API_ENDPOINT/${widget.hotelId}/');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 20));

      if (!mounted) return;

      final String responseBody = utf8.decode(response.bodyBytes);

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = jsonDecode(responseBody);
        final List<dynamic>? roomListData = decodedData['data'] as List<dynamic>?;

        setState(() {
          _hotelRooms = roomListData?.map((data) => Room.fromJson(data)).toList() ?? [];
        });
      } else if (response.statusCode == 404) {
        _hotelRooms = [];
      } else {
        _errorMessage = 'خطا در دریافت اطلاعات. (کد: ${response.statusCode})';
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
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('اتاق‌های هتل ${widget.hotelName}', style: const TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.bold)),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _fetchRoomsForHotel,
            tooltip: 'بارگذاری مجدد',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateAndRefreshAddRoom(context),
        label: const Text('افزودن اتاق', style: TextStyle(fontFamily: 'Vazirmatn')),
        icon: const Icon(Icons.add),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: _primaryColor));
    }

    if (_errorMessage != null) {
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
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.door_sliding_outlined, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 20),
              Text('اتاقی یافت نشد', style: TextStyle(fontFamily: 'Vazirmatn', fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[700])),
              const SizedBox(height: 12),
              Text('برای افزودن اتاق جدید، روی دکمه + پایین صفحه بزنید.', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Vazirmatn', color: Colors.grey[600], height: 1.6)),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchRoomsForHotel,
      color: _primaryColor,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 88),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 350,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: 350 / 380,
        ),
        itemCount: _hotelRooms.length,
        itemBuilder: (context, index) {
          return RoomCard(room: _hotelRooms[index]);
        },
      ),
    );
  }
}