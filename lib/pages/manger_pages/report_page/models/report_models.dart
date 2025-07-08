// lib/models/report_models.dart

class ReservationStats {
  final DateTime startDate;
  final DateTime endDate;
  final int totalReservations;
  final double totalRevenue;
  final List<HotelStats> hotels;

  ReservationStats({
    required this.startDate,
    required this.endDate,
    required this.totalReservations,
    required this.totalRevenue,
    required this.hotels,
  });

  factory ReservationStats.fromJson(Map<String, dynamic> json) {
    var hotelList = json['hotels'] as List;
    List<HotelStats> hotels = hotelList.map((i) => HotelStats.fromJson(i)).toList();

    return ReservationStats(
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      totalReservations: json['total_reservations'],
      totalRevenue: (json['total_revenue'] as num).toDouble(),
      hotels: hotels,
    );
  }
}

class HotelStats {
  final int hotelId;
  final String hotelName;
  final int reservationCount;
  final double revenue;

  HotelStats({
    required this.hotelId,
    required this.hotelName,
    required this.reservationCount,
    required this.revenue,
  });

  factory HotelStats.fromJson(Map<String, dynamic> json) {
    return HotelStats(
      hotelId: json['hotel_id'],
      hotelName: json['hotel_name'],
      reservationCount: json['reservation_count'],
      revenue: (json['revenue'] as num).toDouble(),
    );
  }
}