import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

// --- Data Models ---
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
  final int capacity; // Assuming this means number of beds/persons
  final String mealInfo; // Changed from breakfastInfo to be more general like "صبحانه / شام"
  final double pricePerNight; // This is actually total price for 3 nights in the UI
  final double rating;

  Room({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.capacity,
    required this.mealInfo,
    required this.pricePerNight,
    required this.rating,
  });
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

// --- Custom Clipper for Top Rounded Corners ---
class TopRoundedCornersClipper extends CustomClipper<Path> {
  final double cornerRadius;

  TopRoundedCornersClipper({this.cornerRadius = 25});

  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, cornerRadius);
    path.arcToPoint(Offset(cornerRadius, 0), radius: Radius.circular(cornerRadius), clockwise: false);
    path.lineTo(size.width - cornerRadius, 0);
    path.arcToPoint(Offset(size.width, cornerRadius), radius: Radius.circular(cornerRadius), clockwise: false);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return oldClipper is TopRoundedCornersClipper && oldClipper.cornerRadius != cornerRadius;
  }
}


// --- API Service Stub ---
class ApiService {
  Future<HotelDetails> fetchHotelDetails(String hotelId) async {
    await Future.delayed(const Duration(seconds: 1));
    bool fetchedIsFavorite = false; // Example initial state
    return HotelDetails(
      id: hotelId,
      name: "نام هتل در حالت طولانی ..", // Matched image
      address: "آدرس در حالت طولانی",   // Matched image
      imageUrl: "https://images.unsplash.com/photo-1566073771259-6a8506099945?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8aG90ZWx8ZW58MHx8MHx8fDA%3D&w=1000&q=80", // Using a generic hotel image
      rating: 4.2, // This will result in 4 full stars and one empty if not handled for half stars
      reviewCount: 204, // Example review count
      description:
      "توضیحات کامل هتل، به عنوان مثال: هتل سه ستاره رویال قشم واقع در خیابان فلسطین در سال ۱۳۹۵ فعالیت خود را آغاز نمود. ساختمان هتل در ۵ طبقه بنا و دارای ۴۱ باب اتاق و سوئیت اقامتی با امکانات رفاهی مناسب می‌باشد و همچنین دسترسی آسانی به خلیج نیلگون فارس و مراکز خرید جزیره از جمله بازار ستاره دارد. هتل رویال قشم با پرسنلی مجرب آماده پذیرایی از شما میهمانان گرامی می‌باشد.",
      amenities: [
        Amenity(name: "تاکسی سرویس", icon: Icons.local_taxi),
        Amenity(name: "صبحانه رایگان", icon: Icons.free_breakfast), // Or a food tray icon: Icons.room_service
        Amenity(name: "پارکینگ", icon: Icons.local_parking),
        Amenity(name: "WiFi", icon: Icons.wifi),
      ],
      isCurrentlyFavorite: fetchedIsFavorite,
    );
  }

  Future<List<Room>> fetchHotelRooms(String hotelId) async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      Room(
        id: "room1",
        name: "اسم اتاق در حالت طولانی ...", // Matched image
        imageUrl: "https://images.unsplash.com/photo-1611892440504-42a792e24d32?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8aG90ZWwlMjByb29tfGVufDB8fDB8fHww&w=1000&q=80", // Generic room image
        capacity: 5, // To match "۵ تخته" if "۱ اتاق" is fixed
        mealInfo: "صبحانه / شام", // Matched image
        pricePerNight: 3200000, // This is price for 3 nights in UI
        rating: 4.5,
      ),
      Room(
        id: "room2",
        name: "اسم اتاق دوم طولانی...",
        imageUrl: "https://images.unsplash.com/photo-1590490360182-c33d57733427?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTB8fGhvdGVsJTIwcm9vbXxlbnwwfHwwfHx8MA%3D%3D&w=1000&q=80",
        capacity: 2,
        mealInfo: "فقط صبحانه",
        pricePerNight: 2800000,
        rating: 4.2,
      ),
    ];
  }

  Future<List<Review>> fetchHotelReviews(String hotelId) async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      Review(
        userId: "user1",
        userName: "اسم اشخاص", // Matched image
        date: "تاریخ نظردهی", // Matched image
        positiveFeedback: "نکات مثبت نظردهی", // Matched image
        negativeFeedback: "نکات منفی نظردهی", // Matched image
        rating: 4.5, // Matched image
      ),
      Review(
        userId: "user2",
        userName: "کاربر دیگر",
        date: "۱۴۰۲/۰۵/۱۰",
        positiveFeedback: "هتل بسیار تمیز و آرام بود.",
        negativeFeedback: "صبحانه می‌توانست متنوع‌تر باشد.",
        rating: 4.0,
      ),
    ];
  }

  Future<bool> submitReview(String hotelId, Review reviewData) async {
    print("Submitting review for hotel $hotelId: ${reviewData.userName}");
    await Future.delayed(const Duration(seconds: 1));
    // In a real app, you would add the review to a list or DB and refetch/update UI
    return true;
  }

  Future<bool> toggleFavoriteHotel(String hotelId, bool currentIsFavoriteStatusToServer) async {
    print("Toggling favorite for hotel $hotelId to ${!currentIsFavoriteStatusToServer}");
    await Future.delayed(const Duration(milliseconds: 300));
    return !currentIsFavoriteStatusToServer; // Simulate successful toggle
  }
}

