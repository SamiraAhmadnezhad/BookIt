// lib/pages/guest_pages/hotel_detail_page/widgets/amenity_item_widget.dart

import 'package:bookit/core/models/facility_enum.dart';
import 'package:flutter/material.dart';
import '../../../../core/models/amenity_model.dart';
import '../utils/constants.dart';

class AmenityItemWidget extends StatelessWidget {
  final Facility amenity;

  const AmenityItemWidget({Key? key, required this.amenity}) : super(key: key);

  // تابع کمکی برای پیدا کردن آیکون و نام فارسی
  ({IconData icon, String persianName}) _getAmenityDetails(String amenityName) {
    // نقشه نام‌های API به جزئیات فارسی و آیکون
    const Map<String, ({IconData icon, String name})> amenityDetails = {
      // کلیدها باید با نام‌های دریافتی از API مطابقت داشته باشند
      'Wifi': (icon: Icons.wifi_rounded, name: 'وای فای'),
      'Parking': (icon: Icons.local_parking_rounded, name: 'پارکینگ'),
      'Restaurant': (icon: Icons.restaurant_rounded, name: 'رستوران'),
      'CoffeShop': (icon: Icons.local_cafe_rounded, name: 'کافی شاپ'),
      'Room Service': (icon: Icons.room_service_rounded, name: 'سرویس اتاق'),
      'Laundry Service': (icon: Icons.local_laundry_service_rounded, name: 'خشکشویی'),
      'Support Agent': (icon: Icons.support_agent_rounded, name: 'پشتیبانی'),
      'Elevator': (icon: Icons.elevator_rounded, name: 'آسانسور'),
      'Safebox': (icon: Icons.security_rounded, name: 'صندوق امانات'),
      'TV': (icon: Icons.tv_rounded, name: 'تلویزیون'),
      'FreeBreakFast': (icon: Icons.free_breakfast_rounded, name: 'صبحانه رایگان'),
      'MeetingRoom': (icon: Icons.meeting_room_rounded, name: 'اتاق جلسه'),
      'ChildCare': (icon: Icons.child_friendly_rounded, name: 'مراقبت از کودک'),
      'Pool': (icon: Icons.pool_rounded, name: 'استخر'),
      'Gym': (icon: Icons.fitness_center_rounded, name: 'باشگاه ورزشی'),
      'Taxi': (icon: Icons.local_taxi_rounded, name: 'سرویس تاکسی'),
      'PetsAllowed': (icon: Icons.pets_rounded, name: 'ورود حیوانات'),
      'ShoppingMall': (icon: Icons.shopping_bag_outlined, name: 'مرکز خرید'),
    };

    // اگر نام در نقشه ما موجود بود، جزئیات آن را برگردان
    if (amenityDetails.containsKey(amenityName)) {
      final details = amenityDetails[amenityName]!;
      return (icon: details.icon, persianName: details.name);
    }

    // اگر نام در نقشه نبود، یک مقدار پیش‌فرض برگردان
    return (icon: Icons.check_circle_outline_rounded, persianName: amenityName);
  }

  @override
  Widget build(BuildContext context) {
    final details = _getAmenityDetails(amenity.name);

    return SizedBox(
      width: 70, // عرض ثابت برای هر آیتم
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              details.icon,
              color: kPrimaryColor,
              size: 28, // آیکون بزرگتر
            ),
          ),
          const SizedBox(height: 8),
          Text(
            details.persianName, // نمایش نام فارسی
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}