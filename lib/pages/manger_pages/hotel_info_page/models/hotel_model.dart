
import '../../../../core/models/amenity_model.dart';

class Hotel {
  final int id;
  final String name;
  final String address;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final String description;
  final List<Amenity> amenities;
  final String iban;
  final String licenseImageUrl;
  final String status;
  final double discount;
  final int totalRooms;
  final bool isCurrentlyFavorite;

  Hotel({
    required this.id,
    required this.name,
    required this.address,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.description,
    required this.amenities,
    required this.iban,
    required this.licenseImageUrl,
    required this.status,
    required this.discount,
    required this.totalRooms,
    this.isCurrentlyFavorite = false,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    List<Amenity> amenitiesList = [];
    if (json['facilities'] != null && json['facilities'] is List) {
      var facilityData = json['facilities'] as List<dynamic>;
      amenitiesList = facilityData
          .map((item) {
        // سرور یک لیست از آبجکت‌ها با کلید 'name' برمی‌گرداند
        if (item is Map<String, dynamic> && item.containsKey('name')) {
          return Amenity(name: item['name'] as String);
        }
        // برای سازگاری در صورتی که سرور فقط رشته بفرستد
        else if (item is String) {
          return Amenity(name: item);
        }
        return null;
      })
          .whereType<Amenity>()
          .toList();
    }

    String processUrl(String? url) {
      if (url == null || url.isEmpty) return '';
      if (url.startsWith('/')) {
        return 'https://fbookit.darkube.app$url';
      }
      if (url.contains('http')) {
        return url.substring(url.lastIndexOf('http'));
      }
      return url;
    }

    return Hotel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'نام یافت نشد',
      address: json['location'] as String? ?? 'آدرس یافت نشد',
      imageUrl: processUrl(json['image'] as String?),
      licenseImageUrl: processUrl(json['hotel_license'] as String?),
      description: json['description'] as String? ?? 'توضیحات موجود نیست',
      rating: (json['rate'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['rate_number'] as int? ?? 0,
      amenities: amenitiesList,
      iban: json['hotel_iban_number'] as String? ?? '',
      status: json['status'] as String? ?? 'Pending',
      discount: double.tryParse(json['discount']?.toString() ?? '0.0') ?? 0.0,
      totalRooms: int.tryParse(json['total_rooms']?.toString() ?? '0') ?? 0,
      isCurrentlyFavorite: json['is_favorite'] as bool? ?? false,
    );
  }
}