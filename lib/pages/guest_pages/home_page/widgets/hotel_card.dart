// فایل: widgets/hotel_card.dart
import 'package:flutter/material.dart';
import '../model/hotel_model.dart'; // مسیر مدل هتل
import '../../hotel_detail_page/hotel_detail_page.dart'; // مسیر صفحه جزئیات

class HotelCard extends StatefulWidget {
  // تنها ورودی مورد نیاز، خود آبجکت هتل است
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
    _isFavorite = widget.hotel.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    const Color customPurple = Color(0xFF542545);
    final double discount = widget.hotel.discount ?? 0;

    void goToDetailsPage() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HotelDetailsPage(hotelId: widget.hotel.id.toString())),
      );
    }

    return SizedBox(
      width: 280, // عرض ثابت برای کارت‌ها در لیست افقی
      child: Card(
        elevation: 3.0,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: goToDetailsPage,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.network(
                        widget.hotel.imageUrl ?? 'https://picsum.photos/seed/${widget.hotel.id}/400/300',
                        height: 155,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 155,
                          alignment: Alignment.center,
                          child: const Icon(Icons.broken_image_rounded, size: 40, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 20,
                    left: 20,
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _isFavorite = !_isFavorite);
                        // TODO: این تغییر باید به سرور هم اطلاع داده شود
                      },
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 4, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: Icon(Icons.favorite, color: _isFavorite ? customPurple : Colors.grey.shade400),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12.0, 0, 12.0, 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        widget.hotel.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.hotel.location,
                              style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            children: List.generate(5, (index) => Icon(
                              index < widget.hotel.rate ? Icons.star_rounded : Icons.star_border_rounded,
                              color: customPurple,
                              size: 15,
                            )),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (discount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6)
                              ),
                              child: Text(
                                '${discount.toStringAsFixed(0)}% تخفیف',
                                style: const TextStyle(fontSize: 13, color: Colors.red, fontWeight: FontWeight.bold),
                              ),
                            ),
                          InkWell(
                            onTap: goToDetailsPage,
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
                              child: Row(
                                children: const [
                                  Text('رزرو', style: TextStyle(fontSize: 14, color: customPurple, fontWeight: FontWeight.bold)),
                                  SizedBox(width: 2),
                                  Icon(Icons.arrow_forward, size: 20, color: customPurple),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}