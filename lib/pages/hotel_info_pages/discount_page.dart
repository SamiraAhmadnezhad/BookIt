import 'package:flutter/material.dart';
import 'dart:async'; // برای شبیه‌سازی و تاخیر

// --- Constants ---
const Color kManagerPrimaryColor = Color(0xFF542545);
const Color kPageBackgroundColor = Color(0xFFF0F0F0);
const Color kCardBackgroundColor = Colors.white;
const Color kDiscountOriginalPriceColor = Colors.grey; // رنگ قیمت اصلی
const Color kDiscountedPriceColor = kManagerPrimaryColor; // رنگ قیمت با تخفیف (بنفش)

// --- Model for Discountable Room ---
class DiscountableRoom {
  final String id;
  final String name;
  final String imageUrl;
  final int capacity;
  final String type;
  final double originalPricePerNight;
  bool isSelectedForDiscount;
  double? discountedPrice; // قیمت پس از تخفیف، می‌تواند null باشد

  DiscountableRoom({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.capacity,
    required this.type,
    required this.originalPricePerNight,
    this.isSelectedForDiscount = false,
    this.discountedPrice,
  });
}

class DiscountsPage extends StatefulWidget {
  const DiscountsPage({Key? key}) : super(key: key);

  @override
  State<DiscountsPage> createState() => _DiscountsPageState();
}

