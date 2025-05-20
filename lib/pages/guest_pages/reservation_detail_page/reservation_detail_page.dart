import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:intl/date_symbol_data_local.dart' as intl_local;

const Color kPrimaryColor = Color(0xFF542545);
const Color kAccentColor = Color(0xFF7E3F6B);
const Color kPageBackground = Color(0xFFF4F6F8);
const Color kCardBackground = Colors.white;
const Color kLightTextColor = Color(0xFF606060);
const Color kLighterTextColor = Color(0xFF888888);
const Color kDisabledColor = Color(0xFFBDBDBD);

class BookingApiService {
  Future<Map<String, dynamic>> fetchBookingPreviewDetails(
      String hotelId, int numberOfAdults) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    return {
      'hotelName': 'هتل زیبای ساحلی شمال',
      'hotelAddress': 'مازندران، چالوس، کیلومتر ۵ جاده نمک آبرود',
      'hotelRating': 4.7,
      'hotelStarRatingVisual': 5,
      'hotelImageUrl':
      'https://images.unsplash.com/photo-1561501900-3701fa6a0864?w=800&h=400&fit=crop',
      'checkInDate': "2024-08-10T00:00:00.000Z",
      'checkOutDate': "2024-08-13T00:00:00.000Z",
      'roomInfo': '۱ اتاق دونفره',
      'numberOfNights': 3,
      'numberOfAdults': numberOfAdults,
      'totalPrice': 4850000,
      'reservationTimeLimitMinutes': 10,
    };
  }

  Future<bool> submitHotelBooking(Map<String, dynamic> bookingData) async {
    await Future.delayed(const Duration(seconds: 2));
    return true;
  }
}

class ReservationDetailPage extends StatefulWidget {
  final String hotelId;
  final int numberOfAdults;

  const ReservationDetailPage(
      {Key? key, required this.hotelId, required this.numberOfAdults})
      : super(key: key);

  @override
  _ReservationDetailPageState createState() => _ReservationDetailPageState();
}

class _ReservationDetailPageState extends State<ReservationDetailPage> {
  final BookingApiService _apiService = BookingApiService();
  Map<String, dynamic>? _bookingPageData;
  bool _isLoading = true;
  bool _isIntlInitialized = false;
  String? _errorMessage;

  late List<Map<String, TextEditingController>> _guestFormControllers;
  final _formKey = GlobalKey<FormState>();
  bool _termsAndConditionsAccepted = false;

  Timer? _timer;
  late int _initialTimerSeconds;
  late int _remainingSeconds;
  bool _isTimerActive = false;

  @override
  void initState() {
    super.initState();
    _guestFormControllers = List.generate(
      widget.numberOfAdults > 0 ? widget.numberOfAdults : 1,
          (index) => {
        'firstName': TextEditingController(),
        'lastName': TextEditingController(),
        'nationalCode': TextEditingController(),
        'gender': TextEditingController(),
      },
    );
    _initializeDependencies();
  }

