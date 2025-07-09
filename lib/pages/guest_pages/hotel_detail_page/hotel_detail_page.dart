// lib/pages/guest_pages/hotel_detail_page/hotel_detail_page.dart

import 'package:bookit/pages/guest_pages/hotel_detail_page/utils/constants.dart';
import 'package:bookit/pages/guest_pages/hotel_detail_page/widgets/add_review_form_widget.dart';
import 'package:bookit/pages/guest_pages/hotel_detail_page/widgets/amenity_item_widget.dart';
import 'package:bookit/pages/guest_pages/hotel_detail_page/widgets/hotel_image_widget.dart';
import 'package:bookit/pages/guest_pages/hotel_detail_page/widgets/review_card_widget.dart';
import 'package:bookit/pages/guest_pages/hotel_detail_page/widgets/room_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../authentication_page/auth_service.dart';
import '../home_page/model/hotel_model.dart';
import '../search_page/widgets/custom_shamsi_date_picker.dart';

import 'data/models/amenity_model.dart';
import 'data/models/hotel_details_model.dart';
import 'data/models/review_model.dart';
import 'data/models/room_model.dart';
import 'data/services/hotel_api_service.dart';

class HotelDetailsPage extends StatefulWidget {
  // <<< اصلاح شد: به جای hotelId، کل شیء hotel را دریافت می‌کنیم >>>
  final Hotel hotel;

  const HotelDetailsPage({Key? key, required this.hotel}) : super(key: key);

  @override
  _HotelDetailsPageState createState() => _HotelDetailsPageState();
}

class _HotelDetailsPageState extends State<HotelDetailsPage> with TickerProviderStateMixin {
  final HotelApiService _apiService = HotelApiService();
  // <<< حذف شد: دیگر نیازی به این Future نداریم >>>
  // Future<HotelDetails>? _hotelDetailsFuture;

  Future<List<Room>>? _roomsFuture;
  Future<List<Review>>? _reviewsFuture;

  bool _isFavorite = false;
  String? _currentToken;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    final authService = Provider.of<AuthService>(context, listen: false);
    _currentToken = authService.token;

    // <<< اصلاح شد: اطلاعات اصلی از ویجت خوانده می‌شود >>>
    _isFavorite = widget.hotel.isCurrentlyFavorite;
    _animationController.forward(); // انیمیشن را بلافاصله اجرا کن

