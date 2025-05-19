import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../authentication_page/auth_service.dart';
import 'edit_profile_page.dart';
import '../../authentication_page/authentication_page.dart';


// ... (کلاس‌های مدل UserProfileModel, FavoriteHotelModel, BookingModel, PreviousBookingModel بدون تغییر) ...
class UserProfileModel {
  final String name;
  final String email;
  final String? avatarUrl;
  UserProfileModel({required this.name, required this.email, this.avatarUrl});
}
class FavoriteHotelModel {
  final String id;
  final String imageUrl;
  final String name;
  final double userRating;
  final int starRating;
  final String priceDisplay;
  final String currency;
  final String location;
  final bool isFavorite;
  FavoriteHotelModel({ required this.id, required this.imageUrl, required this.name, required this.userRating, required this.starRating, required this.priceDisplay, required this.currency, required this.location, this.isFavorite = true });
}
class BookingModel {
  final String id;
  final String hotelId;
  final String imageUrl;
  final String hotelName;
  final double userRating;
  final int starRating;
  final String priceDisplay;
  final String currency;
  final String location;
  BookingModel({ required this.id, required this.hotelId, required this.imageUrl, required this.hotelName, required this.userRating, required this.starRating, required this.priceDisplay, required this.currency, required this.location });
}
class PreviousBookingModel {
  final String id;
  final String hotelId;
  final String hotelName;
  final String imageUrl;
  final double? userRating;
  PreviousBookingModel({ required this.id, required this.hotelId, required this.hotelName, required this.imageUrl, this.userRating});
}


class UserAccountPage extends StatefulWidget {
  const UserAccountPage({super.key});
  @override
  State<UserAccountPage> createState() => _UserAccountPageState();
}

class _UserAccountPageState extends State<UserAccountPage> {
  final Color primaryPurple = const Color(0xFF542545);
  String _selectedTab = 'علاقه‌مندی‌ها'; // تب پیش‌فرض

  UserProfileModel? _userProfile;
  List<FavoriteHotelModel> _favoriteHotels = [];
  List<BookingModel> _currentBookings = [];
  List<PreviousBookingModel> _previousBookings = [];

  bool _isLoadingProfile = true;
  bool _isLoadingFavorites = true;
  bool _isLoadingCurrentBookings = false;
  bool _isLoadingPreviousBookings = false;
  // bool _isLoggingOut = false; // دیگر لازم نیست، از authService.isLoading استفاده می‌کنیم

  final double _cardWidthHorizontal = 300.0;
  final double _horizontalListHeight = 390.0;
  final double _interCardSpacingHorizontal = 12.0;
  final double _interCardSpacingVertical = 12.0;


  @override
  void initState() {
    super.initState();
    print("UserAccountPage: initState - Fetching initial data...");
    _fetchDataForPage();
  }

  @override
  void dispose() {
    print("UserAccountPage: dispose");
    super.dispose();
  }

  Future<void> _fetchDataForPage() async {
    await _fetchUserProfile();
    if (!mounted) return;
    if (_selectedTab == 'علاقه‌مندی‌ها') {
      await _fetchFavoriteHotels();
    } else if (_selectedTab == 'لیست رزروها') {
      await _fetchCurrentBookings();
    } else if (_selectedTab == 'رزروهای قبلی') {
      await _fetchPreviousBookings();
    }
  }

  Future<void> _fetchUserProfile() async {
    print("UserAccountPage: _fetchUserProfile started.");
    if (!mounted) return;
    setState(() { _isLoadingProfile = true; });
    try {
      // TODO: Fetch real profile data using AuthService for token and correct API service
      await Future.delayed(const Duration(seconds: 1)); // Mock
      if (!mounted) return;
      _userProfile = UserProfileModel(name: 'علی علوی', email: 'alialavi@gmail.com');
      print("UserAccountPage: User profile data mocked.");
    } catch (e) {
      print("UserAccountPage: Error fetching user profile: $e");
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطا در بارگذاری پروفایل: ${e.toString()}'), backgroundColor: Colors.red));
    }
    finally {
      if (mounted) {
        setState(() { _isLoadingProfile = false; });
        print("UserAccountPage: _fetchUserProfile finished. _isLoadingProfile: $_isLoadingProfile");
      }
    }
  }

