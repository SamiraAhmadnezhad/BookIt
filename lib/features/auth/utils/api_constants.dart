class ApiConstants {
  static const String baseUrl = 'https://fbookit.darkube.app';

  // Auth Endpoints
  static const String guestLogin = '$baseUrl/auth/login/';
  static const String managerLogin = '$baseUrl/hotelManager-api/login/';
  static const String logout = '$baseUrl/auth/logout/';

  // Registration Endpoints
  static const String guestRegister = '$baseUrl/auth/register/';
  static const String managerRegister = '$baseUrl/hotelManager-api/create/';

  // Verification Endpoints
  static const String verifyEmail = '$baseUrl/auth/verify-email/';
  static const String resendOtp = '$baseUrl/auth/resend-verification-code/';
}