  Future<void> _initializeDependencies() async {
    try {
      await intl_local.initializeDateFormatting('fa_IR', null);
      if (mounted) {
        setState(() => _isIntlInitialized = true);
        _loadBookingPageData();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "خطا در آماده‌سازی: $e";
          _isLoading = false;
          _isIntlInitialized = true;
        });
      }
    }
  }

  Future<void> _loadBookingPageData() async {
    if (!mounted || !_isIntlInitialized) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final data = await _apiService.fetchBookingPreviewDetails(
          widget.hotelId, widget.numberOfAdults);
      if (mounted) {
        setState(() {
          _bookingPageData = data;
          _initialTimerSeconds = (_bookingPageData!['reservationTimeLimitMinutes'] as int? ?? 10) * 60;
          _remainingSeconds = _initialTimerSeconds;
          _isLoading = false;
          _startTimer();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'خطا در بارگذاری اطلاعات: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    if (_remainingSeconds <= 0) {
      setState(() => _isTimerActive = false);
      return;
    }
    setState(() => _isTimerActive = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _isTimerActive = false;
          timer.cancel();
          if (mounted) {
            _showSnackBar('زمان شما برای تکمیل رزرو به پایان رسید.', isError: true);
          }
        }
      });
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

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatTimer(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    final minutes =
    duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds =
    duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
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

    List<Map<String, String>> guestDetailsList = [];
    for (var controllersMap in _guestFormControllers) {
      guestDetailsList.add({
        'firstName': controllersMap['firstName']!.text.trim(),
        'lastName': controllersMap['lastName']!.text.trim(),
        'nationalCode': controllersMap['nationalCode']!.text.trim(),
        'gender': controllersMap['gender']!.text.trim(),
      });
    }

    Map<String, dynamic> bookingPayload = {
      'hotelId': widget.hotelId,
      'hotelName': _bookingPageData?['hotelName'],
      'guests': guestDetailsList,
      'totalPrice': _bookingPageData?['totalPrice'],
      'checkInDate': _bookingPageData?['checkInDate'],
      'checkOutDate': _bookingPageData?['checkOutDate'],
    };

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) => const _LoadingDialog(),
      );
    }

    try {
      bool submissionSuccess = await _apiService.submitHotelBooking(bookingPayload);
      if (mounted) Navigator.pop(context);

      if (submissionSuccess) {
        _timer?.cancel();
        setState(() => _isTimerActive = false);
        _showSnackBar('رزرو شما با موفقیت ثبت شد!', isError: false);
      } else {
        _showSnackBar('خطا در ثبت رزرو. لطفاً مجدداً تلاش فرمایید.', isError: true);
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _showSnackBar('خطا در ارتباط با سرور: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: kPageBackground,
        appBar: _buildAppBar(theme),
        body: _buildBody(theme),
        bottomNavigationBar: _isLoading || _errorMessage != null || _bookingPageData == null
            ? null
            : _buildTermsAndPaymentSection(theme),
      ),
    );
  }

  AppBar _buildAppBar(ThemeData theme) {
    return AppBar(
      title: Text(
        _isLoading || _bookingPageData == null
            ? 'بارگذاری اطلاعات...'
            : _bookingPageData!['hotelName'] ?? 'تکمیل اطلاعات رزرو',
        style: theme.appBarTheme.titleTextStyle?.copyWith(color: kPrimaryColor, fontWeight: FontWeight.bold) ??
            const TextStyle(color: kPrimaryColor, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      backgroundColor: kCardBackground,
      elevation: 1,
      iconTheme: const IconThemeData(color: kPrimaryColor),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (!_isIntlInitialized && _errorMessage == null) {
      return _buildLoadingState("در حال آماده سازی...");
    }
    if (_isLoading && _bookingPageData == null) {
      return _buildLoadingState("در حال بارگذاری اطلاعات رزرو...");
    }
    if (_errorMessage != null) {
      return _buildErrorState(_errorMessage!);
    }
    if (_bookingPageData == null) {
      return _buildErrorState('اطلاعات مورد نیاز یافت نشد.');
    }

    final intl.DateFormat longPersianDateFormat =
    intl.DateFormat('EEEE، d MMMM yyyy', 'fa_IR');
    final DateTime checkInDate = intl.DateFormat("yyyy-MM-ddTHH:mm:ss.SSS'Z'")
        .parse(_bookingPageData!['checkInDate'], true)
        .toLocal();
    final DateTime checkOutDate = intl.DateFormat("yyyy-MM-ddTHH:mm:ss.SSS'Z'")
        .parse(_bookingPageData!['checkOutDate'], true)
        .toLocal();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHotelImageSection(theme, _bookingPageData!['hotelImageUrl']),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHotelInfoSection(
                  theme,
                  _bookingPageData!['hotelName'],
                  _bookingPageData!['hotelAddress'],
                  _bookingPageData!['hotelRating'],
                  _bookingPageData!['hotelStarRatingVisual'],
                ),
                const SizedBox(height: 24),
                _buildReservationDetailsSection(
                  theme,
                  longPersianDateFormat.format(checkInDate),
                  longPersianDateFormat.format(checkOutDate),
                  _bookingPageData!['roomInfo'],
                  _bookingPageData!['numberOfAdults'],
                  _bookingPageData!['numberOfNights'],
                ),
                const SizedBox(height: 24),
                _buildTravelerFormsSection(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: kPrimaryColor),
          const SizedBox(height: 20),
          Text(message, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, color: kPrimaryColor, size: 60),
            const SizedBox(height: 16),
            Text(message, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('تلاش مجدد'),
              onPressed: _isIntlInitialized ? _loadBookingPageData : _initializeDependencies,
              style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor, foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHotelImageSection(ThemeData theme, String imageUrl) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey[300],
              child: Center(
                  child: Icon(Icons.broken_image_outlined,
                      size: 60, color: Colors.grey[500])),
            ),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.grey[200],
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                        : null,
                    color: kPrimaryColor,
                    strokeWidth: 2.5,
                  ),
                ),
              );
            },
          ),
        ),
        if (_isTimerActive || _remainingSeconds == 0)
          Container(
            margin: const EdgeInsets.all(12.0),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: (_isTimerActive && _remainingSeconds > 0)
                  ? kCardBackground.withOpacity(0.9)
                  : kPrimaryColor.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Text(
              _isTimerActive && _remainingSeconds > 0
                  ? 'زمان باقی‌مانده: ${_formatTimer(_remainingSeconds)}'
                  : 'زمان به پایان رسید',
              style: theme.textTheme.bodySmall?.copyWith(
                color: (_isTimerActive && _remainingSeconds > 0)
                    ? kLightTextColor
                    : Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHotelInfoSection(ThemeData theme, String name, String address,
      double rating, int starRatingVisual) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.location_on_outlined, color: kLightTextColor, size: 18),
            const SizedBox(width: 6),
            Expanded(
                child: Text(address,
                    style: theme.textTheme.bodyMedium?.copyWith(color: kLightTextColor),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.star_rounded, color: Colors.amber, size: 20),
            const SizedBox(width: 4),
            Text(
              rating.toStringAsFixed(1),
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: Colors.black87, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 4),
            Text("(${_bookingPageData!['hotelStarRatingVisual']} ستاره)", style: theme.textTheme.bodySmall?.copyWith(color: kLighterTextColor)),
          ],
        ),
      ],
    );
  }

  Widget _buildReservationDetailsSection(ThemeData theme, String checkInDateString,
      String checkOutDateString, String roomInfo, int adults, int nights) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: kCardBackground,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('جزئیات رزرو',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold, color: kPrimaryColor)),
            const SizedBox(height: 12),
            _buildDetailRow(Icons.calendar_month_outlined, 'تاریخ ورود:', checkInDateString),
            _buildDetailRow(Icons.calendar_month, 'تاریخ خروج:', checkOutDateString),
            _buildDetailRow(Icons.king_bed_outlined, 'نوع اتاق:', roomInfo),
            _buildDetailRow(Icons.people_alt_outlined, 'تعداد بزرگسال:', '$adults نفر'),
            _buildDetailRow(Icons.nights_stay_outlined, 'مدت اقامت:', '$nights شب'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          Icon(icon, color: kAccentColor, size: 18),
          const SizedBox(width: 10),
          Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: kLightTextColor)),
          const SizedBox(width: 6),
          Expanded(
              child: Text(value,
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600, color: Colors.black87),
                  textAlign: TextAlign.left)),
        ],
      ),
    );
  }

  Widget _buildTravelerFormsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('اطلاعات مسافران',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold, color: kPrimaryColor)),
        const SizedBox(height: 8),
        Text('لطفاً اطلاعات مسافران را مطابق با کارت شناسایی معتبر وارد نمایید.',
            style: theme.textTheme.bodySmall?.copyWith(color: kLightTextColor)),
        const SizedBox(height: 16),
        Form(
          key: _formKey,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _guestFormControllers.length,
            itemBuilder: (context, index) {
              return _buildGuestFormCard(
                theme,
                guestNumber: index + 1,
                isSupervisor: index == 0,
                controllers: _guestFormControllers[index],
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildGuestFormCard(ThemeData theme,
      {required int guestNumber,
        required bool isSupervisor,
        required Map<String, TextEditingController> controllers}) {
    String title = 'مسافر ${guestNumber == 1 ? "اول" : guestNumber == 2 ? "دوم" : intl.NumberFormat("#,##0", "fa_IR").format(guestNumber)}';
    if (isSupervisor) title += ' (سرپرست)';

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: kCardBackground,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: theme.textTheme.titleSmall?.copyWith(
                    color: kAccentColor, fontWeight: FontWeight.bold)),
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
                  if (val.trim().length != 10 || !RegExp(r'^[0-9]{10}$').hasMatch(val.trim())) return 'کد ملی باید ۱۰ رقم باشد';
                  return null;
                }),
            const SizedBox(height: 12),
            _buildGenderDropdown(controllers['gender']!),
          ],
        ),
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
        labelStyle: TextStyle(fontSize: 14, color: kPrimaryColor.withOpacity(0.8)),
        hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade500),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: kPrimaryColor, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.2)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        filled: true,
        fillColor: kPageBackground.withOpacity(0.7),
      ),
      validator: validator,
    );
  }

  Widget _buildGenderDropdown(TextEditingController controller) {
    List<String> genders = ['آقا', 'خانم'];
    if (controller.text.isEmpty && genders.isNotEmpty) {
      controller.text = genders.first;
    }

    return DropdownButtonFormField<String>(
      value: controller.text.isNotEmpty && genders.contains(controller.text) ? controller.text : null,
      decoration: InputDecoration(
        labelText: 'جنسیت *',
        labelStyle: TextStyle(fontSize: 14, color: kPrimaryColor.withOpacity(0.8)),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: kPrimaryColor, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        filled: true,
        fillColor: kPageBackground.withOpacity(0.7),
      ),
      items: genders.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: const TextStyle(fontSize: 15)),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            controller.text = newValue;
          });
        }
      },
      validator: (value) => (value == null || value.isEmpty) ? 'انتخاب جنسیت الزامی است' : null,
    );
  }

  Widget _buildTermsAndPaymentSection(ThemeData theme) {
    final intl.NumberFormat currencyFormatter =
    intl.NumberFormat("#,##0", "fa_IR");

    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 20.0),
      decoration: BoxDecoration(
        color: kCardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, -3)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: _termsAndConditionsAccepted,
                  onChanged: (bool? value) {
                    setState(() => _termsAndConditionsAccepted = value ?? false);
                  },
                  activeColor: kPrimaryColor,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  side: BorderSide(color: Colors.grey.shade400, width: 1.5),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() => _termsAndConditionsAccepted = !_termsAndConditionsAccepted);
                  },
                  child: Text(
                    'قوانین و مقررات رزرو هتل را مطالعه کرده و می‌پذیرم.',
                    style: theme.textTheme.bodySmall?.copyWith(color: kLightTextColor),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('مبلغ قابل پرداخت:', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _bookingPageData != null && _bookingPageData!['totalPrice'] != null
                        ? currencyFormatter.format(_bookingPageData!['totalPrice'])
                        : "...",
                    style: theme.textTheme.titleLarge?.copyWith(
                        color: kPrimaryColor, fontWeight: FontWeight.bold),
                  ),
                  Text('تومان', style: theme.textTheme.bodySmall?.copyWith(color: kLighterTextColor)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isTimerActive ? _handleBookingSubmission : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isTimerActive ? kPrimaryColor : kDisabledColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                textStyle: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              child: Text(
                  _isTimerActive ? 'تایید و پرداخت' : 'زمان به پایان رسید',
                  style: const TextStyle(color: Colors.white)
              ),
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
            CircularProgressIndicator(color: kPrimaryColor),
            const SizedBox(width: 20),
            Text("در حال ثبت رزرو...", style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}