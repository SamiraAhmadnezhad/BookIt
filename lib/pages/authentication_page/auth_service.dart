// auth_service.dart (تغییرات در این فایل)

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// این ثابت‌ها را از AuthenticationPage.dart به اینجا منتقل کنید یا import کنید
const String BASE_URL = 'https://bookit.darkube.app';
const String GUEST_LOGIN_ENDPOINT = '$BASE_URL/auth/login/';
const String MANAGER_LOGIN_ENDPOINT = '$BASE_URL/hotelManager-api/get/';
const String LOGOUT_ENDPOINT = '$BASE_URL/auth/logout/'; // !!! آدرس endpoint خروج را تایید و در صورت نیاز اصلاح کنید !!!


class AuthService with ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  String? _token;
  String? _userRole; // برای اینکه بدانیم کاربر مهمان است یا مدیر
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
      print("Token found in storage: $_token, Role: $_userRole");
      notifyListeners();
    } else {
      print("No token found in storage during auto login.");
    }
  }

  Future<bool> _processLoginResponse(http.Response response, String role) async {
    final String responseBody = utf8.decode(response.bodyBytes);
    final responseData = jsonDecode(responseBody);

    if (response.statusCode == 200 || response.statusCode == 201) { // 201 هم برای created در نظر بگیریم
      print('Login successful ($role): $responseData');
      if (responseData['access'] != null) {
        _token = responseData['access'];
      } else if (responseData['token'] != null) {
        _token = responseData['token'];
      } else {
        print("Token key not found in response for $role login.");
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
      print('Login failed ($role): ${response.statusCode} - $responseBody');
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
      return await _processLoginResponse(response, 'guest');
    } catch (e) {
      print('Error during guest login request: $e');
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
      print('Error during guest login request: $e');
      _errorMessage = 'خطا در برقراری ارتباط با سرور.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sends a logout request to the server.
  /// Returns true if the server logout was successful or if no token was present (already logged out).
  /// Returns false if the server logout failed.
  Future<bool> logoutUserFromServer() async {
    if (_token == null) {
      print("No token to logout from server. Already considered logged out from server.");
      return true; // Already logged out or no session to invalidate on server
    }

    print("Attempting to logout from server with token: $_token");
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(LOGOUT_ENDPOINT), // !!! تایید کنید که این endpoint صحیح است !!!
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $_token', // ارسال توکن برای احراز هویت
        },
        // body: jsonEncode({}), // برخی APIها ممکن است body خالی یا refresh_token را انتظار داشته باشند
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 204) { // 204 No Content هم برای logout موفقیت آمیز است
        print('Successfully logged out from server. Status: ${response.statusCode}');
        return true;
      } else {
        print('Failed to logout from server. Status: ${response.statusCode}, Body: ${response.body}');
        _errorMessage = 'خطا در خروج از حساب کاربری در سرور. (${response.statusCode})';
        // حتی اگر خروج از سرور با خطا مواجه شود، ما هنوز توکن محلی را پاک می‌کنیم
        return false;
      }
    } catch (e) {
      print('Error during server logout request: $e');
      _errorMessage = 'خطا در ارتباط با سرور هنگام خروج.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  /// Clears local authentication data (token, role) and notifies listeners.
  Future<void> clearLocalAuthData() async {
    _token = null;
    _userRole = null;
    await _storage.delete(key: 'authToken');
    await _storage.delete(key: 'userRole');
    notifyListeners();
    print("Local auth data cleared (logged out locally).");
  }

  /// Logs out from server and then clears local auth data.
  Future<void> logout() async {
    bool serverLogoutSuccess = await logoutUserFromServer();
    // صرف نظر از موفقیت خروج از سرور، اطلاعات محلی را پاک می‌کنیم
    // تا کاربر در اپلیکیشن logout شود.
    await clearLocalAuthData();

    if (!serverLogoutSuccess) {
      // می‌توانید یک پیام خطا به کاربر نشان دهید که خروج از سرور ناموفق بوده
      // اما او از اپلیکیشن خارج شده است. این پیام در _errorMessage ست شده.
      print("Server logout was not successful, but local data cleared.");
    }
  }
}