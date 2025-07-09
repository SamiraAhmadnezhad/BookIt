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
import '../reservation_detail_page/reservation_api_service.dart';
import '../reservation_detail_page/reservation_detail_page.dart';
import '../search_page/widgets/custom_shamsi_date_picker.dart';
import 'data/models/amenity_model.dart';
import 'data/models/review_model.dart';
import 'data/models/room_model.dart';
import 'data/services/hotel_api_service.dart';

class HotelDetailsPage extends StatefulWidget {
  final Hotel hotel;

  const HotelDetailsPage({Key? key, required this.hotel}) : super(key: key);

  @override
  _HotelDetailsPageState createState() => _HotelDetailsPageState();
}

class _HotelDetailsPageState extends State<HotelDetailsPage> {
  final HotelApiService _apiService = HotelApiService();
  final ReservationApiService _reservationApiService = ReservationApiService();

  Future<List<Room>>? _roomsFuture;
  Future<List<Review>>? _reviewsFuture;

  bool _isFavorite = false;
  String? _currentToken;

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AuthService>(context, listen: false);
    _currentToken = authService.token;

    _isFavorite = widget.hotel.isCurrentlyFavorite;

    if (_currentToken != null) {
      _roomsFuture = _apiService.fetchHotelRooms(widget.hotel.id.toString(), _currentToken!);
      _reviewsFuture = _apiService.fetchHotelReviews(widget.hotel.id.toString(), _currentToken!);
    }
  }

  Future<void> _toggleFavorite() async {
    if (_currentToken == null) return;
    setState(() => _isFavorite = !_isFavorite);
    bool success = await _apiService.toggleFavoriteHotel(
        widget.hotel.id.toString(), _isFavorite, _currentToken!);
    if (!success && mounted) {
      setState(() => _isFavorite = !_isFavorite);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('خطا در تغییر وضعیت علاقمندی'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _showBookingDateRangePicker(BuildContext context, Room room) async {
    Jalali? startDate;
    Jalali? endDate;
    final Jalali today = Jalali.now();

    startDate = await showCustomShamsiDatePickerDialog(
      context,
      initialDate: today,
      firstDate: today,
      lastDate: today.addDays(365),
      titleText: "تاریخ ورود را انتخاب کنید",
    );

    if (startDate == null || !mounted) return;

    final Jalali firstDateForEndDate = startDate.addDays(1);
    endDate = await showCustomShamsiDatePickerDialog(
      context,
      initialDate: firstDateForEndDate,
      firstDate: firstDateForEndDate,
      lastDate: firstDateForEndDate.addDays(90),
      titleText: "تاریخ خروج را انتخاب کنید",
    );

    if (endDate == null || !mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: kPrimaryColor)),
    );

    final bool isRoomLocked = await _reservationApiService.lockRoom(
      hotelId: widget.hotel.id.toString(),
      roomNumbers: [room.roomNumber.toString()],
      token: _currentToken!,
    );

    if (!mounted) return;
    Navigator.pop(context);

    if (isRoomLocked) {
      final DateTime checkInDateTime = startDate.toDateTime();
      final DateTime checkOutDateTime = endDate.toDateTime();
      final int numberOfNights = checkOutDateTime.difference(checkInDateTime).inDays;
      final double totalPrice = room.pricePerNight * (numberOfNights > 0 ? numberOfNights : 1);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReservationDetailPage(
            hotelId: widget.hotel.id.toString(),
            hotelName: widget.hotel.name,
            hotelAddress: widget.hotel.address,
            hotelRating: widget.hotel.rating,
            hotelImageUrl: widget.hotel.imageUrl,
            roomNumber: room.roomNumber.toString(),
            roomInfo: room.name,
            numberOfAdults: room.capacity,
            totalPrice: totalPrice,
            checkInDate: checkInDateTime,
            checkOutDate: checkOutDateTime,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "متاسفانه این اتاق لحظاتی پیش رزرو شد. لطفا اتاق دیگری را انتخاب کنید.",
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _handleReviewSubmission(Review reviewData) async {
    if (_currentToken == null) return;

    bool success = await _apiService.submitReview(widget.hotel.id.toString(), reviewData, _currentToken!);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('نظر شما با موفقیت ثبت شد.'), backgroundColor: Colors.green),
      );
      setState(() {
        _reviewsFuture = _apiService.fetchHotelReviews(widget.hotel.id.toString(), _currentToken!);
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('خطا در ثبت نظر.'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: kPageBackground,
        body: _currentToken == null
            ? _buildErrorState("برای مشاهده اطلاعات، ابتدا وارد شوید.")
            : _buildHotelContentView(widget.hotel),
      ),
    );
  }

  Widget _buildHotelContentView(Hotel hotel) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          backgroundColor: kPrimaryColor,
          expandedHeight: 250,
          pinned: true,
          stretch: true,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          leading: _buildAppBarButton(
            icon: Icons.arrow_back,
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
            background: HotelImageWidget(imageUrl: hotel.imageUrl, rating: hotel.rating),
            stretchModes: const [StretchMode.zoomBackground],
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildHotelHeaderCard(context, hotel),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: "درباره هتل",
                icon: Icons.info_outline_rounded,
                content: Text(
                  hotel.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
                    height: 1.7,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: "امکانات و ویژگی ها",
                icon: Icons.local_offer_outlined,
                content: _buildAmenitiesHorizontalList(hotel.amenities),
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: "اتاق های موجود",
                icon: Icons.king_bed_outlined,
                content: _buildRoomsList(),
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: "نظرات کاربران",
                icon: Icons.reviews_outlined,
                content: _buildReviewsList(),
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: "ثبت نظر",
                icon: Icons.edit_note_rounded,
                content: AddReviewFormWidget(
                  roomsFuture: _roomsFuture,
                  onSubmit: _handleReviewSubmission,
                  hotelId: widget.hotel.id.toString(),
                  currentToken: _currentToken,
                ),
              ),
            ]),
          ),
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
          icon: Icon(icon, color: color ?? Colors.white, size: 22),
          onPressed: onPressed,
        ),
      ),
    );
  }

  Widget _buildHotelHeaderCard(BuildContext context, Hotel hotel) {
    return Card(
      elevation: 2,
      shadowColor: Colors.grey.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              hotel.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: kPrimaryColor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    hotel.address,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 6),
                Text(
                  hotel.rating.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 4),
                Text(
                  "(${intl.NumberFormat.compact(locale: "fa").format(hotel.reviewCount)} نظر)",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required Widget content}) {
    return Card(
      elevation: 2,
      shadowColor: Colors.grey.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: kPrimaryColor, size: 22),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildAmenitiesHorizontalList(List<Amenity> amenities) {
    if (amenities.isEmpty) {
      return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text("امکاناتی برای این هتل ثبت نشده است.", style: TextStyle(color: Colors.grey[600])));
    }
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
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
          return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator(color: kPrimaryColor)));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: Text("در حال حاضر اتاقی برای رزرو موجود نیست.")));
        }
        final rooms = snapshot.data!;
        return SizedBox(
          height: 350,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
            clipBehavior: Clip.none,
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              return SizedBox(
                width: 280,
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
          return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator(color: kPrimaryColor)));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: Text("هنوز نظری برای این هتل ثبت نشده است.")));
        }
        final reviews = snapshot.data!;
        return SizedBox(
          height: 170,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
            clipBehavior: Clip.none,
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              return SizedBox(
                width: 320,
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            Text(message, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text("تلاش مجدد"),
              onPressed: () {
                if (_currentToken != null) {
                  setState(() {
                    _roomsFuture = _apiService.fetchHotelRooms(widget.hotel.id.toString(), _currentToken!);
                    _reviewsFuture = _apiService.fetchHotelReviews(widget.hotel.id.toString(), _currentToken!);
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
            )
          ],
        ),
      ),
    );
  }
}