import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// این ثابت‌ها را از AuthenticationPage.dart به اینجا منتقل کنید یا import کنید
const String BASE_URL = 'https://bookit.darkube.app';
const String GUEST_LOGIN_ENDPOINT = '$BASE_URL/auth/login/';
const String MANAGER_LOGIN_ENDPOINT = '$BASE_URL/hotelManager-api/hotel-manager/get/';


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
    }
  }

  Future<bool> _processLoginResponse(http.Response response, String role) async {
    final responseData = jsonDecode(utf8.decode(response.bodyBytes)); // utf8.decode برای کاراکترهای فارسی

    if (response.statusCode == 200) {
      print('Login successful ($role): $responseData');
      if (responseData['access'] != null) { // معمولا توکن دسترسی با کلید 'access' یا 'token' میاد
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
      if (responseData['non_field_errors'] != null && responseData['non_field_errors'] is List) {
        _errorMessage = responseData['non_field_errors'][0];
      } else if (responseData is Map) { // برای خطاهای کلی‌تر
        List<String> errors = [];
        responseData.forEach((key, value) {
          if (value is List) errors.add("${value.join(', ')}");
          else if (value is String) errors.add(value);
        });
        if (errors.isNotEmpty) _errorMessage = errors.join('\n');
      }
      print('Login failed ($role): ${response.statusCode} - ${response.body}');
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
      );
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
        Uri.parse(MANAGER_LOGIN_ENDPOINT), // یا endpoint صحیح برای لاگین مدیر
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(<String, String>{'email': email, 'password': password}),
      );
      return await _processLoginResponse(response, 'manager');
    } catch (e) {
      print('Error during manager login request: $e');
      _errorMessage = 'خطا در برقراری ارتباط با سرور.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> logout() async {
    _token = null;
    _userRole = null;
    await _storage.delete(key: 'authToken');
    await _storage.delete(key: 'userRole');
    notifyListeners();
    print("Logged out");
  }

}