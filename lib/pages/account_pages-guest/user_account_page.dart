import 'package:flutter/material.dart';
import 'edit_profile_page.dart';

// TODO: این مدل را بر اساس داده‌های واقعی سرور خود تکمیل یا جایگزین کنید
class UserProfileModel {
  final String name;
  final String email;
  final String? avatarUrl;
  UserProfileModel({required this.name, required this.email, this.avatarUrl});
// TODO: factory UserProfileModel.fromJson(Map<String, dynamic> json)
}

// TODO: این مدل را بر اساس داده‌های واقعی سرور خود تکمیل یا جایگزین کنید
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
// TODO: factory FavoriteHotelModel.fromJson(Map<String, dynamic> json)
}

// TODO: این مدل را بر اساس داده‌های واقعی سرور خود برای یک آیتم رزرو تکمیل یا جایگزین کنید
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
// TODO: factory BookingModel.fromJson(Map<String, dynamic> json)
}

// TODO: این مدل را بر اساس داده‌های واقعی سرور خود برای یک آیتم رزرو قبلی تکمیل کنید
class PreviousBookingModel {
  final String id;
  final String hotelId;
  final String hotelName;
  final String imageUrl;
  final double? userRating;

  PreviousBookingModel({
    required this.id,
    required this.hotelId,
    required this.hotelName,
    required this.imageUrl,
    this.userRating,
  });
// TODO: factory PreviousBookingModel.fromJson(Map<String, dynamic> json)
}


class UserAccountPage extends StatefulWidget {
  const UserAccountPage({super.key});
  @override
  State<UserAccountPage> createState() => _UserAccountPageState();
}

class _UserAccountPageState extends State<UserAccountPage> {
  final Color primaryPurple = const Color(0xFF542545);
  // تب پیش‌فرض را می‌توانید به هرکدام که می‌خواهید تغییر دهید
  String _selectedTab = 'علاقه‌مندی‌ها';

  UserProfileModel? _userProfile;
  List<FavoriteHotelModel> _favoriteHotels = [];
  List<BookingModel> _currentBookings = [];
  List<PreviousBookingModel> _previousBookings = [];

  bool _isLoadingProfile = true;
  bool _isLoadingFavorites = true; // اگر علاقه‌مندی‌ها تب پیش‌فرض است
  bool _isLoadingCurrentBookings = false;
  bool _isLoadingPreviousBookings = false;

  final double _cardWidthHorizontal = 300.0;
  final double _horizontalListHeight = 390.0;
  final double _interCardSpacingHorizontal = 12.0;
  final double _interCardSpacingVertical = 12.0;


  @override
  void initState() {
    super.initState();
    _fetchDataForPage();
  }

  Future<void> _fetchDataForPage() async {
    // اول پروفایل را لود می‌کنیم چون در هر صورت نمایش داده می‌شود
    await _fetchUserProfile();
    // سپس دیتای تب فعال را لود می‌کنیم
    if (_selectedTab == 'علاقه‌مندی‌ها') {
      await _fetchFavoriteHotels();
    } else if (_selectedTab == 'لیست رزروها') {
      await _fetchCurrentBookings();
    } else if (_selectedTab == 'رزروهای قبلی') {
      await _fetchPreviousBookings();
    }
  }

  // TODO: تابع دریافت اطلاعات پروفایل کاربر از سرور
  Future<void> _fetchUserProfile() async {
    setState(() { _isLoadingProfile = true; });
    try {
      await Future.delayed(const Duration(seconds: 1));
      _userProfile = UserProfileModel(name: 'علی علوی', email: 'alialavi@gmail.com');
    } catch (e) { /* TODO: Handle error */ }
    finally { if (mounted) setState(() { _isLoadingProfile = false; }); }
  }

