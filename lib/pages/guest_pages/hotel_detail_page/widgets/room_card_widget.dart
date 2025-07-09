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

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'fa_IR', symbol: '', decimalDigits: 0);

    return Card(
      elevation: 2,
      shadowColor: Colors.grey.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRoomImage(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
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
    );
  }

  Widget _buildRoomImage() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Image.network(
        room.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey.shade200,
          child: const Icon(Icons.broken_image_outlined, size: 40, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildRoomName(BuildContext context) {
    return Text(
      room.name,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildRoomFeatures(BuildContext context) {
    return _buildFeatureItem(context, Icons.group_outlined, "ظرفیت: ${room.capacity} نفر");
  }

  Widget _buildFeatureItem(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: kPrimaryColor.withOpacity(0.8)),
        const SizedBox(width: 8),
        Expanded(
            child: Text(text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54))),
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
            Text("قیمت هر شب",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  currencyFormat.format(room.pricePerNight),
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold, color: kPrimaryColor),
                ),
                const SizedBox(width: 4),
                const Text("تومان", style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.w500, fontSize: 12)),
              ],
            )
          ],
        ),
        ElevatedButton(
          onPressed: onBookNow,
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            textStyle: const TextStyle(fontSize: 15, fontFamily: 'Vazirmatn', fontWeight: FontWeight.bold),
          ),
          child: const Text("انتخاب"),
        ),
      ],
    );
  }
}