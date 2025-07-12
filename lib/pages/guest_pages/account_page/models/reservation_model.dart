class ReservationModel {
  final int id;
  final int hotelId;
  final String hotelName;
  final String roomInfo;
  final String checkInDate;
  final String checkOutDate;
  final double amount;
  final String status;
  final String hotelImageUrl;

  ReservationModel({
    required this.id,
    required this.hotelId,
    required this.hotelName,
    required this.roomInfo,
    required this.checkInDate,
    required this.checkOutDate,
    required this.amount,
    required this.status,
    required this.hotelImageUrl,
  });

  // تابع کمکی برای ساخت URL کامل تصویر
  static String _buildImageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return 'https://via.placeholder.com/150'; // تصویر پیش‌فرض
    }
    // اگر path با http شروع نمی‌شود، آدرس پایه را اضافه کن
    if (path.startsWith('http')) {
      return path;
    }
    return 'https://fbookit.darkube.app$path';
  }

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    // دسترسی به آبجکت تودرتوی room_details
    final roomDetails = json['room_details'] as Map<String, dynamic>? ?? {};
    // دسترسی به آبجکت تودرتوی hotel که داخل room_details است
    final hotelDetails = roomDetails['hotel'] as Map<String, dynamic>? ?? {};

    return ReservationModel(
      id: json['id'] ?? 0,
      hotelId: hotelDetails['id'] ?? 0,
      hotelName: hotelDetails['name'] ?? 'نام هتل نامشخص',

      // ترکیب نوع و شماره اتاق برای roomInfo
      roomInfo: '${roomDetails['room_type'] ?? 'اتاق'} شماره ${roomDetails['room_number'] ?? ''}'.trim(),

      checkInDate: json['check_in_date'] ?? '',
      checkOutDate: json['check_out_date'] ?? '',

      // قیمت از داخل roomDetails خوانده می‌شود و از رشته به عدد تبدیل می‌شود
      amount: double.tryParse(roomDetails['price']?.toString() ?? '0.0') ?? 0.0,

      status: json['status'] ?? 'نامشخص',

      // ساخت URL کامل برای تصویر هتل
      hotelImageUrl: _buildImageUrl(hotelDetails['image']),

    );
  }

  // این متدها برای فیلتر کردن صحیح هستند
  bool get isActive {
    final s = status.toLowerCase();
    return s == 'active' || s == 'confirmed' || s == 'pending';
  }

  bool get isCompleted {
    final s = status.toLowerCase();
    return s == 'completed' || s == 'finished';
  }
}