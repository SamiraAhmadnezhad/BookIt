import 'package:flutter/material.dart';

class HotelCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String location;
  final double rating;
  final bool isFavorite;
  final int discount;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onReserveTap;

  const HotelCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.location,
    required this.rating,
    required this.isFavorite,
    required this.discount,
    required this.onTap,
    required this.onFavoriteToggle,
    required this.onReserveTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color customPurple = Color(0xFF542545);
    const Color discountRedText = Color(0xFF542545);
    const Color discountRedIcon = Color(0xFF542545);
    const Color discountBgColor = Color(0xFFFEEBEE);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.white,
        elevation: 3.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)), // کمی گردتر
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child:ClipRRect(
                      borderRadius: BorderRadius.circular(20.0), //  مقدار شعاع گردی را به دلخواه تنظیم کنید
                      child: Image.network(
                        imageUrl,
                        height: 155,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 155,
                           alignment: Alignment.center,
                          child: const Icon(Icons.broken_image_rounded, size: 40, color: Colors.grey),
                        ),
                      ),
                    )
                  ),
                  Positioned(
                    top: 20,
                    left: 20,
                    child: GestureDetector(
                      onTap: onFavoriteToggle,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: Icon(
                          Icons.favorite,
                          color: isFavorite ? customPurple : Colors.grey.shade400
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12.0, left: 12.0, top: 10.0, bottom: 6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        fontFamily: 'Vazirmatn',
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 20, color: Color(0xFF542545)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Vazirmatn',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: List.generate(5, (index) {
                        IconData starIcon;
                        if (index < rating.floor()) {
                          starIcon = Icons.star_rounded;
                        } else if (index < rating && index == rating.floor()) {
                          starIcon = Icons.star_half_rounded;
                        } else {
                          starIcon = Icons.star_border_rounded;
                        }
                        return Icon(
                          starIcon,
                          color:Color(0xFF542545),
                          size: 15,
                        );
                      }),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12.0, left: 12.0, bottom: 12.0, top: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        textDirection: TextDirection.ltr,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$discount% تخفیف', // متن عکس: 73% تخفیف
                            style: const TextStyle(
                              fontSize: 14,
                              color: discountRedText,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Vazirmatn',
                            ),
                          ),
                          const SizedBox(width: 3),
                          const Icon(
                            Icons.local_fire_department, // یا Icons.local_offer_outlined
                            size: 20,
                            color: discountRedIcon,
                          ),
                        ],
                      ),
                    ),
                    // بخش رزرو (سمت راست در UI، پس در Row دوم می آید)
                    InkWell(
                      onTap: onReserveTap,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              'رزرو',
                              style: TextStyle(
                                fontSize: 14,
                                color: customPurple,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Vazirmatn',
                              ),
                            ),
                            SizedBox(width: 2),
                            Icon(
                              Icons.arrow_forward, // این آیکون در RTL به چپ اشاره می کند
                              size: 20,
                              color: customPurple,
                            ),
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
      ),
    );
  }
}