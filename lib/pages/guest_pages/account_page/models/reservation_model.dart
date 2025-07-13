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

  static String _buildImageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return 'https://via.placeholder.com/150';
    }
    if (path.startsWith('http')) {
      return path;
    }
    return 'https://fbookit.darkube.app$path';
  }

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    final roomDetails = json['room_details'] as Map<String, dynamic>? ?? {};
    final hotelDetails = roomDetails['hotel'] as Map<String, dynamic>? ?? {};

    return ReservationModel(
      id: json['id'] ?? 0,
      hotelId: hotelDetails['id'] ?? 0,
      hotelName: hotelDetails['name'] ?? 'نام هتل نامشخص',

      roomInfo: '${roomDetails['room_type'] ?? 'اتاق'} شماره ${roomDetails['room_number'] ?? ''}'.trim(),

      checkInDate: json['check_in_date'] ?? '',
      checkOutDate: json['check_out_date'] ?? '',

      amount: double.tryParse(roomDetails['price']?.toString() ?? '0.0') ?? 0.0,

      status: json['status'] ?? 'نامشخص',

      hotelImageUrl: _buildImageUrl(hotelDetails['image']),

    );
  }
}