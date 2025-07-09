// فایل: lib/pages/guest_pages/home_page/hotel_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../authentication_page/auth_service.dart';
import 'model/hotel_model.dart';

class HotelApiService {
  static const String _baseUrl = 'https://fbookit.darkube.app/hotel-api/hotels';

  final AuthService _authService;

  HotelApiService(this._authService);

  Future<List<Hotel>> _get(String endpoint, {Map<String, String>? queryParams}) async {
    final uri = Uri.parse('$_baseUrl$endpoint').replace(queryParameters: queryParams);

    final String? token = _authService.token;
    final Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.get(uri, headers: headers);
      print(response.statusCode);
      if (response.statusCode == 200) {
        final dynamic decodedJson = json.decode(utf8.decode(response.bodyBytes));

        final List<dynamic> data;
        if (decodedJson is Map<String, dynamic> && decodedJson.containsKey('data')) {
          data = decodedJson['data'] as List<dynamic>;
        } else if (decodedJson is List<dynamic>) {
          data = decodedJson;
        } else {
          throw Exception('فرمت پاسخ سرور نامعتبر است.');
        }

        return data.map((json) => Hotel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load data from $endpoint. Status: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to connect or process data for $endpoint: $e');
    }
  }

  Future<List<Hotel>> fetchHotelsByLocation(String city) async {
    return _get('/by-location/', queryParams: {'location': city});
  }

  Future<List<Hotel>> fetchHotelsWithDiscount() async {
    return _get('/with-discount/');
  }

  Future<List<Hotel>> fetchTopRatedHotels() async {
    return _get('/top-rated/');
  }
}