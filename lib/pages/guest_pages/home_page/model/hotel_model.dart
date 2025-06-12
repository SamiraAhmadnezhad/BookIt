// فایل: lib/pages/guest_pages/home_page/model/hotel_model.dart

class Hotel {
  final int id;
  final String name;
  final String location;
  final String description;
  final List<String> facilities;
  final int rate;
  final int? rateNumber;
  final String? hotelLicenseUrl;
  final String? imageUrl;
  final String status;
  final String? discount; // به صورت رشته باقی می‌ماند
  final int? totalRooms;
  final double pricePerNight; // برای سازگاری با کارت‌ها
  bool isFavorite;

  Hotel({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.facilities,
    required this.rate,
    this.rateNumber,
    this.hotelLicenseUrl,
    this.imageUrl,
    required this.status,
    this.discount,
    this.totalRooms,
    required this.pricePerNight,
    this.isFavorite = false,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    const String baseUrl = 'https://newbookit.darkube.app';

    // *** بخش کلیدی: اصلاح نحوه خواندن facilities ***
    List<String> facilitiesList = [];
    if (json['facilities'] != null && json['facilities'] is List) {
      facilitiesList = (json['facilities'] as List)
          .where((facility) => facility is Map<String, dynamic> && facility['name'] != null)
          .map((facility) => facility['name'] as String)
          .toList();
    }

    // ساخت URL کامل برای عکس‌ها
    String? relativeImageUrl = json['image'] as String?;
    String? fullImageUrl = relativeImageUrl != null ? '$baseUrl$relativeImageUrl' : null;

    String? relativeLicenseUrl = json['hotel_license'] as String?;
    String? fullLicenseUrl = relativeLicenseUrl != null ? '$baseUrl$relativeLicenseUrl' : null;

    return Hotel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'نامشخص',
      location: json['location'] ?? 'نامشخص',
      description: json['description'] ?? '',
      facilities: facilitiesList,
      rate: (json['rate'] as num?)?.toInt() ?? 0,
      rateNumber: (json['rate_number'] as num?)?.toInt(),
      hotelLicenseUrl: fullLicenseUrl,
      imageUrl: fullImageUrl,
      status: json['status'] ?? 'Pending',
      discount: json['discount'] as String?,
      totalRooms: (json['total_rooms'] as num?)?.toInt(),
      // API شما برای لیست هتل‌ها قیمت ندارد، یک مقدار پیش‌فرض می‌گذاریم
      pricePerNight: (json['price'] as num?)?.toDouble() ?? 0.0,
      isFavorite: false,
    );
  }
}