    if (_currentToken != null) {
      // فقط برای اتاق‌ها و نظرات درخواست API ارسال می‌شود
      _roomsFuture = _apiService.fetchHotelRooms(widget.hotel.id.toString(), _currentToken!);
      _reviewsFuture = _apiService.fetchHotelReviews(widget.hotel.id.toString(), _currentToken!);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // <<< حذف شد: دیگر نیازی به این متد نداریم >>>
  // void _loadDataAndFavoriteStatus(String token) { ... }

  Future<void> _toggleFavorite() async {
    // ... این متد بدون تغییر باقی می‌ماند، فقط از widget.hotel.id استفاده می‌کند
    if (_currentToken == null) return;
    // ...
    bool success = await _apiService.toggleFavoriteHotel(widget.hotel.id.toString(), !_isFavorite, _currentToken!);
    // ...
  }

  Future<void> _showBookingDateRangePicker(BuildContext context, Room room) async {
    Jalali? startDate;
    Jalali? endDate;
    final Jalali today = Jalali.now();
    final Jalali initialFirstDate = today;
    final Jalali initialLastDate = today.addDays(365);

    startDate = await showCustomShamsiDatePickerDialog(
      context,
      initialDate: initialFirstDate,
      firstDate: initialFirstDate,
      lastDate: initialLastDate,
      titleText: "تاریخ ورود را انتخاب کنید",
    );

    if (startDate == null || !mounted) return;

    final Jalali firstDateForEndDate = startDate.addDays(1);
    final Jalali lastDateForEndDate = initialLastDate.compareTo(firstDateForEndDate) < 0
        ? firstDateForEndDate.addDays(30)
        : initialLastDate;

    endDate = await showCustomShamsiDatePickerDialog(
      context,
      initialDate: firstDateForEndDate,
      firstDate: firstDateForEndDate,
      lastDate: lastDateForEndDate,
      titleText: "تاریخ خروج را انتخاب کنید",
    );

    if (endDate == null || !mounted) return;

    final String startDateFormatted = "${startDate.year}/${startDate.month.toString().padLeft(2, '0')}/${startDate.day.toString().padLeft(2, '0')}";
    final String endDateFormatted = "${endDate.year}/${endDate.month.toString().padLeft(2, '0')}/${endDate.day.toString().padLeft(2, '0')}";

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "اتاق ${room.name} برای تاریخ $startDateFormatted تا $endDateFormatted انتخاب شد. ورود به صفحه رزرو...",
          textDirection: TextDirection.rtl,
        ),
        duration: const Duration(seconds: 3),
      ),
    );
    // Navigate to booking page or implement booking logic here
  }


  Future<void> _handleReviewSubmission(Review reviewData) async {
    // ... این متد بدون تغییر باقی می‌ماند، فقط از widget.hotel.id استفاده می‌کند
    if (_currentToken == null) return;
    // ...
    bool success = await _apiService.submitReview(widget.hotel.id.toString(), reviewData, _currentToken!);
    // ...
    _reviewsFuture = _apiService.fetchHotelReviews(widget.hotel.id.toString(), _currentToken!);
    // ...
  }


  @override
  Widget build(BuildContext context) {
    // <<< اصلاح شد: دیگر نیازی به FutureBuilder برای هتل اصلی نیست >>>
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        // اگر توکن نبود، می‌توان یک حالت خطا نمایش داد
        body: _currentToken == null
            ? _buildErrorState("برای مشاهده اطلاعات، ابتدا وارد شوید.")
        // در غیر این صورت، مستقیماً محتوا را با داده‌های دریافتی از ویجت بساز
            : _buildHotelContentView(widget.hotel),
      ),
    );
  }

  Widget _buildHotelContentView(Hotel hotel) { // <<< نوع پارامتر به Hotel تغییر کرد
    return Stack(
      children: [
        Container(color: Colors.white),
        CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              backgroundColor: kPrimaryColor,
              expandedHeight: 280,
              pinned: true,
              stretch: true,
              elevation: 0,
              systemOverlayStyle: SystemUiOverlayStyle.light,
              leading: _buildAppBarButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                _buildAppBarButton(
                  icon: _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: _isFavorite ? Colors.redAccent : Colors.white,
                  onPressed: _toggleFavorite,
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: HotelImageWidget(imageUrl: hotel.imageUrl, rating: hotel.rating,),
                stretchModes: const [StretchMode.zoomBackground],
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
                ),
                transform: Matrix4.translationValues(0.0, -20.0, 0.0),
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) => FadeTransition(opacity: _animationController, child: child),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 20),
                          child: _buildHotelHeader(context, hotel),
                        ),
                        const Divider(height: 32, thickness: 1, indent: 20, endIndent: 20),
                        _buildSection(
                          title: "درباره هتل",
                          icon: Icons.info_outline_rounded,
                          content: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Text(hotel.description, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black54, height: 1.7)),
                          ),
                        ),
                        _buildSection(
                          title: "امکانات و ویژگی ها",
                          icon: Icons.local_offer_outlined,
                          content: _buildAmenitiesHorizontalList(hotel.amenities),
                        ),
                        _buildSection(
                          title: "اتاق های موجود",
                          icon: Icons.king_bed_outlined,
                          content: _buildRoomsList(),
                        ),
                        _buildSection(
                          title: "نظرات کاربران",
                          icon: Icons.reviews_outlined,
                          content: _buildReviewsList(),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          child: _buildSection(
                            title: "ثبت نظر",
                            icon: Icons.edit_note_rounded,
                            content: AddReviewFormWidget(
                              roomsFuture: _roomsFuture,
                              onSubmit: _handleReviewSubmission,
                              hotelId: widget.hotel.id.toString(),
                              currentToken: _currentToken,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAppBarButton({required IconData icon, Color? color, required VoidCallback onPressed}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CircleAvatar(
        backgroundColor: Colors.black.withOpacity(0.4),
        child: IconButton(
          icon: Icon(icon, color: color ?? Colors.white, size: 20),
          onPressed: onPressed,
        ),
      ),
    );
  }

  Widget _buildHotelHeader(BuildContext context, Hotel hotel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hotel.name,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.location_on, size: 18, color: kPrimaryColor),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                hotel.address,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black54),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 22),
            const SizedBox(width: 6),
            Text(
              hotel.rating.toStringAsFixed(1),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 4),
            Text(
              "(${intl.NumberFormat.compact(locale: "fa").format(hotel.reviewCount)} نظر)",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection({required String title, required IconData icon, required Widget content}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                Icon(icon, color: kPrimaryColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  Widget _buildAmenitiesHorizontalList(List<Amenity> amenities) {
    if (amenities.isEmpty) {
      return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text("امکاناتی برای این هتل ثبت نشده است.", style: TextStyle(color: Colors.grey[600]))
      );
    }
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        itemCount: amenities.length,
        itemBuilder: (context, index) {
          return AmenityItemWidget(amenity: amenities[index]);
        },
        separatorBuilder: (context, index) => const SizedBox(width: 16),
      ),
    );
  }

  Widget _buildRoomsList() {
    return FutureBuilder<List<Room>>(
      future: _roomsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: LinearProgressIndicator(color: kPrimaryColor, minHeight: 2));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("در حال حاضر اتاقی برای رزرو موجود نیست."));
        }
        final rooms = snapshot.data!;
        return SizedBox(
          height: 390,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            clipBehavior: Clip.none,
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              return SizedBox(
                width: 320,
                child: RoomCardWidget(
                  room: rooms[index],
                  onBookNow: () => _showBookingDateRangePicker(context, rooms[index]),
                ),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(width: 16),
          ),
        );
      },
    );
  }

  Widget _buildReviewsList() {
    return FutureBuilder<List<Review>>(
      future: _reviewsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: LinearProgressIndicator(color: kPrimaryColor, minHeight: 2));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("هنوز نظری برای این هتل ثبت نشده است."));
        }
        final reviews = snapshot.data!;
        return SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            clipBehavior: Clip.none,
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              return SizedBox(
                width: 350,
                child: ReviewCardWidget(review: reviews[index]),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(width: 16),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(String message, [Object? error]) {
    print("Error details: $error");
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            Text(message, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            if (error != null) Text(error.toString(), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text("تلاش مجدد"),
              onPressed: () {
                if (_currentToken != null) {
                  // اگر در آینده نیاز به رفرش داشتید، باید منطق آن را اینجا پیاده کنید
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
            )
          ],
        ),
      ),
    );
  }
}