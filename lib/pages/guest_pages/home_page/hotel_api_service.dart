import 'dart:convert';
import 'package:bookit/pages/guest_pages/home_page/model/hotel_model.dart';
import 'package:http/http.dart' as http;
import '../../authentication_page/auth_service.dart';

class HotelApiService {
  static const String _baseUrl = 'https://newbookit.darkube.app/hotel-api/all-hotels/';

  final AuthService _authService;

  HotelApiService(this._authService);

  Future<List<Hotel>> fetchHotels({
    String? city,
    bool? hasDiscount,
    double? minRate,
  }) async {
    Map<String, String> queryParams = {};
    if (city != null) queryParams['location'] = city;
    if (hasDiscount != null && hasDiscount) queryParams['has_discount'] = 'true';
    if (minRate != null) queryParams['min_rate'] = minRate.toString();

    final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParams);

    final String? token = _authService.token;

    final Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      final response = await http.get(uri, headers: headers);

      print('Status Code for fetchHotels: ${response.statusCode}');
      print('Response Body: ${utf8.decode(response.bodyBytes)}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((json) => Hotel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load hotels. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }
}