import 'dart:convert';
import 'package:bookit/core/models/review_model.dart';
import 'package:bookit/core/models/room_model.dart';
import 'package:bookit/features/auth/data/services/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class HotelDetailApiService {
  static const String _baseUrl = 'https://fbookit.darkube.app';
  final AuthService _authService;

  HotelDetailApiService(this._authService);

  Future<List<Room>> fetchHotelRooms(String hotelId) async {
    final uri = Uri.parse('$_baseUrl/room-api/room/$hotelId/');
    final headers = {'Authorization': 'Bearer ${_authService.token}'};

    debugPrint('--- [API Request] Fetching Rooms ---');
    debugPrint('URL: $uri');

    try {
      final response = await http.get(uri, headers: headers);
      debugPrint('Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decodedBody = json.decode(utf8.decode(response.bodyBytes));
        if (decodedBody is Map<String, dynamic> &&
            decodedBody.containsKey('data')) {
          final data = decodedBody['data'] as List;
          debugPrint('Rooms fetched successfully: ${data.length} rooms');
          return data.map((json) => Room.fromJson(json)).toList();
        } else {
          debugPrint('Invalid response format: "data" key not found.');
          return []; // Return empty list on invalid format
        }
      } else {
        // For 404 or any other error status, return an empty list
        debugPrint(
            'Failed to load rooms. Status: ${response.statusCode}, Body: ${response.body}');
        return [];
      }
    } catch (e) {
      // For network exceptions, etc., also return an empty list
      debugPrint('An exception occurred while fetching rooms: $e');
      return [];
    }
  }

  Future<List<Review>> fetchHotelReviews(String hotelId) async {
    final uri = Uri.parse('$_baseUrl/reviews/hotels/$hotelId/');
    final headers = {'Authorization': 'Bearer ${_authService.token}'};

    debugPrint('--- [API Request] Fetching Reviews ---');
    debugPrint('URL: $uri');

    final response = await http.get(uri, headers: headers);

    debugPrint('Response Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes)) as List;
      debugPrint('Reviews fetched successfully: ${data.length} reviews');
      return data.map((json) => Review.fromJson(json)).toList();
    } else {
      debugPrint('Failed to load reviews. Body: ${response.body}');
      throw Exception('Failed to load reviews');
    }
  }

  Future<bool> submitReview({
    required String hotelId,
    required double rating,
    required List<String> goodThings,
    required List<String> badThings,
  }) async {
    final uri = Uri.parse('$_baseUrl/reviews/hotels/$hotelId/');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${_authService.token}',
    };

    final body = jsonEncode({
      'hotel': int.parse(hotelId),
      'rating': rating.toInt(),
      'good_thing': goodThings.join(','),
      'bad_thing': badThings.join(','),
    });

    debugPrint('--- [API Request] Submitting Review ---');
    debugPrint('URL: $uri');
    debugPrint('Body: $body');

    final response = await http.post(uri, headers: headers, body: body);

    debugPrint('Response Status: ${response.statusCode}');
    return response.statusCode == 201 || response.statusCode == 200;
  }
}