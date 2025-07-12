class HotelReservationModel {
  final int id;
  final int roomId; // تغییر نام از roomName
  final int userId; // تغییر نام از guestFullName/Email
  final String checkInDate;
  final String checkOutDate;
  final String status;
  // فیلدهای زیر در پاسخ API وجود ندارند، پس مقادیر ثابت یا پیش‌فرض می‌گیرند
  final String hotelName;
  final String hotelLocation;
  final String roomName;
  final double price;
  final String guestFullName;
  final String guestEmail;

  HotelReservationModel({
    required this.id,
    required this.roomId,
    required this.userId,
    required this.checkInDate,
    required this.checkOutDate,
    required this.status,
    // مقادیر پیش‌فرض برای فیلدهای ناموجود
    this.hotelName = 'هتل شما', // چون مدیر فقط هتل خودش را می‌بیند
    this.hotelLocation = 'آدرس نامشخص',
    this.roomName = 'اطلاعات اتاق نامشخص',
    this.price = 0.0,
    this.guestFullName = 'نام کاربر نامشخص',
    this.guestEmail = 'ایمیل نامشخص',
  });

  factory HotelReservationModel.fromJson(Map<String, dynamic> json) {
    return HotelReservationModel(
      id: json['id'] ?? 0,
      roomId: json['room'] ?? 0, // خواندن شناسه اتاق
      userId: json['user'] ?? 0, // خواندن شناسه کاربر
      checkInDate: json['check_in_date'] ?? '',
      checkOutDate: json['check_out_date'] ?? '',
      status: json['status'] ?? 'نامشخص',
      // برای فیلدهای دیگر، مقادیر پیش‌فرض constructor استفاده می‌شود
      // چون در JSON وجود ندارند.
      // می‌توانیم برای نام اتاق، شناسه آن را نمایش دهیم
      roomName: 'اتاق با شناسه: ${json['room'] ?? 0}',
      guestFullName: 'کاربر با شناسه: ${json['user'] ?? 0}',
    );
  }
}