// --- Hotel Details Page Widget ---
class HotelDetailsPage extends StatefulWidget {
  final String hotelId;

  const HotelDetailsPage({Key? key, required this.hotelId}) : super(key: key);

  @override
  _HotelDetailsPageState createState() => _HotelDetailsPageState();
}

class _HotelDetailsPageState extends State<HotelDetailsPage> {
  final ApiService _apiService = ApiService();
  Future<HotelDetails>? _hotelDetailsFuture;
  Future<List<Room>>? _roomsFuture;
  Future<List<Review>>? _reviewsFuture;

  double _newReviewRating = 3.0; // Image shows 3 stars selected initially
  bool _isFavorite = false;

  Room? _selectedRoomForReview; // For the "ثبت نظر" dropdown
  List<TextEditingController> _positiveFeedbackControllers = [];
  List<TextEditingController> _negativeFeedbackControllers = [];

  @override
  void initState() {
    super.initState();
    _loadDataAndFavoriteStatus();
    // Initialize with one controller if empty, to ensure at least one field is present
    if (_positiveFeedbackControllers.isEmpty) {
      _positiveFeedbackControllers.add(TextEditingController());
    }
    if (_negativeFeedbackControllers.isEmpty) {
      _negativeFeedbackControllers.add(TextEditingController());
    }
  }

  void _loadDataAndFavoriteStatus() {
    _hotelDetailsFuture = _apiService.fetchHotelDetails(widget.hotelId).then((hotel) {
      if (mounted) {
        setState(() {
          _isFavorite = hotel.isCurrentlyFavorite;
        });
      }
      return hotel;
    });
    _roomsFuture = _apiService.fetchHotelRooms(widget.hotelId).then((rooms) {
      if (mounted && rooms.isNotEmpty && _selectedRoomForReview == null) {
        // Set initial selected room for review dropdown if not already set
        // The image shows "اتاق ۲ خوابه ۵ تخته" which might be the first or a specific one.
        // For dynamic data, using the first room is a safe default.
        // The image hint is "انتخاب اتاق محل اقامت", so it's initially null.
        // Let's not pre-select, let user choose or keep it null to show hint.
        // _selectedRoomForReview = rooms.first;
      }
      return rooms;
    });
    _reviewsFuture = _apiService.fetchHotelReviews(widget.hotelId);
  }


