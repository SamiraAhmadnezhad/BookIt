import 'package:flutter/foundation.dart';

class Room {
  final String id;
  final String hotelId; // برای اتصال اتاق به هتل
  final String name;
  final String type; // مثلا "دو تخته", "سوئیت", "یک نفره" یا تعداد نفرات "2 نفر"
  final String pricePerNight;
  final String imageUrl;

  Room({
    required this.id,
    required this.hotelId,
    required this.name,
    required this.type,
    required this.pricePerNight,
    required this.imageUrl,
  });
}