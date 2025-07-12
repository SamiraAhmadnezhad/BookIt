import 'dart:convert';
import 'package:bookit/features/auth/data/services/auth_service.dart';
import 'package:bookit/core/models/hotel_model.dart';
import 'package:http/http.dart' as http;

class HomeApiService {
  static const String _baseUrl = 'https://fbookit.darkube.app/hotel-api/hotels';
  final AuthService _authService;

  HomeApiService(this._authService);

  Future<List<Hotel>> _get(String endpoint, {Map<String, String>? queryParams}) async {
    final uri = Uri.parse('$_baseUrl$endpoint').replace(queryParameters: queryParams);
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      if (_authService.token != null) 'Authorization': 'Bearer ${_authService.token}',
    };

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

  Future<List<Hotel>> fetchHotelsByLocation(String city) => _get('/by-location/', queryParams: {'location': city});
  Future<List<Hotel>> fetchHotelsWithDiscount() => _get('/with-discount/');
  Future<List<Hotel>> fetchTopRatedHotels() => _get('/top-rated/');
}