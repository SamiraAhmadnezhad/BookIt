import 'package:bookit/features/auth/data/services/auth_service.dart';
import 'package:http/http.dart' as http;

class ManagerApiService {
  static const String _baseUrl = 'https://fbookit.darkube.app';
  final AuthService _authService;

  ManagerApiService(this._authService);

  Future<bool> deleteHotel(String hotelId) async {
    final uri = Uri.parse('$_baseUrl/hotel-api/hotel/$hotelId/');
    final response = await http
        .delete(uri, headers: {'Authorization': 'Bearer ${_authService.token}'});
    return response.statusCode == 204;
  }

  Future<bool> deleteRoom(String roomId) async {
    final uri = Uri.parse('$_baseUrl/room-api/remove/$roomId/');
    final response = await http
        .delete(uri, headers: {'Authorization': 'Bearer ${_authService.token}'});
    return response.statusCode == 204;
  }
}