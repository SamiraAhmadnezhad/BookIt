import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HotelSearchListCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String location;
  final int price;
  final double discount_price;
  final VoidCallback? onReserveTap;

  const HotelSearchListCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.location,
    required this.price,
    this.onReserveTap,
    required this.discount_price,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryActionColor = Color(0xFF542545);
    final Color mainTextColor = Colors.grey.shade800;
    final bool hasDiscount = discount_price > 0;
    final finalPrice = hasDiscount ? discount_price : price.toDouble();
    final priceFormat = NumberFormat('#,###');

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Card(
          color: Colors.white,
          elevation: 3.0,
          margin: const EdgeInsets.symmetric(vertical: 6.0),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.network(
                          imageUrl,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                height: 180,
                                color: Colors.grey[200],
                                alignment: Alignment.center,
                                child: Icon(Icons.broken_image_outlined,
                                    size: 50, color: Colors.grey[400]),
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding:
                  const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.5,
                          color: mainTextColor,
                          fontFamily: 'Vazirmatn',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.paid,
                                  color: primaryActionColor, size: 22),
                              SizedBox(width: 6),
                              Text(
                                "قیمت 1 شب",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontFamily: 'Vazirmatn',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (hasDiscount)
                                Text(
                                  '${priceFormat.format(price)} تومان',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontFamily: 'Vazirmatn',
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              Row(
                                crossAxisAlignment:
                                CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    priceFormat.format(finalPrice),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: hasDiscount
                                          ? Colors.red.shade700
                                          : primaryActionColor,
                                      fontFamily: 'Vazirmatn',
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    "تومان",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black,
                                      fontFamily: 'Vazirmatn',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  color: primaryActionColor, size: 22),
                              const SizedBox(width: 6),
                              Text(
                                location,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black,
                                  fontFamily: 'Vazirmatn',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: onReserveTap,
                            borderRadius: BorderRadius.circular(8),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 4.0, horizontal: 2.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "رزرو",
                                    style: TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.bold,
                                      color: primaryActionColor,
                                      fontFamily: 'Vazirmatn',
                                    ),
                                  ),
                                  SizedBox(width: 3),
                                  Icon(
                                    Icons.arrow_forward,
                                    size: 20,
                                    color: primaryActionColor,
                                    weight: 50,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}