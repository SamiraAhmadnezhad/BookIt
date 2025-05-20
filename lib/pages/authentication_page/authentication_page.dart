import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../manger_pages/hotel_info_page/screens/hotel_list_screen.dart';
import 'auth_service.dart';
import 'constants.dart';
import 'widgets/auth_card.dart';

// --- API Endpoints ---
const String BASE_URL = 'https://bookit.darkube.app';
const String GUEST_LOGIN_ENDPOINT = '$BASE_URL/auth/login/';
const String MANAGER_LOGIN_ENDPOINT = '$BASE_URL/hotelManager-api/hotel-manager/get/';
const String INITIAL_MANAGER_REGISTER_ENDPOINT='$BASE_URL/hotelManager-api/create/';
const String INITIAL_GUEST_REGISTER_ENDPOINT='$BASE_URL/auth/register/';
const String RESEND_OTP_ENDPOINT = '$BASE_URL/auth/resend-verification-code/'; // For requesting/resending OTP
const String VERIFY_EMAIL_ENDPOINT = '$BASE_URL/auth/verify-email/'; // For final OTP verification

class AuthenticationPage extends StatefulWidget {
  const AuthenticationPage({super.key});
  @override
  State<AuthenticationPage> createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  // --- State Variables ---
  int _selectedTab = 0;
  bool _isChecked = false;
  bool _otpSend = false;
  String _otpTabLabel = "";
  bool _isLoading = false; // For general loading state (main button)
  bool _isLoadingResendOtp = false; // For resend OTP button specifically
  bool _isLoginAsManager = false;

