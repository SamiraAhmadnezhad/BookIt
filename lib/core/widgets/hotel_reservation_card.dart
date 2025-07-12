import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import '../models/hotel_reservation_model.dart';


const Color kPrimaryColor = Color(0xFF542545);
const Color kAccentColor = Color(0xFF7E3F6B);
const Color kPageBackground = Color(0xFFF4F6F8);
const Color kCardBackground = Colors.white;
const Color kLightTextColor = Color(0xFF606060);
const Color kLighterTextColor = Color(0xFF888888);
const Color kPositiveColor = Color(0xFF28a745);
const Color kNegativeColor = Color(0xFFdc3545);

class HotelReservationCard extends StatelessWidget {
  final HotelReservationModel reservation;

  const HotelReservationCard({Key? key, required this.reservation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = intl.NumberFormat.currency(locale: 'fa_IR', symbol: 'تومان', decimalDigits: 0);
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              reservation.hotelName,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: kPrimaryColor),
            ),
            const SizedBox(height: 4),
            Text(
              reservation.roomName,
              style: theme.textTheme.bodyMedium?.copyWith(color: kAccentColor),
            ),
            const Divider(height: 20),

            // بخش جزئیات
            _buildDetailRow(Icons.person_outline, 'مهمان:', reservation.guestFullName),
            const SizedBox(height: 8),
            _buildDetailRow(Icons.email_outlined, 'ایمیل:', reservation.guestEmail),
            const SizedBox(height: 8),
            _buildDetailRow(Icons.location_on_outlined, 'مکان هتل:', reservation.hotelLocation),
            const SizedBox(height: 8),
            _buildDetailRow(Icons.calendar_today_outlined, 'ورود:', reservation.checkInDate),
            const SizedBox(height: 8),
            _buildDetailRow(Icons.calendar_today, 'خروج:', reservation.checkOutDate),

            const Divider(height: 20),

            // ردیف پایین کارت: قیمت
            _buildDetailRow(
              Icons.monetization_on_outlined,
              'مبلغ کل:',
              currencyFormatter.format(reservation.price),
              valueColor: kPositiveColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: kLightTextColor),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontSize: 14, color: kLightTextColor)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: valueColor ?? Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}