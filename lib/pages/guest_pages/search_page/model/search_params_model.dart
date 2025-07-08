// فایل: model/search_params_model.dart

class SearchParams {
  final String city;
  final String checkInDate;
  final String checkOutDate;
  final String roomType; // این مقدار حالا "Single", "Double" یا "Triple" است

  SearchParams({
    required this.city,
    required this.checkInDate,
    required this.checkOutDate,
    required this.roomType,
  });

  int get numberOfPassengers {
    switch (roomType) {
      case 'Single':
        return 1;
      case 'Double':
        return 2;
      case 'Triple':
        return 3;
      default:
        return 1;
    }
  }

// این متد دیگر لازم نیست چون roomType از ابتدا مقدار صحیح API را دارد
// String get apiRoomType => roomType;
}