import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:shamsi_date/shamsi_date.dart';

import '../search_page/widgets/custom_shamsi_date_picker.dart';
class HotelDetails {
  final String id;
  final String name;
  final String address;
  final String imageUrl;
  final double rating;
  final bool isCurrentlyFavorite;
  final int reviewCount;
  final String description;
  final List<Amenity> amenities;

  HotelDetails({
    required this.id,
    required this.name,
    required this.address,
    required this.imageUrl,
    required this.rating,
    required this.isCurrentlyFavorite,
    required this.reviewCount,
    required this.description,
    required this.amenities,
  });
}

class Amenity {
  final String name;
  final IconData icon;

  Amenity({required this.name, required this.icon});
}

class Room {
  final String id;
  final String name;
  final String imageUrl;
  final int capacity;
  final bool hasBreakfast;
  final bool hasLunch;
  final bool hasDinner;
  final double pricePerNight;
  final double rating;

  Room({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.capacity,
    this.hasBreakfast = false,
    this.hasLunch = false,
    this.hasDinner = false,
    required this.pricePerNight,
    required this.rating,
  });

  String get mealInfo {
    List<String> meals = [];
    if (hasBreakfast) meals.add("صبحانه");
    if (hasLunch) meals.add("ناهار");
    if (hasDinner) meals.add("شام");
    if (meals.isEmpty) return "بدون وعده غذایی";
    return meals.join(" / ");
  }
}

class Review {
  final String userId;
  final String userName;
  final String date;
  final String positiveFeedback;
  final String negativeFeedback;
  final double rating;

  Review({
    required this.userId,
    required this.userName,
    required this.date,
    required this.positiveFeedback,
    required this.negativeFeedback,
    required this.rating,
  });
}


// --- API Service Stub ---
// ... (ApiService is unchanged from the previous version) ...
class ApiService {
  Future<HotelDetails> fetchHotelDetails(String hotelId) async {
    await Future.delayed(const Duration(seconds: 1));
    bool fetchedIsFavorite = false;
    return HotelDetails(
      id: hotelId,
      name: "نام هتل در حالت طولانی ..",
      address: "آدرس در حالت طولانی",
      imageUrl: "https://picsum.photos/seed/hotelE/1200/800",
      rating: 4.5,
      reviewCount: 120,
      description:
      "توضیحات کامل هتل، به عنوان مثال: هتل سه ستاره رویال ششم واقع در خیابان فلسطین در سال ۱۳۹۵ فعالیت خود را آغاز نمود. ساختمان هتل در ۵ طبقه بنا و دارای ۴۱ باب اتاق و سوئیت اقامتی با امکانات رفاهی مناسب می‌باشد و همچنین دسترسی آسانی به خلیج نیلگون فارس و مراکز خرید جزیره از جمله بازار ستاره دارد. هتل رویال قشم با پرسنلی مجرب آماده پذیرایی از شما میهمانان گرامی می‌باشد.",
      amenities: [
        Amenity(name: "WiFi رایگان", icon: Icons.wifi),
        Amenity(name: "پارکینگ", icon: Icons.local_parking_outlined),
        Amenity(name: "رستوران", icon: Icons.restaurant_outlined),
      ],
      isCurrentlyFavorite: fetchedIsFavorite,
    );
  }

  Future<List<Room>> fetchHotelRooms(String hotelId) async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      Room(
        id: "room1",
        name: "اسم اتاق در حالت طولانی...",
        imageUrl: "https://picsum.photos/seed/roomE1/400/300",
        capacity: 5,
        hasBreakfast: true,
        hasDinner: true,
        pricePerNight: 3200000,
        rating: 4.5,
      ),
      Room(
        id: "room2",
        name: "سوئیت مجلل با نمای شهر",
        imageUrl: "https://picsum.photos/seed/roomE2/400/300",
        capacity: 3,
        hasBreakfast: true,
        hasLunch: true,
        pricePerNight: 4500000,
        rating: 4.7,
      ),
    ];
  }

  Future<List<Review>> fetchHotelReviews(String hotelId) async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      Review(
        userId: "user1",
        userName: "اسم اشخاص اتاق 2 خوابه 5 تخته",
        date: "تاریخ نظردهی",
        positiveFeedback: "نکات مثبت نظردهی",
        negativeFeedback: "نکات منفی نظردهی",
        rating: 4.5,
      ),
    ];
  }

  Future<bool> submitReview(String hotelId, Review reviewData) async {
    print("Submitting review for hotel $hotelId: ${reviewData.userName}");
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  Future<bool> toggleFavoriteHotel(String hotelId, bool newFavoriteState) async {
    print("Toggling favorite for hotel $hotelId to ${newFavoriteState}");
    await Future.delayed(const Duration(milliseconds: 500));
    return newFavoriteState;
  }
}

