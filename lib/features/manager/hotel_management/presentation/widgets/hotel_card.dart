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
  final VoidCallback onDownloadLicense;

  const HotelCard({
    super.key,
    required this.hotel,
    required this.onHotelUpdated,
    required this.onManageRooms,
    required this.onApplyDiscount,
    required this.onDeleteHotel,
    required this.onDownloadLicense,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildImageHeader(context),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(hotel.name,
                          style: theme.textTheme.titleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.star_rounded,
                              color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            hotel.rating.toStringAsFixed(1),
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '(${hotel.reviewCount})',
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: Colors.grey.shade600),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.location_on_outlined,
                              color: Colors.grey, size: 16),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              hotel.address,
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey.shade700),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.start,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        hotel.description,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: Colors.grey.shade600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      _buildFacilities(),
                      if (hotel.discountEndDate != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'تخفیف تا: ${Jalali.fromDateTime(hotel.discountEndDate!).formatter.y}',
                          style: TextStyle(
                              color: theme.colorScheme.error,
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                  _buildActionButtons(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageHeader(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            hotel.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image, size: 48),
          ),
          if (hotel.discountPercent > 0)
            Positioned(
              top: 12,
              left: 0,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 5,
                      offset: const Offset(1, 1),
                    ),
                  ],
                ),
                child: Text(
                  '${hotel.discountPercent.toInt()}% تخفیف',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFacilities() {
    if (hotel.amenities.isEmpty) {
      return const SizedBox(height: 24);
    }
    return SizedBox(
      height: 24,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: hotel.amenities.length,
        itemBuilder: (context, index) {
          final facility = hotel.amenities[index];
          return Tooltip(
            message: facility.userDisplayName,
            child: Icon(facility.iconData,
                color: Colors.grey.shade700, size: 20),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 12),
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
                      style: TextButton.styleFrom(
                          foregroundColor:
                          Theme.of(context).colorScheme.error),
                      child: const Text('حذف'),
                    ),
                  ],
                ),
              );
              if (confirm ?? false) {
                onDeleteHotel();
              }
            } else if (value == 'license') {
              onDownloadLicense();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('ویرایش')),
            const PopupMenuItem(value: 'license', child: Text('دانلود مجوز')),
            const PopupMenuItem(value: 'delete', child: Text('حذف')),
          ],
          icon: const Icon(Icons.more_vert),
        ),
      ],
    );
  }
}