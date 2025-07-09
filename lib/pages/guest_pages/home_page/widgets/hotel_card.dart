// lib/pages/your_path/widgets/hotel_card.dart

import 'package:bookit/pages/guest_pages/home_page/model/hotel_model.dart';
import 'package:flutter/material.dart';

import '../../hotel_detail_page/hotel_detail_page.dart';
class HotelCard extends StatefulWidget {
  final Hotel hotel;

  const HotelCard({
    super.key,
    required this.hotel,
  });

  @override
  State<HotelCard> createState() => _HotelCardState();
}

class _HotelCardState extends State<HotelCard> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    // <<< اصلاح شد: استفاده از فیلد isCurrentlyFavorite >>>
    _isFavorite = widget.hotel.isCurrentlyFavorite;
  }

  @override
  Widget build(BuildContext context) {
    const Color customPurple = Color(0xFF542545);
    // <<< اصلاح شد: استفاده از فیلد discount که از قبل double است >>>
    final double discount = widget.hotel.discount;

    void goToDetailsPage() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HotelDetailsPage(hotel: widget.hotel)),
      );
    }

    return SizedBox(
      width: 290, // کمی عرض را برای پدینگ بیشتر می‌کنیم
      child: Card(
        elevation: 5.0,
        shadowColor: Colors.black.withOpacity(0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: goToDetailsPage,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageSection(context, customPurple),
              _buildInfoSection(context, customPurple, discount, goToDetailsPage),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context, Color customPurple) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 16 / 10,
          child: Image.network(
            // <<< اصلاح شد: استفاده از فیلد imageUrl >>>
            widget.hotel.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey.shade200,
              alignment: Alignment.center,
              child: const Icon(Icons.business_rounded, size: 50, color: Colors.grey),
            ),
          ),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  // <<< اصلاح شد: استفاده از فیلد rating >>>
                  widget.hotel.rating.toStringAsFixed(1),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 10,
          left: 10,
          child: GestureDetector(
            onTap: () {
              setState(() => _isFavorite = !_isFavorite);
              // TODO: این تغییر باید به سرور هم اطلاع داده شود
            },
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 18,
              child: Icon(
                _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: _isFavorite ? Colors.redAccent : Colors.grey.shade400,
                size: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context, Color customPurple, double discount, VoidCallback onTap) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.hotel.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    // <<< اصلاح شد: استفاده از فیلد address >>>
                    widget.hotel.address,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // نمایش تخفیف یا یک فضای خالی برای حفظ چیدمان
                if (discount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8)
                    ),
                    child: Text(
                      '${discount.toStringAsFixed(0)}% تخفیف',
                      style: const TextStyle(fontSize: 13, color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  )
                else
                  const SizedBox(), // فضای خالی برای حفظ چیدمان

                // دکمه نمایش جزئیات
                InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
                    child: Row(
                      children: [
                        Text('مشاهده جزئیات', style: TextStyle(fontSize: 14, color: customPurple, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward_ios_rounded, size: 16, color: customPurple),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}