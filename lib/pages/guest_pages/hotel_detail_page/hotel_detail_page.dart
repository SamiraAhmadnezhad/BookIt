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
import '../search_page/widgets/custom_shamsi_date_picker.dart';
// مسیر import های رزرو را بر اساس ساختار پروژه خود تنظیم کنید
import '../reservation_detail_page/reservation_api_service.dart';
import '../reservation_detail_page/reservation_detail_page.dart';

import 'data/models/amenity_model.dart';
import 'data/models/hotel_details_model.dart';
import 'data/models/review_model.dart';
// این import باید به مدل Room مخصوص این صفحه اشاره کند
import 'data/models/room_model.dart';
import 'data/services/hotel_api_service.dart';

class HotelDetailsPage extends StatefulWidget {
  final String hotelId;

  const HotelDetailsPage({Key? key, required this.hotelId}) : super(key: key);

  @override
  _HotelDetailsPageState createState() => _HotelDetailsPageState();
}

class _HotelDetailsPageState extends State<HotelDetailsPage> with TickerProviderStateMixin {
  // ... (تمام متغیرها و متدهای منطقی شما بدون تغییر باقی می‌مانند) ...
  final HotelApiService _apiService = HotelApiService();
  final ReservationApiService _reservationApiService = ReservationApiService();

  Future<HotelDetails>? _hotelDetailsFuture;
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

    if (_currentToken != null) {
      _loadDataAndFavoriteStatus(_currentToken!);
    } else {
      print("کاربر لاگین نکرده یا توکن موجود نیست.");

    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadDataAndFavoriteStatus(String token) {
    _hotelDetailsFuture = _apiService.fetchHotelDetails(widget.hotelId, token).then((hotel) {
      if (mounted) {
        setState(() {
          _isFavorite = hotel.isCurrentlyFavorite;
        });
        _animationController.forward();
      }
      return hotel;
    });
    // این متد باید لیستی از مدل Room مخصوص این صفحه را برگرداند
    _roomsFuture = _apiService.fetchHotelRooms(widget.hotelId, token);
    _reviewsFuture = _apiService.fetchHotelReviews(widget.hotelId, token);
  }

  Future<void> _toggleFavorite() async {
    if (_currentToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ابتدا وارد شوید.")));
      return;
    }
    bool newFavoriteState = !_isFavorite;
    setState(() {
      _isFavorite = newFavoriteState;
    });

    try {
      bool success = await _apiService.toggleFavoriteHotel(widget.hotelId, newFavoriteState, _currentToken!);
      if (!success && mounted) {
        setState(() => _isFavorite = !newFavoriteState);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("خطا در به‌روزرسانی علاقه‌مندی")));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isFavorite = !newFavoriteState);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("خطا در ارتباط با سرور")));
      }
    }
  }

  // === متد کاملاً اصلاح شده بر اساس مدل Room این صفحه ===
  Future<void> _showBookingDateRangePicker(BuildContext context, Room room) async {
    if (_currentToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("برای رزرو اتاق، ابتدا وارد شوید.")));
      return;
    }

    final Jalali today = Jalali.now();
    final Jalali? checkInDateJalali = await showCustomShamsiDatePickerDialog(context, initialDate: today.addDays(1), firstDate: today, lastDate: today.addDays(365), titleText: "تاریخ ورود را انتخاب کنید");
    if (checkInDateJalali == null || !mounted) return;

    final Jalali? checkOutDateJalali = await showCustomShamsiDatePickerDialog(context, initialDate: checkInDateJalali.addDays(1), firstDate: checkInDateJalali.addDays(1), lastDate: today.addDays(365), titleText: "تاریخ خروج را انتخاب کنید");
    if (checkOutDateJalali == null || !mounted) return;

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: kPrimaryColor),
                const SizedBox(width: 20),
                const Text("در حال قفل کردن اتاق..."),
              ],
            ),
          ),
        )
    );

    // استفاده از room.id به عنوان شماره اتاق برای API
    final bool isLocked = await _reservationApiService.lockRoom(
      hotelId: widget.hotelId,
      roomNumbers: [room.roomNumber],
      token: _currentToken!,
    );

    if (mounted) Navigator.pop(context);

    if (isLocked) {
      final hotelDetails = await _hotelDetailsFuture;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReservationDetailPage(
            hotelId: widget.hotelId,
            hotelName: hotelDetails?.name ?? 'نام هتل',
            hotelAddress: hotelDetails?.address ?? 'آدرس نامشخص',
            hotelRating: hotelDetails?.rating ?? 0.0,
            hotelImageUrl: hotelDetails?.imageUrl ?? '',
            roomNumber: room.roomNumber,
            roomInfo: room.name,
            checkInDate: checkInDateJalali.toDateTime(),
            checkOutDate: checkOutDateJalali.toDateTime(),
            totalPrice: room.pricePerNight,
            numberOfAdults: room.capacity,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("خطا: این اتاق در حال حاضر توسط شخص دیگری رزرو شده یا در دسترس نیست."),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }


  Future<void> _handleReviewSubmission(Review reviewData) async {
    if (_currentToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ابتدا وارد شوید.")));
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: kPrimaryColor),
                const SizedBox(width: 20),
                const Text("در حال ارسال نظر..."),
              ],
            ),
          ),
        );
      },
    );

    bool success = await _apiService.submitReview(widget.hotelId, reviewData, _currentToken!);

    if (mounted) Navigator.pop(context);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("نظر شما با موفقیت ثبت شد.")));
      setState(() {
        _reviewsFuture = _apiService.fetchHotelReviews(widget.hotelId, _currentToken!);
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("خطا در ثبت نظر. لطفا دوباره تلاش کنید.")));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white, // پس‌زمینه اصلی صفحه
        body: FutureBuilder<HotelDetails>(
          future: _hotelDetailsFuture,
          builder: (context, snapshot) {
            if (_currentToken == null && snapshot.connectionState != ConnectionState.waiting) {
              return _buildErrorState("برای مشاهده اطلاعات هتل، ابتدا وارد شوید.");
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return _buildErrorState("خطا در بارگذاری اطلاعات هتل.", snapshot.error);
            }
            final hotel = snapshot.data!;

            return _buildHotelContentView(hotel);
          },
        ),
      ),
    );
  }

  // ====================== شروع اصلاحیه اصلی در ساختار UI ======================
  Widget _buildHotelContentView(HotelDetails hotel) {
    return Stack(
      children: [
        // پس‌زمینه سفید برای کل صفحه
        Container(color: Colors.white),

        CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              backgroundColor: kPrimaryColor,
              expandedHeight: 280,
              pinned: true,
              stretch: true, // AppBar شفاف می‌شود
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
                  borderRadius: BorderRadius.vertical(top: Radius.circular(50.0)),
                ),
                transform: Matrix4.translationValues(0.0, -20.0, 0.0),
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) => FadeTransition(opacity: _animationController, child: child),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                              hotelId: widget.hotelId,
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
  // ====================== پایان اصلاحیه اصلی در ساختار UI ======================

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

  Widget _buildHotelHeader(BuildContext context, HotelDetails hotel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hotel.name,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 12),
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
            padding: const EdgeInsets.symmetric(horizontal: 20.0), // پدینگ از کناره‌ها
            clipBehavior: Clip.none, // اجازه می‌دهد سایه کارت‌ها بیرون بزند
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
            padding: const EdgeInsets.symmetric(horizontal: 20.0), // پدینگ از کناره‌ها
            clipBehavior: Clip.none, // اجازه می‌دهد سایه کارت‌ها بیرون بزند
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
                  _loadDataAndFavoriteStatus(_currentToken!);
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