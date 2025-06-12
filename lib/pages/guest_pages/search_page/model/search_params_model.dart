// فایل: model/search_params_model.dart

class SearchParams {
  final String city;
  final String checkInDate;
  final String checkOutDate;
  final String roomType; // e.g., "یک نفره", "دو نفره"

  SearchParams({
    required this.city,
    required this.checkInDate,
    required this.checkOutDate,
    required this.roomType,
  });

  // متد برای تبدیل نوع اتاق فارسی به تعداد مسافر
  int get numberOfPassengers {
    switch (roomType) {
      case 'تک نفره':
        return 1;
      case 'دو نفره':
        return 2;
      case 'سه نفره':
        return 3;
      default:
        return 1; // مقدار پیش‌فرض
    }
  }

  // متد برای تبدیل نوع اتاق فارسی به مقدار مورد نیاز API (اگر متفاوت باشد)
  String get apiRoomType {
    // فرض می‌کنیم API همین مقادیر را انتظار دارد. در غیر این صورت، اینجا مپ کنید.
    // مثلا: case 'تک نفره': return 'Single';
    return roomType;
  }
}