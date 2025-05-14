import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

// --- Data Models --- (Assume these are defined as before)
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
  final String breakfastInfo;
  final double pricePerNight;
  final double rating;

  Room({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.capacity,
    required this.breakfastInfo,
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

// --- Custom Clipper for Top Rounded Corners --- (Assume this is defined as before)
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


// --- API Service Stub --- (Assume this is defined as before)
class ApiService {
  Future<HotelDetails> fetchHotelDetails(String hotelId) async {
    await Future.delayed(const Duration(seconds: 1));
    bool fetchedIsFavorite = false;
    return HotelDetails(
      id: hotelId,
      name: "نام هتل در حالت طولانی تست",
      address: "آدرس در حالت طولانی",
      imageUrl: "https://picsum.photos/seed/hotel/800/400",
      rating: 4.2,
      reviewCount: 120,
      description:
      "توضیحات کامل هتل، به عنوان مثال: هتل سه ستاره رویال ششم واقع در خیابان فلسطین در سال ۱۳۹۵ فعالیت خود را آغاز نمود. ساختمان هتل در ۵ طبقه بنا و دارای ۴۱ باب اتاق و سوئیت اقامتی با امکانات رفاهی مناسب می‌باشد و همچنین دسترسی آسانی به خلیج نیلگون فارس و مراکز خرید جزیره از جمله بازار ستاره دارد. هتل رویال قشم با پرسنلی مجرب آماده پذیرایی از شما میهمانان گرامی می‌باشد.",
      amenities: [
        Amenity(name: "تاکسی سرویس", icon: Icons.local_taxi),
        Amenity(name: "صبحانه رایگان", icon: Icons.free_breakfast),
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
        name: "اسم اتاق در حالت طولانی...",
        imageUrl: "https://picsum.photos/seed/room1/400/300",
        capacity: 2,
        breakfastInfo: "صبحانه ۱ تمام",
        pricePerNight: 3200000,
        rating: 4.5,
      ),
      Room(
        id: "room2",
        name: "سوئیت رویال با منظره دریا",
        imageUrl: "https://picsum.photos/seed/room2/400/300",
        capacity: 4,
        breakfastInfo: "صبحانه ۲ تمام",
        pricePerNight: 5500000,
        rating: 4.8,
      ),
    ];
  }

  Future<List<Review>> fetchHotelReviews(String hotelId) async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      Review(
        userId: "user1",
        userName: "اسم اشخاصی",
        date: "تیر ۲, چهارشنبه",
        positiveFeedback: "نکات مثبت نظردهی",
        negativeFeedback: "نکات منفی نظردهی",
        rating: 4.5,
      ),
      Review(
        userId: "user2",
        userName: "کاربر دیگر",
        date: "مرداد ۱۰, شنبه",
        positiveFeedback: "هتل بسیار تمیز و آرام بود.",
        negativeFeedback: "صبحانه می‌توانست متنوع‌تر باشد.",
        rating: 4.0,
      ),
    ];
  }

  Future<bool> submitReview(String hotelId, Review reviewData) async {
    print("Submitting review for hotel $hotelId: ${reviewData.userName}");
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  Future<bool> toggleFavoriteHotel(String hotelId, bool isFavorite) async {
    print("Toggling favorite for hotel $hotelId to ${!isFavorite}");
    await Future.delayed(const Duration(milliseconds: 500));
    return !isFavorite;
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

  double _newReviewRating = 3.0;
  bool _isFavorite = false;

  Room? _selectedRoomForReview;
  List<TextEditingController> _positiveFeedbackControllers = [TextEditingController()];
  List<TextEditingController> _negativeFeedbackControllers = [TextEditingController()];

  @override
  void initState() {
    super.initState();
    _loadDataAndFavoriteStatus();
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
    _roomsFuture = _apiService.fetchHotelRooms(widget.hotelId);
    _reviewsFuture = _apiService.fetchHotelReviews(widget.hotelId);
  }


  Future<void> _toggleFavorite() async {
    bool previousState = _isFavorite;
    setState(() {
      _isFavorite = !_isFavorite;
    });
    try {
      bool success = await _apiService.toggleFavoriteHotel(widget.hotelId, _isFavorite);
      if (!success && mounted) {
        setState(() {
          _isFavorite = previousState;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("خطا در به‌روزرسانی علاقه‌مندی در سرور", textDirection: TextDirection.rtl)),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isFavorite = previousState;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("خطا در ارتباط با سرور برای علاقه‌مندی", textDirection: TextDirection.rtl)),
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
    _positiveFeedbackControllers.forEach((controller) => controller.dispose());
    _negativeFeedbackControllers.forEach((controller) => controller.dispose());
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: FutureBuilder<HotelDetails>(
          future: _hotelDetailsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("خطا در بارگذاری اطلاعات هتل.", textDirection: TextDirection.rtl),
                    ElevatedButton(onPressed: _loadDataAndFavoriteStatus, child: const Text("تلاش مجدد", textDirection: TextDirection.rtl))
                  ],
                ),
              );
            }

            final hotel = snapshot.data!;
            double screenWidth = MediaQuery.of(context).size.width;
            double imageHeight = screenWidth * 0.6;
            double topContentCornerRadius = 25.0;

            return Stack(
              children: <Widget>[
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: imageHeight,
                  child: _buildHotelImage(hotel.imageUrl, hotel.rating),
                ),
                Padding(
                  padding: EdgeInsets.only(top: imageHeight),
                  child: ClipPath(
                    clipper: TopRoundedCornersClipper(cornerRadius: topContentCornerRadius),
                    child: Container(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(
                          top: topContentCornerRadius + 16.0,
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
                            const SizedBox(height: 16),
                            _buildSectionTitle("درباره هتل (${hotel.name})"),
                            const SizedBox(height: 8),
                            Text(hotel.description, style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(height: 24),
                            _buildSectionTitle("امکانات و ویژگی ها"),
                            const SizedBox(height: 8),
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
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHotelImage(String imageUrl, double rating) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        Image.network(
          imageUrl,
          width: screenWidth,
          height: screenWidth * 0.6,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            width: screenWidth,
            height: screenWidth * 0.6,
            color: Color(0xFFEEEEEE),
            child: Icon(Icons.broken_image, size: 50, color: Color(0xFF542545)),
          ),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: screenWidth,
              height: screenWidth * 0.6,
              color: Color(0xFFEEEEEE),
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
        ),
        Positioned(
          top: 16,
          right: 16,
          child: Material(
            color: Colors.white,
            shape: const CircleBorder(),
            elevation: 1.5,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _toggleFavorite,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Color(0xFF542545) : Color(0xFF542545),
                  size: 26,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: Color(0xFFEEEEEE),
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
                  rating.toStringAsFixed(1),
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.thumb_up,
                  color: Color(0xFF542545),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHotelHeader(String name, String address) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.location_on, size: 16, color: Color(0xFF542545)),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                address,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRating(double rating, int reviewCount) {
    return Row(
      children: [
        for (int i = 0; i < 5; i++)
          Icon(
            i < rating.floor() ? Icons.star : (i < rating ? Icons.star_half : Icons.star_border),
            color: Color(0xFF542545),
            size: 20,
          ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            "$rating از 5 (${intl.NumberFormat("#,###", "fa_IR").format(reviewCount)} نظر)",
            style: Theme.of(context).textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    IconData? mainIcon;
    IconData? secondaryIcon;

    if (title.startsWith("درباره هتل")) {
      mainIcon = Icons.info_outline;
    } else if (title == "امکانات و ویژگی ها") {
      mainIcon = Icons.tune_outlined;
    } else if (title == "لیست اتاق ها") {
      mainIcon = Icons.hotel_outlined;
    } else if (title == "نظرات") {
      mainIcon = Icons.chat_bubble_outline;
    } else if (title == "ثبت نظر") {
      mainIcon = Icons.chat_bubble_outline;
      secondaryIcon = Icons.info_outline;
    } else {
      mainIcon = Icons.circle;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (mainIcon != null)
                Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.only(left: 8),
                  child: Icon(
                    mainIcon,
                    size: 22,
                    color: Color(0xFF542545),
                  ),
                ),
              Flexible(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        if (secondaryIcon != null)
          Icon(
            secondaryIcon,
            size: 22,
            color: Color(0xFF542545),
          ),
      ],
    );
  }

  Widget _buildAmenitiesGrid(List<Amenity> amenities) {
    return Wrap(
      spacing: 16.0,
      runSpacing: 12.0,
      children: amenities.map((amenity) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFFEEEEEE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(amenity.icon, size: 28, color: Color(0xFF542545)),
            ),
            const SizedBox(height: 4),
            Text(amenity.name, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildRoomsList() {
    return FutureBuilder<List<Room>>(
      future: _roomsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("اتاقی برای نمایش وجود ندارد.", textDirection: TextDirection.rtl));
        }
        final rooms = snapshot.data!;
        if (_selectedRoomForReview == null && rooms.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _selectedRoomForReview == null) {
              setState(() {
                _selectedRoomForReview = rooms.first;
              });
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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                room.imageUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 100, height: 100, color: Color(0xFFEEEEEE),
                  child: Icon(Icons.broken_image, size: 30, color: Color(0xFFEEEEEE)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(room.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis, maxLines: 2),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.people_alt_outlined, size: 16, color:  Color(0xFF542545)),
                      const SizedBox(width: 4),
                      Flexible(child: Text("ظرفیت ${room.capacity} نفر", style: Theme.of(context).textTheme.bodySmall, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.restaurant_menu_outlined, size: 16, color: Color(0xFF542545)),
                      const SizedBox(width: 4),
                      Flexible(child: Text(room.breakfastInfo, style: Theme.of(context).textTheme.bodySmall, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("قیمت برای ۳ شب", style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.black)),
                            Text(
                              "${_formatPrice(room.pricePerNight)} تومان",
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: Color(0xFF542545)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.thumb_up_alt, size: 16, color: Color(0xFF542545)),
                          const SizedBox(width: 4),
                          Text(room.rating.toString(), style: Theme.of(context).textTheme.bodySmall),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("دکمه رزرو اتاق ${room.name} فشرده شد", textDirection: TextDirection.rtl)),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF542545),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

  Widget _buildReviewsList() {
    return FutureBuilder<List<Review>>(
      future: _reviewsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
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
          separatorBuilder: (context, index) => const Divider(height: 20),
        );
      },
    );
  }

  Widget _buildReviewCard(Review review) {
    return Card(
      elevation: 1,
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
                Flexible(child: Text(review.userName, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                Text(review.date, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
              ],
            ),
            const SizedBox(height: 8),
            _buildFeedbackPoint(icon: Icons.add_circle_outline, text: "نکات مثبت: ${review.positiveFeedback}", color: Color(0xFF542545)),
            const SizedBox(height: 4),
            _buildFeedbackPoint(icon: Icons.remove_circle_outline, text: "نکات منفی: ${review.negativeFeedback}", color: Color(0xFF542545)),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.thumb_up_alt, size: 18, color: Color(0xFF542545)),
                const SizedBox(width: 4),
                Text(review.rating.toStringAsFixed(1), style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackPoint({required IconData icon, required String text, required Color color}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: Theme.of(context).textTheme.bodySmall)),
      ],
    );
  }

  Widget _buildAddReviewForm() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<List<Room>>(
              future: _roomsFuture,
              builder: (context, roomSnapshot) {
                if (roomSnapshot.connectionState == ConnectionState.waiting && _selectedRoomForReview == null) {
                  return Center(child: SizedBox(width:20, height:20, child: CircularProgressIndicator(strokeWidth: 2,)));
                }
                if (!roomSnapshot.hasData || roomSnapshot.data!.isEmpty) {
                  return Text("اتاقی برای انتخاب موجود نیست.", style: TextStyle(color: Colors.grey[700]));
                }
                final rooms = roomSnapshot.data!;
                if (_selectedRoomForReview == null && rooms.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted && _selectedRoomForReview == null) {
                      setState(() {
                        _selectedRoomForReview = rooms.first;
                      });
                    }
                  });
                }
                return DropdownButtonFormField<Room>(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                  ),
                  isExpanded: true,
                  icon: Icon(Icons.arrow_drop_down, color: Color(0xFF542545)),
                  hint: Text("انتخاب اتاق محل اقامت", style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                  value: _selectedRoomForReview,
                  items: rooms.map((Room room) {
                    return DropdownMenuItem<Room>(
                      value: room,
                      child: Text(room.name, style: TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis),
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
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("امتیاز", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                Icon(Icons.more_horiz, color: Color(0xFF542545), size: 20),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  icon: Icon(
                    index < _newReviewRating ? Icons.star : Icons.star_border,
                    color: Color(0xFF542545),
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
            _buildFeedbackSection(
              title: "افزودن نکته مثبت",
              addIcon: Icons.add_circle_outline,
              removeIcon: Icons.remove_circle_outline,
              controllers: _positiveFeedbackControllers,
              onAddField: _addPositiveFeedbackField,
              onRemoveField: _removePositiveFeedbackField,
              hintTextPrefix: "نکته مثبت",
            ),
            const SizedBox(height: 20),
            _buildFeedbackSection(
              title: "افزودن نکته منفی",
              addIcon: Icons.add_circle_outline,
              removeIcon: Icons.remove_circle_outline,
              controllers: _negativeFeedbackControllers,
              onAddField: _addNegativeFeedbackField,
              onRemoveField: _removeNegativeFeedbackField,
              hintTextPrefix: "نکته منفی",
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: Icon(Icons.send_outlined, color: Color(0xFF542545), size: 28),
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
    required IconData removeIcon,
    required List<TextEditingController> controllers,
    required VoidCallback onAddField,
    required Function(int) onRemoveField,
    required String hintTextPrefix,
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
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            InkWell(
              onTap: onAddField,
              child: Icon(addIcon, color: Color(0xFF542545), size: 22),
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
                        filled: true,
                        fillColor: Color(0xFFEEEEEE),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      minLines: 1,
                      maxLines: 3,
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                  if (controllers.length > 1)
                    IconButton(
                      icon: Icon(removeIcon, color: Color(0xFFEEEEEE), size: 20),
                      onPressed: () => onRemoveField(index),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
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
    if (_selectedRoomForReview == null && await _roomsFuture != null && (await _roomsFuture)!.isNotEmpty) {
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
          return const Dialog(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 20),
                  Text("در حال ارسال نظر..."),
                ],
              ),
            ),
          );
        },
      );
    }

    bool success = await _apiService.submitReview(widget.hotelId, reviewData);

    if (mounted) {
      Navigator.pop(context);
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("نظر شما با موفقیت ثبت شد.", textDirection: TextDirection.rtl)),
      );
      _positiveFeedbackControllers.forEach((c) => c.clear());
      _negativeFeedbackControllers.forEach((c) => c.clear());

      if (_positiveFeedbackControllers.length > 1) {
        setState(() { _positiveFeedbackControllers = [TextEditingController()]; });
      }
      if (_negativeFeedbackControllers.length > 1) {
        setState(() { _negativeFeedbackControllers = [TextEditingController()]; });
      }

      setState(() {
        _newReviewRating = 3.0;
        if (_roomsFuture != null) {
          _roomsFuture!.then((rooms) {
            if (mounted && rooms.isNotEmpty) {
              setState(() {
                _selectedRoomForReview = rooms.first;
              });
            } else if (mounted) {
              setState(() {
                _selectedRoomForReview = null;
              });
            }
          });
        } else if (mounted) {
          setState(() {
            _selectedRoomForReview = null;
          });
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