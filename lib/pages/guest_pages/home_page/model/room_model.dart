// فایل: lib/models/room_model.dart

class Room {
  final String id;
  final HotelInRoom hotel;
  final String name;
  final String roomType;
  final String roomNumber;
  final double pricePerNight;
  final String? imageUrl;
  final double rating; // اضافه کردن ریتینگ به مدل اتاق
  final double discount; // اضافه کردن تخفیف به مدل اتاق
  bool isFavorite; // برای مدیریت در UI

  Room({
    required this.id,
    required this.hotel,
    required this.name,
    required this.roomType,
    required this.roomNumber,
    required this.pricePerNight,
    this.imageUrl,
    required this.rating,
    required this.discount,
    this.isFavorite = false,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    const String baseUrl = 'https://newbookit.darkube.app';
    String? relativeImagePath = json['image'] as String?;

    return Room(
      id: json['id']?.toString() ?? '',
      hotel: HotelInRoom.fromJson(json['hotel'] as Map<String, dynamic>? ?? {}),
      name: json['name'] as String? ?? 'نام نامشخص',
      roomNumber: json['room_number']?.toString() ?? '',
      roomType: json['room_type'] as String? ?? 'نامشخص',
      pricePerNight: double.tryParse(json['price'] as String? ?? '0.0') ?? 0.0,
      imageUrl: relativeImagePath != null ? '$baseUrl$relativeImagePath' : null,
      rating: (json['rate'] as num?)?.toDouble() ?? 0.0,
      discount: double.tryParse(json['discounted_price'] as String? ?? '0.0') ?? 0.0,
    );
  }
}

class HotelInRoom {
  final String id;
  final String name;
  final String location;
  final int rate;

  HotelInRoom({required this.id, required this.name, required this.location, required this.rate});

  factory HotelInRoom.fromJson(Map<String, dynamic> json) {
    return HotelInRoom(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? 'نام هتل نامشخص',
      location: json['location'] as String? ?? 'مکان نامشخص',
      rate: (json['rate'] as num?)?.toInt() ?? 0,
    );
  }
}