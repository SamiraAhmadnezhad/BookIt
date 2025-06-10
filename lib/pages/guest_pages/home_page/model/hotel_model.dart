class Hotel {
  final int id;
  final String name;
  final String location;
  final String description;
  final List<String> facilities;
  final int rate; // تعداد ستاره 0-5
  final int? rateNumber; // تعداد رای دهندگان
  final String? hotelLicenseUrl;
  final String? imageUrl;
  final String status;
  final double? discount; // درصد تخفیف
  final int? totalRooms;
  bool isFavorite; // این فیلد را برای مدیریت در UI اضافه می‌کنیم

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
    this.isFavorite = false, // مقدار پیش‌فرض
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse numbers
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return Hotel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'نامشخص',
      location: json['location'] ?? 'نامشخص',
      description: json['description'] ?? '',
      facilities: json['facilities'] != null ? List<String>.from(json['facilities']) : [],
      rate: parseInt(json['rate']) ?? 0,
      rateNumber: parseInt(json['rate_number']),
      hotelLicenseUrl: json['hotel_license'],
      imageUrl: json['image'],
      status: json['status'] ?? 'Pending',
      discount: parseDouble(json['discount']),
      totalRooms: parseInt(json['total_rooms']),
    );
  }
}