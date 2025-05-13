import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:intl/date_symbol_data_local.dart' as intl_local;

class BookingApiService {
  Future<Map<String, dynamic>> fetchBookingPreviewDetails(String hotelId) async {
    print('API Call: fetchBookingPreviewDetails for hotelId: $hotelId');
    await Future.delayed(const Duration(seconds: 1));
    return {
      'hotelName': 'نام هتل در حالت طولانی-',
      'hotelAddress': 'آدرس دقیق هتل در حالت طولانی قرار می‌گیرد',
      'hotelRating': 4.5,
      'hotelStarRatingVisual': 4,
      'hotelImageUrl': 'https://picsum.photos/seed/hotel_booking_final_v4/800/300',
      'checkInDate': "2026-03-15T00:00:00.000Z",
      'checkOutDate': "2026-03-18T00:00:00.000Z",
      'roomInfo': '1 اتاق به مدت 3 شب',
      'numberOfAdults': 2,
      'totalPrice': 3200000,
    };
  }

  Future<bool> submitHotelBooking(Map<String, dynamic> bookingData) async {
    print('API Call: submitHotelBooking with data: $bookingData');
    await Future.delayed(const Duration(seconds: 2));
    return true;
  }
}

class ReservationDetailPage extends StatefulWidget {
  final String hotelId;
  const ReservationDetailPage({Key? key, required this.hotelId}) : super(key: key);

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
  bool _termsAndConditionsAccepted = false;

  Timer? _timer;
  final int _initialTimerSeconds = 15 * 60;
  late int _remainingSeconds;
  bool _isTimerActive = false;
  final Color _primaryColor = const Color(0xFF542545);


  @override
  void initState() {
    super.initState();
    _guestFormControllers = [];
    _remainingSeconds = _initialTimerSeconds;
    _initializeDependencies();
  }

