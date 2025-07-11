import 'package:bookit/core/models/facility_enum.dart';
import 'package:bookit/core/models/hotel_model.dart';
import 'package:flutter/material.dart';

class HotelCard extends StatelessWidget {
  final Hotel hotel;
  final VoidCallback onTap;

  const HotelCard({super.key, required this.hotel, required this.onTap});

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
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImageSection(Theme.of(context).colorScheme),
              _buildInfoSection(Theme.of(context)),
            ],
          ),
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
        ],
      ),
    );
  }

  Widget _buildInfoSection(ThemeData theme) {
    return Expanded(
      flex: 6,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        color: theme.colorScheme.surface.withOpacity(0.6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNameAndStars(theme),
            _buildAmenitiesSection(theme),
            _buildBottomActions(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildNameAndStars(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            hotel.name,
            style: theme.textTheme.titleMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
          ),
        ),
        const SizedBox(width: 16),
        _buildStarRating(theme.colorScheme),
      ],
    );
  }

  Widget _buildStarRating(ColorScheme colorScheme) {
    int fullStars = hotel.rating.floor();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        IconData starIcon = index < fullStars
            ? Icons.star_rounded
            : Icons.star_border_rounded;
        return Icon(starIcon, color: colorScheme.primary, size: 22);
      }),
    );
  }

  Widget _buildAmenitiesSection(ThemeData theme) {
    if (hotel.amenities.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
            theme, theme.colorScheme, "امکانات", Icons.apps_rounded),
        const SizedBox(height: 8),
        Container(
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: theme.dividerColor.withOpacity(0.0),
            borderRadius: BorderRadius.circular(20),
          ),
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
                    color: theme.primaryColor,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildInfoRow(
            theme, theme.colorScheme, "مکان هتل", Icons.location_on_rounded),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("رزرو",
                style: theme.textTheme.titleSmall
                    ?.copyWith(color: theme.colorScheme.primary)),
            const SizedBox(width: 4),
            Icon(Icons.arrow_forward, color: theme.colorScheme.primary),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(
      ThemeData theme, ColorScheme colorScheme, String text, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [

        Icon(icon, color: colorScheme.primary, size: 22),
        const SizedBox(width: 6),
        Text(text,
            style:
            theme.textTheme.bodyMedium?.copyWith(color: Colors.black54)),
      ],
    );
  }
}