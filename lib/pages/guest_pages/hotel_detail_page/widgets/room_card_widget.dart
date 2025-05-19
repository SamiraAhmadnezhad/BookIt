import 'package:flutter/material.dart';
import '../data/models/room_model.dart';
import '../utils/constants.dart'; // Import constants

class RoomCardWidget extends StatelessWidget {
  final Room room;
  final VoidCallback onBookNow;

  const RoomCardWidget({
    Key? key,
    required this.room,
    required this.onBookNow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: kLightGrayColor, // Using constant
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontSize: 15.5,
                        fontFamily: 'Vazirmatn-Bold'),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.group_outlined, size: 18, color: kPrimaryColor),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          "1 اتاق ${room.capacity} تخته",
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54, fontSize: 12.5, fontFamily: 'Vazirmatn'),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.restaurant_menu_outlined, size: 18, color: kPrimaryColor),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          room.mealInfo,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54, fontSize: 12.5, fontFamily: 'Vazirmatn'),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "قیمت برای ۱ شب",
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.black54, fontSize: 10, fontFamily: 'Vazirmatn'),
                          ),
                          Text(
                            "${room.pricePerNight} تومان",
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: kPrimaryColor,
                                fontSize: 14,
                                fontFamily: 'Vazirmatn-Bold'),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.thumb_up_alt_rounded, size: 16, color: kPrimaryColor),
                          const SizedBox(width: 4),
                          Text(
                            room.rating.toStringAsFixed(1),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 12.5, fontFamily: 'Vazirmatn'),
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      room.imageUrl,
                      width: double.infinity,
                      height: 110,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: double.infinity,
                        height: 110,
                        color: kScaffoldContentColor, // Using constant
                        child: Icon(Icons.broken_image_outlined, size: 30, color: kPrimaryColor.withOpacity(0.5)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: onBookNow,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        textStyle: const TextStyle(fontSize: 13, fontFamily: 'Vazirmatn-Bold'),
                        minimumSize: const Size(100, 38)),
                    child: const Text("رزرو اتاق"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}