import 'dart:convert';
import 'package:bookit/pages/guest_pages/home_page/model/hotel_model.dart';
import 'package:http/http.dart' as http;


class HotelApiService {
  // این آدرس پایه ممکن است با آدرس پایه شما متفاوت باشد
  static const String _baseUrl = 'https://bookit-web.onrender.com/hotelManager-api/hotels/';

  Future<List<Hotel>> fetchHotels({
    String? city,
    bool? hasDiscount,
    double? minRate,
  }) async {
    // ساخت کوئری پارامترها
    Map<String, String> queryParams = {};
    if (city != null) queryParams['location'] = city;
    if (hasDiscount != null && hasDiscount) queryParams['has_discount'] = 'true';
    if (minRate != null) queryParams['min_rate'] = minRate.toString();

    final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParams);

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        // فرض می‌کنیم پاسخ سرور یک لیست از هتل‌ها است
        return data.map((json) => Hotel.fromJson(json)).toList();
      } else {
        // اگر سرور خطا برگرداند
        throw Exception('Failed to load hotels. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // اگر مشکل در ارتباط با شبکه باشد
      throw Exception('Failed to connect to the server: $e');
    }
  }
}