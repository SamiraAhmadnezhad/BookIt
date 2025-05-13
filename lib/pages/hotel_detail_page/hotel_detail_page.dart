import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl; // For number formatting

class HotelDetails {
  final String id;
  final String name;
  final String address;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final String description;
  final List<Amenity> amenities;

  HotelDetails({
    required this.id,
    required this.name,
    required this.address,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.description,
    required this.amenities,
  });

// TODO
// factory HotelDetails.fromJson(Map<String, dynamic> json) { ... }
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
// TODO
// factory Room.fromJson(Map<String, dynamic> json) { ... }
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
// TODO
// factory Review.fromJson(Map<String, dynamic> json) { ... }
}
// endregion

// region API Service Stubs
class ApiService {
  Future<HotelDetails> fetchHotelDetails(String hotelId) async {
    // TODO
    await Future.delayed(const Duration(seconds: 1));
    return HotelDetails(
      id: hotelId,
      name: "نام هتل در حالت طولانی تست",
      address: "آدرس در حالت طولانی",
      imageUrl: "https://picsum.photos/seed/hotel/800/400", // Placeholder image
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
    );
  }

  Future<List<Room>> fetchHotelRooms(String hotelId) async {
    // TODO
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
    // TODO
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
    // TODO
    print("Submitting review for hotel $hotelId: ${reviewData.userName}");
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  Future<bool> toggleFavoriteHotel(String hotelId, bool isFavorite) async {
    // TODO
    print("Toggling favorite for hotel $hotelId to ${!isFavorite}");
    await Future.delayed(const Duration(milliseconds: 500));
    return !isFavorite;
  }
}
// endregion

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

  bool _isFavorite = false;

  // Controllers for Add Review Form
  final _positiveTitleController = TextEditingController();
  final _positiveDetailController = TextEditingController();
  final _negativeTitleController = TextEditingController();
  final _negativeDetailController = TextEditingController();
  double _newReviewRating = 3.0; // Default rating

  @override
  void initState() {
    super.initState();
    _loadData();
    // TODO
  }

  void _loadData() {
    setState(() {
      _hotelDetailsFuture = _apiService.fetchHotelDetails(widget.hotelId);
      _roomsFuture = _apiService.fetchHotelRooms(widget.hotelId);
      _reviewsFuture = _apiService.fetchHotelReviews(widget.hotelId);
    });
  }

  Future<void> _toggleFavorite() async {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    try {
      bool success = await _apiService.toggleFavoriteHotel(widget.hotelId, _isFavorite);
      // setState(() { _isFavorite = success; });
    } catch (e) {
      setState(() {
        _isFavorite = !_isFavorite;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("خطا در به‌روزرسانی علاقه‌مندی", textDirection: TextDirection.rtl)),
      );
    }
  }

  String _formatPrice(double price) {
    final formatter = intl.NumberFormat("#,###", "fa_IR");
    return formatter.format(price);
  }


