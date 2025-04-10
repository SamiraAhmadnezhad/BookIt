import 'package:bookit/pages/authentication_page/otp_fields.dart';
import 'package:flutter/material.dart';

class AuthenticationPage extends StatefulWidget {
  const AuthenticationPage({super.key});
  @override
  State<AuthenticationPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<AuthenticationPage> {
  bool isObscured = true;
  int selectedTab = 0;
  bool isChecked = false;
  bool otpSend = false;
  String otpTabLabel = "";

  final TextEditingController loginUsernameController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();

  final TextEditingController managerUsernameController = TextEditingController();
  final TextEditingController managerNameController = TextEditingController();
  final TextEditingController managerLastNameController = TextEditingController();
  final TextEditingController managerNationalIdController = TextEditingController();
  final TextEditingController managerHotelNameController = TextEditingController();
  final TextEditingController managerPasswordController = TextEditingController();
  final TextEditingController managerConfirmPasswordController = TextEditingController();

  final TextEditingController guestUsernameController = TextEditingController();
  final TextEditingController guestEmailController = TextEditingController();
  final TextEditingController guestPasswordController = TextEditingController();
  final TextEditingController guestConfirmPasswordController = TextEditingController();

  final TextEditingController otp1Controller = TextEditingController();
  final TextEditingController otp2Controller = TextEditingController();
  final TextEditingController otp3Controller = TextEditingController();
  final TextEditingController otp4Controller = TextEditingController();

  Color getPrimaryColor() {
    return (selectedTab == 0) ? const Color(0xFF542545) : const Color(0xFFCECECE);
  }

  Color getSecondaryColor() {
    return (selectedTab == 0) ? const Color(0xFFCECECE) : const Color(0xFF542545);
  }

  Color getPrimaryTextColor() {
    return (selectedTab == 0) ? Colors.black : Colors.white;
  }

  Color getSecondaryTextColor() {
    return (selectedTab == 0) ? Colors.white : Colors.black;
  }

  void _clearAllFields() {
    loginUsernameController.clear();
    loginPasswordController.clear();
    managerUsernameController.clear();
    managerNameController.clear();
    managerLastNameController.clear();
    managerNationalIdController.clear();
    managerHotelNameController.clear();
    managerPasswordController.clear();
    managerConfirmPasswordController.clear();
    guestUsernameController.clear();
    guestEmailController.clear();
    guestPasswordController.clear();
    guestConfirmPasswordController.clear();
    otp1Controller.clear();
    otp2Controller.clear();
    otp3Controller.clear();
    otp4Controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(builder: (context, constraints) {
        return Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 60),
                child: Column(
                  children: [
                    SizedBox(height: screenHeight * 0.14),
                    Align(
                      alignment: Alignment.topRight,
                      child: Text.rich(
                        TextSpan(
                          text: 'تا وقتی ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: getPrimaryTextColor(),
                          ),
                          children: [
                            TextSpan(
                              text: 'بوکیت ',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: getPrimaryTextColor(),
                              ),
                            ),
                            TextSpan(
                              text: 'هست',
                              style: TextStyle(
                                color: getPrimaryTextColor(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'کجا بمونم سوال نیست!',
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: getPrimaryTextColor(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: screenHeight * 0.5,
                width: screenWidth,
                decoration: BoxDecoration(
                  color: getPrimaryColor(),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.elliptical(300, 70),
                  ),
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                  decoration: BoxDecoration(
                    color: getSecondaryColor(),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Row(
                            children: [
                              _buildTabButton('ورود', 0),
                              _buildTabButton('ثبت‌نام مدیر هتل', 1),
                              _buildTabButton('ثبت‌نام مهمان', 2),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildFormFieldsForSelectedTab(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Expanded _buildTabButton(String text, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = index;
            isChecked = false;
            otpSend = false;
            _clearAllFields();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selectedTab == index ? getSecondaryColor() : Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: selectedTab == 0 ? Colors.black : (selectedTab == index ? getPrimaryTextColor() : getSecondaryTextColor()),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormFieldsForSelectedTab() {
    List<Widget> fields = [];
    String buttonText = '';
    switch (selectedTab) {
      case 0:
        buttonText = 'ورود';
        fields = [
          _buildTextField('نام کاربری', loginUsernameController),
          const SizedBox(height: 12),
          _buildPasswordField('رمز عبور', loginPasswordController),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'رمز عبورت رو فراموش کردی؟',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: getPrimaryTextColor()),
            ),
          ),
        ];
        break;
      case 1:
        if (otpSend) {
          buttonText = 'ثبت نام';
          fields = [
            Align(
              alignment: Alignment.center,
              child: Text(
                otpTabLabel,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: getPrimaryTextColor()),
              ),
            ),
            const SizedBox(height: 20),
            OtpFields(
              otp1Controller: otp1Controller,
              otp2Controller: otp2Controller,
              otp3Controller: otp3Controller,
              otp4Controller: otp4Controller,
            ),
            const SizedBox(height: 20),
          ];
        } else {
          buttonText = 'ادامه';
          fields = [
            _buildTextField('نام کاربری', managerUsernameController),
            const SizedBox(height: 12),
            _buildTextField('نام', managerNameController),
            const SizedBox(height: 12),
            _buildTextField('نام خانوادگی', managerLastNameController),
            const SizedBox(height: 12),
            _buildTextField('کد ملی', managerNationalIdController),
            const SizedBox(height: 12),
            _buildTextField('نام هتل', managerHotelNameController),
            const SizedBox(height: 12),
            _buildPasswordField('رمز عبور', managerPasswordController),
            const SizedBox(height: 12),
            _buildPasswordField('تکرار رمزعبور', managerConfirmPasswordController),
            const SizedBox(height: 20),
            _buildTermsAndConditions(),
          ];
        }
        break;
      case 2:
        if (otpSend) {
          buttonText = 'ثبت نام';
          fields = [
            Align(
              alignment: Alignment.center,
              child: Text(
                otpTabLabel,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: getPrimaryTextColor()),
              ),
            ),
            const SizedBox(height: 20),
            OtpFields(
              otp1Controller: otp1Controller,
              otp2Controller: otp2Controller,
              otp3Controller: otp3Controller,
              otp4Controller: otp4Controller,
            ),
            const SizedBox(height: 20),
          ];
        } else {
          buttonText = 'ادامه';
          fields = [
            _buildTextField('نام کاربری', guestUsernameController),
            const SizedBox(height: 12),
            _buildTextField('ایمیل', guestEmailController),
            const SizedBox(height: 12),
            _buildPasswordField('رمز عبور', guestPasswordController),
            const SizedBox(height: 12),
            _buildPasswordField('تکرار رمزعبور', guestConfirmPasswordController),
            const SizedBox(height: 20),
            _buildTermsAndConditions(),
          ];
        }
        break;
      case 4:
        buttonText = 'ثبت نام';
        fields = [
          Align(
            alignment: Alignment.center,
            child: Text(
              otpTabLabel,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: getPrimaryTextColor()),
            ),
          ),
          const SizedBox(height: 20),
          OtpFields(
            otp1Controller: otp1Controller,
            otp2Controller: otp2Controller,
            otp3Controller: otp3Controller,
            otp4Controller: otp4Controller,
          ),
          const SizedBox(height: 20),
        ];
        break;
      default:
        buttonText = 'ادامه';
    }
    fields.add(const SizedBox(height: 20));
    fields.add(
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: getPrimaryColor(),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(45)),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onPressed: () {
            if (buttonText == 'ادامه') {
              setState(() {
                if (selectedTab == 1) {
                  otpTabLabel = 'ثبت‌نام مدیر هتل';
                } else if (selectedTab == 2) {
                  otpTabLabel = 'ثبت‌نام مهمان';
                }
                otpSend = true;
              });
            }
          },
          child: Text(
            buttonText,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: getSecondaryTextColor()),
          ),
        ),
      ),
    );
    return Column(children: fields);
  }

  Widget _buildTermsAndConditions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          'قوانین و مقررات اپلیکیشن را می‌پذیرم.',
          textDirection: TextDirection.rtl,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: getPrimaryTextColor()),
        ),
        Checkbox(
          value: isChecked,
          onChanged: (value) {
            setState(() {
              isChecked = value!;
            });
          },
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          activeColor: Colors.white,
          checkColor: const Color(0xFF542545),
          fillColor: MaterialStateProperty.resolveWith<Color>((states) => Colors.white),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            label,
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: getPrimaryTextColor()),
          ),
        ),
        SizedBox(
          height: 40,
          child: TextField(
            controller: controller,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            label,
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: getPrimaryTextColor()),
          ),
        ),
        SizedBox(
          height: 40,
          child: TextField(
            controller: controller,
            obscureText: isObscured,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              prefixIcon: IconButton(
                icon: Icon(isObscured ? Icons.visibility_off : Icons.visibility, color: Colors.black),
                onPressed: () {
                  setState(() {
                    isObscured = !isObscured;
                  });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
