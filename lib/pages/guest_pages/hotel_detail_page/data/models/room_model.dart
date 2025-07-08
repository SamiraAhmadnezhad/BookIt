// lib/pages/guest_pages/hotel_detail_page/data/models/room_model.dart

class Room {
  // ... (فیلدها بدون تغییر)
  final String id;
  final String name;
  final String imageUrl;
  final String roomNumber;
  final int capacity;
  final bool hasBreakfast;
  final bool hasLunch;
  final bool hasDinner;
  final double pricePerNight;
  final double rating;

  Room({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.roomNumber,
    required this.capacity,
    this.hasBreakfast = false,
    this.hasLunch = false,
    this.hasDinner = false,
    required this.pricePerNight,
    required this.rating,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    double safeParseDouble(dynamic value) {
      if (value == null) return 0.0;
      return double.tryParse(value.toString()) ?? 0.0;
    }

    // <<< اصلاح اصلی: پردازش URL عکس اتاق >>>
    String _processUrl(String? url) {
      if (url == null || url.isEmpty) return '';
      // اگر URL با اسلش شروع می‌شود (نسبی است)، آدرس پایه را به آن اضافه کن
      if (url.startsWith('/')) {
        return 'https://fbookit.darkube.app$url';
      }
      if (url.contains('http')) {
        return url.substring(url.lastIndexOf('http'));
      }
      return url;
    }

    return Room(
      id: json['id']?.toString() ?? '0',
      name: json['name'] ?? 'بدون نام',
      imageUrl: _processUrl(json['image']), // استفاده از تابع پردازش URL
      capacity: json['capacity'] ?? 1,
      pricePerNight: safeParseDouble(json['price']),
      hasBreakfast: json['breakfast_included'] ?? false,
      hasLunch: json['lunch_included'] ?? false,
      hasDinner: json['dinner_included'] ?? false,
      rating: safeParseDouble(json['rate']),
    );
  }
}