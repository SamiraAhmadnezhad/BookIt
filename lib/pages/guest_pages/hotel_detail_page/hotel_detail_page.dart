import 'package:bookit/pages/guest_pages/hotel_detail_page/utils/constants.dart';
import 'package:bookit/pages/guest_pages/hotel_detail_page/widgets/add_review_form_widget.dart';
import 'package:bookit/pages/guest_pages/hotel_detail_page/widgets/amenity_item_widget.dart';
import 'package:bookit/pages/guest_pages/hotel_detail_page/widgets/hotel_image_widget.dart';
import 'package:bookit/pages/guest_pages/hotel_detail_page/widgets/review_card_widget.dart';
import 'package:bookit/pages/guest_pages/hotel_detail_page/widgets/room_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../authentication_page/auth_service.dart';
import '../search_page/widgets/custom_shamsi_date_picker.dart';

import 'data/models/amenity_model.dart';
import 'data/models/hotel_details_model.dart';
import 'data/models/review_model.dart';
import 'data/models/room_model.dart';
import 'data/services/hotel_api_service.dart';


class HotelDetailsPage extends StatefulWidget {
  final String hotelId;

  const HotelDetailsPage({Key? key, required this.hotelId}) : super(key: key);

  @override
  _HotelDetailsPageState createState() => _HotelDetailsPageState();
}

class _HotelDetailsPageState extends State<HotelDetailsPage> {
  final HotelApiService _apiService = HotelApiService();
  Future<HotelDetails>? _hotelDetailsFuture;
  Future<List<Room>>? _roomsFuture;
  Future<List<Review>>? _reviewsFuture;

  bool _isFavorite = false; // Initial state, will be updated from API
  String? _currentToken; // Store token once fetched

  @override
  void initState() {
    super.initState();
    // It's better to fetch the token once and store it.
    // Accessing Provider in initState needs listen:false
    final authService = Provider.of<AuthService>(context, listen: false);
    _currentToken = authService.token;

    if (_currentToken != null) {
      print("توکن فعلی در HotelDetailsPage: $_currentToken");
      _loadDataAndFavoriteStatus(_currentToken!);
    } else {
      print("کاربر لاگین نکرده یا توکن موجود نیست.");
      // Handle no token scenario, e.g., show error or redirect
      // For now, we'll let FutureBuilders show errors if data can't load.
    }
  }

  void _loadDataAndFavoriteStatus(String token) {
    _hotelDetailsFuture = _apiService.fetchHotelDetails(widget.hotelId, token).then((hotel) {
      if (mounted) {
        setState(() {
          _isFavorite = hotel.isCurrentlyFavorite;
        });
      }
      return hotel;
    });
    _roomsFuture = _apiService.fetchHotelRooms(widget.hotelId, token);
    _reviewsFuture = _apiService.fetchHotelReviews(widget.hotelId, token);
  }

