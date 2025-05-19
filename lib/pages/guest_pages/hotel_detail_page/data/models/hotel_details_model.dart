import 'amenity_model.dart'; // مسیر صحیح را بررسی کنید

class HotelDetails {
  final String id;
  final String name;
  final String address;
  final String imageUrl;
  final double rating;
  final bool isCurrentlyFavorite;
  final int reviewCount;
  final String description;
  final List<Amenity> amenities;

  HotelDetails({
    required this.id,
    required this.name,
    required this.address,
    required this.imageUrl,
    required this.rating,
    required this.isCurrentlyFavorite,
    required this.reviewCount,
    required this.description,
    required this.amenities,
  });
}