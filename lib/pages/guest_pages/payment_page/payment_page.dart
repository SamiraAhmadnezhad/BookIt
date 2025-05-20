import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const Color appPurpleColor = Color(0xFF542545);

void main() {
  runApp(const HotelPaymentApp());
}

class HotelPaymentApp extends StatelessWidget {
  const HotelPaymentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'درگاه پرداخت',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        fontFamily: 'Vazirmatn',
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: appPurpleColor, width: 1.5),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const PaymentScreen(),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
    );
  }
}

// بقیه کد (PaymentScreen و ویجت‌های داخلی آن) بدون تغییر باقی می‌ماند
// ... (کدی که قبلاً ارائه شد برای PaymentScreen, _PaymentHeader, _CreditCardVisual, etc.)

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TextEditingController _expiryMonthController = TextEditingController();
  final TextEditingController _expiryYearController = TextEditingController();
  final TextEditingController _cvv2Controller = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final String _cardNumber = "6037 - 9974 - 5673 - 9790";
  // TODO: Replace this with the actual image URL fetched from your server
  final String _cardImageUrl = "https://placehold.co/600x375/000000/FFFFFF/png?text=Bank+Card&font=sans-serif";


  @override
  void dispose() {
    _expiryMonthController.dispose();
    _expiryYearController.dispose();
    _cvv2Controller.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    // TODO: Implement payment processing logic here
    // This function will be called when the "پرداخت" button is pressed.
    // It should validate the inputs and then make an API call to the server.
    print("Payment button pressed");
    print("Card Number: $_cardNumber");
    print("Expiry Month: ${_expiryMonthController.text}");
    print("Expiry Year: ${_expiryYearController.text}");
    print("CVV2: ${_cvv2Controller.text}");
    print("Password: ${_passwordController.text}");
  }

  void _cancelPayment() {
    // TODO: Implement cancellation logic here
    // This function will be called when the "لغو" button is pressed.
    // Typically, it would navigate back or clear the form.
    print("Cancel button pressed");
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Container(
                margin: const EdgeInsets.all(20.0),
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _PaymentHeader(),
                    const SizedBox(height: 24.0),
                    _CreditCardVisual(imageUrl: _cardImageUrl),
                    const SizedBox(height: 24.0),
                    _LabeledStaticText(
                        label: "شماره کارت", text: _cardNumber),
                    const SizedBox(height: 20.0),
                    _ExpiryAndCvv2Input(
                      monthController: _expiryMonthController,
                      yearController: _expiryYearController,
                      cvv2Controller: _cvv2Controller,
                    ),
                    const SizedBox(height: 20.0),
                    _PasswordInput(controller: _passwordController),
                    const SizedBox(height: 32.0),
                    _ActionButtons(
                      onPay: _processPayment,
                      onCancel: _cancelPayment,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PaymentHeader extends StatelessWidget {
  const _PaymentHeader();

  @override
  Widget build(BuildContext context) {
    return const Text(
      "درگاه پرداخت",
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 22.0,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }
}

class _CreditCardVisual extends StatelessWidget {
  final String imageUrl;
  const _CreditCardVisual({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: Image.network(
        imageUrl,
        fit: BoxFit.contain,
        height: 180,
        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
                color: appPurpleColor,
              ),
            ),
          );
        },
        errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
          return Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: Colors.grey[700]!),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 40),
                  SizedBox(height: 8),
                  Text(
                    "خطا در بارگیری تصویر کارت",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LabeledStaticText extends StatelessWidget {
  final String label;
  final String text;

  const _LabeledStaticText({required this.label, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8.0),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Align(
            alignment: Alignment.center,
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 18.0,
                letterSpacing: 1.5,
                fontFamily: 'monospace',
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ExpiryAndCvv2Input extends StatelessWidget {
  final TextEditingController monthController;
  final TextEditingController yearController;
  final TextEditingController cvv2Controller;

  const _ExpiryAndCvv2Input({
    required this.monthController,
    required this.yearController,
    required this.cvv2Controller,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "تاریخ انقضا",
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: monthController,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
                      ],
                      decoration: const InputDecoration(hintText: "ماه"),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text("/", style: TextStyle(fontSize: 20.0)),
                  ),
                  Expanded(
                    child: TextField(
                      controller: yearController,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
                      ],
                      decoration: const InputDecoration(hintText: "سال"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 16.0),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "CVV2",
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8.0),
              TextField(
                controller: cvv2Controller,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                decoration: const InputDecoration(hintText: "---"),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PasswordInput extends StatelessWidget {
  final TextEditingController controller;
  const _PasswordInput({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "رمز عبور (رمز دوم پویا)",
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8.0),
        TextField(
          controller: controller,
          obscureText: true,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(hintText: "••••••"),
        ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final VoidCallback onPay;
  final VoidCallback onCancel;

  const _ActionButtons({required this.onPay, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: onCancel,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              textStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: const Text("لغو"),
          ),
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: ElevatedButton(
            onPressed: onPay,
            style: ElevatedButton.styleFrom(
              backgroundColor: appPurpleColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              textStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: const Text("پرداخت"),
          ),
        ),
      ],
    );
  }
}