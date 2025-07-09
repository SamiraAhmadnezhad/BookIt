import 'dart:convert';
import 'package:http/http.dart' as http;

class ReservationApiService {
  static const String _baseUrl = 'https://fbookit.darkube.app';

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
      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

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
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

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
      if (response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}