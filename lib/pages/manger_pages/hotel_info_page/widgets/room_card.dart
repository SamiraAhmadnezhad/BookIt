// فایل: widgets/room_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/room_model.dart';

class RoomCard extends StatelessWidget {
  final Room room;

  const RoomCard({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const primaryColor = Color(0xFF542545);
    final priceFormat = NumberFormat("#,###", "en_US");

    return Card(
      elevation: 4.0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 180,
            child: (room.imageUrl != null && room.imageUrl!.isNotEmpty)
                ? Image.network(
              room.imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
              loadingBuilder: (context, child, progress) => progress == null
                  ? child
                  : const Center(child: CircularProgressIndicator(color: primaryColor)),
            )
                : _buildImagePlaceholder(),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.name, // نمایش نام اتاق (مثلا "رویال")
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.tag, size: 18, color: Colors.grey[700]),
                    const SizedBox(width: 6),
                    Text(
                      "شماره ${room.roomNumber}", // نمایش شماره اتاق
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.king_bed_outlined, size: 18, color: Colors.grey[700]),
                    const SizedBox(width: 6),
                    Text(
                      room.roomType, // نمایش نوع اتاق
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${priceFormat.format(room.pricePerNight)} تومان',
                      style: const TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text('برای هر شب', style: theme.textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Icon(
          Icons.image_not_supported_outlined,
          color: Colors.grey[400],
          size: 50
      ),
    );
  }
}