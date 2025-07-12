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

  factory HotelReservationModel.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] as Map<String, dynamic>? ?? {};

    return HotelReservationModel(
      id: json['id'] ?? 0,
      hotelName: json['hotel_name'] ?? 'نام هتل نامشخص',
      hotelLocation: json['hotel_location'] ?? 'آدرس نامشخص',
      roomName: json['room_name'] ?? 'نام اتاق نامشخص',
      checkInDate: json['check_in_date'] ?? '',
      checkOutDate: json['check_out_date'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      guestFullName: '${userJson['first_name'] ?? ''} ${userJson['last_name'] ?? ''}'.trim(),
      guestEmail: userJson['email'] ?? 'ایمیل نامشخص',
    );
  }
}