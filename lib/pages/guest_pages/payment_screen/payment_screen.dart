import 'dart:math';
import 'package:bookit/features/auth/data/services/auth_service.dart';
import 'package:bookit/features/guest/presentation/pages/guest_main_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:provider/provider.dart';
import '../reservation_detail_page/reservation_api_service.dart';

class PaymentScreen extends StatefulWidget {
  final double amount;
  final Map<String, dynamic> reservationPayload;

  const PaymentScreen({
    super.key,
    required this.amount,
    required this.reservationPayload,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final ReservationApiService _apiService = ReservationApiService();
  bool _isLoading = false;
  bool _showBackView = false;
  late final FocusNode _cvvFocusNode;

  @override
  void initState() {
    super.initState();
    _cvvFocusNode = FocusNode();
    _cvvFocusNode.addListener(() {
      setState(() {
        _showBackView = _cvvFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _cvvFocusNode.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final authService = context.read<AuthService>();
    final token = authService.token;

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('خطا: شما وارد حساب کاربری خود نشده‌اید.')),
      );
      setState(() => _isLoading = false);
      return;
    }

    try {
      final success = await _apiService.createReservation(
          reservationData: widget.reservationPayload, token: token);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('پرداخت و رزرو با موفقیت انجام شد!'),
              backgroundColor: Colors.green),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const GuestMainWrapper()),
              (Route<dynamic> route) => false,
        );
      } else {
        _showErrorSnackBar('خطا در ثبت نهایی رزرو. لطفاً دوباره تلاش کنید.');
      }
    } catch (e) {
      _showErrorSnackBar('خطا در ارتباط با سرور: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('درگاه پرداخت امن')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              children: [
                _buildCreditCard(),
                const SizedBox(height: 24),
                _buildPaymentForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreditCard() {
    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateY(_showBackView ? pi : 0),
      alignment: Alignment.center,
      child: _showBackView ? _buildCardBack() : _buildCardFront(),
    );
  }

  Widget _buildCardFront() {
    return AspectRatio(
      aspectRatio: 1.586,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Theme.of(context).colorScheme.primary,
        child: const Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CREDIT CARD',
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
              Spacer(),
              Text(
                '**** **** **** ****',
                style: TextStyle(
                    color: Colors.white, fontSize: 24, letterSpacing: 4),
              ),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('CARD HOLDER',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Text('EXPIRES',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Your Name',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  Text('MM/YY',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardBack() {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(pi),
      child: AspectRatio(
        aspectRatio: 1.586,
        child: Card(
          elevation: 8,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Theme.of(context).colorScheme.primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Container(
                height: 40,
                color: Colors.black,
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('CVV',
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Container(
                      alignment: Alignment.centerRight,
                      width: double.infinity,
                      height: 40,
                      color: Colors.white,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          '***',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontStyle: FontStyle.italic,
                              letterSpacing: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            decoration: const InputDecoration(
                labelText: 'شماره کارت', hintText: '**** **** **** ****'),
            keyboardType: TextInputType.number,
            inputFormatters: [
              CreditCardNumberInputFormatter(
                onCardSystemSelected: (cardSystem) {},
              )
            ],
            validator: (v) =>
            (v == null || v.isEmpty) ? 'شماره کارت الزامی است' : null,
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(labelText: 'تاریخ انقضا (YY/MM)'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    MaskedInputFormatter('##/##'),
                  ],
                  validator: (v) =>
                  (v == null || v.isEmpty) ? 'تاریخ الزامی است' : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  focusNode: _cvvFocusNode,
                  decoration: const InputDecoration(labelText: 'CVV2'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  validator: (v) =>
                  (v == null || v.isEmpty) ? 'CVV2 الزامی است' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(labelText: 'رمز دوم (پویا)'),
            keyboardType: TextInputType.number,
            obscureText: true,
            validator: (v) =>
            (v == null || v.isEmpty) ? 'رمز دوم الزامی است' : null,
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: _isLoading ? null : _processPayment,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isLoading
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(color: Colors.white),
            )
                : Text(
                'پرداخت ${widget.amount.toStringAsFixed(0)} تومان'),
          )
        ],
      ),
    );
  }
}