  Future<void> _fetchFavoriteHotels() async {
    print("UserAccountPage: _fetchFavoriteHotels started.");
    if ((_selectedTab != 'علاقه‌مندی‌ها' && _favoriteHotels.isNotEmpty && !_isLoadingFavorites) || !mounted) return;
    setState(() { _isLoadingFavorites = true; });
    try {
      // TODO: Fetch real favorite hotels using AuthService for token and correct API service
      await Future.delayed(const Duration(seconds: 1)); // Mock
      if (!mounted) return;
      _favoriteHotels = List.generate(3, (index) => FavoriteHotelModel(id: 'fav${index+1}', imageUrl: 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=300', name: 'هتل لوکس مورد علاقه ${index+1}', userRating: 4.8, starRating: 5, priceDisplay: '۵٬${index}۰۰٬۰۰۰', currency: 'تومان', location: 'تهران'));
      print("UserAccountPage: Favorite hotels data mocked.");
    } catch (e) {
      print("UserAccountPage: Error fetching favorite hotels: $e");
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطا در بارگذاری علاقه‌مندی‌ها: ${e.toString()}'), backgroundColor: Colors.red));
    }
    finally {
      if (mounted) {
        setState(() { _isLoadingFavorites = false; });
        print("UserAccountPage: _fetchFavoriteHotels finished. _isLoadingFavorites: $_isLoadingFavorites");
      }
    }
  }

  Future<void> _fetchCurrentBookings() async {
    print("UserAccountPage: _fetchCurrentBookings started.");
    if ((_selectedTab != 'لیست رزروها' && _currentBookings.isNotEmpty && !_isLoadingCurrentBookings) || !mounted) return;
    setState(() { _isLoadingCurrentBookings = true; });
    try {
      // TODO: Fetch real current bookings using AuthService for token and correct API service
      await Future.delayed(const Duration(seconds: 1)); // Mock
      if (!mounted) return;
      _currentBookings = List.generate(3, (index) => BookingModel(id: 'booking${index+1}', hotelId: 'hotel_xyz_${index+1}', imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=300', hotelName: 'هتل رزرو شده ${index+1}', userRating: 4.5, starRating: 4, priceDisplay: '۳٬${index}۵۰٬۰۰۰', currency: 'تومان', location: 'مکان هتل ${index+1}'));
      print("UserAccountPage: Current bookings data mocked.");
    } catch (e) {
      print("UserAccountPage: Error fetching current bookings: $e");
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطا در بارگذاری رزروهای فعلی: ${e.toString()}'), backgroundColor: Colors.red));
    }
    finally {
      if (mounted) {
        setState(() { _isLoadingCurrentBookings = false; });
        print("UserAccountPage: _fetchCurrentBookings finished. _isLoadingCurrentBookings: $_isLoadingCurrentBookings");
      }
    }
  }

  Future<void> _fetchPreviousBookings() async {
    print("UserAccountPage: _fetchPreviousBookings started.");
    if ((_selectedTab != 'رزروهای قبلی' && _previousBookings.isNotEmpty && !_isLoadingPreviousBookings) || !mounted) return;
    setState(() { _isLoadingPreviousBookings = true; });
    try {
      // TODO: Fetch real previous bookings using AuthService for token and correct API service
      await Future.delayed(const Duration(seconds: 1)); // Mock
      if (!mounted) return;
      _previousBookings = List.generate(5, (index) => PreviousBookingModel(id: 'prev_booking_${index+1}', hotelId: 'hotel_abc_${index+1}', hotelName: 'اسم هتل در حالت طولانی برای رزرو قبلی شماره ${index+1}', imageUrl: 'https://images.unsplash.com/photo-1582719478250-c89caE4dc85b?w=100&h=100&fit=crop', userRating: (index % 2 == 0) ? 4.5 : null ));
      print("UserAccountPage: Previous bookings data mocked.");
    } catch (e) {
      print("UserAccountPage: Error fetching previous bookings: $e");
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطا در بارگذاری رزروهای قبلی: ${e.toString()}'), backgroundColor: Colors.red));
    }
    finally {
      if (mounted) {
        setState(() { _isLoadingPreviousBookings = false; });
        print("UserAccountPage: _fetchPreviousBookings finished. _isLoadingPreviousBookings: $_isLoadingPreviousBookings");
      }
    }
  }

  // ***** تابع خروج از حساب کاربری *****
  Future<void> _logoutUser() async {
    print("UserAccountPage: _logoutUser called.");
    final authService = Provider.of<AuthService>(context, listen: false);

    if (authService.isLoading) {
      print("UserAccountPage: AuthService is already busy. Logout request ignored.");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('عملیات دیگری در حال انجام است، لطفا صبر کنید.'), backgroundColor: Colors.orange),
        );
      }
      return;
    }

    try {
      print("UserAccountPage: Calling authService.logout(). Current token: ${authService.token}");
      await authService.logout();
      print("UserAccountPage: authService.logout() completed. Error from service: ${authService.errorMessage}");

      if (!mounted) return;

      if (authService.errorMessage != null && authService.errorMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('توجه: ${authService.errorMessage}'), backgroundColor: Colors.orange),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('شما با موفقیت از حساب کاربری خود خارج شدید.'), backgroundColor: Colors.green),
        );
      }
      // هدایت به صفحه لاگین
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthenticationPage()), // صفحه لاگین شما
            (Route<dynamic> route) => false,
      );

    } catch (e) {
      print("UserAccountPage: Error in _logoutUser UI catch block: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطای پیش‌بینی نشده هنگام خروج (UI): ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
    // isLoading مربوط به AuthService در خود AuthService مدیریت می‌شود و نیازی به setState محلی نیست.
  }

  void _editProfile() {
    print("UserAccountPage: _editProfile called");
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const EditProfilePage(
          // initialProfileData: _userProfile, // پاس دادن اطلاعات فعلی در صورت نیاز
        ),
      ),
    ).then((value) {
      if (value == true && mounted) { // اگر صفحه ویرایش با موفقیت بسته شد
        print("UserAccountPage: Returned from edit profile, fetching profile again...");
        _fetchUserProfile();
      }
    });
  }

  void _viewBookingDetails(String bookingId) {
    print("UserAccountPage: View details for booking $bookingId");
    // TODO: Navigate to booking details page
  }
  Future<void> _toggleFavoriteStatus(String hotelId, bool currentStatus) async {
    print("UserAccountPage: Toggle favorite for hotel $hotelId, current status: $currentStatus");
    // TODO: Call API to toggle favorite status
    // Mock behavior:
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() {
      final index = _favoriteHotels.indexWhere((h) => h.id == hotelId);
      if (index != -1) {
        // این روش ساده‌انگارانه است. در عمل، باید لیست را از سرور دوباره fetch کنید
        // یا پاسخ API را برای به‌روزرسانی دقیق به کار ببرید.
        // برای این مثال، فقط وضعیت isFavorite را در آیتم محلی تغییر می‌دهیم
        // و سپس لیست را فیلتر می‌کنیم تا آیتم حذف شده (اگر دیگر favorite نیست) نمایش داده نشود.
        var hotel = _favoriteHotels[index];
        _favoriteHotels[index] = FavoriteHotelModel(
            id: hotel.id, imageUrl: hotel.imageUrl, name: hotel.name, userRating: hotel.userRating,
            starRating: hotel.starRating, priceDisplay: hotel.priceDisplay, currency: hotel.currency,
            location: hotel.location, isFavorite: !currentStatus
        );
        // اگر می‌خواهید آیتم بلافاصله از لیست حذف شود وقتی دیگر favorite نیست:
        if (!currentStatus == false) { // یعنی اگر از favorite به non-favorite تغییر کرد
          _favoriteHotels.removeAt(index);
        }
      }
    });
  }
  void _reserveFavoriteHotel(String hotelId) {
    print("UserAccountPage: Reserve favorite hotel $hotelId");
    // TODO: Navigate to hotel details/booking page for this hotelId
  }
  void _ratePreviousBooking(String previousBookingId) {
    print("UserAccountPage: Rate previous booking $previousBookingId");
    // TODO: Navigate to rating page for this previousBookingId
  }

  Widget _buildTabButton(String title) {
    bool isSelected = _selectedTab == title;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_selectedTab != title) {
            if (!mounted) return;
            setState(() { _selectedTab = title; });
            if (title == 'علاقه‌مندی‌ها' && (_favoriteHotels.isEmpty || _isLoadingFavorites)) {
              _fetchFavoriteHotels();
            } else if (title == 'لیست رزروها' && (_currentBookings.isEmpty || _isLoadingCurrentBookings)) {
              _fetchCurrentBookings();
            } else if (title == 'رزروهای قبلی' && (_previousBookings.isEmpty || _isLoadingPreviousBookings)) {
              _fetchPreviousBookings();
            }
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12), margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(color: isSelected ? primaryPurple : Colors.white, borderRadius: BorderRadius.circular(8), border: isSelected ? null : Border.all(color: Colors.grey.shade300)),
          child: Text(title, textAlign: TextAlign.center, style: TextStyle(color: isSelected ? Colors.white : primaryPurple, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final bool isAuthServiceLoading = authService.isLoading;

    print("--- UserAccountPage Build Method ---");
    print("Selected Tab: $_selectedTab");
    print("AuthService isLoading: $isAuthServiceLoading, IsAuthenticated: ${authService.isAuthenticated}, Token: ${authService.token}");

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white, elevation: 0, automaticallyImplyLeading: false,
          leading: IconButton(icon: Icon(Icons.notifications_none_outlined, color: primaryPurple, size: 28), onPressed: () { /* TODO: Notification action */ }),
          actions: [
            Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 8.0, top: 8.0, bottom: 8.0),
                child: ElevatedButton(
                  onPressed: isAuthServiceLoading ? null : _logoutUser,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: primaryPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                  ),
                  child: isAuthServiceLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                      : const Text('خروج از حساب کاربری', style: TextStyle(fontSize: 12)),
                )
            )
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: _isLoadingProfile
                  ? const Center(child: CircularProgressIndicator())
                  : Column(children: [
                // TODO: Use _userProfile?.avatarUrl for CircleAvatar if available
                Icon(Icons.account_circle, size: 100, color: primaryPurple.withOpacity(0.8)),
                const SizedBox(height: 12),
                Text(_userProfile?.name ?? 'کاربر مهمان', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 4),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(_userProfile?.email ?? '', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                  const SizedBox(width: 4),
                  if (_userProfile?.email.isNotEmpty ?? false) Icon(Icons.check_circle, color: Colors.green[600], size: 16)
                ])
              ]),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: const BorderRadius.only(topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0))),
                child: ListView(
                  padding: const EdgeInsets.only(top:16.0, bottom: 16.0),
                  children: [
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: InkWell(
                            onTap: _editProfile,
                            child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('ویرایش اطلاعات', style: TextStyle(fontSize: 15, color: Colors.black87)),
                                      Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
                                    ]
                                )
                            )
                        )
                    ),
                    const SizedBox(height: 20),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(children: [
                          _buildTabButton('رزروهای قبلی'),
                          _buildTabButton('لیست رزروها'),
                          _buildTabButton('علاقه‌مندی‌ها')
                        ])
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
    if (_selectedTab == 'رزروهای قبلی') {
      if (_isLoadingPreviousBookings) return const Center(child: CircularProgressIndicator());
      if (_previousBookings.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(30.0), child: Text('هیچ رزرو قبلی وجود ندارد.', style: TextStyle(fontSize: 16, color: Colors.grey))));
      return ListView.builder(
        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: _previousBookings.length,
        itemBuilder: (context, index) => Padding(padding: EdgeInsets.only(bottom: index < _previousBookings.length - 1 ? _interCardSpacingVertical : 0.0), child: _buildPreviousBookingItemCard(_previousBookings[index])),
      );
    }
    else if (_selectedTab == 'لیست رزروها') {
      if (_isLoadingCurrentBookings) return const Center(child: CircularProgressIndicator());
      if (_currentBookings.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(30.0), child: Text('هیچ رزرو فعالی وجود ندارد.', style: TextStyle(fontSize: 16, color: Colors.grey))));
      // برای لیست رزروها، به جای SizedBox با ارتفاع ثابت، از ListView با shrinkWrap و physics استفاده می‌کنیم تا به اندازه محتوا ارتفاع بگیرد
      return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          itemCount: _currentBookings.length,
          itemBuilder: (context, index) =>
              Padding(
                padding: EdgeInsets.only(bottom: index < _currentBookings.length - 1 ? _interCardSpacingVertical : 0.0),
                child: _buildBookingItemCard(_currentBookings[index]),
              )
      );
    } else if (_selectedTab == 'علاقه‌مندی‌ها') {
      if (_isLoadingFavorites) return const Center(child: CircularProgressIndicator());
      if (_favoriteHotels.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(30.0), child: Text('موردی برای نمایش در علاقه‌مندی‌ها وجود ندارد.', style: TextStyle(fontSize: 16, color: Colors.grey))));
      // برای لیست علاقه‌مندی‌ها هم مشابه لیست رزروها
      return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          itemCount: _favoriteHotels.length,
          itemBuilder: (context, index) =>
              Padding(
                padding: EdgeInsets.only(bottom: index < _favoriteHotels.length - 1 ? _interCardSpacingVertical : 0.0),
                child: _buildFavoriteItemCard(_favoriteHotels[index]),
              )
      );
    }
    return const SizedBox.shrink();
  }

  // ویجت‌های مربوط به آیتم‌ها (بدون تغییر زیاد، فقط چک کردن null بودن _userProfile)
  Widget _buildPreviousBookingItemCard(PreviousBookingModel item) {
    return Card(elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), color: Colors.white, child: Padding(padding: const EdgeInsets.all(12.0), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(item.imageUrl, width: 80, height: 80, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(width: 80, height: 80, color: Colors.grey[200], child: Icon(Icons.image_not_supported, color: Colors.grey[400])))), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item.hotelName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis), const SizedBox(height: 8), Row(children: [Text(item.userRating?.toStringAsFixed(1) ?? 'بدون امتیاز', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: item.userRating != null ? Colors.grey[700] : Colors.grey[500])), if(item.userRating != null) ...[const SizedBox(width: 4), Icon(Icons.thumb_up, size: 16, color: Colors.grey[700])]]), const SizedBox(height: 12), InkWell(onTap: () => _ratePreviousBooking(item.id), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.star_border_outlined, color: primaryPurple, size: 20), const SizedBox(width: 6), Text('ثبت نظر و امتیازدهی', style: TextStyle(color: primaryPurple, fontSize: 13, fontWeight: FontWeight.w600))]))]))])));
  }

  Widget _buildBookingItemCard(BookingModel booking) {
    // این ویجت چون برای نمایش افقی طراحی شده بود، اگر عمودی استفاده شود، width آن را حذف می‌کنیم
    // return SizedBox(width: _cardWidthHorizontal, child: Card(...))
    return Card(elevation: 2, margin: const EdgeInsets.symmetric(vertical: 0), /* قبلا vertical: 4.0 بود */ shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), color: Colors.white, child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Stack(children: [ClipRRect(borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)), child: Image.network(booking.imageUrl, height: 180, width: double.infinity, fit: BoxFit.cover, errorBuilder: (c,e,s) => Container(height: 180, color: Colors.grey[200], child: Center(child: Icon(Icons.broken_image, color: Colors.grey[400], size: 40))))), Positioned(top: 12, right: 12, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(12)), child: Row(mainAxisSize: MainAxisSize.min, children: [Text(booking.userRating.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)), const SizedBox(width: 4), const Icon(Icons.thumb_up_alt_rounded, color: Colors.white, size: 14)])))]), Padding(padding: const EdgeInsets.all(12.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(booking.hotelName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis), const SizedBox(height: 6), Row(children: List.generate(5, (index) => Icon(index < booking.starRating ? Icons.star_rounded : Icons.star_border_rounded, color: const Color(0xFFFFC107), size: 20))), const SizedBox(height: 10), Row(children: [Icon(Icons.account_balance_wallet_outlined, color: Colors.grey[700], size: 18), const SizedBox(width: 6), const Text('قیمت پرداخت شده', style: TextStyle(fontSize: 13, color: Colors.black54)), const Spacer(), Text(booking.priceDisplay, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)), const SizedBox(width: 3), Text(booking.currency, style: TextStyle(fontSize: 11, color: Colors.grey[700]))]), const SizedBox(height: 6), Row(children: [Icon(Icons.location_on_outlined, color: Colors.grey[700], size: 18), const SizedBox(width: 6), Expanded(child: Text(booking.location, style: TextStyle(fontSize: 13, color: Colors.grey[700]), overflow: TextOverflow.ellipsis))]), const SizedBox(height: 16), InkWell(onTap: () => _viewBookingDetails(booking.id), child: Container(padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12), decoration: BoxDecoration(color: primaryPurple.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.receipt_long_outlined, color: primaryPurple, size: 20), const SizedBox(width: 8), Text('مشاهده جزئیات رزرو', style: TextStyle(color: primaryPurple, fontSize: 13, fontWeight: FontWeight.bold))])))]))]));
  }

  Widget _buildFavoriteItemCard(FavoriteHotelModel hotel) {
    // این ویجت چون برای نمایش افقی طراحی شده بود، اگر عمودی استفاده شود، width آن را حذف می‌کنیم
    return Card(elevation: 2, margin: const EdgeInsets.symmetric(vertical: 0), /* قبلا vertical: 4.0 بود */ shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), color: Colors.white, child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Stack(children: [ClipRRect(borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)), child: Image.network(hotel.imageUrl, height: 180, width: double.infinity, fit: BoxFit.cover, errorBuilder: (c,e,s) => Container(height: 180, color: Colors.grey[200], child: Center(child: Icon(Icons.broken_image, color: Colors.grey[400], size: 40))))), Positioned(top: 12, left: 12, child: InkWell(onTap: () => _toggleFavoriteStatus(hotel.id, hotel.isFavorite), child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 3)]), child: Icon(hotel.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: hotel.isFavorite ? Colors.redAccent : primaryPurple, size: 22)))), Positioned(top: 12, right: 12, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(12)), child: Row(mainAxisSize: MainAxisSize.min, children: [Text(hotel.userRating.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)), const SizedBox(width: 4), const Icon(Icons.thumb_up_alt_rounded, color: Colors.white, size: 14)])))]), Padding(padding: const EdgeInsets.all(12.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(hotel.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis), const SizedBox(height: 6), Row(children: List.generate(5, (index) => Icon(index < hotel.starRating ? Icons.star_rounded : Icons.star_border_rounded, color: const Color(0xFFFFC107), size: 20))), const SizedBox(height: 10), Row(children: [Icon(Icons.account_balance_wallet_outlined, color: Colors.grey[700], size: 18), const SizedBox(width: 6), const Text('شروع قیمت از', style: TextStyle(fontSize: 13, color: Colors.black54)), const Spacer(), Text(hotel.priceDisplay, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)), const SizedBox(width: 3), Text(hotel.currency, style: TextStyle(fontSize: 11, color: Colors.grey[700]))]), const SizedBox(height: 6), Row(children: [Icon(Icons.location_on_outlined, color: Colors.grey[700], size: 18), const SizedBox(width: 6), Expanded(child: Text(hotel.location, style: TextStyle(fontSize: 13, color: Colors.grey[700]), overflow: TextOverflow.ellipsis))]), const SizedBox(height: 16), ElevatedButton.icon(onPressed: () => _reserveFavoriteHotel(hotel.id), icon: const Icon(Icons.arrow_back_ios_new, size: 14, textDirection: TextDirection.ltr /* برای آیکون فلش رو به چپ */), label: const Text('رزرو این هتل', style: TextStyle(fontSize: 14)), style: ElevatedButton.styleFrom(backgroundColor: primaryPurple, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))))]))]));
  }
}