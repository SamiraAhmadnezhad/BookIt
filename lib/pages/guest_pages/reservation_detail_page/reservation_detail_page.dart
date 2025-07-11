import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:intl/date_symbol_data_local.dart' as intl_local;
import 'package:provider/provider.dart';

import 'package:bookit/pages/guest_pages/hotel_detail_page/utils/constants.dart';
import '../../../features/auth/data/services/auth_service.dart';
import 'reservation_api_service.dart';

enum PaymentMethod { online, atHotel }

class ReservationDetailPage extends StatefulWidget {
  final String hotelId;
  final String hotelName;
  final String hotelAddress;
  final double hotelRating;
  final String hotelImageUrl;
  final String roomNumber;
  final String roomID;
  final String roomInfo;
  final int numberOfAdults;
  final double totalPrice;
  final DateTime checkInDate;
  final DateTime checkOutDate;

  const ReservationDetailPage({
    Key? key,
    required this.hotelId,
    required this.hotelName,
    required this.hotelAddress,
    required this.hotelRating,
    required this.hotelImageUrl,
    required this.roomNumber,
    required this.roomID,
    required this.roomInfo,
    required this.numberOfAdults,
    required this.totalPrice,
    required this.checkInDate,
    required this.checkOutDate,
  }) : super(key: key);

  @override
  _ReservationDetailPageState createState() => _ReservationDetailPageState();
}

class _ReservationDetailPageState extends State<ReservationDetailPage> {
  final ReservationApiService _apiService = ReservationApiService();
  late final String? _token;
  final _formKey = GlobalKey<FormState>();
  late List<Map<String, TextEditingController>> _guestFormControllers;
  bool _termsAndConditionsAccepted = false;
  PaymentMethod _paymentMethod = PaymentMethod.online;
  late double _amountToPay;
  Timer? _timer;
  final int _reservationTimeLimitMinutes = 10;
  late int _remainingSeconds;
  bool _isTimerActive = true;