  Future<void> _toggleFavorite() async {
    if (_currentToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ابتدا وارد شوید.", textDirection: TextDirection.rtl)));
      return;
    }
    bool newFavoriteState = !_isFavorite;
    // Optimistically update UI
    setState(() {
      _isFavorite = newFavoriteState;
    });

    try {
      bool success = await _apiService.toggleFavoriteHotel(widget.hotelId, newFavoriteState, _currentToken!);
      if (!success && mounted) {
        // Revert if API call failed
        setState(() {
          _isFavorite = !newFavoriteState;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("خطا در به‌روزرسانی علاقه‌مندی", textDirection: TextDirection.rtl)));
      }
    } catch (e) {
      if (mounted) {
        // Revert on error
        setState(() {
          _isFavorite = !newFavoriteState;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("خطا در ارتباط با سرور", textDirection: TextDirection.rtl)));
      }
    }
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
    if (_currentToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ابتدا وارد شوید.", textDirection: TextDirection.rtl)));
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: kPrimaryColor),
                SizedBox(width: 20),
                Text("در حال ارسال نظر...", textDirection: TextDirection.rtl),
              ],
            ),
          ),
        );
      },
    );

    bool success = await _apiService.submitReview(widget.hotelId, reviewData, _currentToken!);

    if (mounted) Navigator.pop(context); // Close loading dialog

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("نظر شما با موفقیت ثبت شد.", textDirection: TextDirection.rtl)),
      );
      // Refresh reviews list
      setState(() {
        _reviewsFuture = _apiService.fetchHotelReviews(widget.hotelId, _currentToken!);
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("خطا در ثبت نظر. لطفا دوباره تلاش کنید.", textDirection: TextDirection.rtl)),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: kLightGrayColor,
        body: FutureBuilder<HotelDetails>(
          future: _hotelDetailsFuture,
          builder: (context, snapshot) {
            if (_currentToken == null && snapshot.connectionState != ConnectionState.waiting) { // Check if token was issue initially
              return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("برای مشاهده اطلاعات هتل، ابتدا وارد شوید.", textDirection: TextDirection.rtl),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          // Example: Navigate to login or trigger auth flow
                          // Navigator.of(context).pushReplacementNamed('/login');
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("منتقل کردن به صفحه لاگین...", textDirection: TextDirection.rtl)));
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
                        child: const Text("ورود", style: TextStyle(color: Colors.white)),
                      )
                    ],
                  )
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("خطا در بارگذاری اطلاعات هتل.", textDirection: TextDirection.rtl),
                    ElevatedButton(
                        onPressed: () {
                          if (_currentToken != null) {
                            _loadDataAndFavoriteStatus(_currentToken!);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ابتدا وارد شوید.", textDirection: TextDirection.rtl)));
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
                        child: const Text("تلاش مجدد", textDirection: TextDirection.rtl, style: TextStyle(color: Colors.white)))
                  ],
                ),
              );
            }

            final hotel = snapshot.data!;
            double screenWidth = MediaQuery.of(context).size.width;
            double imageHeight = screenWidth * 0.7;

            return CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(
                  expandedHeight: imageHeight,
                  pinned: true,
                  floating: false,
                  snap: false,
                  backgroundColor: kPrimaryColor,
                  elevation: 2,
                  automaticallyImplyLeading: false, // We use a custom leading
                  flexibleSpace: FlexibleSpaceBar(
                    background: HotelImageWidget(imageUrl: hotel.imageUrl, rating: hotel.rating),
                    stretchModes: const [StretchMode.zoomBackground, StretchMode.fadeTitle],
                  ),
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Material(
                      color: Colors.black.withOpacity(0.4),
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => Navigator.of(context).pop(),
                        child: const Icon(Icons.arrow_forward, color: Colors.white, size: 22),
                      ),
                    ),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Material(
                        color: Colors.black.withOpacity(0.4),
                        shape: const CircleBorder(),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: _toggleFavorite,
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Icon(
                              _isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: _isFavorite ? Colors.redAccent : Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                SliverToBoxAdapter(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: kScaffoldContentColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(kTopContentCornerRadius),
                        topRight: Radius.circular(kTopContentCornerRadius),
                      ),
                    ),
                    padding: const EdgeInsets.only(
                      top: 20.0,
                      left: 16.0,
                      right: 16.0,
                      bottom: 16.0, // Ensure bottom padding for scroll content
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHotelHeader(context, hotel.name, hotel.address),
                        const SizedBox(height: 8),
                        _buildRating(context, hotel.rating, hotel.reviewCount),
                        const SizedBox(height: 20),
                        _buildSectionTitle(context, "درباره هتل (${hotel.name})", icon: Icons.description_outlined),
                        const SizedBox(height: 8),
                        Text(hotel.description, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black87, height: 1.6, fontSize: 13)),
                        const SizedBox(height: 24),
                        _buildSectionTitle(context, "امکانات و ویژگی ها", icon: Icons.checklist_rtl_outlined),
                        const SizedBox(height: 12),
                        _buildAmenitiesGrid(hotel.amenities),
                        const SizedBox(height: 24),
                        _buildSectionTitle(context, "لیست اتاق ها", icon: Icons.king_bed_outlined),
                        const SizedBox(height: 8),
                        _buildRoomsList(),
                        const SizedBox(height: 24),
                        _buildSectionTitle(context, "نظرات", icon: Icons.rate_review_outlined),
                        const SizedBox(height: 8),
                        _buildReviewsList(),
                        const SizedBox(height: 24),
                        _buildSectionTitle(context, "ثبت نظر", icon: Icons.edit_note_outlined, secondaryIcon: Icons.info_outline),
                        const SizedBox(height: 8),
                        AddReviewFormWidget(
                          roomsFuture: _roomsFuture,
                          onSubmit: _handleReviewSubmission,
                          hotelId: widget.hotelId,
                          currentToken: _currentToken,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHotelHeader(BuildContext context, String name, String address) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 20),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.location_on_outlined, size: 18, color: kPrimaryColor),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                address,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54, fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRating(BuildContext context, double rating, int reviewCount) {
    return Row(
      children: [
        for (int i = 0; i < 5; i++)
          Icon(
            i < rating.floor() ? Icons.star : (i < rating && (rating - i) >= 0.25 ? Icons.star_half : Icons.star_border_outlined),
            color: kPrimaryColor,
            size: 20,
          ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            "${rating.toStringAsFixed(1)} (${intl.NumberFormat("#,###", "en_US").format(reviewCount)} نظر)",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, {IconData? icon, IconData? secondaryIcon}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null)
                Container(
                  width: 28,
                  height: 28,
                  margin: const EdgeInsets.only(left: 10),
                  child: Icon(
                    icon,
                    size: 22,
                    color: kPrimaryColor,
                  ),
                ),
              Flexible(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: Colors.black87, fontSize: 17),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        if (secondaryIcon != null)
          Padding(
            padding: const EdgeInsets.only(left:4.0),
            child: Icon(
              secondaryIcon,
              size: 20,
              color: kPrimaryColor,
            ),
          ),
      ],
    );
  }

  Widget _buildAmenitiesGrid(List<Amenity> amenities) {
    if (amenities.isEmpty) {
      return Text("امکاناتی برای نمایش وجود ندارد.", style: TextStyle(color: Colors.grey[600]), textDirection: TextDirection.rtl);
    }
    return Container(
      alignment: Alignment.centerRight,
      child: Wrap(
        spacing: 10.0,
        runSpacing: 10.0,
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.start,
        children: amenities.map((amenity) => AmenityItemWidget(amenity: amenity)).toList(),
      ),
    );
  }

  Widget _buildRoomsList() {
    return FutureBuilder<List<Room>>(
      future: _roomsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("اتاقی برای نمایش وجود ندارد.", textDirection: TextDirection.rtl));
        }
        final rooms = snapshot.data!;
        return ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: rooms.length,
          itemBuilder: (context, index) => RoomCardWidget(
            room: rooms[index],
            onBookNow: () => _showBookingDateRangePicker(context, rooms[index]),
          ),
          separatorBuilder: (context, index) => const SizedBox(height: 12),
        );
      },
    );
  }

  Widget _buildReviewsList() {
    return FutureBuilder<List<Review>>(
      future: _reviewsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: kPrimaryColor));
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("نظری برای نمایش وجود ندارد.", textDirection: TextDirection.rtl));
        }
        final reviews = snapshot.data!;
        return ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: reviews.length,
          itemBuilder: (context, index) => ReviewCardWidget(review: reviews[index]),
          separatorBuilder: (context, index) => const SizedBox(height: 0), // No space between review cards in this design
        );
      },
    );
  }
}