  // --- Text Editing Controllers ---
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _managerEmailController = TextEditingController();
  final _managerNameController = TextEditingController();
  final _managerLastNameController = TextEditingController();
  final _managerNationalIdController = TextEditingController();
  final _managerHotelNameController = TextEditingController();
  final _managerPasswordController = TextEditingController();
  final _managerConfirmPasswordController = TextEditingController();
  final _guestNameController = TextEditingController();
  final _guestLastNameController = TextEditingController();
  final _guestEmailController = TextEditingController();
  final _guestPasswordController = TextEditingController();
  final _guestConfirmPasswordController = TextEditingController();
  final _otp1Controller = TextEditingController();
  final _otp2Controller = TextEditingController();
  final _otp3Controller = TextEditingController();
  final _otp4Controller = TextEditingController();

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _managerEmailController.dispose();
    _managerNameController.dispose();
    _managerLastNameController.dispose();
    _managerNationalIdController.dispose();
    _managerHotelNameController.dispose();
    _managerPasswordController.dispose();
    _managerConfirmPasswordController.dispose();
    _guestNameController.dispose();
    _guestLastNameController.dispose();
    _guestEmailController.dispose();
    _guestPasswordController.dispose();
    _guestConfirmPasswordController.dispose();
    _otp1Controller.dispose();
    _otp2Controller.dispose();
    _otp3Controller.dispose();
    _otp4Controller.dispose();
    super.dispose();
  }

  void _clearAllFields() {
    _loginEmailController.clear();
    _loginPasswordController.clear();
    _managerEmailController.clear();
    _managerNameController.clear();
    _managerLastNameController.clear();
    _managerNationalIdController.clear();
    _managerHotelNameController.clear();
    _managerPasswordController.clear();
    _managerConfirmPasswordController.clear();
    _guestNameController.clear();
    _guestLastNameController.clear();
    _guestEmailController.clear();
    _guestPasswordController.clear();
    _guestConfirmPasswordController.clear();
    _clearOtpFields();
  }

  void _clearOtpFields() {
    _otp1Controller.clear();
    _otp2Controller.clear();
    _otp3Controller.clear();
    _otp4Controller.clear();
  }

  void _changeTab(int index) {
    if (_selectedTab == index) return;
    setState(() {
      _selectedTab = index;
      _isChecked = false;
      _otpSend = false;
      _isLoading = false;
      _isLoadingResendOtp = false;
      _clearAllFields();
      if (_selectedTab == 0) {
        _isLoginAsManager = false;
      }
    });
  }

  void _toggleTermsCheckbox(bool? value) {
    if (value != null) {
      setState(() {
        _isChecked = value;
      });
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textDirection: TextDirection.rtl),
        backgroundColor: isError ? Colors.redAccent : null,
      ),
    );
  }

  // --- API Call: Submit Initial Registration Data ---
  Future<bool> _handleRequestSignupInitial(String emailForOtp) async {
    // This function is now called by _handleContinueToOtp
    // It sends the initial registration data. If successful, _handleContinueToOtp will then call _requestAndProceedToOtpScreen.
    String INITIAL_REGISTER_ENDPOINT;
    setState(() => _isLoading = true); // Main button is loading

    Map<String, String> requestBody;
    if (_selectedTab == 1) { // Manager
      INITIAL_REGISTER_ENDPOINT=INITIAL_MANAGER_REGISTER_ENDPOINT;
      requestBody = {
        'email': _managerEmailController.text.trim(),
        'name': _managerNameController.text.trim(),
        'last_name': _managerLastNameController.text.trim(),
        'password': _managerPasswordController.text,
        'national_code': _managerNationalIdController.text.trim(),
        // 'hotel_name': _managerHotelNameController.text.trim(),
      };
    } else if (_selectedTab == 2) {// Guest
      INITIAL_REGISTER_ENDPOINT=INITIAL_GUEST_REGISTER_ENDPOINT;
      requestBody = {
        'email': _guestEmailController.text.trim(),
        'name': _guestNameController.text.trim(),
        'last_name': _guestLastNameController.text.trim(),
        'password': _guestPasswordController.text,
        'password2': _guestConfirmPasswordController.text,
        'role': 'Customer',
      };
    } else {
      if (mounted) setState(() => _isLoading = false);
      return false;
    }
    requestBody.removeWhere((key, value) => value.isEmpty && (key == 'hotel_name' || key == 'nationalID'));


    print('Sending initial registration data to $INITIAL_REGISTER_ENDPOINT: $requestBody');

    try {
      final response = await http.post(
        Uri.parse(INITIAL_REGISTER_ENDPOINT),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(requestBody),
      );

      if (!mounted) return false;
      print(response.statusCode);

      if (response.statusCode == 201 || response.statusCode == 200) { // 201 Created or 200 OK if user already exists but not verified
        print('Initial registration data submitted successfully: ${response.body}');
        // Backend should now send OTP automatically, or we request it.
        // For your flow, it seems we need to call the OTP request endpoint next.
        return true; // Indicate success to proceed to OTP step
      } else {
        String errorMessage = 'خطا در ارسال اطلاعات اولیه ثبت نام.';
        try {
          final errorData = jsonDecode(response.body);
          List<String> errorMessages = [];
          errorData.forEach((key, value) {
            if (value is List && value.isNotEmpty) {
              errorMessages.add('$key: ${value.join(", ")}');
            } else if (value is String) {
              errorMessages.add('$key: $value');
            }
          });
          if (errorMessages.isNotEmpty) {
            errorMessage = errorMessages.join('\n');
          } else if (errorData['detail'] != null) {
            errorMessage = errorData['detail'];
          }
        } catch (e) { /* Ignore decoding error */ }
        print('Initial registration failed: ${response.statusCode} - ${response.body}');
        _showSnackBar(errorMessage, isError: true);
        return false;
      }
    } catch (e) {
      print('Error during initial registration request: $e');
      if (mounted) _showSnackBar('خطا در برقراری ارتباط با سرور.', isError: true);
      return false;
    } finally {
      // _isLoading will be set to false by the calling function _handleContinueToOtp OR by _requestAndProceedToOtpScreen
    }
  }


  // --- API Call: Request/Resend OTP and Proceed to OTP Screen ---
  Future<void> _requestAndProceedToOtpScreen(String email, {bool isResend = false}) async {
    // 1. اعتبارسنجی ایمیل (بدون تغییر)
    if (email.isEmpty || !email.contains('@')) {
      _showSnackBar('ایمیل معتبری برای ارسال کد وجود ندارد.', isError: true);
      if (isResend && mounted) setState(() => _isLoadingResendOtp = false);
      else if (mounted) setState(() => _isLoading = false); // _isLoading مربوط به دکمه اصلی "ادامه"
      return;
    }

    if (isResend) {
      // --- این بلاک فقط برای ارسال مجدد کد اجرا می‌شود ---
      if (mounted) setState(() => _isLoadingResendOtp = true);
      print('Requesting OTP for: $email to $RESEND_OTP_ENDPOINT (isResend: $isResend)');

      try {
        final response = await http.post(
          Uri.parse(RESEND_OTP_ENDPOINT),
          headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode(<String, String>{'email': email}),
        );

        if (!mounted) return;

        if (response.statusCode == 200 || response.statusCode == 201) {
          print('OTP resend successful: ${response.body}');
          _showSnackBar('کد جدید ارسال شد.');
          // نیازی به تغییر صفحه نیست چون کاربر از قبل در صفحه OTP است
        } else {
          String errorMessage = 'خطا در ارسال کد تایید.';
          try {
            final errorData = jsonDecode(response.body);
            if (errorData['detail'] != null) {
              errorMessage = errorData['detail'];
            } else if (errorData['email'] != null && errorData['email'] is List) {
              errorMessage = "ایمیل: ${errorData['email'][0]}";
            }
          } catch (e) { /* Ignore decoding error */ }
          print('OTP resend failed: ${response.statusCode} - ${response.body}');
          _showSnackBar(errorMessage, isError: true);
        }
      } catch (e) {
        print('Error during OTP resend: $e');
        if (mounted) _showSnackBar('خطا در برقراری ارتباط برای ارسال کد.', isError: true);
      } finally {
        if (mounted) {
          setState(() => _isLoadingResendOtp = false);
        }
      }
    } else {
      // --- این بلاک برای اولین بار (ارسال اولیه کد) اجرا می‌شود ---
      // _isLoading از قبل توسط _handleContinueToOtp (تابع فراخواننده) true شده است.
      // در این حالت، هیچ درخواست HTTP به بک‌اند ارسال نمی‌کنیم.

      print('Simulating initial OTP request for: $email (isResend: $isResend) - NO BACKEND CALL');

      // شبیه‌سازی موفقیت و رفتن به صفحه OTP بدون تماس با بک‌اند
      if (!mounted) return;

      _showSnackBar('کد تایید به ایمیل شما ارسال شد.'); // پیام موفقیت برای ارسال اولیه
      setState(() {
        _otpTabLabel = (_selectedTab == 1) ? 'تایید ایمیل مدیر هتل' : 'تایید ایمیل مهمان';
        _otpSend = true; // این باعث انتقال به تب OTP می‌شود
        _clearOtpFields();
        _isLoading = false; // ریست کردن وضعیت لودینگ دکمه اصلی "ادامه"
      });
    }
  }

  // --- Action: "ادامه" button pressed (Validate, Submit Initial, Then Request OTP) ---
  Future<void> _handleContinueToOtp() async {
    if (_selectedTab != 1 && _selectedTab != 2) return;

    if (!_isChecked) {
      _showSnackBar('لطفا قوانین و مقررات را بپذیرید.', isError: true);
      return;
    }

    String emailForOtp;
    String password;
    String confirmPassword;
    bool formIsValid = true;

    if (_selectedTab == 1) { // Manager Signup
      emailForOtp = _managerEmailController.text.trim();
      password = _managerPasswordController.text;
      confirmPassword = _managerConfirmPasswordController.text;
      if (_managerNameController.text.isEmpty ||
          _managerLastNameController.text.isEmpty ||
          // nationalID and hotelName can be optional, handled by backend or removeWhere
          emailForOtp.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
        formIsValid = false;
      }
    } else { // Guest Signup
      emailForOtp = _guestEmailController.text.trim();
      password = _guestPasswordController.text;
      confirmPassword = _guestConfirmPasswordController.text;
      if (_guestNameController.text.isEmpty ||
          _guestLastNameController.text.isEmpty ||
          emailForOtp.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
        formIsValid = false;
      }
    }

    if (!formIsValid) {
      _showSnackBar('لطفا تمامی فیلدهای الزامی را پر کنید.', isError: true);
      return;
    }
    if (password != confirmPassword) {
      _showSnackBar('رمز عبور و تکرار آن یکسان نیستند.', isError: true);
      return;
    }
    if (emailForOtp.isEmpty || !emailForOtp.contains('@')) {
      _showSnackBar('لطفا ایمیل معتبری وارد کنید.', isError: true);
      return;
    }


    // Step 1: Submit initial registration data
    // _isLoading will be set to true inside _handleRequestSignupInitial
    bool initialSignupSuccess = await _handleRequestSignupInitial(emailForOtp);

    if (initialSignupSuccess && mounted) {
      // Step 2: If initial data submission was successful, request OTP and proceed to OTP screen
      // _isLoading is still true from _handleRequestSignupInitial, _requestAndProceedToOtpScreen will set it to false in its finally block
      await _requestAndProceedToOtpScreen(emailForOtp, isResend: false);
    } else if (mounted) {
      // If initial signup failed, _handleRequestSignupInitial already showed a snackbar.
      // We need to ensure _isLoading is reset if it was set.
      setState(() => _isLoading = false);
    }
  }


  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    final String email = _loginEmailController.text;
    final String password = _loginPasswordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('لطفا ایمیل و رمز عبور را وارد کنید.', isError: true);
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    // دریافت نمونه AuthService از Provider
    final authService = Provider.of<AuthService>(context, listen: false);

    bool loginSuccess = false;

    if (_isLoginAsManager) {
      loginSuccess = await authService.loginManager(email, password);
    } else {
      loginSuccess = await authService.loginGuest(email, password);
    }

    if (!mounted) return;
    print("loginSuccess$loginSuccess");
    if (loginSuccess && _isLoginAsManager) {
      _showSnackBar('ورود با موفقیت انجام شد.');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HotelListScreen()), // یا HomePage
      );
    } else if (loginSuccess && !_isLoginAsManager) {
      _showSnackBar('ورود با موفقیت انجام شد.');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HotelListScreen()), // یا HomePage
      );
    }else {
      _showSnackBar(authService.errorMessage ?? 'خطا در ورود. لطفا دوباره تلاش کنید.', isError: true);
    }

    setState(() => _isLoading = false);
  }

  // --- Action: Forgot Password ---
  void _handleForgotPassword() {
    print('Forgot password tapped');
    _showSnackBar('قابلیت بازیابی رمز عبور هنوز پیاده‌سازی نشده است.');
  }

  // --- Action: Signup Submit (Verify OTP) ---
  Future<void> _handleSignupSubmit() async {
    final String otpCode = _otp1Controller.text + _otp2Controller.text + _otp3Controller.text + _otp4Controller.text;

    if (otpCode.length != 4) {
      _showSnackBar('کد تایید باید ۴ رقم باشد.', isError: true);
      return;
    }

    setState(() => _isLoading = true); // Main button is loading

    String emailToVerify;
    if (_selectedTab == 1) { // Manager
      emailToVerify = _managerEmailController.text.trim();
    } else if (_selectedTab == 2) { // Guest
      emailToVerify = _guestEmailController.text.trim();
    } else {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    if (emailToVerify.isEmpty) {
      _showSnackBar('ایمیل برای تایید یافت نشد. لطفا از ابتدا تلاش کنید.', isError: true);
      if (mounted) setState(() => _isLoading = false);
      return;
    }


    final Map<String, String> requestBody = {
      'email': emailToVerify,
      'verification_code': otpCode,
    };
    print('Verifying OTP with $VERIFY_EMAIL_ENDPOINT: $requestBody');

    try {
      final response = await http.post(
        Uri.parse(VERIFY_EMAIL_ENDPOINT),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(requestBody),
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) { // Usually 200 for successful verification
        print('OTP Verification successful: ${response.body}');
        _showSnackBar('ایمیل شما با موفقیت تایید شد. لطفا وارد شوید.');
        _changeTab(0); // Go to login tab
      } else {
        String errorMessage = 'خطا در تایید کد.';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['detail'] != null) {
            errorMessage = errorData['detail'];
          } else if (errorData['verification_code'] != null && errorData['verification_code'] is List) {
            errorMessage = "کد تایید: ${errorData['verification_code'][0]}";
          } else if (errorData['non_field_errors'] != null && errorData['non_field_errors'] is List) {
            errorMessage = errorData['non_field_errors'][0];
          }
          // You can add more specific error handling here
        } catch (e) { /* Ignore decoding error */ }
        print('OTP Verification failed: ${response.statusCode} - ${response.body}');
        _showSnackBar(errorMessage, isError: true);
      }
    } catch (e) {
      print('Error during OTP verification request: $e');
      if (mounted) _showSnackBar('خطا در برقراری ارتباط با سرور برای تایید کد.', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- Action: Resend OTP ---
  Future<void> _handleResendOtp() async {
    String emailToResend;
    if (_selectedTab == 1) {
      emailToResend = _managerEmailController.text.trim();
    } else if (_selectedTab == 2) {
      emailToResend = _guestEmailController.text.trim();
    } else {
      return;
    }
    // _isLoadingResendOtp will be managed by _requestAndProceedToOtpScreen
    await _requestAndProceedToOtpScreen(emailToResend, isResend: true);
  }

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: pageBackgroundColor,
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(builder: (context, constraints) {
        return Stack(
          children: [
            _buildTopText(screenHeight),
            _buildBottomCurve(screenHeight, screenWidth),
            Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  left: screenWidth * 0.08,
                  right: screenWidth * 0.08,
                  top: 20,
                ),
                child: AuthCard(
                  selectedTab: _selectedTab,
                  isLoginAsManager: _isLoginAsManager,
                  otpSend: _otpSend,
                  otpTabLabel: _otpTabLabel,
                  isChecked: _isChecked,
                  isLoading: _isLoading,
                  isLoadingResendOtp: _isLoadingResendOtp,
                  loginUsernameController: _loginEmailController,
                  loginPasswordController: _loginPasswordController,
                  managerUsernameController: _managerEmailController,
                  managerNameController: _managerNameController,
                  managerLastNameController: _managerLastNameController,
                  managerNationalIdController: _managerNationalIdController,
                  managerHotelNameController: _managerHotelNameController,
                  managerPasswordController: _managerPasswordController,
                  managerConfirmPasswordController: _managerConfirmPasswordController,
                  guestNameController: _guestNameController,
                  guestLastNameController: _guestLastNameController,
                  guestEmailController: _guestEmailController,
                  guestPasswordController: _guestPasswordController,
                  guestConfirmPasswordController: _guestConfirmPasswordController,
                  otp1Controller: _otp1Controller,
                  otp2Controller: _otp2Controller,
                  otp3Controller: _otp3Controller,
                  otp4Controller: _otp4Controller,
                  onTabChanged: _changeTab,
                  onTermsChanged: _toggleTermsCheckbox,
                  onLoginUserTypeBoolChanged: (bool? newValue) {
                    if (newValue != null) {
                      setState(() => _isLoginAsManager = newValue);
                    }
                  },
                  onLoginPressed: _handleLogin,
                  onForgotPasswordPressed: _handleForgotPassword,
                  onContinuePressed: _handleContinueToOtp,
                  onSignupSubmitPressed: _handleSignupSubmit,
                  onResendOtpPressed: _handleResendOtp,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildTopText(double screenHeight) {
    return Positioned(
      top: screenHeight * 0.12,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Text.rich(
                TextSpan(
                  text: 'تا وقتی ',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: topTextColor),
                  children: [
                    const TextSpan(text: 'بوکیت ', style: TextStyle(fontWeight: FontWeight.w900)),
                    const TextSpan(text: 'هست'),
                  ],
                ),
                textDirection: TextDirection.rtl,
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.topLeft,
              child: const Text(
                'کجا بمونم سوال نیست!',
                textDirection: TextDirection.rtl,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: topTextColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomCurve(double screenHeight, double screenWidth) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: screenHeight * 0.5,
        width: screenWidth,
        decoration: BoxDecoration(
          color: getPrimaryColor(_selectedTab),
          borderRadius: const BorderRadius.vertical(top: Radius.elliptical(300, 70)),
        ),
      ),
    );
  }
}