import 'hotel_in_room_model.dart';

class Room {
  final String id;
  final HotelInRoom hotel;
  final String name;
  final String roomType;
  final String roomNumber;
  final int capacity;
  final double price;
  final double discountPrice;
  final String? imageUrl;
  final double rating;
  final bool isFavorite;

  Room({
    required this.id,
    required this.hotel,
    required this.name,
    required this.roomType,
    required this.roomNumber,
    required this.capacity,
    required this.price,
    required this.discountPrice,
    this.imageUrl,
    required this.rating,
    required this.isFavorite,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    String? processUrl(String? url) {
      if (url == null || url.isEmpty) return null;
      if (url.startsWith('/')) return 'https://fbookit.darkube.app$url';
      return url;
    }

    return Room(
      id: json['id']?.toString() ?? '',
      hotel: HotelInRoom.fromJson(json['hotel'] as Map<String, dynamic>? ?? {}),
      name: json['name'] ?? 'نام نامشخص',
      roomNumber: json['room_number']?.toString() ?? '',
      roomType: json['room_type'] ?? 'نامشخص',
      capacity: json['capacity'] ?? 2,
      price: double.tryParse(json['price']?.toString() ?? '0.0') ?? 0.0,
      discountPrice: double.tryParse(json['discounted_price']?.toString() ?? '0.0') ?? 0.0,
      imageUrl: processUrl(json['image']),
      rating: (json['rate'] as num?)?.toDouble() ?? 0.0,
      isFavorite: json['is_favorite'] ?? false,
    );
  }
}