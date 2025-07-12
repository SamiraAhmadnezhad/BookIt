class HotelReservationModel {
  final int id;
  final String hotelName;
  final String hotelLocation;
  final String roomName;
  final String checkInDate;
  final String checkOutDate;
  final double price;
  final String guestFullName;
  final String guestEmail;

  HotelReservationModel({
    required this.id,
    required this.hotelName,
    required this.hotelLocation,
    required this.roomName,
    required this.checkInDate,
    required this.checkOutDate,
    required this.price,
    required this.guestFullName,
    required this.guestEmail,
  });

  factory HotelReservationModel.fromJson(Map<String, dynamic> json, {String? parentHotelName, String? parentHotelLocation}) {
    final userJson = json['user'] as Map<String, dynamic>? ?? {};
    final paymentJson = json['payments'] as Map<String, dynamic>? ?? {};

    return HotelReservationModel(
      id: json['id'] ?? 0,
      hotelName: json['hotel_name'] ?? parentHotelName ?? 'نام هتل نامشخص',
      hotelLocation: parentHotelLocation ?? 'آدرس نامشخص',
      roomName: json['room_name'] ?? json['room_type'] ?? 'نام اتاق نامشخص',
      checkInDate: json['check_in_date'] ?? '',
      checkOutDate: json['check_out_date'] ?? '',
      price: (paymentJson['amount'] as num?)?.toDouble() ?? 0.0,
      guestFullName: '${userJson['name'] ?? ''} ${userJson['last_name'] ?? ''}'.trim(),
      guestEmail: userJson['email'] ?? 'ایمیل نامشخص',
    );
  }
}