  @override
  void initState() {
    super.initState();
    _token = Provider.of<AuthService>(context, listen: false).token;
    _amountToPay = widget.totalPrice / 2;
    _remainingSeconds = _reservationTimeLimitMinutes * 60;
    _guestFormControllers = List.generate(
      widget.numberOfAdults > 0 ? widget.numberOfAdults : 1,
          (index) => {
        'firstName': TextEditingController(),
        'lastName': TextEditingController(),
        'nationalCode': TextEditingController(),
        'gender': TextEditingController(text: 'آقا'),
      },
    );
    intl_local.initializeDateFormatting('fa_IR', null);
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        if (_isTimerActive) {
          _isTimerActive = false;
          _showSnackBar('زمان شما برای تکمیل رزرو به پایان رسید.', isError: true);
          _handleCancellation(popPage: true);
        }
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controllersMap in _guestFormControllers) {
      controllersMap.forEach((key, controller) => controller.dispose());
    }
    super.dispose();
  }

  Future<void> _handleCancellation({bool popPage = false}) async {
    if (_token != null) {
      await _apiService.unlockRoom(roomID: [widget.roomID], token: _token!);
    }
    if (mounted && popPage) {
      Navigator.of(context).pop();
    }
  }

  Future<bool> _onWillPop() async {
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('لغو رزرو'),
        content: const Text('آیا از لغو رزرو و بازگشت به صفحه‌ی قبل اطمینان دارید؟ اتاق از حالت قفل خارج خواهد شد.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('ادامه رزرو')),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('بله، لغو کن', style: TextStyle(color: Colors.red.shade700))),
        ],
      ),
    );
    if (shouldPop ?? false) {
      await _handleCancellation(popPage: true);
    }
    return false;
  }

  void _updatePaymentMethod(PaymentMethod? value) {
    if (value == null) return;
    setState(() {
      _paymentMethod = value;
      _amountToPay = (_paymentMethod == PaymentMethod.online) ? (widget.totalPrice / 2) : widget.totalPrice;
    });
  }

  Future<void> _handleBookingSubmission() async {
    if (!_isTimerActive) {
      _showSnackBar('زمان شما برای تکمیل رزرو به پایان رسیده است.', isError: true);
      return;
    }
    if (!_termsAndConditionsAccepted) {
      _showSnackBar('لطفاً قوانین و مقررات را مطالعه و تأیید نمایید.', isError: true);
      return;
    }
    if (!_formKey.currentState!.validate()) {
      _showSnackBar('لطفاً اطلاعات تمام مسافران را به درستی وارد کنید.', isError: true);
      return;
    }

    _timer?.cancel();
    showDialog(
        context: context, barrierDismissible: false, builder: (BuildContext dialogContext) => const _LoadingDialog());

    final Map<String, dynamic> reservationPayload = {
      'room_id': int.tryParse(widget.roomID) ?? 0,
      'check_in_date': intl.DateFormat('yyyy-MM-dd').format(widget.checkInDate),
      'check_out_date': intl.DateFormat('yyyy-MM-dd').format(widget.checkOutDate),
      'amount': _amountToPay,
      'method': _paymentMethod == PaymentMethod.online ? 'online' : 'cash',
    };

    bool submissionSuccess = false;
    try {
      submissionSuccess = await _apiService.createReservation(reservationData: reservationPayload, token: _token!);
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _showSnackBar('خطا در ارتباط با سرور: $e', isError: true);
      _startTimer();
      return;
    }

    if (mounted) Navigator.pop(context);

    if (submissionSuccess) {
      await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('موفقیت'),
            content: const Text('رزرو شما با موفقیت ثبت شد.'),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('باشه')),
            ],
          ));
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      _showSnackBar('خطا در ثبت رزرو. لطفاً مجدداً تلاش فرمایید.', isError: true);
      _startTimer();
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating));
  }

  String _formatTimer(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: kPageBackground,
          body: CustomScrollView(
            slivers: [
              _buildSliverAppBar(Theme.of(context)),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildHotelInfoCard(Theme.of(context)),
                    const SizedBox(height: 16),
                    _buildReservationDetailsCard(Theme.of(context)),
                    const SizedBox(height: 16),
                    _buildTravelerFormsSection(Theme.of(context)),
                    const SizedBox(height: 16),
                    _buildPaymentCard(Theme.of(context)),
                  ]),
                ),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomBar(Theme.of(context)),
        ),
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      stretch: true,
      backgroundColor: kPrimaryColor,
      foregroundColor: Colors.white,
      leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: _onWillPop),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(widget.hotelImageUrl, fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image, color: Colors.grey)),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54],
                ),
              ),
            ),
            if (_isTimerActive || _remainingSeconds == 0)
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 4, offset: const Offset(0, 2))
                        ]),
                    child: Text(
                      _isTimerActive && _remainingSeconds > 0
                          ? 'زمان باقی مانده: ${_formatTimer(_remainingSeconds)}'
                          : 'زمان به پایان رسید',
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: kLightTextColor, fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                  ),
                ),
              ),
          ],
        ),
        stretchModes: const [StretchMode.zoomBackground],
      ),
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Card(
      elevation: 2,
      shadowColor: Colors.grey.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }

  Widget _buildHotelInfoCard(ThemeData theme) {
    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.hotelName,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on_outlined, color: kPrimaryColor, size: 16),
              const SizedBox(width: 6),
              Expanded(
                  child: Text(widget.hotelAddress,
                      style: theme.textTheme.bodyMedium?.copyWith(color: kLightTextColor, fontSize: 13))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < widget.hotelRating.floor()
                    ? Icons.star_rounded
                    : index < widget.hotelRating
                    ? Icons.star_half_rounded
                    : Icons.star_border_rounded,
                color: Colors.amber,
                size: 18,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationDetailsCard(ThemeData theme) {
    final intl.DateFormat longPersianDateFormat = intl.DateFormat('EEEE، d MMMM', 'fa_IR');
    final int numberOfNights = widget.checkOutDate.difference(widget.checkInDate).inDays;

    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('اطلاعات رزرو', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const Divider(height: 24),
          _buildDetailRow(
              theme, Icons.calendar_today_outlined, 'تاریخ ورود', longPersianDateFormat.format(widget.checkInDate)),
          _buildDetailRow(
              theme, Icons.calendar_today, 'تاریخ خروج', longPersianDateFormat.format(widget.checkOutDate)),
          _buildDetailRow(theme, Icons.king_bed_outlined, 'اتاق', '${widget.roomInfo} ($numberOfNights شب)'),
          _buildDetailRow(theme, Icons.people_alt_outlined, 'تعداد مسافران', '${widget.numberOfAdults} بزرگسال'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(ThemeData theme, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: kAccentColor, size: 18),
          const SizedBox(width: 10),
          Text('$label:', style: theme.textTheme.bodyMedium?.copyWith(color: kLightTextColor)),
          const SizedBox(width: 6),
          Expanded(
              child: Text(value,
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: Colors.black87),
                  textAlign: TextAlign.end)),
        ],
      ),
    );
  }

  Widget _buildTravelerFormsSection(ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0, bottom: 12),
            child:
            Text('اطلاعات مسافران', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _guestFormControllers.length,
            itemBuilder: (context, index) {
              return _buildGuestFormCard(theme,
                  guestNumber: index + 1, isSupervisor: index == 0, controllers: _guestFormControllers[index]);
            },
            separatorBuilder: (context, index) => const SizedBox(height: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestFormCard(ThemeData theme,
      {required int guestNumber, required bool isSupervisor, required Map<String, TextEditingController> controllers}) {
    String title = 'مسافر ${guestNumber == 1 ? "اول" : intl.NumberFormat("#,##0", "fa_IR").format(guestNumber)}';
    if (isSupervisor) title += ' (سرپرست)';

    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleSmall?.copyWith(color: kAccentColor, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildStyledTextFormField(
              labelText: 'نام',
              controller: controllers['firstName']!,
              validator: (val) => (val == null || val.trim().isEmpty) ? 'نام الزامی است' : null),
          const SizedBox(height: 12),
          _buildStyledTextFormField(
              labelText: 'نام خانوادگی',
              controller: controllers['lastName']!,
              validator: (val) => (val == null || val.trim().isEmpty) ? 'نام خانوادگی الزامی است' : null),
          const SizedBox(height: 12),
          _buildStyledTextFormField(
              labelText: 'کد ملی',
              controller: controllers['nationalCode']!,
              keyboardType: TextInputType.number,
              validator: (val) {
                if (val == null || val.trim().isEmpty) return 'کد ملی الزامی است';
                if (val.trim().length != 10 || !RegExp(r'^[0-9]{10}$').hasMatch(val.trim())) {
                  return 'کد ملی باید ۱۰ رقم باشد';
                }
                return null;
              }),
          const SizedBox(height: 12),
          _buildGenderDropdown(controllers['gender']!),
        ],
      ),
    );
  }

  Widget _buildStyledTextFormField(
      {required String labelText,
        required TextEditingController controller,
        TextInputType keyboardType = TextInputType.text,
        String? Function(String?)? validator}) {
    return TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 15, color: Colors.black87),
        textAlign: TextAlign.right,
        decoration: InputDecoration(
            labelText: '$labelText *',
            labelStyle: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide.none),
            enabledBorder:
            OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0), borderSide: const BorderSide(color: kPrimaryColor, width: 1.5)),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0), borderSide: const BorderSide(color: Colors.redAccent, width: 1.2)),
            focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(color: Colors.redAccent, width: 1.8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filled: true,
            fillColor: kPageBackground),
        validator: validator);
  }

  Widget _buildGenderDropdown(TextEditingController controller) {
    List<String> genders = ['آقا', 'خانم'];
    if (controller.text.isEmpty) controller.text = genders.first;
    return DropdownButtonFormField<String>(
      value: controller.text,
      decoration: InputDecoration(
          labelText: 'جنسیت *',
          labelStyle: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0), borderSide: const BorderSide(color: kPrimaryColor, width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          filled: true,
          fillColor: kPageBackground),
      items: genders
          .map((String value) => DropdownMenuItem<String>(value: value, child: Text(value, style: const TextStyle(fontSize: 15))))
          .toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() => controller.text = newValue);
        }
      },
      validator: (value) => (value == null || value.isEmpty) ? 'انتخاب جنسیت الزامی است' : null,
    );
  }

  Widget _buildPaymentCard(ThemeData theme) {
    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('روش پرداخت', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const Divider(height: 24),
          _buildPaymentMethodSelector(),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                      value: _termsAndConditionsAccepted,
                      onChanged: (bool? value) => setState(() => _termsAndConditionsAccepted = value ?? false),
                      activeColor: kPrimaryColor,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      side: BorderSide(color: Colors.grey.shade400, width: 1.5))),
              const SizedBox(width: 8),
              Expanded(
                  child: InkWell(
                      onTap: () => setState(() => _termsAndConditionsAccepted = !_termsAndConditionsAccepted),
                      child: Text('قوانین و مقررات رزرو هتل را مطالعه کرده و می‌پذیرم.',
                          style: theme.textTheme.bodySmall?.copyWith(color: kLightTextColor, fontSize: 12)))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Column(
      children: [
        RadioListTile<PaymentMethod>(
            title: const Text('پرداخت حضوری (پیش‌پرداخت ۵۰٪ از مبلغ به صورت آنلاین)', style: TextStyle(fontSize: 14)),
            value: PaymentMethod.online,
            groupValue: _paymentMethod,
            onChanged: _updatePaymentMethod,
            activeColor: kPrimaryColor,
            contentPadding: EdgeInsets.zero),
        RadioListTile<PaymentMethod>(
            title: const Text('پرداخت آنلاین', style: TextStyle(fontSize: 14)),
            value: PaymentMethod.atHotel,
            groupValue: _paymentMethod,
            onChanged: _updatePaymentMethod,
            activeColor: kPrimaryColor,
            contentPadding: EdgeInsets.zero),
      ],
    );
  }

  Widget _buildBottomBar(ThemeData theme) {
    final intl.NumberFormat currencyFormatter = intl.NumberFormat("#,##0", "fa_IR");
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, -5))]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_paymentMethod == PaymentMethod.online ? 'مبلغ پیش‌پرداخت:' : 'مبلغ قابل پرداخت:',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, fontSize: 15)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(currencyFormatter.format(_amountToPay),
                      style: theme.textTheme.titleLarge
                          ?.copyWith(color: kPrimaryColor, fontWeight: FontWeight.bold, fontSize: 20)),
                  Text('تومان', style: theme.textTheme.bodySmall?.copyWith(color: kLighterTextColor, fontSize: 11)),
                ],
              ),
            ],
          ),
          if (_paymentMethod == PaymentMethod.online)
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 8),
              child: Text("مابقی (${currencyFormatter.format(widget.totalPrice / 2)} تومان) در هتل تسویه خواهد شد.",
                  style: theme.textTheme.bodySmall?.copyWith(color: kAccentColor, fontSize: 12)),
            ),
          SizedBox(height: _paymentMethod == PaymentMethod.atHotel ? 12 : 0),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isTimerActive ? _handleBookingSubmission : null,
              style: ElevatedButton.styleFrom(
                  backgroundColor: _isTimerActive ? kPrimaryColor : kDisabledColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                  textStyle: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
              child: Text(_isTimerActive ? 'تایید و پرداخت' : 'زمان به پایان رسید',
                  style: const TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingDialog extends StatelessWidget {
  const _LoadingDialog();
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: kPrimaryColor),
            const SizedBox(width: 20),
            Text("در حال ثبت رزرو...", style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}