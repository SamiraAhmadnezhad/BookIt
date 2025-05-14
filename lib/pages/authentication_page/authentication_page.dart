import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../home_page/home_page.dart';
import '../main_screen.dart';
import 'constants.dart'; // Import constants
import 'widgets/auth_card.dart'; // Import the AuthCard widget
// import 'otp_fields.dart'; // OtpFields is now used within OtpForm

class AuthenticationPage extends StatefulWidget {
  const AuthenticationPage({super.key});
  @override
  State<AuthenticationPage> createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  // --- State Variables ---
  int _selectedTab = 0; // 0: Login, 1: Manager Signup, 2: Guest Signup
  bool _isChecked = false; // For terms and conditions
  bool _otpSend = false; // Flag to show OTP fields
  String _otpTabLabel = ""; // Label for the OTP screen

  // --- Text Editing Controllers (Managed by the main page state) ---
  // Login
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  // Manager Signup
  final _managerUsernameController = TextEditingController();
  final _managerNameController = TextEditingController();
  final _managerLastNameController = TextEditingController();
  final _managerNationalIdController = TextEditingController();
  final _managerHotelNameController = TextEditingController();
  final _managerPasswordController = TextEditingController();
  final _managerConfirmPasswordController = TextEditingController();
  // Guest Signup
  final _guestUsernameController = TextEditingController();
  final _guestEmailController = TextEditingController();
  final _guestPasswordController = TextEditingController();
  final _guestConfirmPasswordController = TextEditingController();
  // OTP
  final _otp1Controller = TextEditingController();
  final _otp2Controller = TextEditingController();
  final _otp3Controller = TextEditingController();
  final _otp4Controller = TextEditingController();

  @override
  void dispose() {
    // Dispose all controllers
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _managerUsernameController.dispose();
    _managerNameController.dispose();
    _managerLastNameController.dispose();
    _managerNationalIdController.dispose();
    _managerHotelNameController.dispose();
    _managerPasswordController.dispose();
    _managerConfirmPasswordController.dispose();
    _guestUsernameController.dispose();
    _guestEmailController.dispose();
    _guestPasswordController.dispose();
    _guestConfirmPasswordController.dispose();
    _otp1Controller.dispose();
    _otp2Controller.dispose();
    _otp3Controller.dispose();
    _otp4Controller.dispose();
    super.dispose();
  }

  // --- Helper Methods for State Changes ---
  void _clearAllFields() {
    _loginEmailController.clear();
    _loginPasswordController.clear();
    _managerUsernameController.clear();
    _managerNameController.clear();
    _managerLastNameController.clear();
    _managerNationalIdController.clear();
    _managerHotelNameController.clear();
    _managerPasswordController.clear();
    _managerConfirmPasswordController.clear();
    _guestUsernameController.clear();
    _guestEmailController.clear();
    _guestPasswordController.clear();
    _guestConfirmPasswordController.clear();
    _otp1Controller.clear();
    _otp2Controller.clear();
    _otp3Controller.clear();
    _otp4Controller.clear();
  }

  bool _isLoginAsManager = false;

