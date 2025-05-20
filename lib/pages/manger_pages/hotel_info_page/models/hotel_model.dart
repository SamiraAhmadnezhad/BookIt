import 'package:flutter/foundation.dart';
import 'facility_enum.dart'; // اطمینان حاصل کنید مسیر درست است

// تابع کمکی برای تبدیل رشته نام امکانات به Facility enum
// این تابع باید بتواند مقادیر مختلفی که از API می‌آید را مدیریت کند.
Facility? _parseFacilityFromString(String facilityName) {
  // نرمال‌سازی نام برای مقایسه بهتر (حذف فاصله‌ها، خط تیره، تبدیل به حروف کوچک)
  String normalizedName = facilityName.toLowerCase().replaceAll('-', '').replaceAll('_', '').replaceAll(' ', '');

  for (Facility facility in Facility.values) {
    // مقایسه با نام enum یا یک شناسه جایگزین اگر در enum تعریف کرده‌اید
    String enumNormalizedName = facility.name.toLowerCase().replaceAll('_', '');
    if (enumNormalizedName == normalizedName) {
      return facility;
    }
    // می‌توانید اینجا برای displayName یا مقادیر خاص دیگر هم بررسی کنید
    // مثال: if (facility.displayName.toLowerCase() == normalizedName) return facility;
  }

  // مدیریت موارد خاص که با نام enum مستقیماً مپ نمی‌شوند
  switch (normalizedName) {
    case 'wifi': // اگر API 'wifi' یا 'Wi-Fi' بفرستد و enum شما Facility.Wifi باشد
      return Facility.Wifi;
    case 'parking':
      return Facility.Parking;
  // ... سایر موارد خاص Facility enum خود را اینجا اضافه کنید
  // مثال: اگر API 'airconditioning' بفرستد و enum شما Facility.AirConditioning باشد
  }

  // اگر از FacilityExtension.fromString استفاده می‌کنید، و می‌دانید که کار می‌کند:
  // return FacilityExtension.fromString(facilityName);

  print('Warning: Unknown facility received from API and could not be parsed: $facilityName');
  return null; // یا یک مقدار پیش‌فرض اگر منطقی باشد
}


class Hotel {
  final String id; // باید از API بیاید
  String? imageUrl; // مپ شده از 'image' در API
  final String name; // مپ شده از 'name' در API
  final String location;
  final String description; // ترکیبی از 'description' و 'location' از API
  final List<Facility> amenities; // مپ شده از 'facilities' در API
  final double rating; // مپ شده از 'rate' در API
  final String iban; // مپ شده از 'hotel_iban_number' در API
  String? licenseImageUrl; // مپ شده از 'hotel_license' در API
  final int? roomCount; // فیلد جدید، مپ شده از 'room_count' در API

  Hotel({
    required this.location,
    required this.id,
    this.imageUrl,
    required this.name,
    required this.description,
    required this.amenities,
    required this.rating,
    required this.iban,
    this.licenseImageUrl,
    this.roomCount, // اضافه شده به constructor
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    // بسیار مهم: API شما باید یک فیلد 'id' برای هر هتل ارسال کند.
    // اگر نام فیلد 'id' در JSON متفاوت است، آن را اینجا جایگزین کنید.
    // اگر id وجود ندارد، این یک مشکل بزرگ است و باید در بک‌اند اصلاح شود.
    final String hotelId = json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(); // یک fallback موقت برای ID

    // ترکیب description و location
    String apiDescription = json['description'] as String? ?? 'توضیحاتی ارائه نشده است.';
    String? apiLocation = json['location'] as String?;
    String finalDescription = apiDescription;
    if (apiLocation != null && apiLocation.isNotEmpty) {
      finalDescription += '\nموقعیت: $apiLocation';
    }

    // تبدیل لیست رشته‌های امکانات از JSON (فیلد 'facilities') به List<Facility>
    var facilitiesFromJson = json['facilities'] as List<dynamic>?;
    List<Facility> amenitiesList = facilitiesFromJson
        ?.map((facilityName) => _parseFacilityFromString(facilityName.toString()))
        .whereType<Facility>() // فقط موارد غیر null را نگه می‌دارد
        .toList() ??
        [];

    return Hotel(
      id: hotelId,
      imageUrl: json['image'] as String?, // از فیلد 'image' در API
      name: json['name'] as String? ?? 'نام نامشخص',
      description: finalDescription,
      amenities: amenitiesList,
      rating: (json['rate'] as num?)?.toDouble() ?? 0.0, // از فیلد 'rate' در API
      iban: json['hotel_iban_number'] as String? ?? 'شماره شبا نامشخص', // از فیلد 'hotel_iban_number'
      licenseImageUrl: json['hotel_license'] as String?, // از فیلد 'hotel_license'
      roomCount: (json['room_count'] as num?)?.toInt(),
      location: json['location'] as String? ?? 'مکان نامشخص', // از فیلد 'room_count'
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'location':location,
      'description': description, // ممکن است نیاز به تفکیک location هنگام ارسال باشد
      'image': imageUrl,
      'hotel_license': licenseImageUrl,
      'hotel_iban_number': iban,
      'facilities': amenities.map((amenity) => amenity.name).toList(), // یا یک مقدار رشته‌ای دیگر که API انتظار دارد
      'rate': rating,
      'total_rooms': roomCount,
    };
  }
}

// اگر FacilityExtension.fromString شما به اندازه کافی قوی است، می‌توانید _parseFacilityFromString را با آن جایگزین کنید.
// مثال برای FacilityExtension (باید در facility_enum.dart یا اینجا باشد):
/*
extension FacilityExtension on Facility {
  static Facility? fromString(String value) {
    String normalizedValue = value.toLowerCase().replaceAll('-', '').replaceAll('_', '').replaceAll(' ', '');
    for (Facility facility in Facility.values) {
      String enumNormalizedName = facility.name.toLowerCase().replaceAll('_', '');
      if (enumNormalizedName == normalizedValue) {
        return facility;
      }
      // اگر displayName دارید:
      // if (facility.displayName.toLowerCase().replaceAll(' ', '') == normalizedValue) {
      //   return facility;
      // }
    }
    // موارد خاص
    if (normalizedValue == 'wifi') return Facility.Wifi;

    print('Warning: Could not parse facility from string: $value');
    return null;
  }

  String get displayName {
    // برای نمایش نام‌های فارسی یا کاربرپسند
    switch (this) {
      case Facility.Wifi: return 'وای‌فای';
      // ...
      default: return describeEnum(this);
    }
  }
}
*/