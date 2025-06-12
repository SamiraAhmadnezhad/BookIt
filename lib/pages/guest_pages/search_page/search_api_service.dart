// فایل: lib/pages/guest_pages/search_page/services/search_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../authentication_page/auth_service.dart';
import '../home_page/model/room_model.dart';
import 'model/search_params_model.dart';

class SearchApiService {
  static const String _searchUrl = 'https://newbookit.darkube.app/room-api/all-rooms/';

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
          'type_of_room': params.apiRoomType,
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
        final Map<String, dynamic> decodedData = json.decode(utf8.decode(response.bodyBytes));
        // اینجا هم چک می‌کنیم که کلید data وجود داشته باشد
        if (decodedData.containsKey('data') && decodedData['data'] is List) {
          final List<dynamic> roomListData = decodedData['data'];
          return roomListData.map((json) => Room.fromJson(json)).toList();
        } else {
          // اگر پاسخ ساختار مورد انتظار را نداشت
          return []; // یک لیست خالی برمی‌گردانیم یا خطا throw می‌کنیم
        }
      } else {
        throw Exception('Failed to search rooms. Status: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server or process search result: $e');
    }
  }
}