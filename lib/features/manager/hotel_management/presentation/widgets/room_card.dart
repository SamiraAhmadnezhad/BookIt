import 'package:bookit/core/models/room_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RoomCard extends StatelessWidget {
  final Room room;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const RoomCard({
    super.key,
    required this.room,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final priceFormat = NumberFormat("#,###", "fa_IR");
    final hasDiscount =
        room.discountPrice > 0 && room.discountPrice < room.price;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(
              room.imageUrl ??
                  'https://placehold.co/600x400/EEE/31343C/png?text=Room',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: colorScheme.surfaceVariant,
                child: Icon(Icons.broken_image_outlined,
                    color: colorScheme.onSurfaceVariant.withOpacity(0.5)),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.name,
                    style: theme.textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text('نوع: ${room.roomType} - شماره: ${room.roomNumber}',
                      style: theme.textTheme.bodySmall),
                  const Spacer(),
                  const Divider(height: 16, thickness: 0.5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (hasDiscount)
                            Text(
                              '${priceFormat.format(room.price)} تومان',
                              style: theme.textTheme.bodySmall?.copyWith(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          Text(
                            '${priceFormat.format(hasDiscount ? room.discountPrice : room.price)} تومان',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: hasDiscount
                                  ? colorScheme.error
                                  : colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: onEdit,
                            icon: Icon(Icons.edit_outlined,
                                color: Colors.blue.shade800, size: 22),
                            tooltip: 'ویرایش اتاق',
                          ),
                          IconButton(
                            onPressed: onDelete,
                            icon: Icon(Icons.delete_outline,
                                color: colorScheme.error, size: 22),
                            tooltip: 'حذف اتاق',
                          ),
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}