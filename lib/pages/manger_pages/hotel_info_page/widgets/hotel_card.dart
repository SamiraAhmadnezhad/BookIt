import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/hotel_model.dart';
import '../models/facility_enum.dart'; // <<--- Import FacilityExtension
import '../screens/room_list_screen.dart';
import '../screens/add_hotel_screen.dart';
import '../data/app_data.dart';
import '../utils/colors.dart';
import '../utils/amenity_icons.dart';

class HotelCard extends StatelessWidget {
  final Hotel hotel;
  final VoidCallback? onHotelUpdated;
  final VoidCallback? onManageRooms;

  const HotelCard({
    super.key,
    required this.hotel,
    this.onHotelUpdated,
    this.onManageRooms,
  });

  Future<void> _launchURL(String? urlString) async {
    if (urlString == null || urlString.isEmpty) {
      print('URL مجوز موجود نیست.');
      return;
    }
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      print('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hotelRoomCount = sampleRooms.where((room) => room.hotelId == hotel.id).length;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
            // مدیریت null بودن hotel.imageUrl
            child: hotel.imageUrl != null && hotel.imageUrl!.isNotEmpty
                ? Image.network(
              hotel.imageUrl!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, color: Colors.grey, size: 60),
                );
              },
            )
                : Container( // نمایش placeholder اگر URL تصویر موجود نباشد
              height: 200,
              width: double.infinity,
              color: Colors.grey[300],
              child: const Icon(Icons.hotel, color: Colors.grey, size: 80),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hotel.name,
                  style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: customPurple),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Text(
                  'توضیحات:',
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 80,
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8.0),
                    color: Colors.grey.shade50,
                  ),
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      child: Text(
                        hotel.description,
                        style: textTheme.bodyMedium?.copyWith(height: 1.5),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'امکانات:',
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                if (hotel.amenities.isNotEmpty)
                  SizedBox(
                    height: 60,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: hotel.amenities.length,
                      itemBuilder: (context, index) {
                        final Facility facility = hotel.amenities[index]; // حالا از نوع Facility
                        return Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: customPurple.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  // فرض می‌کنیم getAmenityIcon رشته نام enum را می‌گیرد (Facility.Wifi.name)
                                  // یا خود enum را اگر getAmenityIcon را تغییر داده باشید.
                                  // در فایل amenity_icons.dart فعلی، رشته نام enum را می‌گیرد.
                                  getAmenityIcon(facility.name), // <<--- اصلاح شده
                                  color: customPurple,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                facility.displayName, // <<--- اصلاح شده
                                style: textTheme.bodySmall?.copyWith(fontSize: 10),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  )
                else
                  Text('امکاناتی ثبت نشده است.', style: textTheme.bodyMedium),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'امتیاز: ',
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Icon(Icons.star, color: Colors.amber, size: 22),
                    const SizedBox(width: 4),
                    Text(
                      hotel.rating.toStringAsFixed(1),
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const Text(' از 5', style: TextStyle(color: Colors.grey))
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'شماره شبا: ',
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Expanded(
                      child: Text(
                        hotel.iban,
                        style: textTheme.bodyLarge?.copyWith(fontFamily: 'monospace', letterSpacing: 1.1),
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    if (hotel.licenseImageUrl != null && hotel.licenseImageUrl!.isNotEmpty)
                      TextButton.icon(
                        icon: const Icon(Icons.download_for_offline_outlined),
                        label: const Text('دانلود مجوز'),
                        onPressed: () => _launchURL(hotel.licenseImageUrl),
                        style: TextButton.styleFrom(foregroundColor: Colors.blueGrey[700]),
                      ),
                    if (onManageRooms != null)
                      TextButton.icon(
                        icon: const Icon(Icons.bed_outlined),
                        label: Text('اتاق‌ها ($hotelRoomCount)'),
                        onPressed: onManageRooms,
                        style: TextButton.styleFrom(foregroundColor: customPurple),
                      ),
                  ],
                ),
                if (onHotelUpdated != null)
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton.icon(
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('ویرایش هتل'),
                      onPressed: onHotelUpdated, // <<--- مستقیم از callback استفاده می‌کنیم
                      style: TextButton.styleFrom(foregroundColor: Colors.orange[700]),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}