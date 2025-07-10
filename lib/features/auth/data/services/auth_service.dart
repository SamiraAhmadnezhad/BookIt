import 'dart:convert';
import 'package:bookit/features/auth/utils/api_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService with ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  String? _token;
  String? _userRole;
  bool _isLoading = false;
  String? _errorMessage;

  String? get token => _token;
  String? get userRole => _userRole;
  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthService() {
    _tryAutoLogin();
  }

  Future<void> _tryAutoLogin() async {
    _token = await _storage.read(key: 'authToken');
    _userRole = await _storage.read(key: 'userRole');
    if (_token != null) {
      notifyListeners();
    }
  }

  Future<String?> _performAuthRequest(String url, Map<String, String> body, {String? successRole}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

      final responseBody = utf8.decode(response.bodyBytes);
      final responseData = jsonDecode(responseBody);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (successRole != null) {
          _token = responseData['access'] ?? responseData['token'];
          _userRole = successRole;
          await _storage.write(key: 'authToken', value: _token);
          await _storage.write(key: 'userRole', value: _userRole);
        }
        _errorMessage = null;
        return null; // Success
      } else {
        _errorMessage = _parseError(responseData);
        return _errorMessage;
      }
    } catch (e) {
      _errorMessage = 'خطا در برقراری ارتباط با سرور.';
      return _errorMessage;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _parseError(dynamic responseData) {
    if (responseData == null) return 'خطای نامشخص رخ داد.';
    if (responseData['detail'] is String) return responseData['detail'];
    if (responseData['non_field_errors'] is List && responseData['non_field_errors'].isNotEmpty) {
      return responseData['non_field_errors'][0];
    }
    if (responseData is Map) {
      final errors = <String>[];
      responseData.forEach((key, value) {
        if (value is List) errors.add("${value.join(', ')}");
        else if (value is String) errors.add(value);
      });
      if (errors.isNotEmpty) return errors.join('\n');
    }
    return 'خطا در پردازش پاسخ سرور.';
  }

  Future<String?> login(String email, String password, bool isManager) async {
    final url = isManager ? ApiConstants.managerLogin : ApiConstants.guestLogin;
    final role = isManager ? 'manager' : 'guest';
    return await _performAuthRequest(url, {'email': email, 'password': password}, successRole: role);
  }

  Future<String?> register(Map<String, String> data, bool isManager) async {
    final url = isManager ? ApiConstants.managerRegister : ApiConstants.guestRegister;
    return await _performAuthRequest(url, data);
  }

  Future<String?> verifyOtp(String email, String otp) async {
    return await _performAuthRequest(ApiConstants.verifyEmail, {'email': email, 'verification_code': otp});
  }

  Future<String?> resendOtp(String email) async {
    return await _performAuthRequest(ApiConstants.resendOtp, {'email': email});
  }

  Future<void> logout() async {
    _token = null;
    _userRole = null;
    await _storage.deleteAll();
    notifyListeners();
  }
}