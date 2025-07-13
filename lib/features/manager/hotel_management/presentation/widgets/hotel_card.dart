import 'package:bookit/core/models/facility_enum.dart';
import 'package:bookit/core/models/hotel_model.dart';
import 'package:flutter/material.dart';

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
    return AspectRatio(
      aspectRatio: 0.8,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 3.0,
        shadowColor: Colors.black.withOpacity(0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildImageSection(Theme.of(context).colorScheme),
            _buildInfoSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(ColorScheme colorScheme) {
    return Expanded(
      flex: 5,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            hotel.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: colorScheme.surface,
              alignment: Alignment.center,
              child: Icon(Icons.business_rounded,
                  size: 50, color: colorScheme.onSurface.withOpacity(0.3)),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.thumb_up_alt_rounded,
                      color: colorScheme.primary, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    hotel.rating.toStringAsFixed(1),
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (hotel.discountPercent > 0)
            Positioned(
              top: 12,
              left: 0,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.error.withOpacity(0.95),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Text(
                  '${hotel.discountPercent.toInt()}% تخفیف',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      flex: 6,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        color: theme.colorScheme.surface.withOpacity(0.6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNameAndDiscountInfo(theme),
            _buildAmenitiesSection(theme),
            _buildBottomActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscountCountdown(ThemeData theme) {
    if (hotel.discountEndDate == null) return const SizedBox.shrink();

    final now = DateTime.now();
    final remaining = hotel.discountEndDate!.difference(now);

    String remainingText;
    final daysLeft = remaining.inDays;

    if (daysLeft > 0) {
      remainingText = 'فقط ${daysLeft} روز مانده';
    } else {
      final hoursLeft = remaining.inHours;
      if (hoursLeft > 0) {
        remainingText = 'فقط ${hoursLeft} ساعت مانده';
      } else {
        remainingText = 'فرصت محدود';
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.timer_outlined, color: theme.colorScheme.error, size: 20),
        const SizedBox(width: 4),
        Text(
          remainingText,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.error,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildNameAndDiscountInfo(ThemeData theme) {
    final bool hasActiveDiscount = hotel.discountPercent > 0 &&
        hotel.discountEndDate != null &&
        hotel.discountEndDate!.isAfter(DateTime.now());

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            hotel.name,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
          ),
        ),
        const SizedBox(width: 16),
        if (hasActiveDiscount) _buildDiscountCountdown(theme),
      ],
    );
  }

  Widget _buildAmenitiesSection(ThemeData theme) {
    if (hotel.amenities.isEmpty) {
      return const SizedBox(height: 38);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text("امکانات", style: theme.textTheme.bodySmall),
        const SizedBox(height: 8),
        SizedBox(
          height: 30,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: hotel.amenities.length,
            reverse: true,
            itemBuilder: (context, index) {
              final amenity = hotel.amenities[index];
              return Tooltip(
                message: amenity.userDisplayName,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(
                    amenity.iconData,
                    size: 20,
                    color: theme.primaryColor.withOpacity(0.7),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: _buildInfoRow(
            theme,
            theme.colorScheme,
            hotel.address,
            Icons.location_on_rounded,
          ),
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert_rounded, color: theme.colorScheme.primary),
          onSelected: (value) async {
            if (value == 'rooms') {
              onManageRooms();
            } else if (value == 'discount') {
              onApplyDiscount();
            } else if (value == 'edit') {
              onHotelUpdated();
            } else if (value == 'license') {
              onDownloadLicense();
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
                          foregroundColor: Theme.of(context).colorScheme.error),
                      child: const Text('حذف'),
                    ),
                  ],
                ),
              );
              if (confirm ?? false) {
                onDeleteHotel();
              }
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'rooms', child: Text('مدیریت اتاق‌ها')),
            const PopupMenuItem(value: 'discount', child: Text('اعمال تخفیف')),
            const PopupMenuItem(value: 'edit', child: Text('ویرایش هتل')),
            const PopupMenuItem(value: 'license', child: Text('دانلود مجوز')),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'delete',
              child: Text(
                'حذف هتل',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(
      ThemeData theme, ColorScheme colorScheme, String text, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Icon(icon, color: colorScheme.primary, size: 22),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}