// lib/pages/guest_pages/hotel_detail_page/data/services/hotel_api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/hotel_details_model.dart';
import '../models/room_model.dart';
import '../models/review_model.dart';

class HotelApiService {
  static const String _hotelApiBaseUrl = 'https://fbookit.darkube.app/hotel-api';
  static const String _roomApiBaseUrl = 'https://fbookit.darkube.app/room-api';

  Future<HotelDetails> fetchHotelDetails(String hotelId, String token) async {
    final url = Uri.parse('$_hotelApiBaseUrl/hotel/$hotelId/');
    print("Fetching real hotel details via GET from: $url");

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      ).timeout(const Duration(seconds: 20));

      // <<< اینجا خط print اضافه شده است >>>
      print("===== Hotel Details API Response (Status: ${response.statusCode}) =====");
      print(utf8.decode(response.bodyBytes));
      print("==========================================================");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(utf8.decode(response.bodyBytes));

        if (responseData.containsKey('data') && responseData['data'] is Map) {
          return HotelDetails.fromJson(responseData['data']);
        } else {
          return HotelDetails.fromJson(responseData);
        }
      } else {
        throw Exception('Failed to load hotel details (Status code: ${response.statusCode})');
      }
    } catch (e) {
      // اینجا خطا را دوباره پرتاب می‌کنیم تا FutureBuilder آن را دریافت کند
      throw Exception('An error occurred while fetching hotel details: $e');
    }
  }

  // بقیه متدها بدون تغییر باقی می‌مانند
  Future<List<Room>> fetchHotelRooms(String hotelId, String token) async {
    final url = Uri.parse('$_roomApiBaseUrl/room/$hotelId/');
    print("Fetching real rooms via GET from: $url");
    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 20));

      // این پرینت را برای اتاق‌ها هم اضافه می‌کنیم برای اطمینان
      print("===== Rooms API Response (Status: ${response.statusCode}) =====");
      print(utf8.decode(response.bodyBytes));
      print("==================================================");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(utf8.decode(response.bodyBytes));
        if (responseData.containsKey('data') && responseData['data'] != null) {
          final List<dynamic> roomsData = responseData['data'] as List<dynamic>;
          return roomsData.map((json) => Room.fromJson(json)).toList();
        } else {
          return [];
        }
      } else {
        return [];
      }
    } catch (e) {
      print("Error fetching rooms: $e");
      return [];
    }
  }

  Future<List<Review>> fetchHotelReviews(String hotelId, String currentToken) async {
    await Future.delayed(const Duration(seconds: 1));
    return Review.sampleReviews;
  }

  Future<bool> submitReview(String hotelId, Review reviewData, String currentToken) async {
    print("Submitting review for hotel $hotelId: ${reviewData.userName}");
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  Future<bool> toggleFavoriteHotel(String hotelId, bool newFavoriteState, String currentToken) async {
    print("Toggling favorite for hotel $hotelId to $newFavoriteState");
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }
}