import 'package:bookit/core/models/facility_enum.dart';
import 'package:bookit/core/models/hotel_model.dart';
import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';

class HotelCard extends StatelessWidget {
  final Hotel hotel;
  final VoidCallback onHotelUpdated;
  final VoidCallback onManageRooms;
  final VoidCallback onApplyDiscount;
  final VoidCallback onDeleteHotel;

  const HotelCard({
    super.key,
    required this.hotel,
    required this.onHotelUpdated,
    required this.onManageRooms,
    required this.onApplyDiscount,
    required this.onDeleteHotel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildImageHeader(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(hotel.name, style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(hotel.address, style: theme.textTheme.bodyLarge),
                  if (hotel.discountEndDate != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'تخفیف تا: ${Jalali.fromDateTime(hotel.discountEndDate!).formatter.y+"/"+Jalali.fromDateTime(hotel.discountEndDate!).formatter.m+"/"+Jalali.fromDateTime(hotel.discountEndDate!).formatter.d}',
                      style: TextStyle(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                  const Spacer(),
                  _buildActionButtons(context),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildImageHeader() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(hotel.imageUrl, fit: BoxFit.cover),
          if (hotel.discountPercent > 0)
            Banner(
              message: '${hotel.discountPercent.toInt()}%',
              location: BannerLocation.topStart,
              color: Colors.red,
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(onPressed: onManageRooms, child: const Text('اتاق‌ها')),
        TextButton(onPressed: onApplyDiscount, child: const Text('تخفیف')),
        PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'edit') {
              onHotelUpdated();
            } else if (value == 'delete') {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('تایید حذف'),
                  content: Text('آیا از حذف هتل «${hotel.name}» اطمینان دارید؟'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text('انصراف')),
                    TextButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: const Text('حذف')),
                  ],
                ),
              );
              if (confirm ?? false) {
                onDeleteHotel();
              }
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('ویرایش')),
            const PopupMenuItem(value: 'delete', child: Text('حذف')),
          ],
        ),
      ],
    );
  }
}