import 'package:flutter/material.dart';

// TODO: این مدل را بر اساس داده‌های واقعی سرور خود تکمیل یا جایگزین کنید
class UserProfileModel {
  final String name;
  final String email;
  final String? avatarUrl; // آدرس تصویر پروفایل کاربر می‌تواند null باشد

  UserProfileModel({required this.name, required this.email, this.avatarUrl});

// TODO: یک factory constructor برای تبدیل JSON به این مدل ایجاد کنید
// factory UserProfileModel.fromJson(Map<String, dynamic> json) {
//   return UserProfileModel(
//     name: json['name'],
//     email: json['email'],
//     avatarUrl: json['avatarUrl'],
//   );
// }
}

// TODO: این مدل را بر اساس داده‌های واقعی سرور خود تکمیل یا جایگزین کنید
class FavoriteHotelModel {
  final String id;
  final String imageUrl;
  final String name;
  final double userRating; // امتیاز کاربران مثلا 4.5
  final int starRating; // ستاره هتل مثلا 4 ستاره
  final String priceDisplay; // قیمت به صورت رشته نمایش "۳٬۲۰۰٬۰۰۰"
  final String currency; // مثلا "تومان"
  final String location;
  final bool isFavorite; // برای آیکون قلب

  FavoriteHotelModel({
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.userRating,
    required this.starRating,
    required this.priceDisplay,
    required this.currency,
    required this.location,
    this.isFavorite = true,
  });

// TODO: یک factory constructor برای تبدیل JSON به این مدل ایجاد کنید
// factory FavoriteHotelModel.fromJson(Map<String, dynamic> json) {
//   return FavoriteHotelModel(...);
// }
}


