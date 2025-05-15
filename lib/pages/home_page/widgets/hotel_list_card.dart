import 'package:flutter/material.dart';

class HotelListCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String location; // Kept for API compatibility, not displayed as dynamic text in this version
  final double rating;   // Used for both star display and numeric rating
  final bool isFavorite;
  final int price;      // Interpreted from original 'discount' parameter
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onReserveTap;

  const HotelListCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.location,
    required this.rating,
    required this.isFavorite,
    required this.price,
    this.onTap,
    this.onFavoriteToggle,
    this.onReserveTap,
  });

  @override
  Widget build(BuildContext context) {
    // Consistent colors based on the image
    const Color primaryActionColor = Color(0xFF542545); // Deep purple from image
    final Color mainTextColor = Colors.grey.shade800;
    final Color secondaryTextColor = Colors.grey.shade600;


    return Directionality(
      textDirection: TextDirection.rtl,
      child: Card(
        color: Colors.white,
        elevation: 3.0,
        margin: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        clipBehavior: Clip.antiAlias, // Clips the image to the card's rounded corners
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Image Section with Favorite and Thumbs-up Rating ---
              Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Image.network(
                      imageUrl,
                      height: 180, // Adjust height as needed
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 180,
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: Icon(Icons.broken_image_outlined, size: 50, color: Colors.grey[400]),
                      ),
                    ),
                  ),
                  // Favorite Icon (Visually Top-Left on the image)
                  Positioned(
                    top: 22,
                    left: 22,
                    child: GestureDetector(
                      onTap: onFavoriteToggle,
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
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
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? primaryActionColor : Colors.grey.shade400,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  // Numeric Rating (Visually Top-Right on the image)
                  Positioned(
                    top: 22,
                    right: 22,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white, // Semi-transparent background
                        borderRadius: BorderRadius.circular(20), // Pill shape
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            rating.toStringAsFixed(1), // e.g., "4.5"
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              fontFamily: 'Vazirmatn', // Ensure this font is in your project
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Icon(Icons.thumb_up, color: primaryActionColor, size: 15),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // --- Details Section ---
              Padding(
                padding: const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hotel Name and Star Rating
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.5,
                              color: mainTextColor,
                              fontFamily: 'Vazirmatn',
                            ),
                            maxLines: 1, // Single line for name as in image
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.start, // Aligns to right in RTL
                          ),
                        ),
                        const SizedBox(width: 10),
                        Row( // Star display
                          children: List.generate(5, (index) {
                            return Icon(
                              index < rating.round() ? Icons.star_rounded : Icons.star_border_rounded,
                              color: primaryActionColor,
                              size: 20,
                            );
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Price Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Right part (in RTL): "شروع قیمت از"
                        Row(
                          children: [
                            const Icon(Icons.paid, color: primaryActionColor, size: 22), // Coin/price icon
                            const SizedBox(width: 6),
                            Text(
                              "شروع قیمت از",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                fontFamily: 'Vazirmatn',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        // Left part (in RTL): Price + "تومان"
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [

                            Text(
                              "تومان",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                                fontFamily: 'Vazirmatn',
                              ),
                            ),
                            Text(
                              price.toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: primaryActionColor,
                                fontFamily: 'Vazirmatn',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Location and Reserve Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: primaryActionColor, size: 22),
                            const SizedBox(width: 6),
                            Text(
                              "مکان هتل", // Static label from image
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black,
                                fontFamily: 'Vazirmatn',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        // Left part (in RTL): "رزرو" Button
                        InkWell(
                          onTap: onReserveTap,
                          borderRadius: BorderRadius.circular(8),
                          child: Padding( // Add padding for better tap area
                            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
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
                                  Icons.arrow_forward, // Points left in RTL for "forward"
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
    );
  }
}