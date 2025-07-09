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
    print("Fetching ALL hotels from: $url to find hotel with id: $hotelId");
    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(utf8.decode(response.bodyBytes));

        if (responseData.containsKey('data') && responseData['data'] is List) {
          final List<dynamic> hotelList = responseData['data'];

          final hotelJson = hotelList.firstWhere(
                (hotel) => hotel['id'].toString() == hotelId,
            orElse: () => null,
          );

          if (hotelJson != null) {
            return HotelDetails.fromJson(hotelJson);
          } else {
            throw Exception('Hotel with ID $hotelId not found in user\'s accessible list.');
          }
        } else {
          throw Exception('Invalid response format for hotel list: "data" key not found or is not a list.');
        }
      } else {
        throw Exception('Failed to load hotel list (Status code: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('An error occurred while fetching hotel details: $e');
    }
  }

  Future<List<Room>> fetchHotelRooms(String hotelId, String token) async {
    final url = Uri.parse('$_roomApiBaseUrl/room/$hotelId/');
    print("Fetching real rooms via GET from: $url");
    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 20));
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