  Future<void> _initializeDependencies() async {
    try {
      await intl_local.initializeDateFormatting('fa_IR', null);
      if (mounted) {
        setState(() {
          _isIntlInitialized = true;
        });
        _loadBookingPageData();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "خطا در آماده‌سازی اطلاعات زبان: $e";
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
      final data = await _apiService.fetchBookingPreviewDetails(widget.hotelId);
      if (mounted) {
        setState(() {
          _bookingPageData = data;
          _guestFormControllers = List.generate(
            (_bookingPageData?['numberOfAdults'] as int?) ?? 1,
                (index) => {
              'firstName': TextEditingController(),
              'lastName': TextEditingController(),
              'nationalCode': TextEditingController(),
              'gender': TextEditingController(),
            },
          );
          _isLoading = false;
          _startTimer();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'خطا در بارگذاری اطلاعات صفحه: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    if (_remainingSeconds <= 0) {
      setState(() { _isTimerActive = false; });
      return;
    }
    setState(() { _isTimerActive = true; });
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('زمان شما برای تکمیل رزرو به پایان رسید.', textDirection: TextDirection.rtl, style: TextStyle(fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily)),
                backgroundColor: Colors.orangeAccent,
              ),
            );
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

  String _formatTimer(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _handleBookingSubmission() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final currentTheme = Theme.of(context);

    if (!_isTimerActive) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('زمان شما برای تکمیل رزرو به پایان رسیده است.',
              style: TextStyle(fontFamily: currentTheme.textTheme.bodyMedium?.fontFamily, color: Colors.white)),
          backgroundColor: _primaryColor,
        ),
      );
      return;
    }

    if (!_termsAndConditionsAccepted) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('لطفاً قوانین و مقررات رزرو را مطالعه و تأیید نمایید.',
              style: TextStyle(fontFamily: currentTheme.textTheme.bodyMedium?.fontFamily, color: Colors.white)),
          backgroundColor: _primaryColor,
        ),
      );
      return;
    }

    bool formIsValid = true;
    for (int i = 0; i < _guestFormControllers.length; i++) {
      if (_guestFormControllers[i]['firstName']!.text.trim().isEmpty ||
          _guestFormControllers[i]['lastName']!.text.trim().isEmpty ||
          _guestFormControllers[i]['nationalCode']!.text.trim().isEmpty) {
        formIsValid = false;
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('لطفاً اطلاعات مسافر ${i + 1} را به صورت کامل وارد کنید.',
                style: TextStyle(fontFamily: currentTheme.textTheme.bodyMedium?.fontFamily, color: Colors.white)),
            backgroundColor: _primaryColor,
          ),
        );
        break;
      }
    }
    if (!formIsValid) return;

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
        builder: (BuildContext dialogContext) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: _primaryColor),
                  const SizedBox(width: 20),
                  Text("در حال ثبت رزرو...", style: TextStyle(fontFamily: currentTheme.textTheme.bodyLarge?.fontFamily, fontSize: currentTheme.textTheme.bodyLarge?.fontSize)),
                ],
              ),
            ),
          );
        },
      );
    }

    try {
      bool submissionSuccess = await _apiService.submitHotelBooking(bookingPayload);
      if (mounted) Navigator.pop(context);

      if (submissionSuccess) {
        _timer?.cancel();
        setState(() { _isTimerActive = false; });
        scaffoldMessenger.showSnackBar(
          SnackBar(
              content: Text('رزرو شما با موفقیت ثبت شد!',
                  style: TextStyle(fontFamily: currentTheme.textTheme.bodyMedium?.fontFamily, color: Colors.white)),
              backgroundColor: Colors.green),
        );
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(
              content: Text('خطا در ثبت رزرو. لطفاً مجدداً تلاش فرمایید.',
                  style: TextStyle(fontFamily: currentTheme.textTheme.bodyMedium?.fontFamily, color: Colors.white)),
              backgroundColor: _primaryColor),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      scaffoldMessenger.showSnackBar(
        SnackBar(
            content: Text('خطا در ارتباط با سرور: $e',
                style: TextStyle(fontFamily: currentTheme.textTheme.bodyMedium?.fontFamily, color: Colors.white)),
            backgroundColor: _primaryColor),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(),
        bottomNavigationBar: !_isIntlInitialized || _isLoading || _errorMessage != null || _bookingPageData == null
            ? null
            : _buildTermsAndPaymentSection(),
      ),
    );
  }

  AppBar? _buildAppBar() {
    final appBarTextStyle = Theme.of(context).appBarTheme.titleTextStyle ?? Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).appBarTheme.foregroundColor);

    if (!_isIntlInitialized || (_isIntlInitialized && _isLoading && _bookingPageData == null)) {
      return AppBar(
        title: Text('بارگذاری اطلاعات...', style: appBarTextStyle),
      );
    }
    if (_errorMessage != null && _bookingPageData == null) {
      return AppBar(
        title: Text('خطا', style: appBarTextStyle),
      );
    }
    return AppBar(
      title: Text(_bookingPageData!['hotelName'] ?? 'تکمیل اطلاعات رزرو', style: appBarTextStyle),
    );
  }

  Widget _buildBody() {
    final textTheme = Theme.of(context).textTheme;

    if (!_isIntlInitialized && _errorMessage == null) {
      return Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: _primaryColor),
          const SizedBox(height: 16),
          Text("در حال آماده سازی...", style: textTheme.bodyLarge),
        ],
      ));
    }
    if (_isLoading && _isIntlInitialized && _errorMessage == null) {
      return Center(child: CircularProgressIndicator(color: _primaryColor));
    }
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: _primaryColor, size: 60),
              const SizedBox(height: 16),
              Text(_errorMessage!, style: textTheme.bodyLarge, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isIntlInitialized ? _loadBookingPageData : _initializeDependencies,
                style: ElevatedButton.styleFrom(backgroundColor: _primaryColor),
                child: const Text('تلاش مجدد'),
              )
            ],
          ),
        ),
      );
    }
    if (_bookingPageData == null) {
      return Center(child: Text('اطلاعات مورد نیاز برای نمایش صفحه یافت نشد.', style: textTheme.bodyLarge));
    }

    final intl.DateFormat longPersianDateFormat = intl.DateFormat('EEEE d MMMM yyyy', 'fa_IR');
    final DateTime checkInDate = intl.DateFormat("yyyy-MM-ddTHH:mm:ss.SSS'Z'").parse(_bookingPageData!['checkInDate'], true).toLocal();
    final DateTime checkOutDate = intl.DateFormat("yyyy-MM-ddTHH:mm:ss.SSS'Z'").parse(_bookingPageData!['checkOutDate'], true).toLocal();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHotelImageSection(
            imageUrl: _bookingPageData!['hotelImageUrl'],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHotelInfoSection(
                  address: _bookingPageData!['hotelAddress'],
                  rating: _bookingPageData!['hotelRating'],
                  starRatingVisual: _bookingPageData!['hotelStarRatingVisual'],
                ),
                const SizedBox(height: 24),
                _buildReservationDetailsSection(
                  checkInDateString: longPersianDateFormat.format(checkInDate),
                  checkOutDateString: longPersianDateFormat.format(checkOutDate),
                  roomInfo: _bookingPageData!['roomInfo'],
                  adults: _bookingPageData!['numberOfAdults'],
                ),
                const SizedBox(height: 24),
                _buildTravelerNotesSection(),
                const SizedBox(height: 24),
                _buildRoomFormsSection(),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotelImageSection({required String imageUrl}) {
    return Stack(
      children: [
        Image.network(
          imageUrl,
          width: double.infinity,
          height: 200,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            height: 200,
            color: Colors.grey[300],
            child: Center(child: Icon(Icons.broken_image_outlined, size: 50, color: Colors.grey[600])),
          ),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 200,
              color: Colors.grey[200],
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                  color: _primaryColor,
                ),
              ),
            );
          },
        ),
        if (_isTimerActive || _remainingSeconds > 0 || !_isTimerActive && _remainingSeconds == 0)
          Positioned(
            bottom: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _isTimerActive && _remainingSeconds > 0
                    ? Color(0xFFEEEEEE)
                    : Color(0xFF542545),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _isTimerActive && _remainingSeconds > 0
                    ? 'زمان باقی مانده: ${_formatTimer(_remainingSeconds)}'
                    : 'زمان به پایان رسید',
                style: TextStyle(
                  fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
                  color: Color(0xFF5F5F5F),
                  fontSize: 11,
                  fontWeight: _isTimerActive && _remainingSeconds > 0 ? FontWeight.normal : FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHotelInfoSection({
    required String address,
    required double rating,
    required int starRatingVisual,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.location_on, color: _primaryColor, size: 18),
            const SizedBox(width: 6),
            Expanded(
              child: Text(address, style: textTheme.bodyMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Icon(Icons.thumb_up, color: _primaryColor, size: 18),
            const SizedBox(width: 4),
            Text(
              rating.toStringAsFixed(1),
              style: textTheme.bodyMedium?.copyWith(color: _primaryColor, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 16),
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < starRatingVisual ? Icons.star_rounded : Icons.star_border_rounded,
                  color: _primaryColor,
                  size: 20,
                );
              }),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReservationDetailsSection({
    required String checkInDateString,
    required String checkOutDateString,
    required String roomInfo,
    required int adults,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.calendar_today_outlined, color: _primaryColor, size: 20),
            const SizedBox(width: 8),
            Text('اطلاعات رزرو', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Column(
            children: [
              _buildDetailRowItem(context, Icons.login_outlined, checkInDateString),
              _buildDetailRowItem(context, Icons.logout_outlined, checkOutDateString),
              _buildDetailRowItem(context, Icons.bed_outlined, roomInfo),
              _buildDetailRowItem(context, Icons.person_outline, '$adults بزرگسال'),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildDetailRowItem(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, color: _primaryColor, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }

  Widget _buildTravelerNotesSection() {
    final textTheme = Theme.of(context).textTheme;
    final notes = [
      'کاربر گرامی، لطفا در هنگام وارد کردن اطلاعات به نکات زیر توجه داشته باشید:',
      'لطفا از صحت اطلاعات وارد شده (شماره موبایل و ایمیل) خود اطمینان حاصل فرمائید تا در مواقع ضروری با شما تماس گرفته شود. در صورت عدم صحت اطلاعات وارد شده عواقب ناشی از آن متوجه مشتری است.',
      'بعد از رزرواسیون امکان تغییر نام مسافرین وجود ندارد.',
      'در صورت رزرو اتاق برای اتباع غیرایرانی، مطابق با قوانین هتل ممکن است در زمان ورود مابه التفاوت به هتل پرداخت نمائید.',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.list_alt_outlined, color: _primaryColor, size: 20),
            const SizedBox(width: 8),
            Text('اطلاعات مسافران', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: notes.map((note) {
              bool isFirstNote = note == notes.first;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isFirstNote)
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0, top: 6.0),
                        child: Icon(Icons.circle, size: 6, color: textTheme.bodyMedium?.color ?? Colors.black54),
                      ),
                    if (!isFirstNote) const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        note,
                        style: textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                          fontWeight: isFirstNote ? FontWeight.bold : FontWeight.normal,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildRoomFormsSection() {
    const String roomTitle = "اتاق ۱";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0, right: 4.0),
          child: Text(
            roomTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        for (int i = 0; i < _guestFormControllers.length; i++) ...[
          _buildGuestFormWidget(
            guestNumber: i + 1,
            isSupervisor: i == 0,
            controllers: _guestFormControllers[i],
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildGuestFormWidget({
    required int guestNumber,
    required bool isSupervisor,
    required Map<String, TextEditingController> controllers,
  }) {
    final textTheme = Theme.of(context).textTheme;
    String title = 'بزرگسال ${guestNumber == 1 ? "اول" : guestNumber == 2 ? "دوم" : guestNumber.toString()}';
    if (isSupervisor) {
      title += ' - سرپرست';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0, right: 4.0),
            child: Text(
              title,
              style: textTheme.titleMedium?.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
          ),
          _buildFormTextField(hintText: 'نام', controller: controllers['firstName']!),
          const SizedBox(height: 12),
          _buildFormTextField(hintText: 'نام خانوادگی', controller: controllers['lastName']!),
          const SizedBox(height: 12),
          _buildFormTextField(
              hintText: 'کد ملی',
              controller: controllers['nationalCode']!,
              keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          _buildFormTextField(
              hintText: 'جنسیت',
              controller: controllers['gender']!),
        ],
      ),
    );
  }

  Widget _buildFormTextField({
    required String hintText,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final inputDecorationTheme = Theme.of(context).inputDecorationTheme;
    final textTheme = Theme.of(context).textTheme;
    final String? fontFamily = textTheme.bodyMedium?.fontFamily;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(fontFamily: fontFamily, fontSize: 15, color: textTheme.bodyMedium?.color ?? Colors.black87),
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(fontFamily: fontFamily, fontSize: 15, color: Colors.grey.shade600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: _primaryColor, width: 1.5),
        ),
        contentPadding: inputDecorationTheme.contentPadding ??
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: inputDecorationTheme.fillColor ?? Colors.white,
      ),
    );
  }

  Widget _buildTermsAndPaymentSection() {
    final textTheme = Theme.of(context).textTheme;
    final intl.NumberFormat currencyFormatter = intl.NumberFormat("#,##0", "fa_IR");
    final String? fontFamily = textTheme.titleMedium?.fontFamily;

    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _termsAndConditionsAccepted = !_termsAndConditionsAccepted;
                    });
                  },
                  child: Text(
                    'قوانین و مقررات رزرو هتل را می‌پذیرم.',
                    style: textTheme.bodyMedium?.copyWith(fontSize: 13.5),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 22,
                height: 22,
                child: Checkbox(
                  value: _termsAndConditionsAccepted,
                  onChanged: (bool? value) {
                    setState(() {
                      _termsAndConditionsAccepted = value ?? false;
                    });
                  },
                  activeColor: _primaryColor,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  side: BorderSide(color: Colors.grey.shade400, width: 1.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'تومان',
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade700,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _bookingPageData != null && _bookingPageData!['totalPrice'] != null
                        ? currencyFormatter.format(_bookingPageData!['totalPrice'])
                        : "...",
                    style: TextStyle(
                      fontFamily: textTheme.titleLarge?.fontFamily,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('مبلغ قابل پرداخت',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    color: _primaryColor,
                    size: 26,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isTimerActive ? _handleBookingSubmission : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isTimerActive ? _primaryColor : Colors.grey.shade400,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28.0),
                ),
              ),
              child: Text(
                _isTimerActive ? 'تایید و ادامه' : 'زمان به پایان رسید',
                style: TextStyle(
                  fontFamily: fontFamily,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}