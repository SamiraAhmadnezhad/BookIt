import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:intl/date_symbol_data_local.dart' as intl_local;
import 'package:provider/provider.dart';

import 'package:bookit/pages/guest_pages/hotel_detail_page/utils/constants.dart';
import '../../authentication_page/auth_service.dart';
import 'reservation_api_service.dart';

enum PaymentMethod { online, atHotel }

class ReservationDetailPage extends StatefulWidget {
  final String hotelId;
  final String hotelName;
  final String hotelAddress;
  final double hotelRating;
  final String hotelImageUrl;
  final String roomNumber;
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
      await _apiService.unlockRoom(roomNumbers: [widget.roomNumber], token: _token!);
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
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text('بله، لغو کن', style: TextStyle(color: Colors.red.shade700))),
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

    showDialog(context: context, barrierDismissible: false, builder: (BuildContext dialogContext) => const _LoadingDialog());

    final Map<String, dynamic> reservationPayload = {
      'room_number': int.tryParse(widget.roomNumber) ?? 0,
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
          )
      );
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      _showSnackBar('خطا در ثبت رزرو. لطفاً مجدداً تلاش فرمایید.', isError: true);
      _startTimer();
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message, style: const TextStyle(color: Colors.white)), backgroundColor: isError ? Colors.redAccent : Colors.green, behavior: SnackBarBehavior.floating));
  }

  String _formatTimer(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth / 375.0;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: CustomScrollView(
            slivers: [
              _buildSliverAppBar(Theme.of(context), screenWidth, scaleFactor),
              SliverToBoxAdapter(child: _buildBodyContent(Theme.of(context), scaleFactor)),
            ],
          ),
        ),
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(ThemeData theme, double screenWidth, double scaleFactor) {
    return SliverAppBar(
      expandedHeight: screenWidth * 0.58,
      pinned: true,
      stretch: true,
      backgroundColor: kPrimaryColor,
      leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: _onWillPop),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(widget.hotelImageUrl, fit: BoxFit.cover),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black45],
                ),
              ),
            ),
            if (_isTimerActive || _remainingSeconds == 0)
              Positioned(
                bottom: 16 * scaleFactor,
                left: 16 * scaleFactor,
                right: 16 * scaleFactor,
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12 * scaleFactor, vertical: 6 * scaleFactor),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 4, offset: const Offset(0, 2))]),
                    child: Text(
                      _isTimerActive && _remainingSeconds > 0 ? 'زمان باقی مانده: ${_formatTimer(_remainingSeconds)}' : 'زمان به پایان رسید',
                      style: theme.textTheme.bodySmall?.copyWith(color: kLightTextColor, fontWeight: FontWeight.w600, fontSize: (12 * scaleFactor).clamp(10, 15)),
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

  Widget _buildBodyContent(ThemeData theme, double scaleFactor) {
    final intl.DateFormat longPersianDateFormat = intl.DateFormat('EEEE، d MMMM yyyy', 'fa_IR');
    final int numberOfNights = widget.checkOutDate.difference(widget.checkInDate).inDays;

    return Container(
      transform: Matrix4.translationValues(0.0, -20.0, 0.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      child: Padding(
        padding: EdgeInsets.all(16 * scaleFactor),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHotelInfoSection(theme, scaleFactor),
            SizedBox(height: 24 * scaleFactor),
            _buildStarRating(scaleFactor, widget.hotelRating),
            SizedBox(height: 24 * scaleFactor),
            _buildReservationDetailsSection(theme, scaleFactor, longPersianDateFormat.format(widget.checkInDate), longPersianDateFormat.format(widget.checkOutDate), widget.roomInfo, widget.numberOfAdults, numberOfNights),
            SizedBox(height: 24 * scaleFactor),
            _buildRulesSection(theme, scaleFactor),
            SizedBox(height: 24 * scaleFactor),
            _buildTravelerFormsSection(theme, scaleFactor),
            SizedBox(height: 24 * scaleFactor),
            _buildTermsAndPaymentSection(theme, scaleFactor),
          ],
        ),
      ),
    );
  }

  Widget _buildHotelInfoSection(ThemeData theme, double scaleFactor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.hotelName, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: (22 * scaleFactor).clamp(18, 28))),
        SizedBox(height: 12 * scaleFactor),
        Row(
          children: [
            Icon(Icons.location_on_outlined, color: kPrimaryColor, size: 20 * scaleFactor),
            SizedBox(width: 8 * scaleFactor),
            Expanded(child: Text(widget.hotelAddress, style: theme.textTheme.bodyMedium?.copyWith(color: kLightTextColor, fontSize: (14 * scaleFactor).clamp(12, 17)))),
          ],
        ),
        SizedBox(height: 12 * scaleFactor),
        Row(
          children: [
            Icon(Icons.thumb_up_alt_outlined, color: kPrimaryColor, size: 20 * scaleFactor),
            SizedBox(width: 8 * scaleFactor),
            Text(widget.hotelRating.toStringAsFixed(1), style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: (14 * scaleFactor).clamp(12, 17))),
          ],
        ),
      ],
    );
  }

  Widget _buildStarRating(double scaleFactor, double rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating.floor() ? Icons.star_rounded :
          index < rating ? Icons.star_half_rounded : Icons.star_border_rounded,
          color: kPrimaryColor,
          size: 20 * scaleFactor,
        );
      }),
    );
  }

  Widget _buildRulesSection(ThemeData theme, double scaleFactor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('اطلاعات مسافران', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: kPrimaryColor, fontSize: (16 * scaleFactor).clamp(14, 20))),
        SizedBox(height: 12 * scaleFactor),
        _buildRuleItem(theme, scaleFactor, 'کاربر گرامی، لطفا در هنگام وارد کردن اطلاعات به نکات زیر توجه داشته باشید:'),
        Padding(
          padding: EdgeInsets.only(right: 16 * scaleFactor),
          child: Column(
            children: [
              _buildRuleItem(theme, scaleFactor, 'لطفا از صحت اطلاعات وارد شده (شماره موبایل و ایمیل) خود اطمینان حاصل فرمائید تا در مواقع ضروری با شما تماس گرفته شود. در صورت عدم صحت اطلاعات وارد شده عواقب ناشی از آن متوجه مشتری است.'),
              _buildRuleItem(theme, scaleFactor, 'بعد از رزرواسیون امکان تغییر نام مسافرین وجود ندارد.'),
              _buildRuleItem(theme, scaleFactor, 'در صورت رزرو اتاق برای اتباع غیرایرانی، مطابق با قوانین هتل ممکن است در زمان ورود ما به التفاوت به هتل پرداخت نمایید.'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRuleItem(ThemeData theme, double scaleFactor, String text) {
    return Padding(
      padding: EdgeInsets.only(top: 8 * scaleFactor),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if(text.startsWith('لطفا') || text.startsWith('در') || text.startsWith('بعد'))
            Padding(padding: EdgeInsets.only(top: 6 * scaleFactor, left: 8 * scaleFactor), child: Icon(Icons.circle, size: 6 * scaleFactor, color: kLightTextColor)),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium?.copyWith(color: kLightTextColor, height: 1.6, fontSize: (13 * scaleFactor).clamp(11, 16)))),
        ],
      ),
    );
  }

  Widget _buildReservationDetailsSection(ThemeData theme, double scaleFactor, String checkInDateString, String checkOutDateString, String roomInfo, int adults, int nights) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('اطلاعات رزرو', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: kPrimaryColor, fontSize: (16 * scaleFactor).clamp(14, 20))),
        SizedBox(height: 12 * scaleFactor),
        _buildDetailRow(theme, scaleFactor, Icons.calendar_today_outlined, checkInDateString, ''),
        _buildDetailRow(theme, scaleFactor, Icons.calendar_today, checkOutDateString, ''),
        _buildDetailRow(theme, scaleFactor, Icons.king_bed_outlined, '$roomInfo به مدت $nights شب', ''),
        _buildDetailRow(theme, scaleFactor, Icons.people_alt_outlined, '$adults بزرگسال', ''),
      ],
    );
  }

  Widget _buildDetailRow(ThemeData theme, double scaleFactor, IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5 * scaleFactor),
      child: Row(
        children: [
          Icon(icon, color: kAccentColor, size: 18 * scaleFactor),
          SizedBox(width: 10 * scaleFactor),
          Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: kLightTextColor, fontSize: (14 * scaleFactor).clamp(12, 17))),
          SizedBox(width: 6 * scaleFactor),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: Colors.black87, fontSize: (14 * scaleFactor).clamp(12, 17)), textAlign: TextAlign.left)),
        ],
      ),
    );
  }

  Widget _buildTravelerFormsSection(ThemeData theme, double scaleFactor) {
    return Form(
      key: _formKey,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _guestFormControllers.length,
        itemBuilder: (context, index) {
          return _buildGuestFormCard(theme, scaleFactor, guestNumber: index + 1, isSupervisor: index == 0, controllers: _guestFormControllers[index]);
        },
        separatorBuilder: (context, index) => SizedBox(height: 16 * scaleFactor),
      ),
    );
  }

  Widget _buildGuestFormCard(ThemeData theme, double scaleFactor, {required int guestNumber, required bool isSupervisor, required Map<String, TextEditingController> controllers}) {
    String title = 'مسافر ${guestNumber == 1 ? "اول" : intl.NumberFormat("#,##0", "fa_IR").format(guestNumber)}';
    if (isSupervisor) title += ' (سرپرست)';
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: kPageBackground,
      child: Padding(
        padding: EdgeInsets.all(16 * scaleFactor),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleSmall?.copyWith(color: kAccentColor, fontWeight: FontWeight.bold, fontSize: (14 * scaleFactor).clamp(12, 17))),
            SizedBox(height: 16 * scaleFactor),
            _buildStyledTextFormField(scaleFactor, labelText: 'نام', controller: controllers['firstName']!, validator: (val) => (val == null || val.trim().isEmpty) ? 'نام الزامی است' : null),
            SizedBox(height: 12 * scaleFactor),
            _buildStyledTextFormField(scaleFactor, labelText: 'نام خانوادگی', controller: controllers['lastName']!, validator: (val) => (val == null || val.trim().isEmpty) ? 'نام خانوادگی الزامی است' : null),
            SizedBox(height: 12 * scaleFactor),
            _buildStyledTextFormField(scaleFactor, labelText: 'کد ملی', controller: controllers['nationalCode']!, keyboardType: TextInputType.number, validator: (val) { if (val == null || val.trim().isEmpty) return 'کد ملی الزامی است'; if (val.trim().length != 10 || !RegExp(r'^[0-9]{10}$').hasMatch(val.trim())) return 'کد ملی باید ۱۰ رقم باشد'; return null; }),
            SizedBox(height: 12 * scaleFactor),
            _buildGenderDropdown(scaleFactor, controllers['gender']!),
          ],
        ),
      ),
    );
  }

  Widget _buildStyledTextFormField(double scaleFactor, {required String labelText, required TextEditingController controller, TextInputType keyboardType = TextInputType.text, String? Function(String?)? validator}) {
    return TextFormField(controller: controller, keyboardType: keyboardType, style: TextStyle(fontSize: (15 * scaleFactor).clamp(13, 18), color: Colors.black87), textAlign: TextAlign.right, decoration: InputDecoration(labelText: '$labelText *', labelStyle: TextStyle(fontSize: (14 * scaleFactor).clamp(12, 17), color: kPrimaryColor.withOpacity(0.8)), hintStyle: TextStyle(fontSize: (14 * scaleFactor).clamp(12, 17), color: Colors.grey.shade500), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide(color: Colors.grey.shade300)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide(color: Colors.grey.shade300)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: const BorderSide(color: kPrimaryColor, width: 1.5)), errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: const BorderSide(color: Colors.redAccent, width: 1.2)), focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: const BorderSide(color: Colors.redAccent, width: 1.8)), contentPadding: EdgeInsets.symmetric(horizontal: 16 * scaleFactor, vertical: 12 * scaleFactor), filled: true, fillColor: kPageBackground.withOpacity(0.7)), validator: validator);
  }

  Widget _buildGenderDropdown(double scaleFactor, TextEditingController controller) {
    List<String> genders = ['آقا', 'خانم'];
    if (controller.text.isEmpty) controller.text = genders.first;
    return DropdownButtonFormField<String>(
      value: controller.text,
      decoration: InputDecoration(labelText: 'جنسیت *', labelStyle: TextStyle(fontSize: (14 * scaleFactor).clamp(12, 17), color: kPrimaryColor.withOpacity(0.8)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide(color: Colors.grey.shade300)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide(color: Colors.grey.shade300)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: const BorderSide(color: kPrimaryColor, width: 1.5)), contentPadding: EdgeInsets.symmetric(horizontal: 16 * scaleFactor, vertical: 12 * scaleFactor), filled: true, fillColor: kPageBackground.withOpacity(0.7)),
      items: genders.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value, style: TextStyle(fontSize: (15 * scaleFactor).clamp(13, 18))))).toList(),
      onChanged: (String? newValue) { if (newValue != null) { setState(() => controller.text = newValue); } },
      validator: (value) => (value == null || value.isEmpty) ? 'انتخاب جنسیت الزامی است' : null,
    );
  }

  Widget _buildTermsAndPaymentSection(ThemeData theme, double scaleFactor) {
    final intl.NumberFormat currencyFormatter = intl.NumberFormat("#,##0", "fa_IR");
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16 * scaleFactor),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPaymentMethodSelector(theme, scaleFactor),
          SizedBox(height: 16 * scaleFactor),
          Row(
            children: [
              SizedBox(width: 24 * scaleFactor, height: 24 * scaleFactor, child: Checkbox(value: _termsAndConditionsAccepted, onChanged: (bool? value) => setState(() => _termsAndConditionsAccepted = value ?? false), activeColor: kPrimaryColor, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, side: BorderSide(color: Colors.grey.shade400, width: 1.5))),
              SizedBox(width: 8 * scaleFactor),
              Expanded(child: InkWell(onTap: () => setState(() => _termsAndConditionsAccepted = !_termsAndConditionsAccepted), child: Text('قوانین و مقررات رزرو هتل را مطالعه کرده و می‌پذیرم.', style: theme.textTheme.bodySmall?.copyWith(color: kLightTextColor, fontSize: (12 * scaleFactor).clamp(10, 15))))),
            ],
          ),
          SizedBox(height: 16 * scaleFactor),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_paymentMethod == PaymentMethod.online ? 'مبلغ پیش‌پرداخت:' : 'مبلغ قابل پرداخت در محل:', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, fontSize: (15 * scaleFactor).clamp(13, 18))),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(currencyFormatter.format(_amountToPay), style: theme.textTheme.titleLarge?.copyWith(color: kPrimaryColor, fontWeight: FontWeight.bold, fontSize: (20 * scaleFactor).clamp(17, 25))),
                  Text('تومان', style: theme.textTheme.bodySmall?.copyWith(color: kLighterTextColor, fontSize: (11 * scaleFactor).clamp(9, 14))),
                ],
              ),
            ],
          ),
          if (_paymentMethod == PaymentMethod.online) Padding(padding: EdgeInsets.only(top: 4 * scaleFactor), child: Text("مابقی (${currencyFormatter.format(widget.totalPrice / 2)} تومان) در هتل تسویه خواهد شد.", style: theme.textTheme.bodySmall?.copyWith(color: kAccentColor, fontSize: (12 * scaleFactor).clamp(10, 15)))),
          SizedBox(height: 16 * scaleFactor),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isTimerActive ? _handleBookingSubmission : null,
              style: ElevatedButton.styleFrom(backgroundColor: _isTimerActive ? kPrimaryColor : kDisabledColor, padding: EdgeInsets.symmetric(vertical: 14 * scaleFactor), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)), textStyle: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white, fontSize: (16 * scaleFactor).clamp(14, 20))),
              child: Text(_isTimerActive ? 'تایید و پرداخت' : 'زمان به پایان رسید', style: const TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSelector(ThemeData theme, double scaleFactor) {
    return Card(
      elevation: 0,
      color: kPageBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          RadioListTile<PaymentMethod>(
              title: Text('پرداخت آنلاین (پیش‌پرداخت ۵۰٪)', style: TextStyle(fontSize: (14 * scaleFactor).clamp(12, 17))),
              value: PaymentMethod.online, groupValue: _paymentMethod, onChanged: _updatePaymentMethod, activeColor: kPrimaryColor),
          RadioListTile<PaymentMethod>(
              title: Text('پرداخت در محل (حضوری)', style: TextStyle(fontSize: (14 * scaleFactor).clamp(12, 17))),
              value: PaymentMethod.atHotel, groupValue: _paymentMethod, onChanged: _updatePaymentMethod, activeColor: kPrimaryColor),
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
            CircularProgressIndicator(color: kPrimaryColor),
            const SizedBox(width: 20),
            Text("در حال ثبت رزرو...", style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}