import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../models/reservation_model.dart';
import '../user_account_page.dart';

class ActiveReservationCard extends StatelessWidget {
  final ReservationModel reservation;

  const ActiveReservationCard({Key? key, required this.reservation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Jalali checkInJalali = Jalali.fromDateTime(DateTime.parse(reservation.checkInDate));
    final String formattedCheckIn = checkInJalali.formatter.y+"/"+checkInJalali.formatter.m+"/"+checkInJalali.formatter.d;

    final Jalali checkOutJalali = Jalali.fromDateTime(DateTime.parse(reservation.checkOutDate));
    final String formattedCheckOut = checkOutJalali.formatter.y+"/"+checkOutJalali.formatter.m+"/"+checkOutJalali.formatter.d;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    reservation.hotelImageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) =>
                        Container(color: kPageBackground, width: 80, height: 80, child: const Icon(Icons.hotel, color: kLightTextColor)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reservation.hotelName,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: kPrimaryColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reservation.roomInfo,
                        style: theme.textTheme.bodyMedium?.copyWith(color: kLightTextColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      _buildStatusChip(reservation.status),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildDetailRow(Icons.calendar_today_outlined, 'تاریخ ورود:', formattedCheckIn),
            const SizedBox(height: 8),
            _buildDetailRow(Icons.calendar_today, 'تاریخ خروج:', formattedCheckOut),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    String statusText;

    switch (status.toLowerCase()) {
      case 'active':
      case 'confirmed':
        chipColor = Colors.green;
        statusText = 'فعال';
        break;
      default:
        chipColor = Colors.grey;
        statusText = 'نامشخص';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statusText,
        style: TextStyle(color: chipColor, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: kAccentColor),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: kLightTextColor, fontSize: 14)),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}