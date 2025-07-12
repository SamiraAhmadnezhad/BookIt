import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/models/facility_enum.dart';
import '../../../../core/models/hotel_model.dart';

class HotelCard extends StatelessWidget {
  final Hotel hotel;
  final VoidCallback onHotelUpdated;
  final VoidCallback onManageRooms;
  final VoidCallback onApplyDiscount;

  const HotelCard({
    super.key,
    required this.hotel,
    required this.onHotelUpdated,
    required this.onManageRooms,
    required this.onApplyDiscount,
  });

  static const Color _primaryColor = Color(0xFF542545);
  static const Color _accentColor = Color(0xFF7E3F6B);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3.0,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildImageHeader(context),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoSection(context),
                          if (hotel.amenities.isNotEmpty) _buildAmenitiesSection(context),
                          _buildDescriptionSection(context),
                        ],
                      ),
                    ),
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
          if (hotel.imageUrl.isNotEmpty)
            Image.network(
              hotel.imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) =>
              progress == null ? child : const Center(child: CircularProgressIndicator(color: _primaryColor)),
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: Colors.grey[200], child: Icon(Icons.broken_image_outlined, size: 60, color: Colors.grey[400])),
            )
          else
            Container(color: Colors.grey[200], child: Icon(Icons.hotel_class_outlined, size: 80, color: Colors.grey[400])),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                  stops: const [0.0, 0.6],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 16.0,
            right: 16.0,
            left: 16.0,
            child: Text(
              hotel.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Vazirmatn',
                shadows: [Shadow(blurRadius: 4.0, color: Colors.black54, offset: Offset(0, 1))],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.location_on_outlined, color: Colors.grey[600], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              hotel.address,
              style: TextStyle(color: Colors.grey[800], fontFamily: 'Vazirmatn', fontSize: 13),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            decoration: BoxDecoration(
              color: _accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Row(
              children: [
                Text(
                  hotel.rating.toStringAsFixed(1),
                  style: const TextStyle(color: _accentColor, fontWeight: FontWeight.bold, fontFamily: 'Vazirmatn', fontSize: 14),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.star_rounded, color: _accentColor, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenitiesSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Wrap(
        spacing: 16.0,
        runSpacing: 10.0,
        children: hotel.amenities.take(4).map((amenity) {
          final facilityEnum = FacilityParsing.fromApiValue(amenity.name);
          return Tooltip(
            message: facilityEnum.userDisplayName,
            child: Icon(facilityEnum.iconData, color: Colors.grey[600], size: 22),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDescriptionSection(BuildContext context) {
    if (hotel.description.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        hotel.description,
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontFamily: 'Vazirmatn', color: Colors.grey[700], height: 1.7),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: [
              ElevatedButton(
                onPressed: onManageRooms,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                ),
                child: const Text('اتاق‌ها', style: TextStyle(fontFamily: 'Vazirmatn')),
              ),
              OutlinedButton(
                onPressed: onApplyDiscount,
                style: OutlinedButton.styleFrom(
                  foregroundColor: _primaryColor,
                  side: BorderSide(color: _primaryColor.withOpacity(0.5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                ),
                child: const Text('تخفیف', style: TextStyle(fontFamily: 'Vazirmatn')),
              ),
            ],
          ),
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              onHotelUpdated();
            } else if (value == 'license') {
              _launchURL(hotel.licenseImageUrl);
            }
          },
          icon: Icon(Icons.more_vert, color: Colors.grey[700]),
          itemBuilder: (BuildContext context) {
            final items = <PopupMenuEntry<String>>[];
            items.add(
              const PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 20),
                    SizedBox(width: 8),
                    Text('ویرایش', style: TextStyle(fontFamily: 'Vazirmatn')),
                  ],
                ),
              ),
            );

            if (hotel.licenseImageUrl.isNotEmpty) {
              items.add(const PopupMenuDivider());
              items.add(
                PopupMenuItem<String>(
                  value: 'license',
                  child: const Row(
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 20),
                      SizedBox(width: 8),
                      Text('نمایش مجوز', style: TextStyle(fontFamily: 'Vazirmatn')),
                    ],
                  ),
                  onTap: () => _launchURL(hotel.licenseImageUrl),
                ),
              );
            }
            return items;
          },
        ),
      ],
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }
}