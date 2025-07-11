import 'package:flutter/material.dart';
import '../models/reservation_model.dart';
import '../user_account_page.dart'; // برای دسترسی به ثابت‌های رنگ

class PreviousReservationCard extends StatelessWidget {
  final ReservationModel reservation;

  const PreviousReservationCard({Key? key, required this.reservation}) : super(key: key);

  void _onAddReviewPressed(BuildContext context) {
    // TODO: پیاده‌سازی ناوبری به صفحه ثبت نظر
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('رفتن به صفحه ثبت نظر برای هتل با شناسه: ${reservation.hotelId}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      shadowColor: Colors.grey.withOpacity(0.2),
      color: kCardBackground,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // بخش اطلاعات
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reservation.hotelName,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        reservation.hotelRating.toStringAsFixed(1),
                        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: kLightTextColor),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.thumb_up_alt, color: kAccentColor, size: 18),
                    ],
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () => _onAddReviewPressed(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: kPrimaryColor, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'ثبت نظر و امتیازدهی',
                            style: theme.textTheme.titleSmall?.copyWith(color: kPrimaryColor, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(width: 12),
            // تصویر هتل
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                reservation.hotelImageUrl,
                width: 120,
                height: 130,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 120,
                  height: 130,
                  color: kPageBackground,
                  child: const Icon(Icons.broken_image_outlined, color: kLightTextColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}