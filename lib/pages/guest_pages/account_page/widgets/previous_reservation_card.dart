import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/reservation_model.dart';
import '../../../../core/theme/app_colors.dart';


class PreviousReservationCard extends StatelessWidget {
  final ReservationModel reservation;

  const PreviousReservationCard({Key? key, required this.reservation}) : super(key: key);

  void _onAddReviewPressed(BuildContext context) {
    // TODO: پیاده‌سازی ناوبری به صفحه ثبت نظر
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('رفتن به صفحه ثبت نظر برای هتل با شناسه: ${reservation.hotelId}')),
    );
  }

  Widget _buildDetailRow(BuildContext context, {required IconData icon, required String text}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.black54),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.primaryDark),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final String checkIn = reservation.checkInDate;
    final String checkOut = reservation.checkOutDate;

    final String formattedPrice = NumberFormat('#,###', 'fa_IR').format(reservation.amount);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      shadowColor: Colors.grey.withOpacity(0.2),
      color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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

                  _buildDetailRow(context, icon: Icons.king_bed_outlined, text: reservation.roomInfo ),
                  _buildDetailRow(context, icon: Icons.login_outlined, text: 'ورود: $checkIn'),
                  _buildDetailRow(context, icon: Icons.logout_outlined, text: 'خروج: $checkOut'),
                  _buildDetailRow(context, icon: Icons.wallet_travel_outlined, text: 'قیمت کل: $formattedPrice تومان'),

                  const SizedBox(height: 12),

                  InkWell(
                    onTap: () => _onAddReviewPressed(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: AppColors.primaryDark, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'ثبت نظر و امتیازدهی',
                            style: theme.textTheme.titleSmall?.copyWith(color: AppColors.primaryDark, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(width: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                reservation.hotelImageUrl,
                width: 120,
                height: 150,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 120,
                  height: 150,
                  color: AppColors.formBackgroundGrey,
                  child: const Icon(Icons.broken_image_outlined, color: AppColors.lightGrey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}