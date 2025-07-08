// lib/services/report_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../models/report_models.dart';

class ReportService {
  static const String _baseUrl = 'https://fbookit.darkube.app';
  static const String _endpoint = '/hotelManager-api/hotel_manager/reservation_stats/';

  Future<ReservationStats> fetchReservationStats({
    required DateTime startDate,
    required DateTime endDate,
    required String token,
  }) async {
    final url = Uri.parse('$_baseUrl$_endpoint');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    // فرمت‌بندی تاریخ به صورت YYYY-MM-DD
    final body = json.encode({
      'start_date': DateFormat('y-MM-d').format(startDate),
      'end_date': DateFormat('y-MM-d').format(endDate),
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        return ReservationStats.fromJson(json.decode(decodedBody));
      } else {
        // پرتاب یک خطا با جزئیات برای مدیریت در UI
        throw Exception('Failed to load stats. Status code: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      // برای خطاهای شبکه و ...
      throw Exception('Failed to connect to the server: $e');
    }
  }
}