  Future<void> _toggleFavorite() async {
    final HotelDetails? currentHotel = await _hotelDetailsFuture;
    if (currentHotel == null) return;

    bool previousState = _isFavorite;
    setState(() {
      _isFavorite = !_isFavorite;
    });
    try {
      // Pass the new state to the API
      bool success = await _apiService.toggleFavoriteHotel(widget.hotelId, previousState);
      if (!success && mounted) { // If API failed, revert
        setState(() {
          _isFavorite = previousState;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("خطا در به‌روزرسانی علاقه‌مندی", textDirection: TextDirection.rtl)),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isFavorite = previousState;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("خطا در ارتباط با سرور", textDirection: TextDirection.rtl)),
        );
      }
    }
  }


  String _formatPrice(double price) {
    final formatter = intl.NumberFormat("#,###", "fa_IR");
    return formatter.format(price);
  }


  @override
  void dispose() {
    for (var controller in _positiveFeedbackControllers) {
      controller.dispose();
    }
    for (var controller in _negativeFeedbackControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addPositiveFeedbackField() {
    setState(() {
      _positiveFeedbackControllers.add(TextEditingController());
    });
  }

  void _removePositiveFeedbackField(int index) {
    if (_positiveFeedbackControllers.length > 1) {
      setState(() {
        _positiveFeedbackControllers[index].dispose();
        _positiveFeedbackControllers.removeAt(index);
      });
    } else {
      // Clear the text if it's the last one, don't remove
      _positiveFeedbackControllers[index].clear();
    }
  }

  void _addNegativeFeedbackField() {
    setState(() {
      _negativeFeedbackControllers.add(TextEditingController());
    });
  }

  void _removeNegativeFeedbackField(int index) {
    if (_negativeFeedbackControllers.length > 1) {
      setState(() {
        _negativeFeedbackControllers[index].dispose();
        _negativeFeedbackControllers.removeAt(index);
      });
    } else {
      _negativeFeedbackControllers[index].clear();
    }
  }


  @override
  Widget build(BuildContext context) {
    // Define the purple color from the image
    final Color primaryColor = Color(0xFF542545);
    final Color lightGrayColor = Color(0xFFEEEEEE);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: FutureBuilder<HotelDetails>(
          future: _hotelDetailsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: primaryColor));
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("خطا در بارگذاری اطلاعات هتل.", textDirection: TextDirection.rtl),
                    ElevatedButton(
                      onPressed: _loadDataAndFavoriteStatus,
                      child: const Text("تلاش مجدد", textDirection: TextDirection.rtl),
                      style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white),
                    )
                  ],
                ),
              );
            }

            final hotel = snapshot.data!;
            double screenWidth = MediaQuery.of(context).size.width;
            double imageHeight = screenWidth * 0.7; // Adjusted for better look
            double topContentCornerRadius = 25.0;

            return CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(
                  expandedHeight: imageHeight,
                  pinned: false, // Set to true if you want the app bar to stick
                  floating: false,
                  backgroundColor: Colors.transparent, // Make AppBar transparent
                  elevation: 0,
                  automaticallyImplyLeading: false, // Remove back button
                  flexibleSpace: FlexibleSpaceBar(
                    background: _buildHotelImage(hotel.imageUrl, 4.5, primaryColor, lightGrayColor), // Using fixed rating from image example
                  ),
                ),
                SliverToBoxAdapter(
                  child: Transform.translate(
                    offset: Offset(0, -topContentCornerRadius), // Pull content up to overlap rounded corners
                    child: ClipPath(
                      clipper: TopRoundedCornersClipper(cornerRadius: topContentCornerRadius),
                      child: Container(
                        color: Theme.of(context).scaffoldBackgroundColor, // Usually white or light gray
                        padding: EdgeInsets.only(
                          top: topContentCornerRadius + 16.0, // Start content below the curve
                          left: 16.0,
                          right: 16.0,
                          bottom: 16.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHotelHeader(hotel.name, hotel.address, primaryColor),
                            const SizedBox(height: 8),
                            _buildRating(hotel.rating, hotel.reviewCount, primaryColor),
                            const SizedBox(height: 16),
                            _buildSectionTitle("درباره هتل (${hotel.name})", primaryColor),
                            const SizedBox(height: 8),
                            Text(hotel.description, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5)),
                            const SizedBox(height: 24),
                            _buildSectionTitle("امکانات و ویژگی ها", primaryColor),
                            const SizedBox(height: 8),
                            _buildAmenitiesGrid(hotel.amenities, primaryColor, lightGrayColor),
                            const SizedBox(height: 24),
                            _buildSectionTitle("لیست اتاق ها", primaryColor),
                            const SizedBox(height: 8),
                            _buildRoomsList(primaryColor),
                            const SizedBox(height: 24),
                            _buildSectionTitle("نظرات", primaryColor),
                            const SizedBox(height: 8),
                            _buildReviewsList(primaryColor),
                            const SizedBox(height: 24),
                            _buildSectionTitle("ثبت نظر", primaryColor, secondaryIconData: Icons.info_outline),
                            const SizedBox(height: 8),
                            _buildAddReviewForm(primaryColor, lightGrayColor),
                          ],
                        ),
                      ),
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

  Widget _buildHotelImage(String imageUrl, double displayRating, Color primaryColor, Color lightGrayColor) {
    double screenWidth = MediaQuery.of(context).size.width;
    double imageHeight = screenWidth * 0.7;
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: lightGrayColor,
            child: Icon(Icons.broken_image, size: 50, color: primaryColor.withOpacity(0.6)),
          ),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: lightGrayColor,
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                  color: primaryColor,
                ),
              ),
            );
          },
        ),
        // Favorite button
        Positioned(
          top: MediaQuery.of(context).padding.top + 10, // Adjust for status bar
          left: 16, // Left in LTR, so right in RTL
          child: Material(
            color: Colors.white,
            shape: const CircleBorder(),
            elevation: 2,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _toggleFavorite,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: primaryColor,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
        // Rating display
        Positioned(
          top: MediaQuery.of(context).padding.top + 10, // Adjust for status bar
          right: 16, // Right in LTR, so left in RTL
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                color: lightGrayColor.withOpacity(0.9), // Matched image's light gray, slightly transparent
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  )
                ]
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  displayRating.toStringAsFixed(1), // Show "4.5"
                  style: TextStyle(
                    color: Colors.black, // Black text for rating
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 5),
                Icon(
                  Icons.thumb_up, // Thumbs up icon
                  color: primaryColor, // Purple color
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHotelHeader(String name, String address, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(Icons.location_on, size: 18, color: primaryColor),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                address,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRating(double rating, int reviewCount, Color primaryColor) {
    // For 4.2 rating as in image: 4 full, 0 half, 1 empty
    // For 4.5 rating: 4 full, 1 half, 0 empty
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;

    return Row(
      children: [
        for (int i = 0; i < 5; i++)
          Icon(
            i < fullStars ? Icons.star : (i == fullStars && hasHalfStar ? Icons.star_half : Icons.star_border),
            color: primaryColor, // Purple stars
            size: 22,
          ),
        const SizedBox(width: 8),
        // Text is not shown in the main rating stars line in the image, it's separate if needed.
        // The image just shows 4 purple stars and one outlined star.
        // The text "$rating از 5..." is usually part of a review summary, not here.
        // Let's remove the text to match the image.
      ],
    );
  }

  Widget _buildSectionTitle(String title, Color primaryColor, {IconData? secondaryIconData}) {
    IconData? mainIcon;

    if (title.startsWith("درباره هتل")) {
      mainIcon = Icons.article_outlined; // Icon for "About"
    } else if (title == "امکانات و ویژگی ها") {
      mainIcon = Icons.tune_outlined; // Sliders/tune icon
    } else if (title == "لیست اتاق ها") {
      mainIcon = Icons.list; // List icon (three horizontal lines)
    } else if (title == "نظرات" || title == "ثبت نظر") {
      mainIcon = Icons.chat_bubble_outline; // Chat bubble
    } else {
      mainIcon = Icons.circle; // Default
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (mainIcon != null)
                Icon(
                  mainIcon,
                  size: 24,
                  color: primaryColor,
                ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 18),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        if (secondaryIconData != null)
          Icon(
            secondaryIconData,
            size: 22,
            color: primaryColor,
          ),
      ],
    );
  }

  Widget _buildAmenitiesGrid(List<Amenity> amenities, Color primaryColor, Color lightGrayColor) {
    return Container(
      alignment: Alignment.centerRight, // Ensure items align to the right in RTL
      child: Wrap(
        spacing: 12.0, // Spacing between items horizontally
        runSpacing: 12.0, // Spacing between rows
        alignment: WrapAlignment.start, // Start items from the right (due to RTL)
        children: amenities.map((amenity) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60, // Fixed width for amenity holder
                height: 60, // Fixed height
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: lightGrayColor, // Light gray background
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                ),
                child: Icon(amenity.icon, size: 28, color: primaryColor),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: 60, // Match width of icon container for text alignment
                child: Text(
                  amenity.name,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRoomsList(Color primaryColor) {
    return FutureBuilder<List<Room>>(
      future: _roomsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: primaryColor));
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("اتاقی برای نمایش وجود ندارد.", textDirection: TextDirection.rtl));
        }
        final rooms = snapshot.data!;
        return ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: rooms.length,
          itemBuilder: (context, index) => _buildRoomCard(rooms[index], primaryColor),
          separatorBuilder: (context, index) => const SizedBox(height: 12),
        );
      },
    );
  }

  Widget _buildRoomCard(Room room, Color primaryColor) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero, // Remove default card margin
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                room.imageUrl,
                width: 90, // Slightly smaller image
                height: 120, // Taller image for room
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 90, height: 120, color: Color(0xFFEEEEEE),
                  child: Icon(Icons.broken_image, size: 30, color: Colors.grey[400]),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(room.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 15), overflow: TextOverflow.ellipsis, maxLines: 2),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.people_alt_outlined, size: 16, color: primaryColor.withOpacity(0.8)),
                      const SizedBox(width: 4),
                      // Text in image: "۱ اتاق ۵ تخته". If capacity is just beds:
                      Flexible(child: Text("۱ اتاق ${room.capacity} تخته", style: Theme.of(context).textTheme.bodySmall, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.restaurant_menu_outlined, size: 16, color: primaryColor.withOpacity(0.8)),
                      const SizedBox(width: 4),
                      Flexible(child: Text(room.mealInfo, style: Theme.of(context).textTheme.bodySmall, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("قیمت برای ۳ شب", style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.black54, fontSize: 10)),
                            Text(
                              "${_formatPrice(room.pricePerNight)} تومان",
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Moved rating and button to a column for better alignment if needed, or keep in Row
                      Row( // Rating next to price, button below or to the left
                        children: [
                          Icon(Icons.thumb_up, size: 16, color: primaryColor), // Filled thumb_up
                          const SizedBox(width: 4),
                          Text(room.rating.toStringAsFixed(1), style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft, // This is the far left in RTL
                    child: ElevatedButton(
                      onPressed: () { /* Booking action */ },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          textStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)
                      ),
                      child: const Text("رزرو اتاق"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsList(Color primaryColor) {
    return FutureBuilder<List<Review>>(
      future: _reviewsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: primaryColor));
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("نظری برای نمایش وجود ندارد.", textDirection: TextDirection.rtl));
        }
        final reviews = snapshot.data!;
        return ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: reviews.length,
          itemBuilder: (context, index) => _buildReviewCard(reviews[index], primaryColor),
          separatorBuilder: (context, index) => const SizedBox(height: 10), // Use SizedBox instead of Divider
        );
      },
    );
  }

  Widget _buildReviewCard(Review review, Color primaryColor) {
    return Card(
      elevation: 0.5, // Softer shadow
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(child: Text(review.userName, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 13), overflow: TextOverflow.ellipsis)),
                Text(review.date, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600], fontSize: 11)),
              ],
            ),
            const SizedBox(height: 10),
            _buildFeedbackPoint(icon: Icons.add_circle_outline, text: review.positiveFeedback, color: primaryColor), // Matched image's positive prefix
            const SizedBox(height: 6),
            _buildFeedbackPoint(icon: Icons.remove_circle_outline, text: review.negativeFeedback, color: Colors.redAccent.shade200), // Matched image's negative prefix
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.thumb_up, size: 18, color: primaryColor), // Filled thumb_up
                const SizedBox(width: 4),
                Text(review.rating.toStringAsFixed(1), style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackPoint({required IconData icon, required String text, required Color color}) {
    // The image shows "نکات مثبت نظردهی" without a prefix "نکات مثبت:". Assuming `text` is the full string.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12, height: 1.4))),
      ],
    );
  }

  Widget _buildAddReviewForm(Color primaryColor, Color lightGrayColor) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      color: Colors.white, // Explicitly white background
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Room selection dropdown
            FutureBuilder<List<Room>>(
              future: _roomsFuture, // Ensure _roomsFuture is initialized
              builder: (context, roomSnapshot) {
                if (roomSnapshot.connectionState == ConnectionState.waiting && _selectedRoomForReview == null) {
                  return Center(child: SizedBox(width:20, height:20, child: CircularProgressIndicator(strokeWidth: 2, color: primaryColor)));
                }
                // Handle error or no data for rooms specifically for the dropdown
                if (!roomSnapshot.hasData || roomSnapshot.data == null || roomSnapshot.data!.isEmpty) {
                  return Text("اتاقی برای انتخاب موجود نیست.", style: TextStyle(color: Colors.grey[700], fontSize: 13));
                }
                final rooms = roomSnapshot.data!;
                // Ensure _selectedRoomForReview is one of the items or null
                if (_selectedRoomForReview != null && !rooms.any((r) => r.id == _selectedRoomForReview!.id)) {
                  _selectedRoomForReview = null; // Reset if selected room not in list
                }

                return DropdownButtonFormField<Room>(
                  decoration: InputDecoration(
                    hintText: "انتخاب اتاق محل اقامت", // Matched image hint
                    hintStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
                    contentPadding: EdgeInsets.symmetric(vertical: 8.0), // Adjust padding
                    border: InputBorder.none, // No border for the dropdown field itself
                    isDense: true,
                  ),
                  isExpanded: true,
                  icon: Icon(Icons.keyboard_arrow_down, color: primaryColor), // Dropdown arrow
                  value: _selectedRoomForReview,
                  items: rooms.map((Room room) {
                    return DropdownMenuItem<Room>(
                      value: room,
                      child: Text(room.name, style: TextStyle(fontSize: 13, color: Colors.black87), overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (Room? newValue) {
                    setState(() {
                      _selectedRoomForReview = newValue;
                    });
                  },
                );
              },
            ),
            const Divider(height: 24), // Divider after dropdown

            // Rating stars section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("امتیاز", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 15)),
                Icon(Icons.more_horiz, color: primaryColor, size: 24), // "..." icon
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.start, // Align stars to the right (start in RTL)
              children: List.generate(5, (index) {
                return IconButton(
                  padding: EdgeInsets.symmetric(horizontal: 2), // Minimal padding
                  constraints: BoxConstraints(),
                  icon: Icon(
                    index < _newReviewRating ? Icons.star : Icons.star_border,
                    color: primaryColor,
                    size: 30,
                  ),
                  onPressed: () {
                    setState(() {
                      _newReviewRating = index + 1.0;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 20),

            // Positive feedback section
            _buildFeedbackSection(
              title: "افزودن نکته مثبت",
              addIcon: Icons.add_circle_outline,
              controllers: _positiveFeedbackControllers,
              onAddField: _addPositiveFeedbackField,
              onRemoveField: _removePositiveFeedbackField,
              hintTextPrefix: "نکته مثبت",
              primaryColor: primaryColor,
              lightGrayColor: lightGrayColor,
            ),
            const SizedBox(height: 20),

            // Negative feedback section
            _buildFeedbackSection(
              title: "افزودن نکته منفی",
              addIcon: Icons.add_circle_outline,
              controllers: _negativeFeedbackControllers,
              onAddField: _addNegativeFeedbackField,
              onRemoveField: _removeNegativeFeedbackField,
              hintTextPrefix: "نکته منفی",
              primaryColor: primaryColor,
              lightGrayColor: lightGrayColor,
            ),
            const SizedBox(height: 24),

            // Submit button
            Align(
              alignment: Alignment.centerLeft, // Far left in RTL
              child: IconButton(
                icon: Icon(Icons.send, color: primaryColor, size: 28), // Filled send icon
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

  Widget _buildFeedbackSection({
    required String title,
    required IconData addIcon,
    required List<TextEditingController> controllers,
    required VoidCallback onAddField,
    required Function(int) onRemoveField,
    required String hintTextPrefix,
    required Color primaryColor,
    required Color lightGrayColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 15),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            InkWell( // "+" button to add more fields
              onTap: onAddField,
              customBorder: CircleBorder(),
              child: Padding(
                padding: const EdgeInsets.all(4.0), // Make tap target larger
                child: Icon(addIcon, color: primaryColor, size: 22),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: controllers.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  // Remove button ("-") if more than one field
                  if (controllers.length > 1 || controllers[index].text.isNotEmpty) // Show if multiple or if single has text
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0), // Left in RTL means to the right of TextField
                      child: IconButton(
                        icon: Icon(Icons.remove_circle_outline, color: Colors.grey[400], size: 22),
                        onPressed: () => onRemoveField(index),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                    ),
                  Expanded(
                    child: TextField(
                      controller: controllers[index],
                      decoration: InputDecoration(
                        hintText: "$hintTextPrefix ${index + 1}",
                        hintStyle: TextStyle(fontSize: 13, color: Colors.grey[500]),
                        filled: true,
                        fillColor: lightGrayColor, // Light gray background for TextField
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8), // Matched image's rounded corners
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), // Adjusted padding
                        isDense: true,
                      ),
                      minLines: 1,
                      maxLines: 3,
                      style: TextStyle(fontSize: 13),
                      textDirection: TextDirection.rtl, // Ensure text input is also RTL
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

  Future<void> _submitReview() async {
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

    final List<Room>? rooms = await _roomsFuture; // Await future to get list
    if (rooms != null && rooms.isNotEmpty && _selectedRoomForReview == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("لطفا اتاق محل اقامت خود را انتخاب کنید.", textDirection: TextDirection.rtl)),
        );
      }
      return;
    }


    final reviewData = Review(
      userId: "currentUser", // Replace with actual user ID
      userName: "شما", // User name for the review
      date: intl.DateFormat('yyyy/MM/dd', 'fa_IR').format(DateTime.now()),
      positiveFeedback: positiveFeedbacks,
      negativeFeedback: negativeFeedbacks,
      rating: _newReviewRating,
    );

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Color(0xFF542545)),
                  SizedBox(width: 20),
                  Text("در حال ارسال نظر...", style: TextStyle(fontSize: 13)),
                ],
              ),
            ),
          );
        },
      );
    }

    bool success = await _apiService.submitReview(widget.hotelId, reviewData);

    if (mounted) {
      Navigator.pop(context); // Close loading dialog
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("نظر شما با موفقیت ثبت شد.", textDirection: TextDirection.rtl)),
      );
      // Clear positive feedback fields and reset to one
      _positiveFeedbackControllers.forEach((c) => c.clear());
      if (_positiveFeedbackControllers.length > 1) {
        _positiveFeedbackControllers.skip(1).forEach((c) => c.dispose());
        setState(() { _positiveFeedbackControllers = [_positiveFeedbackControllers.first]; });
      }
      // Clear negative feedback fields and reset to one
      _negativeFeedbackControllers.forEach((c) => c.clear());
      if (_negativeFeedbackControllers.length > 1) {
        _negativeFeedbackControllers.skip(1).forEach((c) => c.dispose());
        setState(() { _negativeFeedbackControllers = [_negativeFeedbackControllers.first]; });
      }

      setState(() {
        _newReviewRating = 3.0; // Reset rating
        // _selectedRoomForReview = null; // Reset selected room, or to first if that's desired
        if (rooms != null && rooms.isNotEmpty) {
          _selectedRoomForReview = null; // Let user pick again, or set to rooms.first
        } else {
          _selectedRoomForReview = null;
        }
        // Refresh reviews list
        _reviewsFuture = _apiService.fetchHotelReviews(widget.hotelId);
      });

    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("خطا در ثبت نظر. لطفا دوباره تلاش کنید.", textDirection: TextDirection.rtl)),
      );
    }
  }
}

// To run this example:
// void main() {
//   runApp(MaterialApp(
//     theme: ThemeData(
//       fontFamily: 'IranSans', // Example custom font, ensure it's in pubspec.yaml and assets
//       primaryColor: Color(0xFF542545),
//       scaffoldBackgroundColor: Colors.white,
//       textTheme: TextTheme( // Define some default text styles if needed
//         bodyMedium: TextStyle(fontSize: 14.0, color: Colors.black87),
//         bodySmall: TextStyle(fontSize: 12.0, color: Colors.black54),
//         titleMedium: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.black87),
//         titleSmall: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500, color: Colors.black87),
//         labelSmall: TextStyle(fontSize: 10.0, color: Colors.grey[600]),
//       ),
//       inputDecorationTheme: InputDecorationTheme(
//         hintStyle: TextStyle(color: Colors.grey[500]),
//       )
//     ),
//     home: HotelDetailsPage(hotelId: "hotel123"),
//     debugShowCheckedModeBanner: false,
//   ));
// }