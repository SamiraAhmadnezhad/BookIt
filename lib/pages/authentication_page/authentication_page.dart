import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../manger_pages/hotel_info_page/screens/hotel_list_screen.dart';
import 'auth_service.dart';
import 'constants.dart';
import 'widgets/auth_card.dart';

const String BASE_URL = 'http://newbookit.darkube.app';
const String INITIAL_MANAGER_REGISTER_ENDPOINT='$BASE_URL/hotelManager-api/create/';
const String INITIAL_GUEST_REGISTER_ENDPOINT='$BASE_URL/auth/register/';
const String RESEND_OTP_ENDPOINT = '$BASE_URL/auth/resend-verification-code/';
const String VERIFY_EMAIL_ENDPOINT = '$BASE_URL/auth/verify-email/';

class AuthenticationPage extends StatefulWidget {
  const AuthenticationPage({super.key});
  @override
  State<AuthenticationPage> createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  int _selectedTab = 0;
  bool _isChecked = false;
  bool _otpSend = false;
  String _otpTabLabel = "";
  bool _isLoading = false;
  bool _isLoadingResendOtp = false;
  bool _isLoginAsManager = false;

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

  // Define a constant for max width
  static const double kMaxFormWidth = 400.0;

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

  Future<bool> _handleRequestSignupInitial(String emailForOtp) async {
    String INITIAL_REGISTER_ENDPOINT;
    setState(() => _isLoading = true);

    Map<String, String> requestBody;
    if (_selectedTab == 1) {
      INITIAL_REGISTER_ENDPOINT=INITIAL_MANAGER_REGISTER_ENDPOINT;
      requestBody = {
        'email': _managerEmailController.text.trim(),
        'name': _managerNameController.text.trim(),
        'last_name': _managerLastNameController.text.trim(),
        'password': _managerPasswordController.text,
        'national_code': _managerNationalIdController.text.trim(),
      };
    } else if (_selectedTab == 2) {
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

    try {
      final response = await http.post(
        Uri.parse(INITIAL_REGISTER_ENDPOINT),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(requestBody),
      );

      if (!mounted) return false;

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
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
        } catch (e) {
        }
        _showSnackBar(errorMessage, isError: true);
        return false;
      }
    } catch (e) {
      if (mounted) _showSnackBar('خطا در برقراری ارتباط با سرور.', isError: true);
      return false;
    }
  }

  Future<void> _requestAndProceedToOtpScreen(String email, {bool isResend = false}) async {
    if (email.isEmpty || !email.contains('@')) {
      _showSnackBar('ایمیل معتبری برای ارسال کد وجود ندارد.', isError: true);
      if (isResend && mounted) setState(() => _isLoadingResendOtp = false);
      else if (mounted) setState(() => _isLoading = false);
      return;
    }

    if (isResend) {
      if (mounted) setState(() => _isLoadingResendOtp = true);

      try {
        final response = await http.post(
          Uri.parse(RESEND_OTP_ENDPOINT),
          headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode(<String, String>{'email': email}),
        );

        if (!mounted) return;

        if (response.statusCode == 200 || response.statusCode == 201) {
          _showSnackBar('کد جدید ارسال شد.');
        } else {
          String errorMessage = 'خطا در ارسال کد تایید.';
          try {
            final errorData = jsonDecode(response.body);
            if (errorData['detail'] != null) {
              errorMessage = errorData['detail'];
            } else if (errorData['email'] != null && errorData['email'] is List) {
              errorMessage = "ایمیل: ${errorData['email'][0]}";
            }
          } catch (e) {
          }
          _showSnackBar(errorMessage, isError: true);
        }
      } catch (e) {
        if (mounted) _showSnackBar('خطا در برقراری ارتباط برای ارسال کد.', isError: true);
      } finally {
        if (mounted) {
          setState(() => _isLoadingResendOtp = false);
        }
      }
    } else {
      if (!mounted) return;
      _showSnackBar('کد تایید به ایمیل شما ارسال شد.');
      setState(() {
        _otpTabLabel = (_selectedTab == 1) ? 'تایید ایمیل مدیر هتل' : 'تایید ایمیل مهمان';
        _otpSend = true;
        _clearOtpFields();
        _isLoading = false;
      });
    }
  }

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

    if (_selectedTab == 1) {
      emailForOtp = _managerEmailController.text.trim();
      password = _managerPasswordController.text;
      confirmPassword = _managerConfirmPasswordController.text;
      if (_managerNameController.text.isEmpty ||
          _managerLastNameController.text.isEmpty ||
          emailForOtp.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
        formIsValid = false;
      }
    } else {
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

    bool initialSignupSuccess = await _handleRequestSignupInitial(emailForOtp);

    if (initialSignupSuccess && mounted) {
      await _requestAndProceedToOtpScreen(emailForOtp, isResend: false);
    } else if (mounted) {
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

    final authService = Provider.of<AuthService>(context, listen: false);

    bool loginSuccess = false;

    if (_isLoginAsManager) {
      loginSuccess = await authService.loginManager(email, password);
    } else {
      loginSuccess = await authService.loginGuest(email, password);
    }

    if (!mounted) return;

    if (loginSuccess) {
      _showSnackBar('ورود با موفقیت انجام شد.');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HotelListScreen()),
      );
    } else {
      _showSnackBar(authService.errorMessage ?? 'خطا در ورود. لطفا دوباره تلاش کنید.', isError: true);
    }

    setState(() => _isLoading = false);
  }

  void _handleForgotPassword() {
    _showSnackBar('قابلیت بازیابی رمز عبور هنوز پیاده‌سازی نشده است.');
  }

  Future<void> _handleSignupSubmit() async {
    final String otpCode = _otp1Controller.text + _otp2Controller.text + _otp3Controller.text + _otp4Controller.text;

    if (otpCode.length != 4) {
      _showSnackBar('کد تایید باید ۴ رقم باشد.', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    String emailToVerify;
    if (_selectedTab == 1) {
      emailToVerify = _managerEmailController.text.trim();
    } else if (_selectedTab == 2) {
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

    try {
      final response = await http.post(
        Uri.parse(VERIFY_EMAIL_ENDPOINT),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(requestBody),
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnackBar('ایمیل شما با موفقیت تایید شد. لطفا وارد شوید.');
        _changeTab(0);
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
        } catch (e) {
        }
        _showSnackBar(errorMessage, isError: true);
      }
    } catch (e) {
      if (mounted) _showSnackBar('خطا در برقراری ارتباط با سرور برای تایید کد.', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleResendOtp() async {
    String emailToResend;
    if (_selectedTab == 1) {
      emailToResend = _managerEmailController.text.trim();
    } else if (_selectedTab == 2) {
      emailToResend = _guestEmailController.text.trim();
    } else {
      return;
    }
    await _requestAndProceedToOtpScreen(emailToResend, isResend: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackgroundColor,
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(builder: (context, constraints) {
        return Stack(
          fit: StackFit.expand,
          children: [
            _buildBottomCurve(constraints.maxHeight, constraints.maxWidth),

            Align(
              alignment: const Alignment(0.0, 0.3),
              child: SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: kMaxFormWidth,
                    ),
                    child: Padding(
                      // Use a fixed padding instead of percentage
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
                ),
              ),
            ),

            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: _buildTopText(),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildTopText() {
    return Container(
      // This container will be centered horizontally because of Align(alignment: Alignment.topCenter)
      padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 60.0),
      // NEW: Wrap the content in a ConstrainedBox
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: kMaxFormWidth,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
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
        height: screenHeight * 0.50,
        width: screenWidth,
        decoration: BoxDecoration(
          color: getPrimaryColor(_selectedTab),
          borderRadius: const BorderRadius.vertical(top: Radius.elliptical(300, 70)),
        ),
      ),
    );
  }
}