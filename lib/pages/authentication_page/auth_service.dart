import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String BASE_URL = 'https://newbookit.darkube.app';
const String GUEST_LOGIN_ENDPOINT = '$BASE_URL/auth/login/';
const String MANAGER_LOGIN_ENDPOINT = '$BASE_URL/hotelManager-api/get/';
const String LOGOUT_ENDPOINT = '$BASE_URL/auth/logout/';

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

  Future<bool> _processLoginResponse(http.Response response, String role) async {
    final String responseBody = utf8.decode(response.bodyBytes);
    final responseData = jsonDecode(responseBody);
    print(responseData);
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (responseData['access'] != null) {
        _token = responseData['access'];
      } else if (responseData['token'] != null) {
        _token = responseData['token'];
      } else {
        _errorMessage = "پاسخ سرور معتبر نیست (توکن یافت نشد).";
        return false;
      }
      _userRole = role;
      await _storage.write(key: 'authToken', value: _token);
      await _storage.write(key: 'userRole', value: _userRole);
      _errorMessage = null;
      return true;
    } else {
      _errorMessage = responseData['detail'] ?? 'خطا در ورود ($role).';
      if (responseData['non_field_errors'] != null && responseData['non_field_errors'] is List && responseData['non_field_errors'].isNotEmpty) {
        _errorMessage = responseData['non_field_errors'][0];
      } else if (responseData is Map) {
        List<String> errors = [];
        responseData.forEach((key, value) {
          if (value is List) errors.add("${value.join(', ')}");
          else if (value is String) errors.add(value);
        });
        if (errors.isNotEmpty) _errorMessage = errors.join('\n');
      }
      return false;
    }
  }

  Future<bool> loginGuest(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await http.post(
        Uri.parse(GUEST_LOGIN_ENDPOINT),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(<String, String>{'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 15));
      print(response.statusCode);
      return await _processLoginResponse(response, 'guest');
    } catch (e) {
      _errorMessage = 'خطا در برقراری ارتباط با سرور.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> loginManager(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await http.post(
        Uri.parse(MANAGER_LOGIN_ENDPOINT),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(<String, String>{'email': email.trim(), 'password': password}),
      ).timeout(const Duration(seconds: 15));
      return await _processLoginResponse(response, 'manager');
    } catch (e) {
      _errorMessage = 'خطا در برقراری ارتباط با سرور.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> logoutUserFromServer() async {
    if (_token == null) {
      return true;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(LOGOUT_ENDPOINT),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $_token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        _errorMessage = 'خطا در خروج از حساب کاربری در سرور. (${response.statusCode})';
        return false;
      }
    } catch (e) {
      _errorMessage = 'خطا در ارتباط با سرور هنگام خروج.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearLocalAuthData() async {
    _token = null;
    _userRole = null;
    await _storage.delete(key: 'authToken');
    await _storage.delete(key: 'userRole');
    notifyListeners();
  }

  Future<void> logout() async {
    await logoutUserFromServer();
    await clearLocalAuthData();
  }
}