  // TODO: تابع دریافت لیست هتل‌های مورد علاقه از سرور
  Future<void> _fetchFavoriteHotels() async {
    if (_selectedTab != 'علاقه‌مندی‌ها' && _favoriteHotels.isNotEmpty && !_isLoadingFavorites) return;
    setState(() { _isLoadingFavorites = true; });
    try {
      await Future.delayed(const Duration(seconds: 1));
      _favoriteHotels = List.generate(3, (index) => FavoriteHotelModel(id: 'fav${index+1}', imageUrl: 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=300', name: 'هتل لوکس مورد علاقه ${index+1}', userRating: 4.8, starRating: 5, priceDisplay: '۵٬${index}۰۰٬۰۰۰', currency: 'تومان', location: 'تهران'));
    } catch (e) { /* TODO: Handle error */ }
    finally { if (mounted) setState(() { _isLoadingFavorites = false; }); }
  }

  // TODO: تابع دریافت لیست رزروهای فعلی از سرور
  Future<void> _fetchCurrentBookings() async {
    if (_selectedTab != 'لیست رزروها' && _currentBookings.isNotEmpty && !_isLoadingCurrentBookings) return;
    setState(() { _isLoadingCurrentBookings = true; });
    try {
      await Future.delayed(const Duration(seconds: 1));
      _currentBookings = List.generate(3, (index) => BookingModel(id: 'booking${index+1}', hotelId: 'hotel_xyz_${index+1}', imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=300', hotelName: 'هتل رزرو شده ${index+1}', userRating: 4.5, starRating: 4, priceDisplay: '۳٬${index}۵۰٬۰۰۰', currency: 'تومان', location: 'مکان هتل ${index+1}'));
    } catch (e) { /* TODO: Handle error */ }
    finally { if (mounted) setState(() { _isLoadingCurrentBookings = false; }); }
  }

  // TODO: تابع دریافت لیست رزروهای قبلی از سرور
  Future<void> _fetchPreviousBookings() async {
    if (_selectedTab != 'رزروهای قبلی' && _previousBookings.isNotEmpty && !_isLoadingPreviousBookings) return;
    setState(() { _isLoadingPreviousBookings = true; });
    try {
      await Future.delayed(const Duration(seconds: 1));
      _previousBookings = List.generate(5, (index) => PreviousBookingModel(id: 'prev_booking_${index+1}', hotelId: 'hotel_abc_${index+1}', hotelName: 'اسم هتل در حالت طولانی برای رزرو قبلی شماره ${index+1}', imageUrl: 'https://images.unsplash.com/photo-1582719478250-c89caE4dc85b?w=100&h=100&fit=crop', userRating: (index % 2 == 0) ? 4.5 : null ));
    } catch (e) { /* TODO: Handle error */ }
    finally { if (mounted) setState(() { _isLoadingPreviousBookings = false; }); }
  }

  Future<void> _logoutUser() async { /* TODO: Implement */ }

  // تابع برای هدایت به صفحه ویرایش پروفایل
  void _editProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const EditProfilePage(
          // TODO: در صورت نیاز، اطلاعات اولیه کاربر را از _userProfile به EditProfilePage پاس دهید
          // مثال: initialProfileData: _userProfile != null ? UserEditableProfileModel(...) : null,
        ),
      ),
    ).then((value) {
      // TODO: این بخش بعد از بازگشت از EditProfilePage اجرا می‌شود.
      // اگر اطلاعات پروفایل تغییر کرده باشد، می‌توانید _fetchUserProfile() را دوباره صدا بزنید.
      // if (value == true) { // true می‌تواند نشانه‌ای از ذخیره موفقیت‌آمیز باشد
      //   _fetchUserProfile();
      // }
    });
  }

  void _viewBookingDetails(String bookingId) { /* TODO: Implement */ }
  Future<void> _toggleFavoriteStatus(String hotelId, bool currentStatus) async { /* TODO: Implement */ }
  void _reserveFavoriteHotel(String hotelId) { /* TODO: Implement */ }
  void _ratePreviousBooking(String previousBookingId) { /* TODO: Implement */ }

  Widget _buildTabButton(String title) {
    bool isSelected = _selectedTab == title;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_selectedTab != title) {
            setState(() { _selectedTab = title; });
            // فقط دیتای تب جدید را لود کن اگر قبلا لود نشده یا نیاز به رفرش دارد
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white, elevation: 0, automaticallyImplyLeading: false,
          leading: IconButton(icon: Icon(Icons.notifications_none_outlined, color: primaryPurple, size: 28), onPressed: () { /* TODO: Notification action */ }),
          actions: [Padding(padding: const EdgeInsets.only(left: 16.0, right: 8.0, top: 8.0, bottom: 8.0), child: ElevatedButton(onPressed: _logoutUser, style: ElevatedButton.styleFrom(backgroundColor: primaryPurple, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))), child: const Text('خروج از حساب کاربری', style: TextStyle(fontSize: 12))))],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: _isLoadingProfile ? const Center(child: CircularProgressIndicator()) : Column(children: [Icon(Icons.account_circle, size: 100, color: primaryPurple.withOpacity(0.8)), const SizedBox(height: 12), Text(_userProfile?.name ?? 'کاربر', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)), const SizedBox(height: 4), Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(_userProfile?.email ?? '', style: TextStyle(fontSize: 14, color: Colors.grey[600])), const SizedBox(width: 4), if (_userProfile?.email.isNotEmpty ?? false) Icon(Icons.check_circle, color: Colors.green[600], size: 16)])]),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: const BorderRadius.only(topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0))),
                child: ListView(
                  padding: const EdgeInsets.only(top:16.0, bottom: 16.0),
                  children: [
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: InkWell(
                            onTap: _editProfile, // اتصال به تابع هدایت به صفحه ویرایش
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
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0), child: Row(children: [_buildTabButton('رزروهای قبلی'), _buildTabButton('لیست رزروها'), _buildTabButton('علاقه‌مندی‌ها')])),
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
      return SizedBox(height: _horizontalListHeight, child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16.0), itemCount: _currentBookings.length, itemBuilder: (context, index) => Container(margin: EdgeInsets.only(left: index > 0 ? _interCardSpacingHorizontal : 0.0), child: _buildBookingItemCard(_currentBookings[index]))));
    } else if (_selectedTab == 'علاقه‌مندی‌ها') {
      if (_isLoadingFavorites) return const Center(child: CircularProgressIndicator());
      if (_favoriteHotels.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(30.0), child: Text('موردی برای نمایش در علاقه‌مندی‌ها وجود ندارد.', style: TextStyle(fontSize: 16, color: Colors.grey))));
      return SizedBox(height: _horizontalListHeight, child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16.0), itemCount: _favoriteHotels.length, itemBuilder: (context, index) => Container(margin: EdgeInsets.only(left: index > 0 ? _interCardSpacingHorizontal : 0.0), child: _buildFavoriteItemCard(_favoriteHotels[index]))));
    }
    return const SizedBox.shrink();
  }

  Widget _buildPreviousBookingItemCard(PreviousBookingModel item) {
    return Card(elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), color: Colors.white, child: Padding(padding: const EdgeInsets.all(12.0), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(item.imageUrl, width: 80, height: 80, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(width: 80, height: 80, color: Colors.grey[200], child: Icon(Icons.image_not_supported, color: Colors.grey[400])))), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item.hotelName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis), const SizedBox(height: 8), Row(children: [Text(item.userRating?.toString() ?? '-', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[700])), const SizedBox(width: 4), Icon(Icons.thumb_up, size: 16, color: Colors.grey[700])]), const SizedBox(height: 12), InkWell(onTap: () => _ratePreviousBooking(item.id), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.star, color: primaryPurple, size: 20), const SizedBox(width: 6), Text('ثبت نظر و امتیازدهی', style: TextStyle(color: primaryPurple, fontSize: 13, fontWeight: FontWeight.w600))]))]))])));
  }

  Widget _buildBookingItemCard(BookingModel booking) {
    return SizedBox(width: _cardWidthHorizontal, child: Card(elevation: 2, margin: const EdgeInsets.symmetric(vertical: 4.0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), color: Colors.white, child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Stack(children: [ClipRRect(borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)), child: Image.network(booking.imageUrl, height: 180, width: double.infinity, fit: BoxFit.cover, errorBuilder: (c,e,s) => Container(height: 180, color: Colors.grey[200], child: Center(child: Icon(Icons.broken_image, color: Colors.grey[400], size: 40))))), Positioned(top: 12, right: 12, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(12)), child: Row(mainAxisSize: MainAxisSize.min, children: [Text(booking.userRating.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)), const SizedBox(width: 4), const Icon(Icons.thumb_up_alt_rounded, color: Colors.white, size: 14)])))]), Padding(padding: const EdgeInsets.all(12.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(booking.hotelName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis), const SizedBox(height: 6), Row(children: List.generate(5, (index) => Icon(index < booking.starRating ? Icons.star_rounded : Icons.star_border_rounded, color: const Color(0xFFFFC107), size: 20))), const SizedBox(height: 10), Row(children: [Icon(Icons.account_balance_wallet_outlined, color: Colors.grey[700], size: 18), const SizedBox(width: 6), const Text('قیمت پرداخت شده', style: TextStyle(fontSize: 13, color: Colors.black54)), const Spacer(), Text(booking.priceDisplay, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)), const SizedBox(width: 3), Text(booking.currency, style: TextStyle(fontSize: 11, color: Colors.grey[700]))]), const SizedBox(height: 6), Row(children: [Icon(Icons.location_on_outlined, color: Colors.grey[700], size: 18), const SizedBox(width: 6), Text(booking.location, style: TextStyle(fontSize: 13, color: Colors.grey[700]))]), const SizedBox(height: 16), InkWell(onTap: () => _viewBookingDetails(booking.id), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.check_circle, color: primaryPurple, size: 20), const SizedBox(width: 8), Text('رزرو', style: TextStyle(color: primaryPurple, fontSize: 14, fontWeight: FontWeight.bold))]))]))])));
  }

  Widget _buildFavoriteItemCard(FavoriteHotelModel hotel) {
    return SizedBox(width: _cardWidthHorizontal, child: Card(elevation: 2, margin: const EdgeInsets.symmetric(vertical: 4.0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), color: Colors.white, child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Stack(children: [ClipRRect(borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)), child: Image.network(hotel.imageUrl, height: 180, width: double.infinity, fit: BoxFit.cover, errorBuilder: (c,e,s) => Container(height: 180, color: Colors.grey[200], child: Center(child: Icon(Icons.broken_image, color: Colors.grey[400], size: 40))))), Positioned(top: 12, left: 12, child: InkWell(onTap: () => _toggleFavoriteStatus(hotel.id, hotel.isFavorite), child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.white.withOpacity(0.85), shape: BoxShape.circle), child: Icon(hotel.isFavorite ? Icons.favorite : Icons.favorite_border, color: primaryPurple, size: 22)))), Positioned(top: 12, right: 12, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(12)), child: Row(mainAxisSize: MainAxisSize.min, children: [Text(hotel.userRating.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)), const SizedBox(width: 4), const Icon(Icons.thumb_up_alt_rounded, color: Colors.white, size: 14)])))]), Padding(padding: const EdgeInsets.all(12.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(hotel.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis), const SizedBox(height: 6), Row(children: List.generate(5, (index) => Icon(index < hotel.starRating ? Icons.star_rounded : Icons.star_border_rounded, color: const Color(0xFFFFC107), size: 20))), const SizedBox(height: 10), Row(children: [Icon(Icons.account_balance_wallet_outlined, color: Colors.grey[700], size: 18), const SizedBox(width: 6), const Text('شروع قیمت از', style: TextStyle(fontSize: 13, color: Colors.black54)), const Spacer(), Text(hotel.priceDisplay, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)), const SizedBox(width: 3), Text(hotel.currency, style: TextStyle(fontSize: 11, color: Colors.grey[700]))]), const SizedBox(height: 6), Row(children: [Icon(Icons.location_on_outlined, color: Colors.grey[700], size: 18), const SizedBox(width: 6), Text(hotel.location, style: TextStyle(fontSize: 13, color: Colors.grey[700]))]), const SizedBox(height: 16), ElevatedButton.icon(onPressed: () => _reserveFavoriteHotel(hotel.id), icon: const Icon(Icons.arrow_back_ios_new, size: 14, color: Colors.white), label: const Text('رزرو', style: TextStyle(color: Colors.white, fontSize: 14)), style: ElevatedButton.styleFrom(backgroundColor: primaryPurple, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))))]))])));
  }
}