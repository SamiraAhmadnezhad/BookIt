// فایل: models/room_model.dart

class Room {
  final String id;
  final String hotelId;
  final String name; // نام اتاق مثل "رویال"
  final String roomNumber; // شماره اتاق
  final String roomType;
  final double pricePerNight;
  final String? imageUrl; // تغییر از List<String> به یک String اختیاری

  Room({
    required this.id,
    required this.hotelId,
    required this.name,
    required this.roomNumber,
    required this.roomType,
    required this.pricePerNight,
    this.imageUrl,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    const String baseUrl = 'https://newbookit.darkube.app';
    String? relativeImagePath = json['image'] as String?;

    return Room(
      // تبدیل مقادیر عددی به رشته با toString()
      id: json['id']?.toString() ?? '',
      hotelId: json['hotel']?['id']?.toString() ?? '', // استخراج id از آبجکت hotel

      name: json['name'] as String? ?? 'نام نامشخص',

      // تبدیل شماره اتاق از int به String
      roomNumber: json['room_number']?.toString() ?? '',

      roomType: json['room_type'] as String? ?? 'نامشخص',

      // تبدیل قیمت از رشته به double
      pricePerNight: double.tryParse(json['price'] as String? ?? '0.0') ?? 0.0,

      // ساخت URL کامل برای عکس
      imageUrl: relativeImagePath != null ? '$baseUrl$relativeImagePath' : null,
    );
  }
}