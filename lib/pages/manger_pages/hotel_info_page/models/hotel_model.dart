// فایل: models/hotel_model.dart

import 'facility_enum.dart';

class Hotel {
  final String id;
  String? imageUrl;
  final String name;
  final String location;
  final String description;
  final List<Facility> amenities;
  final double rating;
  final String iban;
  String? licenseImageUrl;
  final int? roomCount;

  Hotel({
    required this.id,
    this.imageUrl,
    required this.name,
    required this.location,
    required this.description,
    required this.amenities,
    required this.rating,
    required this.iban,
    this.licenseImageUrl,
    this.roomCount,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    var facilitiesData = json['facilities'] as List<dynamic>?;

    List<Facility> amenitiesList = facilitiesData?.map((facilityItem) {
      if (facilityItem is Map<String, dynamic> && facilityItem.containsKey('name')) {
        return FacilityExtension.fromApiValue(facilityItem['name'] as String?);
      } else if (facilityItem is String) {
        // برای سازگاری در صورتی که API گاهی رشته هم بفرستد
        return FacilityExtension.fromApiValue(facilityItem);
      }
      return null;
    })
        .whereType<Facility>() // فقط موارد غیر null را نگه می‌دارد
        .toList() ?? [];

    return Hotel(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      imageUrl: json['image'] as String?,
      name: json['name'] as String? ?? 'نام نامشخص',
      location: json['location'] as String? ?? 'مکان نامشخص',
      description: json['description'] as String? ?? 'توضیحاتی ارائه نشده است.',
      amenities: amenitiesList,
      rating: (json['rate'] as num?)?.toDouble() ?? 0.0,
      iban: json['hotel_iban_number'] as String? ?? 'شماره شبا نامشخص',
      licenseImageUrl: json['hotel_license'] as String?,
      roomCount: (json['room_count'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'description': description,
      'image': imageUrl,
      'hotel_license': licenseImageUrl,
      'hotel_iban_number': iban,
      'facilities': amenities.map((amenity) => amenity.apiValue).toList(),
      'rate': rating,
      'room_count': roomCount,
    };
  }
}