  @override
  void dispose() {
    _positiveTitleController.dispose();
    _positiveDetailController.dispose();
    _negativeTitleController.dispose();
    _negativeDetailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        // appBar: AppBar(title: Text("جزئیات هتل")),
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
                    ElevatedButton(onPressed: _loadData, child: const Text("تلاش مجدد", textDirection: TextDirection.rtl))
                  ],
                ),
              );
            }

            final hotel = snapshot.data!;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHotelImage(hotel.imageUrl),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHotelHeader(hotel.name, hotel.address),
                        const SizedBox(height: 8),
                        _buildRating(hotel.rating, hotel.reviewCount),
                        const SizedBox(height: 16),
                        _buildSectionTitle("درباره هتل (نام هتل)"),
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
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHotelImage(String imageUrl) {
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
            color: Colors.grey[300],
            child: Icon(Icons.broken_image, size: 50, color: Colors.grey[600]),
          ),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: screenWidth,
              height: screenWidth * 0.6,
              color: Colors.grey[200],
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
          left: 16,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.red : Colors.white,
              ),
              onPressed: _toggleFavorite,
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
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                address,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
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
            color: Colors.amber,
            size: 20,
          ),
        const SizedBox(width: 8),
        Text(
          "$rating از 5 (${intl.NumberFormat("#,###", "fa_IR").format(reviewCount)} نظر)",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          margin: const EdgeInsets.only(left: 8),
          child: Icon(
            title == "درباره هتل (نام هتل)" ? Icons.info_outline :
            title == "امکانات و ویژگی ها" ? Icons.tune_outlined :
            title == "لیست اتاق ها" ? Icons.hotel_outlined :
            title == "نظرات" ? Icons.chat_bubble_outline :
            title == "ثبت نظر" ? Icons.edit_note_outlined :
            Icons.circle, // Default icon
            size: 18,
            color: Theme.of(context).primaryColorDark,
          ),
        ),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildAmenitiesGrid(List<Amenity> amenities) {
    // اگر تعداد امکانات زیاد است، استفاده از GridView مناسب‌تر است
    // برای تعداد کم، Row یا Wrap هم کافیست
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
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(amenity.icon, size: 28, color: Theme.of(context).primaryColorDark),
            ),
            const SizedBox(height: 4),
            Text(amenity.name, style: Theme.of(context).textTheme.bodySmall),
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
        return ListView.separated(
          physics: const NeverScrollableScrollPhysics(), // برای جلوگیری از اسکرول داخلی
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
                  width: 100, height: 100, color: Colors.grey[300],
                  child: Icon(Icons.broken_image, size: 30, color: Colors.grey[600]),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(room.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.people_alt_outlined, size: 16, color: Colors.grey[700]),
                      const SizedBox(width: 4),
                      Text("ظرفیت ${room.capacity} نفر", style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.restaurant_menu_outlined, size: 16, color: Colors.grey[700]),
                      const SizedBox(width: 4),
                      Text(room.breakfastInfo, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("قیمت برای ۳ شب", style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey[600])),
                          Text(
                            "${_formatPrice(room.pricePerNight)} تومان",
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColorDark),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.thumb_up_alt_outlined, size: 16, color: Colors.blue),
                          const SizedBox(width: 4),
                          Text(room.rating.toString(), style: Theme.of(context).textTheme.bodySmall),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft, // برای RTL
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: پیاده‌سازی ناوبری به صفحه رزرو اتاق
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("دکمه رزرو اتاق ${room.name} فشرده شد", textDirection: TextDirection.rtl)),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
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
                Text(review.userName, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                Text(review.date, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
              ],
            ),
            const SizedBox(height: 8),
            _buildFeedbackPoint(icon: Icons.add_circle_outline, text: "نکات مثبت: ${review.positiveFeedback}", color: Colors.green),
            const SizedBox(height: 4),
            _buildFeedbackPoint(icon: Icons.remove_circle_outline, text: "نکات منفی: ${review.negativeFeedback}", color: Colors.red),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.thumb_up_alt_outlined, size: 18, color: Colors.blue),
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
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("امتیاز شما:", style: Theme.of(context).textTheme.titleMedium),
                Row(
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < _newReviewRating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                      ),
                      onPressed: () {
                        setState(() {
                          _newReviewRating = index + 1.0;
                        });
                      },
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildReviewTextField(_positiveTitleController, "عنوان نکته مثبت (اختیاری)"),
            const SizedBox(height: 8),
            _buildReviewTextField(_positiveDetailController, "نکته مثبت ۱"),
            const SizedBox(height: 12),
            _buildReviewTextField(_negativeTitleController, "عنوان نکته منفی (اختیاری)"),
            const SizedBox(height: 8),
            _buildReviewTextField(_negativeDetailController, "نکته منفی ۱"),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColorDark,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("ارسال نظر"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      minLines: label.contains("عنوان") ? 1 : 2,
      maxLines: label.contains("عنوان") ? 1 : 3,
      textDirection: TextDirection.rtl,
    );
  }

  Future<void> _submitReview() async {
    if (_positiveDetailController.text.isEmpty && _negativeDetailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("لطفا حداقل یک نکته مثبت یا منفی وارد کنید.", textDirection: TextDirection.rtl)),
      );
      return;
    }

    final reviewData = Review( // userId باید از سیستم احراز هویت گرفته شود
      userId: "currentUser", // Placeholder
      userName: "شما", // Placeholder, سرور باید نام کاربر را بداند
      date: intl.DateFormat('yyyy/MM/dd', 'fa_IR').format(DateTime.now()), // فرمت تاریخ شمسی
      positiveFeedback: "${_positiveTitleController.text}: ${_positiveDetailController.text}".trim(),
      negativeFeedback: "${_negativeTitleController.text}: ${_negativeDetailController.text}".trim(),
      rating: _newReviewRating,
    );

    // نمایش یک لودینگ کوچک
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

    bool success = await _apiService.submitReview(widget.hotelId, reviewData);
    Navigator.pop(context); // بستن دیالوگ لودینگ

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("نظر شما با موفقیت ثبت شد.", textDirection: TextDirection.rtl)),
      );
      // پاک کردن فیلدها و رفرش لیست نظرات
      _positiveTitleController.clear();
      _positiveDetailController.clear();
      _negativeTitleController.clear();
      _negativeDetailController.clear();
      setState(() {
        _newReviewRating = 3.0;
        _reviewsFuture = _apiService.fetchHotelReviews(widget.hotelId); // رفرش لیست نظرات
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("خطا در ثبت نظر. لطفا دوباره تلاش کنید.", textDirection: TextDirection.rtl)),
      );
    }
  }
}