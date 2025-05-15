import 'package:flutter/material.dart';
import 'dart:async';

const Color kManagerPrimaryColor = Color(0xFF542545);
const Color kPageBackgroundColor = Color(0xFFF0F0F0);
const Color kCardBackgroundColor = Colors.white;
const Color kInfoIconColor = Color(0xFF542545); //

class ReservedRoomInfo {
  final String id;
  final String roomName;
  final String roomImageUrl;
  final int capacity;
  final String roomType;
  final String reservedByUserName;


  ReservedRoomInfo({
    required this.id,
    required this.roomName,
    required this.roomImageUrl,
    required this.capacity,
    required this.roomType,
    required this.reservedByUserName,
  });
}

class ReservedRoomsPage extends StatefulWidget {
  const ReservedRoomsPage({Key? key}) : super(key: key);

  @override
  State<ReservedRoomsPage> createState() => _ReservedRoomsPageState();
}

class _ReservedRoomsPageState extends State<ReservedRoomsPage> {
  List<ReservedRoomInfo> _reservedRooms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReservedRoomsData();
  }

  Future<void> _fetchReservedRoomsData() async {
    setState(() { _isLoading = true; });
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _reservedRooms = [
        ReservedRoomInfo(id: 'res1', roomName: 'اسم اتاق در حالت طولانی ...', roomImageUrl: 'https://picsum.photos/seed/reserved_room1/200/300', capacity: 2, roomType: 'دو تخته', reservedByUserName: 'علی علوی'),
        ReservedRoomInfo(id: 'res2', roomName: 'اسم اتاق در حالت طولانی برای مثال ...', roomImageUrl: 'https://picsum.photos/seed/reserved_room2/200/300', capacity: 2, roomType: 'دو تخته', reservedByUserName: 'سارا محمدی'),
        ReservedRoomInfo(id: 'res3', roomName: 'سوئیت مجلل با نمای شهر و امکانات کامل', roomImageUrl: 'https://picsum.photos/seed/reserved_room3/200/300', capacity: 4, roomType: 'سوئیت', reservedByUserName: 'رضا احمدی'),
        ReservedRoomInfo(id: 'res4', roomName: 'اتاق استاندارد یک نفره اقتصادی', roomImageUrl: 'https://picsum.photos/seed/reserved_room4/200/300', capacity: 1, roomType: 'یک تخته', reservedByUserName: 'مریم رضایی'),
      ];
      _isLoading = false;
    });
  }

  void _showMoreReservationInfo(BuildContext context, ReservedRoomInfo roomInfo) {
    debugPrint("TODO: Show more info for reservation ID: ${roomInfo.id}");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('اطلاعات بیشتر برای اتاق ${roomInfo.roomName} رزرو شده توسط ${roomInfo.reservedByUserName}')),
    );
  }


  Widget _buildReservedRoomCard(ReservedRoomInfo room, ThemeData theme) {
    return Card(
      color: kCardBackgroundColor,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.network(
                room.roomImageUrl,
                width: 110,
                height: 110,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, st) => Container(width: 110, height: 110, color: Colors.grey, child: const Icon(Icons.broken_image_outlined, size: 40, color: Colors.grey)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(room.roomName, textAlign: TextAlign.right, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [const Icon(Icons.people_alt_outlined, size: 18, color: kManagerPrimaryColor), const SizedBox(width: 6), Text('تعداد افراد : ${room.capacity}', textAlign: TextAlign.right, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[800]))]),
                  const SizedBox(height: 4),
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [const Icon(Icons.king_bed_outlined, size: 18, color: kManagerPrimaryColor), const SizedBox(width: 6), Text('نوع : ${room.roomType}', textAlign: TextAlign.right, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[800]))]),
                  const SizedBox(height: 12),
                  Text('رزرو شده توسط : ${room.reservedByUserName}', textAlign: TextAlign.right, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700])),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _showMoreReservationInfo(context, room),
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.info_outline_rounded, size: 18, color: kInfoIconColor),
                          const SizedBox(width: 6),
                          Text('اطلاعات بیشتر', textAlign: TextAlign.right, style: theme.textTheme.bodyMedium?.copyWith(color: kInfoIconColor)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: kPageBackgroundColor,
        appBar: AppBar(
          backgroundColor: kPageBackgroundColor,
          elevation: 0,
          scrolledUnderElevation: 1,
          title: Text(
            'لیست اتاق‌های رزرو شده',
            textAlign: TextAlign.right,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          centerTitle: false,
          actions: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Icon(Icons.list_alt_rounded, color: Colors.black54, size: 28),
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: kManagerPrimaryColor))
            : _reservedRooms.isEmpty
            ? Center(child: Text('هیچ اتاق رزرو شده‌ای برای نمایش وجود ندارد.', textAlign: TextAlign.center, style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[700])))
            : ListView.builder(
          padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
          itemCount: _reservedRooms.length, // Added itemCount
          itemBuilder: (context, index) {
            return _buildReservedRoomCard(_reservedRooms[index], theme);
          },
        ),
      ),
    );
  }
}