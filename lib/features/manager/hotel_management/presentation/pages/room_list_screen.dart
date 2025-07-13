import 'package:bookit/core/models/room_model.dart';
import 'package:bookit/features/auth/data/services/auth_service.dart';
import 'package:bookit/features/guest/hotel_detail/data/services/hotel_detail_api_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/services/manager_api_service.dart';
import '../widgets/room_card.dart';
import 'add_room_screen.dart';

class RoomListScreen extends StatefulWidget {
  final String hotelId;
  final String hotelName;

  const RoomListScreen(
      {super.key, required this.hotelId, required this.hotelName});

  @override
  State<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {
  late final HotelDetailApiService _guestApiService;
  late final ManagerApiService _managerApiService;
  Future<List<Room>>? _roomsFuture;

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AuthService>(context, listen: false);
    _guestApiService = HotelDetailApiService(authService);
    _managerApiService = ManagerApiService(authService);
    _loadRooms();
  }

  void _loadRooms() {
    setState(() {
      _roomsFuture = _guestApiService.fetchHotelRooms(widget.hotelId);
    });
  }

  void _deleteRoom(String roomId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تایید حذف'),
        content: const Text('آیا از حذف این اتاق اطمینان دارید؟'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('انصراف')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirm ?? false) {
      final success = await _managerApiService.deleteRoom(roomId);
      if (success) {
        _loadRooms();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('اتاق‌های هتل ${widget.hotelName}')),
      body: FutureBuilder<List<Room>>(
        future: _roomsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            if (snapshot.error.toString().contains('404')) {
              return const Center(child: Text('هتلی یافت نشد.'));
            }
            return Center(child: Text('خطا: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('اتاقی برای این هتل ثبت نشده است.'));
          }
          final rooms = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async => _loadRooms(),
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 400.0,
                childAspectRatio: 0.9,
                mainAxisSpacing: 16.0,
                crossAxisSpacing: 16.0,
              ),
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                final room = rooms[index];
                return RoomCard(
                  room: room,
                  onEdit: () async {
                    final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddRoomScreen(
                          hotelId: widget.hotelId,
                          room: room,
                        ),
                      ),
                    );
                    if (result == true) {
                      _loadRooms();
                    }
                  },
                  onDelete: () => _deleteRoom(room.id),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => AddRoomScreen(hotelId: widget.hotelId),
            ),
          );
          if (result == true) _loadRooms();
        },
        icon: const Icon(Icons.add),
        label: const Text('افزودن اتاق'),
      ),
    );
  }
}