  void _changeTab(int index) {
    if (_selectedTab == index) return; // Avoid unnecessary rebuilds
    setState(() {
      _selectedTab = index;
      _isChecked = false;
      _otpSend = false; // Reset OTP state when changing main tabs
      _clearAllFields();
      if (_selectedTab == 0) {
        _isLoginAsManager = false; // ریست به مقدار پیش‌فرض هنگام رفتن به تب ورود
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

  void _proceedToOtp() {
    // Basic validation (add more as needed)
    if (_selectedTab == 1 || _selectedTab == 2) {
      if (!_isChecked) {
        // Show error: terms not accepted (use Snackbar or other feedback)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لطفا قوانین و مقررات را بپذیرید.', textDirection: TextDirection.rtl)),
        );
        print("Please accept terms and conditions");
        return;
      }
      // Add more specific field validation here if required before showing OTP
    }

    setState(() {
      if (_selectedTab == 1) {
        _otpTabLabel = 'ثبت‌نام مدیر هتل';
      } else if (_selectedTab == 2) {
        _otpTabLabel = 'ثبت‌نام مهمان';
      }
      _otpSend = true; // Show OTP form
      // Clear OTP fields before showing them
      _otp1Controller.clear();
      _otp2Controller.clear();
      _otp3Controller.clear();
      _otp4Controller.clear();
      // TODO: Call API to send OTP here
      print("Proceeding to OTP screen for tab: $_selectedTab");
    });
  }

  // --- Action Handlers (with TODOs) ---
  Future<void> _handleLogin() async {
    print('Logging in as manager: $_isLoginAsManager');
    print('Login button pressed');

    final String email = _loginEmailController.text.trim();
    final String password = _loginPasswordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لطفا ایمیل و رمز عبور را وارد کنید.', textDirection: TextDirection.rtl)),
      );
      return;
    }
    final String apiUrl;
    if (_isLoginAsManager) {
      apiUrl = 'https://bookit.darkube.app/auth/login/';
    } else {
      apiUrl = 'YOUR_DJANGO_GUEST_LOGIN_API_ENDPOINT';
    }
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );


      if (mounted) {
        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          print('Login successful: $responseData');

          // TODO: توکن را از responseData استخراج و ذخیره کنید

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        } else {
          String errorMessage = 'خطا در ورود. لطفا دوباره تلاش کنید.';
          if (response.body.isNotEmpty) {
            try {
              final errorData = jsonDecode(response.body);
              // مثلا: errorData['detail'] یا errorData['error'] یا errorData['message']
              if (errorData['detail'] != null) {
                errorMessage = errorData['detail'];
              } else if (errorData['non_field_errors'] != null && errorData['non_field_errors'] is List && errorData['non_field_errors'].isNotEmpty) {
                errorMessage = errorData['non_field_errors'][0];
              } else if (response.statusCode == 401 || response.statusCode == 400) {
                errorMessage = 'ایمیل یا رمز عبور نامعتبر است.';
              }
            } catch (e) {
              print('Error decoding error response: $e');
            }
          }
          print('Login failed: ${response.statusCode} - ${response.body}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage, textDirection: TextDirection.rtl)),
          );
        }
      }
    }catch (e) {
      // setState(() { _isLoading = false; }); // پنهان کردن Indicator
      print('Error during login request: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خطا در برقراری ارتباط با سرور.', textDirection: TextDirection.rtl)),
        );
      }
    }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
  }

  void _handleForgotPassword() {
    // TODO: Implement Forgot Password Logic
    print('Forgot password tapped');
    // Navigate to forgot password screen or show dialog
  }

  void _handleSignupSubmit() {
    final String otpCode = _otp1Controller.text + _otp2Controller.text + _otp3Controller.text + _otp4Controller.text;
    if (_selectedTab == 1) {
      // TODO: Implement Manager OTP Verification & Final Signup Logic
      print('Manager Signup Submit (OTP: $otpCode)');
      print('Manager Data: ${_managerUsernameController.text}, ${_managerNameController.text}, ...');
      // Validate OTP, call signup API with manager data, handle response, navigate
    } else if (_selectedTab == 2) {
      // TODO: Implement Guest OTP Verification & Final Signup Logic
      print('Guest Signup Submit (OTP: $otpCode)');
      print('Guest Data: ${_guestUsernameController.text}, ${_guestEmailController.text}, ...');
      // Validate OTP, call signup API with guest data, handle response, navigate
    }
  }

  void _handleResendOtp() {
    // TODO: Implement Resend OTP Logic
    print("Resend OTP tapped for tab: $_selectedTab");
    // Call API to resend OTP
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('کد جدید ارسال شد.', textDirection: TextDirection.rtl)),
    );
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
            // Top decorative text remains here
            _buildTopText(screenHeight),
            // Bottom curved background remains here
            _buildBottomCurve(screenHeight, screenWidth),
            // Centered authentication card - uses the new AuthCard widget
            Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  left: screenWidth * 0.1,
                  right: screenWidth * 0.1,
                  top: 20,
                ),
                child: AuthCard(
                  // Pass State
                  selectedTab: _selectedTab,
                  isLoginAsManager: _isLoginAsManager,
                  otpSend: _otpSend,
                  otpTabLabel: _otpTabLabel,
                  isChecked: _isChecked,
                  // Pass Controllers
                  loginUsernameController: _loginEmailController,
                  loginPasswordController: _loginPasswordController,
                  managerUsernameController: _managerUsernameController,
                  managerNameController: _managerNameController,
                  managerLastNameController: _managerLastNameController,
                  managerNationalIdController: _managerNationalIdController,
                  managerHotelNameController: _managerHotelNameController,
                  managerPasswordController: _managerPasswordController,
                  managerConfirmPasswordController: _managerConfirmPasswordController,
                  guestUsernameController: _guestUsernameController,
                  guestEmailController: _guestEmailController,
                  guestPasswordController: _guestPasswordController,
                  guestConfirmPasswordController: _guestConfirmPasswordController,
                  otp1Controller: _otp1Controller,
                  otp2Controller: _otp2Controller,
                  otp3Controller: _otp3Controller,
                  otp4Controller: _otp4Controller,
                  // Pass Callbacks (linking UI actions to state methods)
                  onTabChanged: _changeTab,
                  onTermsChanged: _toggleTermsCheckbox,
                  onLoginUserTypeBoolChanged: (bool? newValue) { // نام تابع را هم تغییر می‌دهیم
                    if (newValue != null) {
                      setState(() {
                        _isLoginAsManager = newValue;
                      });
                    }
                  },
                  onLoginPressed: _handleLogin,
                  onForgotPasswordPressed: _handleForgotPassword,
                  onContinuePressed: _proceedToOtp,
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

  // --- UI Building Methods for Page Structure ---
  // (Keep these in the main page state as they define the overall layout)

  Widget _buildTopText(double screenHeight) {
    return Positioned(
      top: screenHeight * 0.14,
      left: 60,
      right: 60,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Text.rich(
              TextSpan(
                text: 'تا وقتی ',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: topTextColor,
                ),
                children: [
                  const TextSpan(
                    text: 'بوکیت ',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: topTextColor,
                    ),
                  ),
                  const TextSpan(
                    text: 'هست',
                    style: TextStyle(
                      color: topTextColor,
                    ),
                  ),
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
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: topTextColor,
              ),
            ),
          ),
        ],
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
          color: getPrimaryColor(_selectedTab), // Use helper from constants
          borderRadius: const BorderRadius.vertical(
            top: Radius.elliptical(300, 70),
          ),
        ),
      ),
    );
  }
}