// --- Hotel Details Page Widget ---
class HotelDetailsPage extends StatefulWidget {
  final String hotelId;
  static const Color primaryColor = Color(0xFF542545);

  const HotelDetailsPage({Key? key, required this.hotelId}) : super(key: key);

  @override
  _HotelDetailsPageState createState() => _HotelDetailsPageState();
}

class _HotelDetailsPageState extends State<HotelDetailsPage> {
  final ApiService _apiService = ApiService();
  Future<HotelDetails>? _hotelDetailsFuture;
  Future<List<Room>>? _roomsFuture;
  Future<List<Review>>? _reviewsFuture;

  double _newReviewRating = 3.0;
  bool _isFavorite = false;

  Room? _selectedRoomForReview;
  List<TextEditingController> _positiveFeedbackControllers = [TextEditingController()];
  List<TextEditingController> _negativeFeedbackControllers = [TextEditingController()];

  // static const Color _primaryColor = Color(0xFF542545); // Defined in HotelDetailsPage
  static const Color _lightGrayColor = Color(0xFFF5F5F5);
  static const Color _scaffoldContentColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _loadDataAndFavoriteStatus();
  }

  void _loadDataAndFavoriteStatus() {
    // ... (unchanged)
    _hotelDetailsFuture = _apiService.fetchHotelDetails(widget.hotelId).then((hotel) {
      if (mounted) {
        setState(() {
          _isFavorite = hotel.isCurrentlyFavorite;
        });
      }
      return hotel;
    });
    _roomsFuture = _apiService.fetchHotelRooms(widget.hotelId);
    _reviewsFuture = _apiService.fetchHotelReviews(widget.hotelId);
  }

  Future<void> _toggleFavorite() async {
    // ... (unchanged)
    bool newFavoriteState = !_isFavorite;
    setState(() { _isFavorite = newFavoriteState; });
    try {
      bool success = await _apiService.toggleFavoriteHotel(widget.hotelId, newFavoriteState);
      if (!success && mounted) {
        setState(() { _isFavorite = !newFavoriteState; });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("خطا در به‌روزرسانی علاقه‌مندی", textDirection: TextDirection.rtl)));
      }
    } catch (e) {
      if (mounted) {
        setState(() { _isFavorite = !newFavoriteState; });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("خطا در ارتباط با سرور", textDirection: TextDirection.rtl)));
      }
    }
  }

  String _formatPrice(double price) {
    // ... (unchanged)
    final formatter = intl.NumberFormat("#,###", "fa_IR");
    return formatter.format(price);
  }

  @override
  void dispose() {
    // ... (unchanged)
    _positiveFeedbackControllers.forEach((controller) => controller.dispose());
    _negativeFeedbackControllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void _addPositiveFeedbackField() { setState(() {_positiveFeedbackControllers.add(TextEditingController());});}
  void _removePositiveFeedbackField(int index) { if (_positiveFeedbackControllers.length > 1) {setState(() {_positiveFeedbackControllers[index].dispose();_positiveFeedbackControllers.removeAt(index);});} else {_positiveFeedbackControllers[index].clear();}}
  void _addNegativeFeedbackField() { setState(() {_negativeFeedbackControllers.add(TextEditingController());});}
  void _removeNegativeFeedbackField(int index) { if (_negativeFeedbackControllers.length > 1) {setState(() {_negativeFeedbackControllers[index].dispose();_negativeFeedbackControllers.removeAt(index);});} else {_negativeFeedbackControllers[index].clear();}}

  Future<void> _showBookingDateRangePicker(BuildContext context, Room room) async {
    // ... (unchanged from previous correct version)
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
    // Ensure end date's last selectable date is not before its first selectable date
    final Jalali lastDateForEndDate = initialLastDate.compareTo(firstDateForEndDate) < 0
        ? firstDateForEndDate.addDays(30) // a fallback if initialLastDate is too early
        : initialLastDate;


    endDate = await showCustomShamsiDatePickerDialog(
      context,
      initialDate: firstDateForEndDate,
      firstDate: firstDateForEndDate,
      lastDate: lastDateForEndDate,
      titleText: "تاریخ خروج را انتخاب کنید",
    );

    if (endDate == null || !mounted) return;

    final String startDateFormatted = startDate.formatter.yyyy+startDate.formatter.mm+startDate.formatter.dd;
    final String endDateFormatted = endDate.formatter.yyyy+endDate.formatter.mm+endDate.formatter.dd;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "اتاق ${room.name} برای تاریخ ${startDateFormatted} تا ${endDateFormatted} انتخاب شد. ورود به صفحه رزرو...",
          textDirection: TextDirection.rtl,
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ... (build method with CustomScrollView is unchanged from the previous version)
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _lightGrayColor,
        body: FutureBuilder<HotelDetails>(
          future: _hotelDetailsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: HotelDetailsPage.primaryColor));
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("خطا در بارگذاری اطلاعات هتل.", textDirection: TextDirection.rtl),
                    ElevatedButton(
                        onPressed: _loadDataAndFavoriteStatus,
                        style: ElevatedButton.styleFrom(backgroundColor: HotelDetailsPage.primaryColor),
                        child: const Text("تلاش مجدد", textDirection: TextDirection.rtl, style: TextStyle(color: Colors.white)))
                  ],
                ),
              );
            }

            final hotel = snapshot.data!;
            double screenWidth = MediaQuery.of(context).size.width;
            double imageHeight = screenWidth * 0.7;
            double topContentCornerRadius = 25.0;

            return CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(
                  expandedHeight: imageHeight,
                  pinned: true,
                  floating: false,
                  snap: false,
                  backgroundColor: HotelDetailsPage.primaryColor,
                  elevation: 2,
                  automaticallyImplyLeading: false,
                  flexibleSpace: FlexibleSpaceBar(
                    background: _buildHotelImageWithOverlays(hotel.imageUrl, hotel.rating),
                    stretchModes: [StretchMode.zoomBackground, StretchMode.fadeTitle],
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
                        child: const Padding(
                          padding: EdgeInsets.all(0),
                          child: Icon(Icons.arrow_forward, color: Colors.white, size: 22),
                        ),
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
                    decoration: BoxDecoration(
                      color: _scaffoldContentColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(topContentCornerRadius),
                        topRight: Radius.circular(topContentCornerRadius),
                      ),
                    ),
                    padding: EdgeInsets.only(
                      top: 20.0,
                      left: 16.0,
                      right: 16.0,
                      bottom: 16.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHotelHeader(hotel.name, hotel.address),
                        const SizedBox(height: 8),
                        _buildRating(hotel.rating, hotel.reviewCount),
                        const SizedBox(height: 20),
                        _buildSectionTitle("درباره هتل (${hotel.name})"),
                        const SizedBox(height: 8),
                        Text(hotel.description, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black87, height: 1.6, fontSize: 13)),
                        const SizedBox(height: 24),
                        _buildSectionTitle("امکانات و ویژگی ها"),
                        const SizedBox(height: 12),
                        _buildAmenitiesGrid(hotel.amenities),
                        const SizedBox(height: 24),
                        _buildSectionTitle("لیست اتاق ها"),
                        const SizedBox(height: 8),
                        _buildRoomsList(),
                        const SizedBox(height: 24),
                        _buildSectionTitle("نظرات"),
                        const SizedBox(height: 8),
                        _buildReviewsList(),
                        const SizedBox(height: 24),
                        _buildSectionTitle("ثبت نظر"),
                        const SizedBox(height: 8),
                        _buildAddReviewForm(),
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

  Widget _buildHotelImageWithOverlays(String imageUrl, double rating) { /* ... unchanged ... */
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(25),
            bottomRight: Radius.circular(25),
          ),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: _lightGrayColor,
              child: Icon(Icons.broken_image, size: 60, color: HotelDetailsPage.primaryColor.withOpacity(0.7)),
            ),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: _lightGrayColor,
                child: Center(
                  child: CircularProgressIndicator(
                    color: HotelDetailsPage.primaryColor,
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
          ),
        ),
        Positioned(
          bottom: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  rating.toStringAsFixed(1),
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.thumb_up,
                  color: HotelDetailsPage.primaryColor,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildHotelHeader(String name, String address) { /* ... unchanged ... */
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
            Icon(Icons.location_on_outlined, size: 18, color: HotelDetailsPage.primaryColor),
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
  Widget _buildRating(double rating, int reviewCount) { /* ... unchanged ... */
    return Row(
      children: [
        for (int i = 0; i < 5; i++)
          Icon(
            i < rating.floor() ? Icons.star : (i < rating && (rating - i) >= 0.25 ? Icons.star_half : Icons.star_border_outlined),
            color: HotelDetailsPage.primaryColor,
            size: 20,
          ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            "${rating.toStringAsFixed(1)} (${intl.NumberFormat("#,###", "fa_IR").format(reviewCount)} نظر)",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
  Widget _buildSectionTitle(String title) { /* ... unchanged ... */
    IconData? mainIcon;
    IconData? secondaryIcon;
    if (title.startsWith("درباره هتل")) {
      mainIcon = Icons.description_outlined;
    } else if (title == "امکانات و ویژگی ها") {
      mainIcon = Icons.checklist_rtl_outlined;
    } else if (title == "لیست اتاق ها") {
      mainIcon = Icons.king_bed_outlined;
    } else if (title == "نظرات") {
      mainIcon = Icons.rate_review_outlined;
    } else if (title == "ثبت نظر") {
      mainIcon = Icons.edit_note_outlined;
      secondaryIcon = Icons.info_outline;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (mainIcon != null)
                Container(
                  width: 28,
                  height: 28,
                  margin: const EdgeInsets.only(left: 10),
                  child: Icon(
                    mainIcon,
                    size: 22,
                    color: HotelDetailsPage.primaryColor,
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
              color: HotelDetailsPage.primaryColor,
            ),
          ),
      ],
    );
  }
  Widget _buildAmenitiesGrid(List<Amenity> amenities) { /* ... unchanged ... */
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
        children: amenities.map((amenity) {
          return Container(
            width: (MediaQuery.of(context).size.width - 32 - 30) / 4,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _lightGrayColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(amenity.icon, size: 26, color: HotelDetailsPage.primaryColor.withOpacity(0.8)),
                ),
                const SizedBox(height: 5),
                Text(
                  amenity.name,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54, fontSize: 10.5, height: 1.3),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRoomsList() {
    // ... (unchanged from previous version)
    return FutureBuilder<List<Room>>(
      future: _roomsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: HotelDetailsPage.primaryColor));
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("اتاقی برای نمایش وجود ندارد.", textDirection: TextDirection.rtl));
        }
        final rooms = snapshot.data!;
        if (_selectedRoomForReview == null && rooms.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _selectedRoomForReview == null) {
              setState(() { _selectedRoomForReview = rooms.first; });
            }
          });
        }
        return ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: rooms.length,
          itemBuilder: (context, index) => _buildRoomCard(rooms[index]),
          separatorBuilder: (context, index) => const SizedBox(height: 12),
        );
      },
    );
  }

  Widget _buildRoomCard(Room room) {
    // ... (unchanged from previous version that had date picker logic)
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: _lightGrayColor,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontSize: 15.5,
                        fontFamily: 'Vazirmatn-Bold'
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.group_outlined, size: 18, color: HotelDetailsPage.primaryColor),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          "1 اتاق ${room.capacity} تخته",
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54, fontSize: 12.5, fontFamily: 'Vazirmatn'),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.restaurant_menu_outlined, size: 18, color: HotelDetailsPage.primaryColor),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          room.mealInfo,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54, fontSize: 12.5, fontFamily: 'Vazirmatn'),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "قیمت برای ۱ شب",
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.black54, fontSize: 10, fontFamily: 'Vazirmatn'),
                          ),
                          Text(
                            "${_formatPrice(room.pricePerNight)} تومان",
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: HotelDetailsPage.primaryColor,
                                fontSize: 14,
                                fontFamily: 'Vazirmatn-Bold'
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.thumb_up_alt_rounded, size: 16, color: HotelDetailsPage.primaryColor),
                          const SizedBox(width: 4),
                          Text(
                            room.rating.toStringAsFixed(1),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 12.5, fontFamily: 'Vazirmatn'),
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      room.imageUrl,
                      width: double.infinity,
                      height: 110,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: double.infinity, height: 110, color: _scaffoldContentColor,
                        child: Icon(Icons.broken_image_outlined, size: 30, color: HotelDetailsPage.primaryColor.withOpacity(0.5)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      _showBookingDateRangePicker(context, room);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: HotelDetailsPage.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        textStyle: TextStyle(fontSize: 13, fontFamily: 'Vazirmatn-Bold'),
                        minimumSize: Size(100, 38)
                    ),
                    child: const Text("رزرو اتاق"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsList() { /* ... unchanged ... */
    return FutureBuilder<List<Review>>(
      future: _reviewsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: HotelDetailsPage.primaryColor));
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("نظری برای نمایش وجود ندارد.", textDirection: TextDirection.rtl));
        }
        final reviews = snapshot.data!;
        return ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: reviews.length,
          itemBuilder: (context, index) => _buildReviewCard(reviews[index]),
          separatorBuilder: (context, index) => const SizedBox(height:0),
        );
      },
    );
  }
  Widget _buildReviewCard(Review review) { /* ... unchanged ... */
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(child: Text(review.userName, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 13), overflow: TextOverflow.ellipsis)),
                Text(review.date, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600], fontSize: 10.5)),
              ],
            ),
            const SizedBox(height: 10),
            if (review.positiveFeedback.isNotEmpty) ...[
              _buildFeedbackPointDisplay(icon: Icons.add_circle_outline_rounded, text: review.positiveFeedback, color: Colors.green.shade700),
              const SizedBox(height: 4),
            ],
            if (review.negativeFeedback.isNotEmpty) ...[
              _buildFeedbackPointDisplay(icon: Icons.remove_circle_outline_rounded, text: review.negativeFeedback, color: Colors.red.shade600),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                Icon(Icons.thumb_up_alt_outlined, size: 15, color: HotelDetailsPage.primaryColor),
                const SizedBox(width: 4),
                Text(review.rating.toStringAsFixed(1), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildFeedbackPointDisplay({required IconData icon, required String text, required Color color}) { /* ... unchanged ... */
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: color),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54, height: 1.4, fontSize: 11.5))),
      ],
    );
  }
  Widget _buildAddReviewForm() { /* ... unchanged ... */
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!, width: 0.8),
      ),
      color: _scaffoldContentColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<List<Room>>(
              future: _roomsFuture,
              builder: (context, roomSnapshot) {
                if (roomSnapshot.connectionState == ConnectionState.waiting && _selectedRoomForReview == null) {
                  return Center(child: SizedBox(width:18, height:18, child: CircularProgressIndicator(strokeWidth: 1.5, color: HotelDetailsPage.primaryColor)));
                }
                if (!roomSnapshot.hasData || roomSnapshot.data!.isEmpty) {
                  return Text("اتاقی برای انتخاب موجود نیست.", style: TextStyle(color: Colors.grey[700], fontSize: 12.5));
                }
                final rooms = roomSnapshot.data!;
                if (_selectedRoomForReview == null && rooms.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if(mounted && _selectedRoomForReview == null) {
                      setState(() { _selectedRoomForReview = rooms.first; });
                    }
                  });
                }
                return DropdownButtonFormField<Room>(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    hintText: "انتخاب اتاق محل اقامت",
                    hintStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  isExpanded: true,
                  icon: Icon(Icons.keyboard_arrow_down_rounded, color: HotelDetailsPage.primaryColor, size: 26),
                  value: _selectedRoomForReview,
                  items: rooms.map((Room room) {
                    return DropdownMenuItem<Room>(
                      value: room,
                      child: Text(room.name, style: TextStyle(fontSize: 13, color: Colors.black87), overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (Room? newValue) {
                    setState(() { _selectedRoomForReview = newValue; });
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("امتیاز شما", style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 13)),
                Icon(Icons.more_horiz_rounded, color: HotelDetailsPage.primaryColor, size: 22),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  padding: EdgeInsets.symmetric(horizontal: 3),
                  constraints: BoxConstraints(),
                  icon: Icon(
                    index < _newReviewRating.round() ? Icons.star_rounded : Icons.star_border_rounded,
                    color: HotelDetailsPage.primaryColor,
                    size: 30,
                  ),
                  onPressed: () {
                    setState(() { _newReviewRating = index + 1.0; });
                  },
                );
              }),
            ),
            const SizedBox(height: 20),
            _buildFeedbackEntrySection(
              title: "افزودن نکته مثبت",
              controllers: _positiveFeedbackControllers,
              onAddField: _addPositiveFeedbackField,
              onRemoveField: _removePositiveFeedbackField,
              hintTextPrefix: "نکته مثبت",
            ),
            const SizedBox(height: 20),
            _buildFeedbackEntrySection(
              title: "افزودن نکته منفی",
              controllers: _negativeFeedbackControllers,
              onAddField: _addNegativeFeedbackField,
              onRemoveField: _removeNegativeFeedbackField,
              hintTextPrefix: "نکته منفی",
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: Icon(Icons.send_rounded, color: HotelDetailsPage.primaryColor, size: 26),
                onPressed: _submitReview,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildFeedbackEntrySection({ required String title, required List<TextEditingController> controllers, required VoidCallback onAddField, required Function(int) onRemoveField, required String hintTextPrefix, }) { /* ... unchanged ... */
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            InkWell(
              onTap: onAddField,
              child: Icon(Icons.add_circle_outline_rounded, color: HotelDetailsPage.primaryColor, size: 20),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: controllers.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                        controller: controllers[index],
                        decoration: InputDecoration(
                          hintText: "$hintTextPrefix ${index + 1}",
                          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 12),
                          filled: true,
                          fillColor: _lightGrayColor.withOpacity(0.7),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                        minLines: 1, maxLines: 3,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(fontSize: 13, color: Colors.black87)
                    ),
                  ),
                  if (controllers.length > 1)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: InkWell(
                        onTap: () => onRemoveField(index),
                        child: Icon(Icons.remove_circle_outline_rounded, color: HotelDetailsPage.primaryColor.withOpacity(0.6), size: 20),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
  Future<void> _submitReview() async { /* ... unchanged ... */
    String positiveFeedbacks = _positiveFeedbackControllers
        .where((c) => c.text.trim().isNotEmpty)
        .map((c) => c.text.trim())
        .join("\n");

    String negativeFeedbacks = _negativeFeedbackControllers
        .where((c) => c.text.trim().isNotEmpty)
        .map((c) => c.text.trim())
        .join("\n");

    if (positiveFeedbacks.isEmpty && negativeFeedbacks.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("لطفا حداقل یک نکته مثبت یا منفی وارد کنید.", textDirection: TextDirection.rtl)),
        );
      }
      return;
    }

    final List<Room> currentRooms = await (_roomsFuture ?? Future.value([]));
    if (_selectedRoomForReview == null && currentRooms.isNotEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("لطفا اتاق محل اقامت خود را انتخاب کنید.", textDirection: TextDirection.rtl)),
        );
      }
      return;
    }

    final reviewData = Review(
      userId: "currentUser",
      userName: "شما (اتاق: ${_selectedRoomForReview?.name ?? 'نامشخص'})",
      date: intl.DateFormat('d MMMM yyyy', 'fa_IR').format(DateTime.now()),
      positiveFeedback: positiveFeedbacks,
      negativeFeedback: negativeFeedbacks,
      rating: _newReviewRating,
    );

    if (mounted) {
      showDialog(
        context: context, barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: HotelDetailsPage.primaryColor),
                  SizedBox(width: 20),
                  Text("در حال ارسال نظر...", textDirection: TextDirection.rtl),
                ],
              ),
            ),
          );
        },
      );
    }

    bool success = await _apiService.submitReview(widget.hotelId, reviewData);

    if (mounted) { Navigator.pop(context); }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("نظر شما با موفقیت ثبت شد.", textDirection: TextDirection.rtl)),
      );

      _positiveFeedbackControllers.forEach((c) => c.clear());
      if (_positiveFeedbackControllers.length > 1) {
        _positiveFeedbackControllers.skip(1).forEach((c) => c.dispose());
        _positiveFeedbackControllers = [TextEditingController()];
      } else if (_positiveFeedbackControllers.isNotEmpty) {
        _positiveFeedbackControllers.first.clear();
      }

      _negativeFeedbackControllers.forEach((c) => c.clear());
      if (_negativeFeedbackControllers.length > 1) {
        _negativeFeedbackControllers.skip(1).forEach((c) => c.dispose());
        _negativeFeedbackControllers = [TextEditingController()];
      } else if (_negativeFeedbackControllers.isNotEmpty) {
        _negativeFeedbackControllers.first.clear();
      }

      setState(() {
        _newReviewRating = 3.0;
        if (currentRooms.isNotEmpty) {
          _selectedRoomForReview = currentRooms.first;
        } else {
          _selectedRoomForReview = null;
        }
        _reviewsFuture = _apiService.fetchHotelReviews(widget.hotelId);
      });

    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("خطا در ثبت نظر. لطفا دوباره تلاش کنید.", textDirection: TextDirection.rtl)),
      );
    }
  }
}