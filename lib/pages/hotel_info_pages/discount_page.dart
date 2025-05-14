import 'package:flutter/material.dart';
import 'dart:async';

const Color kManagerPrimaryColor = Color(0xFF542545);
const Color kPageBackgroundColor = Color(0xFFF0F0F0);
const Color kCardBackgroundColor = Colors.white;
const Color kDiscountOriginalPriceColor = Colors.grey;
const Color kDiscountedPriceColor = kManagerPrimaryColor;

class DiscountableRoom {
  final String id;
  final String name;
  final String imageUrl;
  final int capacity;
  final String type;
  final double originalPricePerNight;
  bool isSelectedForDiscount;
  double? discountedPrice;

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
  double _discountPercentage = 50.0;
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
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _rooms = [
        DiscountableRoom(id: '1', name: 'اسم اتاق در حالت طولانی ...', imageUrl: 'https://picsum.photos/seed/discount_room1_rtl/200/300', capacity: 20, type: 'دو تخته', originalPricePerNight: 1200000, isSelectedForDiscount: true),
        DiscountableRoom(id: '2', name: 'اسم اتاق در حالت طولانی برای مثال و تست نمایش ...', imageUrl: 'https://picsum.photos/seed/discount_room2_rtl/200/300', capacity: 5, type: 'سوئیت', originalPricePerNight: 3200000),
        DiscountableRoom(id: '3', name: 'اتاق دیگری با توضیحات کامل و امکانات ویژه برای مسافران', imageUrl: 'https://picsum.photos/seed/discount_room3_rtl/200/300', capacity: 15, type: 'اتاق ویژه', originalPricePerNight: 2800000, isSelectedForDiscount: true),
      ];
      _applyDiscountToSelectedRooms();
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
          room.discountedPrice = null;
        }
      }
    });
  }

  void _onDiscountPercentageChanged(String value) {
    final newPercentage = double.tryParse(value);
    if (newPercentage != null && newPercentage >= 0 && newPercentage <= 100) {
      setState(() { _discountPercentage = newPercentage; });
    } else if (value.isEmpty){
      setState(() { _discountPercentage = 0; });
    } else if (newPercentage != null && newPercentage > 100) {
      _discountController.text = "100";
      setState(() { _discountPercentage = 100; });
    }
    _applyDiscountToSelectedRooms();
  }

  // TODO: تابع برای ارسال اطلاعات تخفیف‌ها به سرور
  Future<void> _saveDiscounts() async {
    List<Map<String, dynamic>> discountedRoomsData = _rooms
        .where((room) => room.isSelectedForDiscount && room.discountedPrice != null)
        .map((room) => {
      'roomId': room.id, 'discountPercentage': _discountPercentage,
      'originalPrice': room.originalPricePerNight, 'discountedPrice': room.discountedPrice,
    }).toList();

    if (discountedRoomsData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('هیچ اتاقی برای اعمال تخفیف انتخاب نشده است.')));
      return;
    }
    debugPrint("TODO: Sending discount data to server: $discountedRoomsData");
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
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 12.0),
      color: kPageBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("اعمال تخفیف‌های ویژه", textAlign: TextAlign.right, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87)),
              Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: kManagerPrimaryColor, shape: BoxShape.circle,), child: const Icon(Icons.percent, color: Colors.white, size: 20),),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text("  مقدار تخفیف :", textAlign: TextAlign.right, style: theme.textTheme.titleMedium?.copyWith(color: Colors.black54)),
              const SizedBox(width: 8),
              SizedBox(width: 70, height: 40,
                child: TextFormField(
                  controller: _discountController, keyboardType: const TextInputType.numberWithOptions(decimal: false), textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
                  decoration: InputDecoration(
                    filled: true, fillColor: kCardBackgroundColor, contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide(color: Colors.grey.shade300)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide(color: Colors.grey.shade300)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: const BorderSide(color: kManagerPrimaryColor, width: 1.5)),
                  ),
                  onChanged: _onDiscountPercentageChanged,
                ),
              ),
              const SizedBox(width: 4),
              Text("%", style: theme.textTheme.titleMedium?.copyWith(color: Colors.black54)),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: Text(
              "اتاق‌هایی را که شامل تخفیف می‌شوند انتخاب کنید:",
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomItemForDiscount(DiscountableRoom room, ThemeData theme) {
    return Card(
      color: kCardBackgroundColor,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 12.0, 12.0, 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(room.imageUrl, width: 100, height: 110, fit: BoxFit.cover, errorBuilder: (ctx, err, st) => Container(width: 100, height: 110, color: Colors.grey[200], child: const Icon(Icons.broken_image_outlined, size: 30))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(room.name, textAlign: TextAlign.right, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 6),
                        Row(mainAxisAlignment: MainAxisAlignment.start, children: [const Icon(Icons.people_alt_outlined, size: 16, color: Colors.black), const SizedBox(width: 4), Text('ظرفیت: ${room.capacity}', textAlign: TextAlign.right, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700]))]),
                        const SizedBox(height: 3),
                        Row(mainAxisAlignment: MainAxisAlignment.start, children: [const Icon(Icons.home_outlined, size: 16, color: Colors.black), const SizedBox(width: 4), Text('نوع: ${room.type}', textAlign: TextAlign.right, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700]))]),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_formatPrice(room.originalPricePerNight), style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: kDiscountOriginalPriceColor, decoration: room.isSelectedForDiscount ? TextDecoration.lineThrough : TextDecoration.none, decorationThickness: 1.5)),
                                if (room.isSelectedForDiscount && room.discountedPrice != null) ...[
                                  const SizedBox(height: 2),
                                  Text(_formatPrice(room.discountedPrice!), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: kDiscountedPriceColor)),
                                ],
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('قیمت یک شب', textAlign: TextAlign.right, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                                if (room.isSelectedForDiscount)
                                  Text('قیمت یک شب پس از تخفیف', textAlign: TextAlign.right, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 24, height: 24,
              child: Checkbox(
                value: room.isSelectedForDiscount,
                onChanged: (bool? value) { setState(() { room.isSelectedForDiscount = value ?? false; _applyDiscountToSelectedRooms(); }); },
                activeColor: kManagerPrimaryColor, visualDensity: VisualDensity.compact, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, side: BorderSide(color: Colors.grey.shade500, width: 1.5),
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
        appBar: AppBar(backgroundColor: kPageBackgroundColor, elevation: 0, leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: Colors.grey[700]), onPressed: () => Navigator.of(context).pop()),),
        body: Column(
          children: [
            _buildDiscountInputSection(theme),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: kManagerPrimaryColor))
                  : _rooms.isEmpty
                  ? Center(child: Text('اتاقی برای اعمال تخفیف یافت نشد.', textAlign: TextAlign.center, style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[700])))
                  : ListView.builder(
                padding: const EdgeInsets.only(bottom: 90.0, top: 4.0), itemCount: _rooms.length,
                itemBuilder: (context, index) { return _buildRoomItemForDiscount(_rooms[index], theme); },
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          color: kPageBackgroundColor, padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 24.0),
          child: ElevatedButton(
            onPressed: _saveDiscounts,
            style: ElevatedButton.styleFrom(backgroundColor: kManagerPrimaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), textStyle: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),),
            child: const Text('اعمال و ذخیره تخفیف‌ها'),
          ),
        ),
      ),
    );
  }
}