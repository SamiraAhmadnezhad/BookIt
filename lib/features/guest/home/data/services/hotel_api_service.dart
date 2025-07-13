import 'dart:convert';
import 'package:bookit/features/auth/data/services/auth_service.dart';
import 'package:bookit/core/models/hotel_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class HomeApiService {
  // جدا کردن آدرس‌های پایه برای خوانایی و مدیریت بهتر
  static const String _hotelBaseUrl = 'https://fbookit.darkube.app/hotel-api/hotels';
  static const String _authBaseUrl = 'https://fbookit.darkube.app/auth';

  final AuthService _authService;

  HomeApiService(this._authService);

  // متد عمومی برای ارسال درخواست GET به API هتل‌ها
  Future<List<Hotel>> _getHotels(String endpoint, {Map<String, String>? queryParams}) async {
    final uri = Uri.parse('$_hotelBaseUrl$endpoint').replace(queryParameters: queryParams);
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      if (_authService.token != null) 'Authorization': 'Bearer ${_authService.token}',
    };

    debugPrint("Fetching hotels from: $uri");

    try {
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        final dynamic decodedJson = json.decode(utf8.decode(response.bodyBytes));
        final List<dynamic> data;

        if (decodedJson is Map<String, dynamic> && decodedJson.containsKey('data')) {
          data = decodedJson['data'] as List<dynamic>;
        } else if (decodedJson is List<dynamic>) {
          data = decodedJson;
        } else {
          throw Exception('Invalid server response format');
        }
        return data.map((json) => Hotel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load data. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect or process data: $e');
    }
  }

  // متدهای مربوط به دریافت لیست هتل‌ها
  Future<List<Hotel>> fetchHotelsByLocation(String city) => _getHotels('/by-location/', queryParams: {'location': city});
  Future<List<Hotel>> fetchHotelsWithDiscount() => _getHotels('/with-discount/');
  Future<List<Hotel>> fetchTopRatedHotels() => _getHotels('/top-rated/');

  // --- متدهای مربوط به علاقه‌مندی‌ها ---

  Future<bool> isHotelFavorite(int hotelId) async {
    final token = _authService.token;
    if (token == null) return false;

    final uri = Uri.parse('$_authBaseUrl/favorites/$hotelId/is-favorite/');
    final headers = {'Authorization': 'Bearer $token'};

    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['is_favorite'] ?? false;
      }
    } catch (e) {
      debugPrint("Error checking favorite status: $e");
    }
    return false;
  }

  Future<bool> addFavorite(int hotelId) async {
    final token = _authService.token;
    if (token == null) return false;

    final uri = Uri.parse('$_authBaseUrl/favorites/add/');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    final body = json.encode({'hotel_id': hotelId});

    try {
      final response = await http.post(uri, headers: headers, body: body);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("Error adding favorite: $e");
      return false;
    }
  }

  Future<bool> removeFavorite(int hotelId) async {
    final token = _authService.token;
    if (token == null) return false;

    // برای متد DELETE، بهتر است پارامترها را در URL یا body بفرستیم.
    // مستندات شما نشان می‌دهد که پارامتر در body است.
    final uri = Uri.parse('$_authBaseUrl/favorites/remove/');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    final body = json.encode({'hotel_id': hotelId});

    try {
      // استفاده از http.delete که برای این کار استانداردتر است.
      final response = await http.delete(uri, headers: headers, body: body);
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      debugPrint("Error removing favorite: $e");
      return false;
    }
  }
}