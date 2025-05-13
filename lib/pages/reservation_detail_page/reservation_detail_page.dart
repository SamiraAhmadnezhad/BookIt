import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:intl/date_symbol_data_local.dart' as intl_local; // ایمپورت برای initializeDateFormatting

// شبیه‌سازی سرویس API (بدون تغییر نسبت به قبل)
class BookingApiService {
  Future<Map<String, dynamic>> fetchBookingPreviewDetails(String hotelId) async {
    print('API Call: fetchBookingPreviewDetails for hotelId: $hotelId');
    await Future.delayed(const Duration(seconds: 1));
    return {
      'hotelName': 'نام هتل در حالت طولانی-',
      'hotelAddress': 'آدرس دقیق هتل در حالت طولانی قرار می‌گیرد',
      'hotelRating': 4.5,
      'hotelStarRatingVisual': 4,
      'hotelImageUrl': 'https://picsum.photos/seed/hotel_booking_figma_local_init/800/300',
      'remainingTime': '11:48',
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
// پایان شبیه‌سازی سرویس API

class ReservationDetailPage extends StatefulWidget {
  final String hotelId;

  const ReservationDetailPage({Key? key, required this.hotelId}) : super(key: key);

  @override
  _ReservationDetailPageState createState() => _ReservationDetailPageState();
}

class _ReservationDetailPageState extends State<ReservationDetailPage> {
  final BookingApiService _apiService = BookingApiService();
  Map<String, dynamic>? _bookingPageData;
  bool _isLoading = true; // برای بارگذاری داده‌های اصلی صفحه
  bool _isIntlInitialized = false; // وضعیت جدید برای مقداردهی اولیه intl
  String? _errorMessage;

  late List<Map<String, TextEditingController>> _guestFormControllers;
  bool _termsAndConditionsAccepted = false;

  @override
  void initState() {
    super.initState();
    _guestFormControllers = [];
    _initializeDependencies(); // ابتدا وابستگی‌ها (شامل intl) را مقداردهی اولیه می‌کنیم
  }

  Future<void> _initializeDependencies() async {
    try {
      // مقداردهی اولیه intl برای لوکال فارسی
      await intl_local.initializeDateFormatting('fa_IR', null);
      if (mounted) {
        setState(() {
          _isIntlInitialized = true;
        });
        // پس از مقداردهی اولیه موفقیت آمیز intl، داده‌های اصلی صفحه را بارگذاری کنید
        _loadBookingPageData();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "خطا در آماده‌سازی اطلاعات زبان: $e";
          _isLoading = false; // چون بارگذاری اصلی شروع نشده، این را false می‌کنیم
          _isIntlInitialized = true; // اجازه می‌دهیم UI خطا را نمایش دهد
        });
      }
    }
  }

  Future<void> _loadBookingPageData() async {
    if (!mounted) return;
    // اطمینان از اینکه intl مقداردهی اولیه شده است
    if (!_isIntlInitialized) {
      // این حالت نباید رخ دهد اگر _initializeDependencies به درستی کار کند
      print("Warning: _loadBookingPageData called before intl initialization.");
      return;
    }
    setState(() {
      _isLoading = true; // شروع بارگذاری داده‌های اصلی
      _errorMessage = null;
    });
    try {
      final data = await _apiService.fetchBookingPreviewDetails(widget.hotelId);
      if (!mounted) return;
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
        _isLoading = false; // پایان بارگذاری داده‌های اصلی
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'خطا در بارگذاری اطلاعات صفحه: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    for (var controllersMap in _guestFormControllers) {
      controllersMap.forEach((key, controller) => controller.dispose());
    }
    super.dispose();
  }

  Future<void> _handleBookingSubmission() async {
    // این تابع بدون تغییر باقی می‌ماند
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final currentTheme = Theme.of(context);

    if (!_termsAndConditionsAccepted) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('لطفاً قوانین و مقررات رزرو را مطالعه و تأیید نمایید.',
              style: currentTheme.textTheme.bodyMedium?.copyWith(color: Colors.white)),
          backgroundColor: Colors.redAccent,
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
                style: currentTheme.textTheme.bodyMedium?.copyWith(color: Colors.white)),
            backgroundColor: Colors.redAccent,
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
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: currentTheme.colorScheme.primary),
                  const SizedBox(width: 20),
                  Text("در حال ثبت رزرو...", style: currentTheme.textTheme.bodyLarge),
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
        scaffoldMessenger.showSnackBar(
          SnackBar(
              content: Text('رزرو شما با موفقیت ثبت شد!',
                  style: currentTheme.textTheme.bodyMedium?.copyWith(color: Colors.white)),
              backgroundColor: Colors.green),
        );
        // TODO: هدایت به صفحه تایید
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(
              content: Text('خطا در ثبت رزرو. لطفاً مجدداً تلاش فرمایید.',
                  style: currentTheme.textTheme.bodyMedium?.copyWith(color: Colors.white)),
              backgroundColor: Colors.redAccent),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      scaffoldMessenger.showSnackBar(
        SnackBar(
            content: Text('خطا در ارتباط با سرور: $e',
                style: currentTheme.textTheme.bodyMedium?.copyWith(color: Colors.white)),
            backgroundColor: Colors.redAccent),
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
    // اگر intl هنوز مقداردهی اولیه نشده یا در حال بارگذاری داده‌های اصلی هستیم
    if (!_isIntlInitialized || (_isIntlInitialized && _isLoading && _bookingPageData == null)) {
      return AppBar(
        title: Text('بارگذاری اطلاعات...', style: Theme.of(context).textTheme.titleMedium),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      );
    }
    // اگر خطایی وجود دارد (به جز خطای اولیه intl که در بدنه اصلی نمایش داده می‌شود)
    if (_errorMessage != null && _bookingPageData == null) {
      return AppBar(
        title: Text('خطا', style: Theme.of(context).textTheme.titleMedium),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      );
    }
    // اگر داده‌ها با موفقیت بارگذاری شده‌اند
    return AppBar(
      title: Text(_bookingPageData!['hotelName'] ?? 'تکمیل اطلاعات رزرو',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 0.5,
    );
  }

  Widget _buildBody() {
    final textTheme = Theme.of(context).textTheme;

    // 1. ابتدا بررسی می‌کنیم که آیا intl مقداردهی اولیه شده است یا نه
    if (!_isIntlInitialized && _errorMessage == null) { // اگر errorMessage به خاطر خطای intl نباشد
      return Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text("در حال آماده سازی...", style: textTheme.bodyLarge),
        ],
      ));
    }

    // 2. سپس وضعیت بارگذاری داده‌های اصلی یا خطا را بررسی می‌کنیم
    if (_isLoading && _isIntlInitialized && _errorMessage == null) { // تنها اگر intl آماده شده، لودینگ اصلی را نشان بده
      return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary));
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.redAccent, size: 60),
              const SizedBox(height: 16),
              Text(_errorMessage!, style: textTheme.bodyLarge, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isIntlInitialized ? _loadBookingPageData : _initializeDependencies,
                child: const Text('تلاش مجدد'),
                style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
              )
            ],
          ),
        ),
      );
    }

    if (_bookingPageData == null) { // این حالت نباید زیاد اتفاق بیفتد اگر منطق بالا درست باشد
      return Center(child: Text('اطلاعات مورد نیاز برای نمایش صفحه یافت نشد.', style: textTheme.bodyLarge));
    }

    // --- بقیه کد buildBody بدون تغییر ---
    final intl.DateFormat longPersianDateFormat = intl.DateFormat('EEEE d MMMM yyyy', 'fa_IR');
    final DateTime checkInDate = intl.DateFormat("yyyy-MM-ddTHH:mm:ss.SSS'Z'").parse(_bookingPageData!['checkInDate'], true).toLocal();
    final DateTime checkOutDate = intl.DateFormat("yyyy-MM-ddTHH:mm:ss.SSS'Z'").parse(_bookingPageData!['checkOutDate'], true).toLocal();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHotelImageSection(
            imageUrl: _bookingPageData!['hotelImageUrl'],
            remainingTime: _bookingPageData!['remainingTime'],
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
                for (int i = 0; i < _guestFormControllers.length; i++) ...[
                  _buildGuestFormWidget(
                    guestNumber: i + 1,
                    isSupervisor: i == 0,
                    controllers: _guestFormControllers[i],
                  ),
                  const SizedBox(height: 16),
                ],
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- بقیه توابع _build... بدون تغییر باقی می‌مانند ---
  // _buildHotelImageSection, _buildHotelInfoSection, _buildReservationDetailsSection,
  // _buildTravelerNotesSection, _buildGuestFormWidget, _buildFormTextField,
  // _buildTermsAndPaymentSection

  Widget _buildHotelImageSection({required String imageUrl, required String remainingTime}) {
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
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            );
          },
        ),
        Positioned(
          bottom: 10,
          right: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'زمان باقی مانده: $remainingTime',
              style: TextStyle(
                fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
                color: Colors.white,
                fontSize: 11,
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
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.location_on_outlined, color: textTheme.bodyMedium?.color, size: 18),
            const SizedBox(width: 6),
            Expanded(
              child: Text(address, style: textTheme.bodyMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Icon(Icons.thumb_up_alt_outlined, color: colorScheme.primary, size: 18),
            const SizedBox(width: 4),
            Text(
              rating.toStringAsFixed(1),
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 16),
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < starRatingVisual ? Icons.star_rounded : Icons.star_border_rounded,
                  color: Colors.amber,
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
            Icon(Icons.calendar_today_outlined, color: textTheme.bodyMedium?.color, size: 20),
            const SizedBox(width: 8),
            Text('اطلاعات رزرو', style: textTheme.titleMedium),
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
          Icon(icon, color: Theme.of(context).textTheme.bodyMedium?.color, size: 18),
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
            Icon(Icons.list_alt_outlined, color: textTheme.bodyMedium?.color, size: 20),
            const SizedBox(width: 8),
            Text('اطلاعات مسافران', style: textTheme.titleMedium),
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
                        child: Icon(Icons.circle, size: 6, color: textTheme.bodyMedium?.color),
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

  Widget _buildGuestFormWidget({
    required int guestNumber,
    required bool isSupervisor,
    required Map<String, TextEditingController> controllers,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    String title = 'بزرگسال $guestNumber';
    if (isSupervisor) {
      title += ' - سرپرست';
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.titleMedium?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
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
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: inputDecorationTheme.hintStyle,
        border: inputDecorationTheme.border,
        focusedBorder: inputDecorationTheme.focusedBorder,
        enabledBorder: inputDecorationTheme.border,
        contentPadding: inputDecorationTheme.contentPadding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        filled: true,
        fillColor: inputDecorationTheme.fillColor ?? Colors.grey.shade100.withOpacity(0.5),
      ),
    );
  }

  Widget _buildTermsAndPaymentSection() {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final intl.NumberFormat currencyFormatter = intl.NumberFormat("#,##0", "fa_IR");

    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
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
                    setState(() {
                      _termsAndConditionsAccepted = value ?? false;
                    });
                  },
                  activeColor: colorScheme.primary,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _termsAndConditionsAccepted = !_termsAndConditionsAccepted;
                    });
                  },
                  child: Text(
                    'قوانین و مقررات رزرو هتل را می‌پذیرم.',
                    style: textTheme.bodyMedium,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('مبلغ قابل پرداخت:', style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
              Text(
                // اطمینان از اینکه _bookingPageData و totalPrice نال نیستند
                _bookingPageData != null && _bookingPageData!['totalPrice'] != null
                    ? "${currencyFormatter.format(_bookingPageData!['totalPrice'])} تومان"
                    : "محاسبه...",
                style: textTheme.titleLarge?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _handleBookingSubmission,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              child: const Text('تایید و ادامه'),
            ),
          ),
        ],
      ),
    );
  }
}