class _DiscountsPageState extends State<DiscountsPage> {
  List<DiscountableRoom> _rooms = [];
  bool _isLoading = true;
  double _discountPercentage = 50.0; // مقدار تخفیف پیش‌فرض از فیگما
  final TextEditingController _discountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _discountController.text = _discountPercentage.toStringAsFixed(0);
    _fetchDiscountableRooms();
  }

  @override
  void dispose() {
    _discountController.dispose();
    super.dispose();
  }

  // TODO: تابع برای دریافت لیست اتاق‌های قابل تخفیف از سرور
  Future<void> _fetchDiscountableRooms() async {
    setState(() { _isLoading = true; });
    await Future.delayed(const Duration(seconds: 1)); // شبیه‌سازی تاخیر شبکه
    setState(() {
      _rooms = [ // داده‌های نمونه
        DiscountableRoom(id: '1', name: 'اسم اتاق در حالت طولانی ...', imageUrl: 'https://picsum.photos/seed/discount_room1/200/300', capacity: 20, type: 'دو تخته', originalPricePerNight: 1200000),
        DiscountableRoom(id: '2', name: 'اسم اتاق در حالت طولانی ...', imageUrl: 'https://picsum.photos/seed/discount_room2/200/300', capacity: 5, type: 'سوئیت', originalPricePerNight: 3200000, isSelectedForDiscount: true), // یک اتاق نمونه انتخاب شده
        DiscountableRoom(id: '3', name: 'اسم اتاق در حالت طولانی ...', imageUrl: 'https://picsum.photos/seed/discount_room3/200/300', capacity: 15, type: 'اتاق ویژه', originalPricePerNight: 2800000),
        DiscountableRoom(id: '4', name: 'اتاق لوکس با نمای شهر', imageUrl: 'https://picsum.photos/seed/discount_room4/200/300', capacity: 2, type: 'دولوکس', originalPricePerNight: 4500000),
      ];
      _applyDiscountToSelectedRooms(); // اعمال تخفیف اولیه به اتاق‌های از قبل انتخاب شده
      _isLoading = false;
    });
  }

  void _applyDiscountToSelectedRooms() {
    final discountFactor = _discountPercentage / 100.0;
    setState(() {
      for (var room in _rooms) {
        if (room.isSelectedForDiscount) {
          room.discountedPrice = room.originalPricePerNight * (1 - discountFactor);
        } else {
          room.discountedPrice = null; // حذف تخفیف اگر انتخاب نشده
        }
      }
    });
  }

  void _onDiscountPercentageChanged(String value) {
    final newPercentage = double.tryParse(value);
    if (newPercentage != null && newPercentage >= 0 && newPercentage <= 100) {
      setState(() {
        _discountPercentage = newPercentage;
      });
      _applyDiscountToSelectedRooms();
    } else if (value.isEmpty){
      setState(() { _discountPercentage = 0; }); // یا هر مقدار پیش‌فرض دیگر
      _applyDiscountToSelectedRooms();
    }
  }

  // TODO: تابع برای ارسال اطلاعات تخفیف‌ها به سرور
  Future<void> _saveDiscounts() async {
    List<Map<String, dynamic>> discountedRoomsData = [];
    for (var room in _rooms) {
      if (room.isSelectedForDiscount && room.discountedPrice != null) {
        discountedRoomsData.add({
          'roomId': room.id,
          'discountPercentage': _discountPercentage,
          'originalPrice': room.originalPricePerNight,
          'discountedPrice': room.discountedPrice,
        });
      }
    }
    if (discountedRoomsData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('هیچ اتاقی برای اعمال تخفیف انتخاب نشده است.')));
      return;
    }
    debugPrint("TODO: Sending discount data to server: $discountedRoomsData");
    // شبیه‌سازی ذخیره
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تخفیف‌ها با موفقیت (شبیه‌سازی شده) اعمال شدند.')));
    }
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  Widget _buildDiscountInputSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      color: kPageBackgroundColor, // پس‌زمینه این بخش باید با پس‌زمینه کلی صفحه یکی باشد
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("اعمال تخفیف‌های ویژه", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87)),
              const Icon(Icons.percent, color: kManagerPrimaryColor, size: 30),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end, // برای چینش از راست
            children: [
              Text("%", style: theme.textTheme.titleMedium?.copyWith(color: Colors.black54)),
              const SizedBox(width: 8),
              SizedBox(
                width: 60, // عرض ثابت برای فیلد درصد
                height: 40, // ارتفاع ثابت
                child: TextFormField(
                  controller: _discountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: false),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: kCardBackgroundColor, // پس‌زمینه سفید برای فیلد
                    contentPadding: const EdgeInsets.symmetric(vertical: 8.0), // پدینگ داخلی
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(color: kManagerPrimaryColor, width: 1.5),
                    ),
                  ),
                  onChanged: _onDiscountPercentageChanged,
                ),
              ),
              const SizedBox(width: 8),
              Text("مقدار تخفیف : ", style: theme.textTheme.titleMedium?.copyWith(color: Colors.black54)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "اتاق‌هایی را که شامل تخفیف می‌شوند انتخاب کنید:",
            textAlign: TextAlign.right,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomItemForDiscount(DiscountableRoom room, ThemeData theme) {
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
            // Checkbox در سمت راست ترین قسمت
            SizedBox(
              width: 24, // فضای کافی برای چک‌باکس
              child: Checkbox(
                value: room.isSelectedForDiscount,
                onChanged: (bool? value) {
                  setState(() {
                    room.isSelectedForDiscount = value ?? false;
                    _applyDiscountToSelectedRooms(); // اعمال مجدد تخفیف با تغییر انتخاب
                  });
                },
                activeColor: kManagerPrimaryColor,
                visualDensity: VisualDensity.compact,
                side: BorderSide(color: Colors.grey.shade500, width: 1.5),
              ),
            ),
            const SizedBox(width: 10), // فاصله بین چک‌باکس و محتوای اصلی
            Expanded( // محتوای اصلی اتاق
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded( // اطلاعات متنی اتاق
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(room.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 6),
                        Row(children: [const Icon(Icons.people_alt_outlined, size: 18, color: Colors.grey), const SizedBox(width: 4), Text('ظرفیت: ${room.capacity}', style: theme.textTheme.bodyMedium)]),
                        const SizedBox(height: 3),
                        Row(children: [const Icon(Icons.home_outlined, size: 18, color: Colors.grey), const SizedBox(width: 4), Text('نوع: ${room.type}', style: theme.textTheme.bodyMedium)]),
                        const SizedBox(height: 10),
                        Text('تومان', style: theme.textTheme.bodySmall?.copyWith(color: kDiscountOriginalPriceColor)),
                        Text(_formatPrice(room.originalPricePerNight), style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: kDiscountOriginalPriceColor, decoration: room.isSelectedForDiscount ? TextDecoration.lineThrough : TextDecoration.none)),
                        if (room.isSelectedForDiscount && room.discountedPrice != null) ...[
                          const SizedBox(height: 4),
                          Text(_formatPrice(room.discountedPrice!), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: kDiscountedPriceColor)),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12), // فاصله بین متن و تصویر
                  Column( // تصویر و لیبل‌های قیمت
                    crossAxisAlignment: CrossAxisAlignment.end, // چینش از راست برای لیبل‌های قیمت
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(room.imageUrl, width: 100, height: 100, fit: BoxFit.cover, errorBuilder: (ctx, err, st) => Container(width: 100, height: 100, color: Colors.grey[200], child: const Icon(Icons.broken_image_outlined, size: 30))),
                      ),
                      const SizedBox(height: 8),
                      Text('قیمت یک شب', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]), textAlign: TextAlign.right),
                      if (room.isSelectedForDiscount)
                        Text('قیمت یک شب پس از تخفیف', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]), textAlign: TextAlign.right),
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


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: kPageBackgroundColor,
        appBar: AppBar(
          backgroundColor: kPageBackgroundColor, // یا kManagerPrimaryColor برای ظاهر متفاوت
          elevation: 0, // یا 1 اگر می‌خواهید کمی سایه داشته باشد
          title: Text('اعمال تخفیف', style: theme.textTheme.titleLarge?.copyWith(color: Colors.black87, fontWeight: FontWeight.bold)),
          centerTitle: true,
          leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: Colors.grey[700]), onPressed: () => Navigator.of(context).pop()),
          // actions: [ // دکمه ذخیره می‌تواند اینجا هم باشد
          //   TextButton(onPressed: _saveDiscounts, child: Text('ذخیره', style: TextStyle(color: kManagerPrimaryColor, fontWeight: FontWeight.bold)))
          // ],
        ),
        body: Column(
          children: [
            _buildDiscountInputSection(theme),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: kManagerPrimaryColor))
                  : _rooms.isEmpty
                  ? Center(child: Text('اتاقی برای اعمال تخفیف یافت نشد.', style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[700])))
                  : ListView.builder(
                padding: const EdgeInsets.only(bottom: 80.0), // فضا برای دکمه شناور یا دکمه پایین
                itemCount: _rooms.length,
                itemBuilder: (context, index) {
                  return _buildRoomItemForDiscount(_rooms[index], theme);
                },
              ),
            ),
          ],
        ),
        // دکمه ذخیره می‌تواند به صورت شناور یا ثابت در پایین باشد
        // مثال برای دکمه ثابت در پایین:
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _saveDiscounts,
            style: ElevatedButton.styleFrom(
              backgroundColor: kManagerPrimaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              textStyle: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            child: const Text('اعمال و ذخیره تخفیف‌ها'),
          ),
        ),
      ),
    );
  }
}