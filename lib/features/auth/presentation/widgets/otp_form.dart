import 'package:bookit/features/auth/presentation/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class OtpForm extends StatefulWidget {
  final String email;
  final Function(String otp) onSubmit;
  final VoidCallback onResend;
  final bool isLoading;
  final bool isResending;

  const OtpForm({
    super.key,
    required this.email,
    required this.onSubmit,
    required this.onResend,
    required this.isLoading,
    required this.isResending,
  });

  @override
  State<OtpForm> createState() => _OtpFormState();
}

class _OtpFormState extends State<OtpForm> {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 4; i++) {
      _controllers[i].addListener(() {
        if (_controllers[i].text.length == 1 && i < 3) {
          _focusNodes[i + 1].requestFocus();
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _submit() {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length == 4) {
      widget.onSubmit(otp);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('کد باید ۴ رقم باشد'), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 50,
      height: 50,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        maxLength: 1,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 24),
        Text('تایید ایمیل', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          'کد ۴ رقمی ارسال شده به ${widget.email} را وارد کنید.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 32),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(4, (index) => _buildOtpBox(index)),
          ),
        ),
        const Spacer(),
        CustomButton(text: 'تایید و ثبت نام', onPressed: _submit, isLoading: widget.isLoading),
        const SizedBox(height: 16),
        widget.isResending
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator())
            : TextButton(
          onPressed: widget.onResend,
          child: Text('ارسال مجدد کد', style: TextStyle(color: theme.colorScheme.primary)),
        ),
      ],
    );
  }
}