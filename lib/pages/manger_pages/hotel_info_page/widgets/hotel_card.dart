// lib/pages/manger_pages/widgets/hotel_card.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/models/facility_enum.dart';
import '../../../../core/models/hotel_model.dart';

class HotelCard extends StatelessWidget {
  final Hotel hotel;
  final VoidCallback onHotelUpdated;
  final VoidCallback onManageRooms;

  const HotelCard({
    super.key,
    required this.hotel,
    required this.onHotelUpdated,
    required this.onManageRooms,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF542545);
    const accentColor = Color(0xFF7E3F6B);

    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageHeader(context, primaryColor),
          _buildInfoSection(context, accentColor),
          if (hotel.amenities.isNotEmpty) _buildAmenitiesSection(context),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildActionButtons(context, primaryColor),
        ],
      ),
    );
  }

  Widget _buildImageHeader(BuildContext context, Color primaryColor) {
    return Stack(
      children: [
        SizedBox(
          height: 200,
          width: double.infinity,
          child: (hotel.imageUrl.isNotEmpty)
              ? Image.network(
            hotel.imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) =>
            progress == null ? child : Center(child: CircularProgressIndicator(color: primaryColor)),
            errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.hotel_class_outlined, size: 80, color: Colors.grey),
          )
              : Container(
            color: Colors.grey[200],
            child: const Icon(Icons.hotel_class_outlined, size: 80, color: Colors.grey),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.center,
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
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              shadows: [const Shadow(blurRadius: 2.0, color: Colors.black54)],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context, Color accentColor) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(Icons.location_on_outlined, color: theme.hintColor, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    hotel.address,
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodySmall?.color),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  hotel.rating.toStringAsFixed(1),
                  style: theme.textTheme.bodyMedium?.copyWith(color: accentColor, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 4),
                Icon(Icons.star_rounded, color: accentColor, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ====================== شروع اصلاحیه اصلی ======================
  Widget _buildAmenitiesSection(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Wrap(
        spacing: 12.0,
        runSpacing: 8.0,
        children: hotel.amenities.take(6).map((amenity) {
          // 1. از مدل Amenity که فقط name دارد، Facility enum را پیدا می‌کنیم.
          final facilityEnum = FacilityParsing.fromApiValue(amenity.name);

          // 2. از facilityEnum برای دریافت آیکون و نام فارسی استفاده می‌کنیم.
          return Tooltip(
            message: facilityEnum.userDisplayName,
            child: Icon(facilityEnum.iconData, color: theme.iconTheme.color?.withOpacity(0.7), size: 22),
          );
        }).toList(),
      ),
    );
  }
  // ======================= پایان اصلاحیه اصلی =======================

  Widget _buildActionButtons(BuildContext context, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            child: Text('اطلاعات بیشتر', style: TextStyle(fontWeight: FontWeight.w600, color: primaryColor)),
            onPressed: () => _showDetailsDialog(context, primaryColor),
          ),
          TextButton(
            child: Text('ویرایش', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
            onPressed: onHotelUpdated,
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.meeting_room_outlined, size: 20, color: Colors.white),
            label: const Text('مدیریت اتاق‌ها'),
            onPressed: onManageRooms,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailsDialog(BuildContext context, Color primaryColor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(hotel.name, style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                _buildDetailRow(context, Icons.description_outlined, 'توضیحات:', hotel.description),
                const Divider(height: 24),
                _buildDetailRow(context, Icons.account_balance_wallet_outlined, 'شماره شبا:', hotel.iban, isLtr: true),
              ],
            ),
          ),
          actions: <Widget>[
            if (hotel.licenseImageUrl.isNotEmpty)
              TextButton.icon(
                icon: Icon(Icons.receipt_long_outlined, color: primaryColor),
                label: Text('نمایش مجوز', style: TextStyle(color: primaryColor)),
                onPressed: () => _launchURL(hotel.licenseImageUrl),
              ),
            TextButton(
              child: Text('بستن', style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String title, String value, {bool isLtr = false}) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: theme.hintColor),
            const SizedBox(width: 8),
            Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            textAlign: isLtr ? TextAlign.left : TextAlign.right,
            textDirection: isLtr ? TextDirection.ltr : TextDirection.rtl,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
        ),
      ],
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      print('Could not launch $url');
    }
  }
}