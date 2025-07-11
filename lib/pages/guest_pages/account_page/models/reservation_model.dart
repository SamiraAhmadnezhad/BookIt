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
  final double hotelRating;

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
    required this.hotelRating,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      id: json['id'] ?? 0,
      hotelId: json['hotel_id'] ?? 0,
      hotelName: json['hotel_name'] ?? 'نام هتل نامشخص',
      roomInfo: json['room_info'] ?? 'اطلاعات اتاق نامشخص',
      checkInDate: json['check_in_date'] ?? '',
      checkOutDate: json['check_out_date'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'نامشخص',
      hotelImageUrl: json['hotel_image_url'] ?? 'https://via.placeholder.com/150',
      hotelRating: (json['hotel_rating'] as num?)?.toDouble() ?? 0.0,
    );
  }

  bool get isCompleted {
    return status.toLowerCase() == 'completed';
  }

  bool get isActive {
    return status.toLowerCase() == 'active' || status.toLowerCase() == 'confirmed';
  }
}