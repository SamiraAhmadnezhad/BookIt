// lib/pages/guest_pages/hotel_detail_page/widgets/room_card_widget.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/models/room_model.dart';
import '../utils/constants.dart';

class RoomCardWidget extends StatelessWidget {
  final Room room;
  final VoidCallback onBookNow;

  const RoomCardWidget({
    Key? key,
    required this.room,
    required this.onBookNow,
  }) : super(key: key);

  String get _getMealInfo {
    final meals = <String>[];
    if (room.hasBreakfast) meals.add("صبحانه");
    if (room.hasLunch) meals.add("ناهار");
    if (room.hasDinner) meals.add("شام");
    if (meals.isEmpty) return "بدون وعده غذایی";
    return meals.join('، ');
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'fa_IR', symbol: '', decimalDigits: 0);

    return Container(
      // استفاده از Container برای اضافه کردن سایه و حاشیه
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRoomImage(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildRoomName(context),
                    _buildRoomFeatures(context),
                    _buildPriceAndBooking(context, currencyFormat),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRoomImage() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            room.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey.shade200,
              child: const Icon(Icons.broken_image_outlined, size: 40, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomName(BuildContext context) {
    return Text(
      room.name,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildRoomFeatures(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFeatureItem(context, Icons.group_outlined, "ظرفیت: ${room.capacity} نفر"),
      ],
    );
  }

  Widget _buildFeatureItem(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: kPrimaryColor.withOpacity(0.8)),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black54))),
      ],
    );
  }

  Widget _buildPriceAndBooking(BuildContext context, NumberFormat currencyFormat) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("قیمت هر شب", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  currencyFormat.format(room.pricePerNight),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: kPrimaryColor),
                ),
                const SizedBox(width: 4),
                const Text("تومان", style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.w500)),
              ],
            )
          ],
        ),
        ElevatedButton(
          onPressed: onBookNow,
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: const TextStyle(fontSize: 16, fontFamily: 'Vazirmatn', fontWeight: FontWeight.bold),
          ),
          child: const Text("انتخاب"),
        ),
      ],
    );
  }
}