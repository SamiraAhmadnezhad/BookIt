import 'facility_enum.dart';

class Hotel {
  final int id;
  final String name;
  final String address;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final String description;
  final List<Facility> amenities;
  final String iban;
  final String licenseImageUrl;
  final String status;
  final double discountPercent;
  final DateTime? discountStartDate;
  final DateTime? discountEndDate;
  final int totalRooms;
  bool isFavorite;

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
    required this.discountPercent,
    this.discountStartDate,
    this.discountEndDate,
    required this.totalRooms,
    required this.isFavorite,
  });

  bool get isCurrentlyFavorite => isFavorite;

  factory Hotel.fromJson(Map<String, dynamic> json) {
    String processUrl(String? url) {
      if (url == null || url.isEmpty) {
        return 'https://placehold.co/600x400/EEE/31343C/png?text=Image';
      }
      if (url.startsWith('/')) {
        return 'https://fbookit.darkube.app$url';
      }
      return url;
    }

    var amenitiesList = (json['facilities'] as List<dynamic>?)
        ?.map((facility) =>
        FacilityParsing.fromApiValue(facility['name'] ?? ''))
        .toList() ??
        [];

    return Hotel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'نام یافت نشد',
      address: json['location'] ?? 'آدرس یافت نشد',
      imageUrl: processUrl(json['image']),
      licenseImageUrl: processUrl(json['hotel_license']),
      description: json['description'] ?? 'توضیحات موجود نیست',
      rating: (json['rate'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['rate_number'] ?? 0,
      status: json['status']?.toString() ?? 'Pending',
      discountPercent:
      double.tryParse(json['discount']?.toString() ?? '0.0') ?? 0.0,
      discountStartDate: json['discount_start_date'] != null
          ? DateTime.tryParse(json['discount_start_date'])
          : null,
      discountEndDate: json['discount_end_date'] != null
          ? DateTime.tryParse(json['discount_end_date'])
          : null,
      totalRooms: int.tryParse(json['total_rooms']?.toString() ?? '0') ?? 0,
      isFavorite: json['is_favorite'] ?? false,
      amenities: amenitiesList,
      iban: json['hotel_iban_number'] ?? '',
    );
  }
}