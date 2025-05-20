import 'package:flutter/material.dart';
import 'dart:async';
import 'add_room_page.dart';
import 'discount_page.dart';

const Color kManagerPrimaryColor = Color(0xFF542545);
const Color kPageBackgroundColor = Color(0xFFF0F0F0);
const Color kCardBackgroundColor = Colors.white;

class Room {
  final String id;
  final String name;
  final String imageUrl;
  final int capacity;
  final String type;
  final double pricePerNight;

  Room({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.capacity,
    required this.type,
    required this.pricePerNight,
  });
}

class _RoomCardWidget extends StatelessWidget {
  final Room room;
  final VoidCallback onDelete;

  const _RoomCardWidget({
    required this.room,
    required this.onDelete,
  });

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: kCardBackgroundColor,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                room.imageUrl,
                width: 100,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 100,
                    height: 120,
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: Colors.grey[400],
                      size: 40,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.name,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.people_alt_outlined, 'ظرفیت: ${room.capacity}', theme),
                  const SizedBox(height: 4),
                  _buildInfoRow(Icons.home_outlined, 'نوع: ${room.type}', theme),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'قیمت یک شب',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '${_formatPrice(room.pricePerNight)} تومان',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: kManagerPrimaryColor,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: onDelete,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kManagerPrimaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          textStyle: theme.textTheme.labelLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 1,
                        ),
                        child: const Text('حذف'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[700]),
        const SizedBox(width: 6),
        Text(text, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54)),
      ],
    );
  }
}


class RoomInfoPage extends StatefulWidget {
  const RoomInfoPage({Key? key}) : super(key: key);

  @override
  State<RoomInfoPage> createState() => _RoomInfoPageState();
}

class _RoomInfoPageState extends State<RoomInfoPage> {
  List<Room> _rooms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRoomsData();
  }

  // TODO: تابع برای دریافت اطلاعات اتاق‌ها از سرور
  Future<void> _fetchRoomsData() async {
    setState(() { _isLoading = true; });
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _rooms = [
        Room(
          id: '1',
          name: 'اسم اتاق در حالت طولانی',
          imageUrl: 'https://picsum.photos/seed/hotelA/200/300',
          capacity: 20,
          type: 'دو تخته',
          pricePerNight: 1200000,
        ),
        Room(
          id: '2',
          name: 'اسم اتاق در حالت طولانی برای مثال و تست نمایش ...',
          imageUrl: 'https://picsum.photos/seed/hotelB/200/300',
          capacity: 5,
          type: 'سوئیت',
          pricePerNight: 3200000,
        ),
        Room(
          id: '3',
          name: 'اتاق دیگری با توضیحات کامل',
          imageUrl: 'https://picsum.photos/seed/hotelC/200/300',
          capacity: 15,
          type: 'اتاق ویژه',
          pricePerNight: 2800000,
        ),
        Room(
          id: '4',
          name: 'اتاق لوکس با نمای دریا و امکانات کامل رفاهی',
          imageUrl: 'https://picsum.photos/seed/hotelD/200/300',
          capacity: 2,
          type: 'دولوکس',
          pricePerNight: 4500000,
        ),
      ];
      _isLoading = false;
    });
  }

  // TODO: تابع برای حذف اتاق از سرور
  Future<void> _deleteRoom(String roomId) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('تایید حذف', textAlign: TextAlign.right),
          content: const Text('آیا از حذف این اتاق اطمینان دارید؟', textAlign: TextAlign.right),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            TextButton(
              child: const Text('لغو'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
              child: const Text('حذف'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      debugPrint('TODO: Call API to delete room $roomId');
      setState(() {
        _rooms.removeWhere((room) => room.id == roomId);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('اتاق با موفقیت حذف شد'),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
          ),
        );
      }
    }
  }

  void _navigateToAddRoomPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddRoomPage()),
    );
  }

  void _navigateToDiscountsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DiscountsPage()),
    );
  }

  Widget _buildHeaderActionItem(IconData iconData, String label, VoidCallback? onPressed, ThemeData theme, {required bool isTitle}) {
    Widget rowContent = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isTitle ? Colors.transparent : kManagerPrimaryColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            iconData,
            color: isTitle ? kManagerPrimaryColor : Colors.white,
            size: isTitle ? 24 : 18,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.black.withOpacity(0.85),
          ),
        ),
      ],
    );

    if (onPressed != null && !isTitle) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
            child: rowContent,
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        child: rowContent,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: kPageBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderActionItem(Icons.add, 'افزودن اتاق جدید', _navigateToAddRoomPage, theme, isTitle: false),
                    _buildHeaderActionItem(Icons.percent_rounded, 'اعمال تخفیف‌های ویژه', _navigateToDiscountsPage, theme, isTitle: false),
                    _buildHeaderActionItem(Icons.list_alt_outlined, 'لیست اتاق‌های هتل', null, theme, isTitle: true), // onPressed is null
                  ],
                ),
              ),
              // Divider(height: 1, thickness: 1, color: Colors.grey[300], indent: 16, endIndent: 16),

              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: kManagerPrimaryColor))
                    : _rooms.isEmpty
                    ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'هیچ اتاقی برای نمایش وجود ندارد. برای افزودن اتاق جدید از گزینه بالا استفاده کنید.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
                      ),
                    ))
                    : ListView.builder(
                  padding: const EdgeInsets.only(top: 0, bottom: 16),
                  itemCount: _rooms.length,
                  itemBuilder: (context, index) {
                    final room = _rooms[index];
                    return _RoomCardWidget(
                      room: room,
                      onDelete: () => _deleteRoom(room.id),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}