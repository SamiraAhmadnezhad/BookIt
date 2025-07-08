
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../authentication_page/auth_service.dart';
import '../home_page/model/room_model.dart';
import 'model/search_params_model.dart';

class SearchApiService {
  static const String _searchUrl = 'https://fbookit.darkube.app/room-api/all-rooms/';

  final AuthService _authService;

  SearchApiService(this._authService);

  Future<List<Room>> searchAvailableRooms(SearchParams params) async {
    final String? token = _authService.token;
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final body = jsonEncode({
      'city': params.city,
      'check_in_date': params.checkInDate,
      'check_out_date': params.checkOutDate,
      'rooms': [
        {
          'type_of_room': params.roomType, // استفاده مستقیم از مقدار API
          'number_of_passengers': params.numberOfPassengers,
          'number_of_rooms': 1,
        }
      ]
    });

    try {
      final response = await http.post(
        Uri.parse(_searchUrl),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        // *** بخش کلیدی: بازنویسی کامل منطق خواندن JSON ***

        final Map<String, dynamic> decodedResponse = json.decode(utf8.decode(response.bodyBytes));

        // 1. به مسیر data -> available_rooms بروید
        final Map<String, dynamic>? data = decodedResponse['data'] as Map<String, dynamic>?;
        final Map<String, dynamic>? availableRooms = data?['available_rooms'] as Map<String, dynamic>?;

        if (availableRooms == null || availableRooms.isEmpty) {
          return []; // اگر هیچ اتاق موجودی نبود، لیست خالی برگردان
        }

        // 2. یک لیست برای جمع‌آوری تمام اتاق‌ها ایجاد کنید
        List<Room> allAvailableRooms = [];

        // 3. روی تمام کلیدهای داخل available_rooms (مثلا "Single", "Double") پیمایش کنید
        availableRooms.forEach((roomType, roomTypeData) {
          if (roomTypeData is Map<String, dynamic> && roomTypeData['available'] == true) {
            // 4. لیست rooms را از داخل هر نوع اتاق استخراج کنید
            final List<dynamic>? roomsList = roomTypeData['rooms'] as List<dynamic>?;
            if (roomsList != null) {
              for (var roomJson in roomsList) {
                // 5. هر اتاق را به مدل Room تبدیل کرده و به لیست کلی اضافه کنید
                allAvailableRooms.add(Room.fromJson(roomJson));
              }
            }
          }
        });

        return allAvailableRooms;

      } else {
        throw Exception('Failed to search rooms. Status: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to connect or process search result: $e');
    }
  }
}