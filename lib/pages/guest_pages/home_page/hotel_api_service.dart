// فایل: services/hotel_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../authentication_page/auth_service.dart';
import 'model/hotel_model.dart';

class HotelApiService {
  static const String _baseUrl = 'https://newbookit.darkube.app/hotel-api/hotels';

  final AuthService _authService;

  HotelApiService(this._authService);

  // تابع کمکی برای ارسال درخواست و مدیریت پاسخ
  Future<List<Hotel>> _get(String endpoint, {Map<String, String>? queryParams}) async {
    final uri = Uri.parse('$_baseUrl$endpoint').replace(queryParameters: queryParams);

    final String? token = _authService.token;
    final Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        // *** بخش کلیدی: اصلاح نحوه خواندن JSON ***

        // 1. ابتدا کل پاسخ را به عنوان یک Map دیکد می‌کنیم
        // این کار برای APIهایی که لیست را داخل یک آبجکت برمی‌گردانند، ضروری است.
        final dynamic decodedJson = json.decode(utf8.decode(response.bodyBytes));

        // 2. چک می‌کنیم که آیا پاسخ یک Map است و کلید 'data' دارد یا مستقیما یک لیست است
        final List<dynamic> data;
        if (decodedJson is Map<String, dynamic> && decodedJson.containsKey('data')) {
          data = decodedJson['data'] as List<dynamic>;
        } else if (decodedJson is List<dynamic>) {
          data = decodedJson; // برای سازگاری با APIهایی که مستقیما لیست برمی‌گردانند
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

  /// دریافت هتل‌ها بر اساس شهر
  Future<List<Hotel>> fetchHotelsByLocation(String city) async {
    return _get('/by-location/', queryParams: {'location': city});
  }

  /// دریافت هتل‌های تخفیف‌دار
  Future<List<Hotel>> fetchHotelsWithDiscount() async {
    return _get('/with-discount/');
  }

  /// دریافت هتل‌های برتر
  Future<List<Hotel>> fetchTopRatedHotels() async {
    return _get('/top-rated/');
  }
}