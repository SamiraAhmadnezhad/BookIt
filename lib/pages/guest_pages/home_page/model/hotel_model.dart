// lib/pages/shared_models/hotel_model.dart (یا مسیر قبلی)

import '../../hotel_detail_page/data/models/amenity_model.dart';

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
      var facilityObjects = List<Map<String, dynamic>>.from(json['facilities']);
      amenitiesList = facilityObjects.map((obj) => Amenity(name: obj['name'] ?? '')).toList();
    }

    String _processUrl(String? url) {
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
      id: json['id'] ?? 0,
      name: json['name'] ?? 'نام یافت نشد',
      address: json['location'] ?? 'آدرس یافت نشد',
      imageUrl: _processUrl(json['image']),
      licenseImageUrl: _processUrl(json['hotel_license']),
      description: json['description'] ?? 'توضیحات موجود نیست',
      rating: (json['rate'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['rate_number'] ?? 0,
      amenities: amenitiesList,
      iban: json['hotel_iban_number'] ?? '',
      status: json['status']?.toString() ?? 'Pending',
      discount: double.tryParse(json['discount']?.toString() ?? '0.0') ?? 0.0,
      totalRooms: int.tryParse(json['total_rooms']?.toString() ?? '0') ?? 0,
      isCurrentlyFavorite: json['is_favorite'] ?? false,
    );
  }
}