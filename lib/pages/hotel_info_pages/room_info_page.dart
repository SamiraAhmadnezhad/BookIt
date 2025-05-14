// lib/pages/hotel_info_pages/hotel_info_page.dart
import 'package:flutter/material.dart';
import 'dart:async'; // برای Future.delayed

// --- ثابت رنگ اصلی ---
const Color kManagerPrimaryColor = Color(0xFF542545);

// --- مدل داده برای اتاق ---
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

// --- ویجت کارت اتاق ---
class _RoomCardWidget extends StatelessWidget {
  final Room room;
  final VoidCallback onDelete;

  const _RoomCardWidget({
    required this.room,
    required this.onDelete,
  });

  // تابع کمکی برای فرمت قیمت با ویرگول
  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // استفاده از تم Material 3

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2, // Material 3 از elevation کمتری استفاده می‌کند
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
                    color: theme.colorScheme.surfaceVariant, // رنگ مناسب برای placeholder در M3
                    child: Icon(
                      Icons.broken_image,
                      color: theme.colorScheme.onSurfaceVariant,
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    room.name,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  _buildInfoRow(Icons.people_alt_outlined, 'ظرفیت: ${room.capacity} نفر', theme),
                  const SizedBox(height: 3),
                  _buildInfoRow(Icons.king_bed_outlined, 'نوع: ${room.type}', theme),
                  const SizedBox(height: 8),
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
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            '${_formatPrice(room.pricePerNight)} تومان',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: kManagerPrimaryColor, // رنگ بنفش برای قیمت
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: onDelete,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kManagerPrimaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          textStyle: theme.textTheme.labelLarge?.copyWith(color: Colors.white),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
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
        Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7)),
        const SizedBox(width: 6),
        Text(text, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}


// --- صفحه اصلی مدیریت اطلاعات هتل/اتاق‌ها ---
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
    // شبیه‌سازی تاخیر شبکه
    await Future.delayed(const Duration(seconds: 1));

    // داده‌های نمونه - این بخش باید با فراخوانی API واقعی جایگزین شود
    // استفاده از picsum.photos برای تنوع تصاویر
    setState(() {
      _rooms = [
        Room(
          id: '1',
          name: 'اسم اتاق در حالت طولانی ...',
          imageUrl: 'https://picsum.photos/seed/r1/200/300',
          capacity: 20,
          type: 'دو تخته',
          pricePerNight: 1200000,
        ),
        Room(
          id: '2',
          name: 'اسم اتاق در حالت طولانی برای مثال ...',
          imageUrl: 'https://picsum.photos/seed/r2/200/300',
          capacity: 5,
          type: 'سوئیت',
          pricePerNight: 3200000,
        ),
        Room(
          id: '3',
          name: 'اتاق دیگری با توضیحات بیشتر ...',
          imageUrl: 'https://picsum.photos/seed/r3/200/300',
          capacity: 15,
          type: 'اتاق ویژه',
          pricePerNight: 2800000,
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
          title: const Text('تایید حذف'),
          content: const Text('آیا از حذف این اتاق اطمینان دارید؟'),
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
      // اینجا باید API حذف اتاق از سرور کال شود
      // مثال: await ApiService.deleteRoom(roomId);
      debugPrint('TODO: Call API to delete room $roomId');

      setState(() {
        _rooms.removeWhere((room) => room.id == roomId);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('اتاق با موفقیت حذف شد'), behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  // TODO: تابع برای ناوبری به صفحه افزودن اتاق جدید
  void _navigateToAddRoomPage() {
    debugPrint('TODO: Navigate to Add New Room Page');
    // Navigator.push(context, MaterialPageRoute(builder: (context) => AddRoomPage()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('به صفحه افزودن اتاق جدید هدایت می‌شوید...'), behavior: SnackBarBehavior.floating),
    );
  }

  // TODO: تابع برای ناوبری به صفحه اعمال تخفیف‌های ویژه
  void _navigateToDiscountsPage() {
    debugPrint('TODO: Navigate to Special Discounts Page');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('به صفحه تخفیف‌های ویژه هدایت می‌شوید...'), behavior: SnackBarBehavior.floating),
    );
  }

  // TODO: تابع برای نمایش لیست کامل اتاق‌های هتل (اگر این صفحه خودش نیست)
  void _navigateToHotelRoomsList() {
    debugPrint('TODO: Navigate to Hotel Rooms List Page or refresh');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('لیست اتاق‌های هتل نمایش داده می‌شود...'), behavior: SnackBarBehavior.floating),
    );
  }

  Widget _buildActionItem(IconData icon, String label, VoidCallback onPressed, ThemeData theme) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Row(
          children: [
            Icon(icon, color: kManagerPrimaryColor, size: 26),
            const SizedBox(width: 16),
            Text(label, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500)),
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
        // AppBar در تصویر شما نبود، اما اگر نیاز داشتید، می‌توانید اضافه کنید:
        // appBar: AppBar(
        //   title: Text('مدیریت اتاق‌ها', style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onPrimary)),
        //   backgroundColor: theme.colorScheme.primary,
        //   elevation: 2,
        // ),
        backgroundColor: theme.colorScheme.background, // استفاده از رنگ پس‌زمینه تم
        body: SafeArea(
          child: Column(
            children: [
              // بخش بالایی با گزینه‌ها
              Container(
                color: theme.cardColor, // یا theme.colorScheme.surface برای تطابق با M3
                padding: const EdgeInsets.only(top:8.0, bottom:0),
                child: Column(
                  children: [
                    _buildActionItem(Icons.add_circle_outline, 'افزودن اتاق جدید', _navigateToAddRoomPage, theme),
                    _buildActionItem(Icons.percent_outlined, 'اعمال تخفیف‌های ویژه', _navigateToDiscountsPage, theme),
                    _buildActionItem(Icons.list_alt_outlined, 'لیست اتاق‌های هتل', _navigateToHotelRoomsList, theme),
                  ],
                ),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _rooms.isEmpty
                    ? Center(
                    child: Text(
                      'هیچ اتاقی برای نمایش وجود ندارد.',
                      style: theme.textTheme.titleMedium,
                    ))
                    : ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 16), // فاصله برای اسکرول
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
        // اگر bottomNavigationBar هم دارید، اینجا اضافه کنید
        // bottomNavigationBar: BottomNavigationBar(
        //   items: const [
        //      BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'اتاق‌ها'),
        //      BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'تنظیمات'),
        //   ],
        // ),
      ),
    );
  }
}