class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final Color primaryPurple = const Color(0xFF542545);
  String _selectedTab = 'علاقه‌مندی‌ها';

  UserProfileModel? _userProfile;
  List<FavoriteHotelModel> _favoriteHotels = [];
  // TODO: مدل‌های مشابه برای لیست رزروها و رزروهای قبلی تعریف کنید
  // List<BookingModel> _currentBookings = [];
  // List<BookingModel> _previousBookings = [];

  bool _isLoadingProfile = true;
  bool _isLoadingFavorites = true;
  // TODO: متغیرهای isLoading برای تب‌های دیگر
  // bool _isLoadingCurrentBookings = true;
  // bool _isLoadingPreviousBookings = true;


  @override
  void initState() {
    super.initState();
    _fetchDataForPage();
  }

  Future<void> _fetchDataForPage() async {
    await _fetchUserProfile();
    await _fetchFavoriteHotels();
    // TODO: فراخوانی توابع fetch برای تب‌های دیگر
    // await _fetchCurrentBookings();
    // await _fetchPreviousBookings();
  }

  // TODO: تابع دریافت اطلاعات پروفایل کاربر از سرور
  Future<void> _fetchUserProfile() async {
    setState(() {
      _isLoadingProfile = true;
    });
    try {
      // شبیه‌سازی تاخیر شبکه
      await Future.delayed(const Duration(seconds: 1));
      // TODO: اینجا کد واقعی فراخوانی API برای دریافت اطلاعات کاربر قرار می‌گیرد
      // final response = await http.get(Uri.parse('YOUR_USER_PROFILE_API_ENDPOINT'));
      // if (response.statusCode == 200) {
      //   final data = json.decode(response.body);
      //   _userProfile = UserProfileModel.fromJson(data);
      // } else {
      //   // TODO: مدیریت خطا
      // }
      _userProfile = UserProfileModel(name: 'علی علوی', email: 'alialavi@gmail.com');
    } catch (e) {
      // TODO: مدیریت خطا در دریافت اطلاعات کاربر
      print('Error fetching user profile: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }

  // TODO: تابع دریافت لیست هتل‌های مورد علاقه از سرور
  Future<void> _fetchFavoriteHotels() async {
    if (_selectedTab != 'علاقه‌مندی‌ها' && _favoriteHotels.isNotEmpty) return; // فقط اگر تب فعال است و دیتا نداریم، fetch کن
    setState(() {
      _isLoadingFavorites = true;
    });
    try {
      await Future.delayed(const Duration(seconds: 1));
      // TODO: اینجا کد واقعی فراخوانی API برای دریافت لیست علاقه‌مندی‌ها قرار می‌گیرد
      _favoriteHotels = [
        FavoriteHotelModel(
          id: '1',
          imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NXx8aG90ZWx8ZW58MHx8MHx8fDA%3D&w=1000&q=80',
          name: 'اسم هتل در حالت طولانی که ممکن است دو خط شود',
          userRating: 4.5,
          starRating: 4,
          priceDisplay: '۳٬۲۰۰٬۰۰۰',
          currency: 'تومان',
          location: 'مکان هتل نمونه',
        ),
        // TODO: در صورت نیاز، آیتم‌های بیشتر اضافه کنید
      ];
    } catch (e) {
      // TODO: مدیریت خطا در دریافت لیست علاقه‌مندی‌ها
      print('Error fetching favorite hotels: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingFavorites = false;
        });
      }
    }
  }

  // TODO: تابع دریافت لیست رزروهای فعلی از سرور
  Future<void> _fetchCurrentBookings() async {
    if (_selectedTab != 'لیست رزروها') return;
    // setState(() { _isLoadingCurrentBookings = true; });
    try {
      await Future.delayed(const Duration(seconds: 1));
      // TODO: اینجا کد واقعی فراخوانی API برای دریافت لیست رزروهای فعلی قرار می‌گیرد
      // _currentBookings = parseBookings(response.body);
    } catch (e) {
      // TODO: مدیریت خطا
    } finally {
      // if (mounted) setState(() { _isLoadingCurrentBookings = false; });
    }
  }

  // TODO: تابع دریافت لیست رزروهای قبلی از سرور
  Future<void> _fetchPreviousBookings() async {
    if (_selectedTab != 'رزروهای قبلی') return;
    // setState(() { _isLoadingPreviousBookings = true; });
    try {
      await Future.delayed(const Duration(seconds: 1));
      // TODO: اینجا کد واقعی فراخوانی API برای دریافت لیست رزروهای قبلی قرار می‌گیرد
      // _previousBookings = parseBookings(response.body);
    } catch (e) {
      // TODO: مدیریت خطا
    } finally {
      // if (mounted) setState(() { _isLoadingPreviousBookings = false; });
    }
  }

  // TODO: تابع خروج از حساب کاربری (احتمالا نیاز به فراخوانی API دارد)
  Future<void> _logoutUser() async {
    // TODO: کد مربوط به پاک کردن توکن کاربر، فراخوانی API خروج و هدایت به صفحه ورود
    print('Logout tapped');
  }

  // TODO: تابع برای ویرایش اطلاعات کاربر (ممکن است به صفحه دیگری هدایت شود یا یک دیالوگ باز کند)
  void _editProfile() {
    // TODO: پیاده‌سازی منطق ویرایش پروفایل
    print('Edit profile tapped');
  }

  // TODO: تابع برای رزرو هتل (احتمالا به صفحه جزئیات هتل یا رزرو هدایت می‌کند)
  void _reserveHotel(String hotelId) {
    // TODO: پیاده‌سازی منطق رزرو هتل
    print('Reserve hotel $hotelId tapped');
  }

  // TODO: تابع برای افزودن/حذف از علاقه‌مندی‌ها (نیاز به فراخوانی API دارد)
  Future<void> _toggleFavoriteStatus(String hotelId, bool currentStatus) async {
    // TODO: پیاده‌سازی منطق تغییر وضعیت علاقه‌مندی در سرور و آپدیت UI
    // این یک مثال ساده است، شما باید state محلی را نیز آپدیت کنید
    final newStatus = !currentStatus;
    print('Toggling favorite for $hotelId to $newStatus');
    // شبیه‌سازی آپدیت UI
    setState(() {
      final index = _favoriteHotels.indexWhere((h) => h.id == hotelId);
      if (index != -1) {
        _favoriteHotels[index] = FavoriteHotelModel(
          id: _favoriteHotels[index].id,
          imageUrl: _favoriteHotels[index].imageUrl,
          name: _favoriteHotels[index].name,
          userRating: _favoriteHotels[index].userRating,
          starRating: _favoriteHotels[index].starRating,
          priceDisplay: _favoriteHotels[index].priceDisplay,
          currency: _favoriteHotels[index].currency,
          location: _favoriteHotels[index].location,
          isFavorite: newStatus, // آپدیت وضعیت
        );
      }
    });
  }


  Widget _buildTabButton(String title) {
    bool isSelected = _selectedTab == title;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_selectedTab != title) {
            setState(() {
              _selectedTab = title;
            });
            // TODO: فراخوانی تابع fetch مربوط به تب جدید در صورت نیاز
            if (title == 'علاقه‌مندی‌ها' && _favoriteHotels.isEmpty) {
              _fetchFavoriteHotels();
            } else if (title == 'لیست رزروها' /* && _currentBookings.isEmpty */) {
              _fetchCurrentBookings();
            } else if (title == 'رزروهای قبلی' /* && _previousBookings.isEmpty */) {
              _fetchPreviousBookings();
            }
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? primaryPurple : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: isSelected ? null : Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : primaryPurple,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(Icons.notifications_none_outlined, color: primaryPurple, size: 28),
            onPressed: () {
              // TODO: Action for notifications
            },
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 8.0, top: 8.0, bottom: 8.0),
              child: ElevatedButton(
                onPressed: _logoutUser, // TODO: اتصال به تابع خروج از حساب
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('خروج از حساب کاربری', style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: _isLoadingProfile
                  ? const CircularProgressIndicator()
                  : Column(
                children: [
                  // TODO: نمایش آواتار کاربر از _userProfile.avatarUrl
                  Icon(
                    Icons.account_circle,
                    size: 100,
                    color: primaryPurple.withOpacity(0.8),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _userProfile?.name ?? 'کاربر مهمان',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _userProfile?.email ?? '',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 4),
                      if (_userProfile?.email.isNotEmpty ?? false) // فقط اگر ایمیل وجود دارد، تیک را نشان بده
                        Icon(Icons.check_circle, color: Colors.green[600], size: 16),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
                ),
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    InkWell(
                      onTap: _editProfile, // TODO: اتصال به تابع ویرایش پروفایل
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('ویرایش اطلاعات', style: TextStyle(fontSize: 15, color: Colors.black87)),
                            Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _buildTabButton('رزروهای قبلی'),
                        _buildTabButton('لیست رزروها'),
                        _buildTabButton('علاقه‌مندی‌ها'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSelectedTabContent(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedTabContent() {
    if (_selectedTab == 'علاقه‌مندی‌ها') {
      if (_isLoadingFavorites) {
        return const Center(child: CircularProgressIndicator());
      }
      if (_favoriteHotels.isEmpty) {
        return const Center(child: Padding(
          padding: EdgeInsets.all(30.0),
          child: Text('موردی برای نمایش در علاقه‌مندی‌ها وجود ندارد.', style: TextStyle(fontSize: 16, color: Colors.grey)),
        ));
      }
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _favoriteHotels.length,
        itemBuilder: (context, index) {
          return _buildFavoriteItemCard(_favoriteHotels[index]);
        },
      );
    } else if (_selectedTab == 'لیست رزروها') {
      // TODO: نمایش لودینگ و لیست رزروهای فعلی
      // if (_isLoadingCurrentBookings) return Center(child: CircularProgressIndicator());
      // if (_currentBookings.isEmpty) return Center(child: Text('لیست رزروها خالی است.'));
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(30.0),
          child: Text('لیست رزروها در اینجا نمایش داده می‌شود.', style: TextStyle(fontSize: 16, color: Colors.grey)),
        ),
      );
    } else if (_selectedTab == 'رزروهای قبلی') {
      // TODO: نمایش لودینگ و لیست رزروهای قبلی
      // if (_isLoadingPreviousBookings) return Center(child: CircularProgressIndicator());
      // if (_previousBookings.isEmpty) return Center(child: Text('رزرو قبلی وجود ندارد.'));
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(30.0),
          child: Text('رزروهای قبلی در اینجا نمایش داده می‌شود.', style: TextStyle(fontSize: 16, color: Colors.grey)),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildFavoriteItemCard(FavoriteHotelModel hotel) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Image.network(
                  hotel.imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 180,
                      color: Colors.grey[200],
                      child: Center(child: Icon(Icons.broken_image, color: Colors.grey[400], size: 40)),
                    );
                  },
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: InkWell(
                  onTap: () => _toggleFavoriteStatus(hotel.id, hotel.isFavorite), // TODO: اتصال به تابع تغییر وضعیت علاقه‌مندی
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                        hotel.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: primaryPurple,
                        size: 22
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(hotel.userRating.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(width: 4),
                      const Icon(Icons.thumb_up_alt_rounded, color: Colors.white, size: 14),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hotel.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < hotel.starRating ? Icons.star_rounded : Icons.star_border_rounded,
                      color: const Color(0xFFFFC107),
                      size: 20,
                    );
                  }),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.account_balance_wallet_outlined, color: Colors.grey[700], size: 18),
                    const SizedBox(width: 6),
                    const Text('شروع قیمت از', style: TextStyle(fontSize: 13, color: Colors.black54)),
                    const Spacer(),
                    Text(
                      hotel.priceDisplay,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(width: 3),
                    Text(hotel.currency, style: TextStyle(fontSize: 11, color: Colors.grey[700])),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, color: Colors.grey[700], size: 18),
                    const SizedBox(width: 6),
                    Text(hotel.location, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                  ],
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton.icon(
                    onPressed: () => _reserveHotel(hotel.id), // TODO: اتصال به تابع رزرو
                    icon: const Icon(Icons.arrow_back_ios_new, size: 14, color: Colors.white),
                    label: const Text('رزرو', style: TextStyle(color: Colors.white, fontSize: 14)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}