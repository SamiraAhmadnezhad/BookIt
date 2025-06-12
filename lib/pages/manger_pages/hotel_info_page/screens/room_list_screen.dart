import 'package:flutter/material.dart';
import '../models/room_model.dart';
import '../widgets/room_card.dart';
import 'add_room_screen.dart';
import '../data/app_data.dart';

class RoomListScreen extends StatefulWidget {
  final String hotelId;
  final String hotelName;

  const RoomListScreen({super.key, required this.hotelId, required this.hotelName});

  @override
  State<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {
  List<Room> _hotelRooms = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchRoomsForHotel();
  }

  Future<void> _fetchRoomsForHotel() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    await Future.delayed(const Duration(milliseconds: 300)); // شبیه سازی تاخیر
    if (!mounted) return;
    setState(() {
      _hotelRooms = sampleRooms.where((room) => room.hotelId == widget.hotelId).toList();
      _isLoading = false;
    });
    print("اتاق‌های هتل ${widget.hotelName} بارگذاری شدند: ${_hotelRooms.length} اتاق");
  }

  void _navigateAndRefreshAddRoom(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddRoomScreen(),
      ),
    );
    if (result == true && mounted) {
      _fetchRoomsForHotel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('اتاق‌های ${widget.hotelName}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hotelRooms.isEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'هیچ اتاقی برای این هتل ثبت نشده است.\n برای افزودن، روی دکمه + پایین صفحه بزنید.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      )
          : RefreshIndicator(
        onRefresh: _fetchRoomsForHotel,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 80.0),
          itemCount: _hotelRooms.length,
          itemBuilder: (context, index) {
            final room = _hotelRooms[index];
            return RoomCard(room: room);
          },
          separatorBuilder: (context, index) => const SizedBox(height: 16),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _navigateAndRefreshAddRoom(context);
        },
        label: const Text('افزودن اتاق'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}