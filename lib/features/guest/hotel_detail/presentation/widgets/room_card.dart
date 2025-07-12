import 'package:bookit/core/models/room_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RoomCard extends StatelessWidget {
  final Room room;
  final VoidCallback onBookNow;

  const RoomCard({super.key, required this.room, required this.onBookNow});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currencyFormat =
    NumberFormat.currency(locale: 'fa_IR', symbol: '', decimalDigits: 0);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(
              room.imageUrl ??
                  'https://placehold.co/600x400/EEE/31343C/png?text=Room',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: colorScheme.surface,
                child: Icon(Icons.broken_image_outlined,
                    color: colorScheme.onSurface.withOpacity(0.3)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(room.name, style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Icon(Icons.people_alt_outlined,
                    //     size: 16,
                    //     color: colorScheme.onSurface.withOpacity(0.7)),
                    // const SizedBox(width: 4),
                    // Text('${room.capacity} نفر',
                    //     style: theme.textTheme.bodyMedium),
                    // const SizedBox(width: 12),
                    Icon(Icons.king_bed_outlined,
                        size: 16,
                        color: colorScheme.onSurface.withOpacity(0.7)),
                    const SizedBox(width: 4),
                    Text(room.roomType, style: theme.textTheme.bodyMedium),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('هر شب', style: theme.textTheme.bodySmall),
                        Text(
                          '${currencyFormat.format(room.price)} تومان',
                          style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: onBookNow,
                      child: const Text('انتخاب'),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}