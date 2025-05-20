import 'package:flutter/material.dart';

// می‌توانید این مپ را گسترش دهید
const Map<String, IconData> amenityIcons = {
  'wifi': Icons.wifi,
  'pool': Icons.pool,
  'parking': Icons.local_parking,
  'restaurant': Icons.restaurant,
  'gym': Icons.fitness_center,
  'spa': Icons.spa,
  'elevator': Icons.elevator,
  'air_conditioning': Icons.ac_unit,
  'breakfast': Icons.free_breakfast,
  'bar': Icons.local_bar,
  'laundry': Icons.local_laundry_service,
  'room_service': Icons.room_service,
  'pet_friendly': Icons.pets,
  // ... سایر امکانات
};

IconData getAmenityIcon(String amenityName) {
  return amenityIcons[amenityName.toLowerCase().replaceAll(' ', '_')] ?? Icons.help_outline; // آیکون پیشفرض اگر پیدا نشد
}