import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

class ReservationApiService {
  static const String _baseUrl = 'https://fbookit.darkube.app';

  // Endpoint 1: Lock Room
  Future<bool> lockRoom({
    required String hotelId,
    required List<String> roomNumbers,
    required String token,
  }) async {
    final uri = Uri.parse('$_baseUrl/reservation-api/lock-rooms/');
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
    final body = json.encode({
      'hotel_id': hotelId,
      'room_numbers': roomNumbers,
    });

    try {
      final response = await http.post(uri, headers: headers, body: body);
      // موفقیت‌آمیز بودن قفل اتاق معمولا با کد 200 یا 204 مشخص می‌شود
      if (response.statusCode == 200 || response.statusCode == 204) {
        print('اتاق‌ها با موفقیت قفل شدند: $roomNumbers');
        return true;
      } else {
        print('خطا در قفل کردن اتاق: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('استثنا در قفل کردن اتاق: $e');
      return false;
    }
  }

  // Endpoint 2: Unlock Room
  Future<bool> unlockRoom({
    required List<String> roomNumbers,
    required String token,
  }) async {
    final uri = Uri.parse('$_baseUrl/reservation-api/unlock-rooms/');
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
    final body = json.encode({
      'room_numbers': roomNumbers,
    });

    try {
      final response = await http.post(uri, headers: headers, body: body);
      if (response.statusCode == 200 || response.statusCode == 204) {
        print('اتاق‌ها با موفقیت آزاد شدند: $roomNumbers');
        return true;
      } else {
        print('خطا در آزاد کردن اتاق: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('استثنا در آزاد کردن اتاق: $e');
      return false;
    }
  }

  // Endpoint 3: Create Reservation
  Future<bool> createReservation({
    required Map<String, dynamic> reservationData,
    required String token,
  }) async {
    final uri = Uri.parse('$_baseUrl/reservation-api/reserve/');
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
    final body = json.encode(reservationData);

    try {
      final response = await http.post(uri, headers: headers, body: body);
      if (response.statusCode == 201) { // 201 Created
        print('رزرو با موفقیت ایجاد شد.');
        return true;
      } else {
        print('خطا در ایجاد رزرو: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('استثنا در ایجاد رزرو: $e');
      return false;
    }
  }
}