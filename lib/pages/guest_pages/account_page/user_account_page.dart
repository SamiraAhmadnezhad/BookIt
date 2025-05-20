import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../authentication_page/auth_service.dart';
import 'edit_profile_page.dart';
import '../../authentication_page/authentication_page.dart';

const Color kPrimaryColor = Color(0xFF542545);
const Color kAccentColor = Color(0xFF7E3F6B);
const Color kPageBackground = Color(0xFFF4F6F8);
const Color kCardBackground = Colors.white;
const Color kLightTextColor = Color(0xFF606060);
const Color kLighterTextColor = Color(0xFF888888);
const Color kIconColor = Color(0xFF404040);

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
  FavoriteHotelModel(
      {required this.id,
        required this.imageUrl,
        required this.name,
        required this.userRating,
        required this.starRating,
        required this.priceDisplay,
        required this.currency,
        required this.location,
        this.isFavorite = true});
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
  BookingModel(
      {required this.id,
        required this.hotelId,
        required this.imageUrl,
        required this.hotelName,
        required this.userRating,
        required this.starRating,
        required this.priceDisplay,
        required this.currency,
        required this.location});
}

class PreviousBookingModel {
  final String id;
  final String hotelId;
  final String hotelName;
  final String imageUrl;
  final double? userRating;
  PreviousBookingModel(
      {required this.id,
        required this.hotelId,
        required this.hotelName,
        required this.imageUrl,
        this.userRating});
}

class UserAccountPage extends StatefulWidget {
  const UserAccountPage({super.key});
  @override
  State<UserAccountPage> createState() => _UserAccountPageState();
}

class _UserAccountPageState extends State<UserAccountPage>
    with SingleTickerProviderStateMixin {
  String _selectedTab = 'علاقه‌مندی‌ها';
  TabController? _tabController;

  UserProfileModel? _userProfile;
  List<FavoriteHotelModel> _favoriteHotels = [];
  List<BookingModel> _currentBookings = [];
  List<PreviousBookingModel> _previousBookings = [];

  bool _isLoadingProfile = true;
  bool _isLoadingFavorites = true;
  bool _isLoadingCurrentBookings = false;
  bool _isLoadingPreviousBookings = false;

  final List<String> _tabs = const [
    'علاقه‌مندی‌ها',
    'لیست رزروها',
    'رزروهای قبلی'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController!.addListener(_handleTabSelection);
    _fetchDataForPage();
  }

  void _handleTabSelection() {
    if (_tabController!.indexIsChanging ||
        _selectedTab == _tabs[_tabController!.index]) return;

    if (mounted) {
      setState(() {
        _selectedTab = _tabs[_tabController!.index];
      });
      _fetchDataForSelectedTab();
    }
  }

  @override
  void dispose() {
    _tabController?.removeListener(_handleTabSelection);
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _fetchDataForPage() async {
    await _fetchUserProfile();
    _fetchDataForSelectedTab();
  }

  Future<void> _fetchDataForSelectedTab() async {
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
    if (!mounted) return;
    setState(() => _isLoadingProfile = true);
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      _userProfile = UserProfileModel(
          name: 'علی علوی',
          email: 'alialavi@gmail.com',
          avatarUrl: 'https://i.pravatar.cc/150?u=alialavi');
    } catch (e) {
      _showErrorSnackBar('خطا در بارگذاری پروفایل: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoadingProfile = false);
    }
  }

  Future<void> _fetchFavoriteHotels() async {
    if (!mounted || _isLoadingFavorites) return;
    setState(() => _isLoadingFavorites = true);
    try {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      _favoriteHotels = List.generate(
          3,
              (index) => FavoriteHotelModel(
              id: 'fav${index + 1}',
              imageUrl:
              'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=400&h=300&fit=crop',
              name: 'هتل لوکس مورد علاقه ${index + 1}',
              userRating: 4.8 - (index * 0.1),
              starRating: 5,
              priceDisplay: '۵٬${index}۰۰٬۰۰۰',
              currency: 'تومان',
              location: 'تهران، منطقه ${index + 1}'));
    } catch (e) {
      _showErrorSnackBar('خطا در بارگذاری علاقه‌مندی‌ها: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoadingFavorites = false);
    }
  }

  Future<void> _fetchCurrentBookings() async {
    if (!mounted || _isLoadingCurrentBookings) return;
    setState(() => _isLoadingCurrentBookings = true);
    try {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      _currentBookings = List.generate(
          2,
              (index) => BookingModel(
              id: 'booking${index + 1}',
              hotelId: 'hotel_xyz_${index + 1}',
              imageUrl:
              'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&h=300&fit=crop',
              hotelName: 'هتل رزرو شده ${index + 1}',
              userRating: 4.5 - (index * 0.2),
              starRating: 4,
              priceDisplay: '۳٬${index}۵۰٬۰۰۰',
              currency: 'تومان',
              location: 'مکان هتل ${index + 1}'));
    } catch (e) {
      _showErrorSnackBar('خطا در بارگذاری رزروهای فعلی: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoadingCurrentBookings = false);
    }
  }

  Future<void> _fetchPreviousBookings() async {
    if (!mounted || _isLoadingPreviousBookings) return;
    setState(() => _isLoadingPreviousBookings = true);
    try {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      _previousBookings = List.generate(
          4,
              (index) => PreviousBookingModel(
              id: 'prev_booking_${index + 1}',
              hotelId: 'hotel_abc_${index + 1}',
              hotelName:
              'اسم هتل طولانی برای رزرو قبلی شماره ${index + 1}',
              imageUrl:
              'https://images.unsplash.com/photo-1582719478250-c89caE4dc85b?w=150&h=150&fit=crop',
              userRating: (index % 2 == 0) ? 4.5 - (index * 0.3) : null));
    } catch (e) {
      _showErrorSnackBar('خطا در بارگذاری رزروهای قبلی: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoadingPreviousBookings = false);
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating));
  }

  Future<void> _logoutUser() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (authService.isLoading) return;

    try {
      await authService.logout();
      if (!mounted) return;

      if (authService.errorMessage != null &&
          authService.errorMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('توجه: ${authService.errorMessage}'),
            backgroundColor: Colors.orangeAccent,
            behavior: SnackBarBehavior.floating));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('شما با موفقیت از حساب کاربری خود خارج شدید.'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating));
      }
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthenticationPage()),
            (Route<dynamic> route) => false,
      );
    } catch (e) {
      _showErrorSnackBar('خطای پیش‌بینی نشده هنگام خروج: ${e.toString()}');
    }
  }

  void _editProfile() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const EditProfilePage()))
        .then((value) {
      if (value == true && mounted) {
        _fetchUserProfile();
      }
    });
  }

  void _viewBookingDetails(String bookingId) {
    debugPrint("View details for booking $bookingId");
  }

  Future<void> _toggleFavoriteStatus(
      String hotelId, bool currentStatus) async {
    debugPrint("Toggle favorite for hotel $hotelId, current status: $currentStatus");
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() {
      final index = _favoriteHotels.indexWhere((h) => h.id == hotelId);
      if (index != -1) {
        _favoriteHotels.removeAt(index);
      }
    });
  }

  void _reserveFavoriteHotel(String hotelId) {
    debugPrint("Reserve favorite hotel $hotelId");
  }

  void _ratePreviousBooking(String previousBookingId) {
    debugPrint("Rate previous booking $previousBookingId");
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: kPageBackground,
        appBar: AppBar(
          backgroundColor: kCardBackground,
          elevation: 0.5,
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'حساب کاربری',
              style: theme.textTheme.titleLarge?.copyWith(
                  color: kPrimaryColor, fontWeight: FontWeight.bold),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 8.0),
              child: IconButton(
                icon: Icon(Icons.logout_outlined, color: kPrimaryColor, size: 26),
                onPressed: authService.isLoading ? null : _logoutUser,
                tooltip: 'خروج از حساب',
              ),
            )
          ],
        ),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(child: _buildProfileHeader(theme)),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverTabBarDelegate(
                  TabBar(
                    controller: _tabController,
                    indicatorColor: kPrimaryColor,
                    labelColor: kPrimaryColor,
                    unselectedLabelColor: kLightTextColor,
                    indicatorWeight: 2.5,
                    labelStyle: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                    unselectedLabelStyle: theme.textTheme.titleSmall,
                    tabs: _tabs.map((String name) => Tab(text: name)).toList(),
                  ),
                  kCardBackground,
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: _tabs.map((String tabName) {
              return RefreshIndicator(
                  onRefresh: _fetchDataForSelectedTab,
                  color: kPrimaryColor,
                  child: _buildSelectedTabContent(tabName));
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      color: kCardBackground,
      child: _isLoadingProfile
          ? const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 30.0),
            child: CircularProgressIndicator(color: kPrimaryColor),
          ))
          : Column(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundColor: kPrimaryColor.withOpacity(0.1),
            backgroundImage: _userProfile?.avatarUrl != null
                ? NetworkImage(_userProfile!.avatarUrl!)
                : null,
            child: _userProfile?.avatarUrl == null
                ? Icon(Icons.person_outline,
                size: 50, color: kPrimaryColor.withOpacity(0.8))
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            _userProfile?.name ?? 'کاربر',
            style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 6),
          if (_userProfile?.email.isNotEmpty ?? false)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _userProfile!.email,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: kLightTextColor),
                ),
                const SizedBox(width: 6),
                Icon(Icons.verified_user_outlined,
                    color: Colors.green[600], size: 16)
              ],
            ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('ویرایش پروفایل'),
            onPressed: _editProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
              padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              textStyle: theme.textTheme.labelLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedTabContent(String tabName) {
    if (tabName == 'علاقه‌مندی‌ها') {
      if (_isLoadingFavorites) return _buildLoadingIndicator();
      if (_favoriteHotels.isEmpty) return _buildEmptyState('موردی در علاقه‌مندی‌ها یافت نشد.');
      return _buildList(_favoriteHotels, _buildFavoriteItemCard);
    } else if (tabName == 'لیست رزروها') {
      if (_isLoadingCurrentBookings) return _buildLoadingIndicator();
      if (_currentBookings.isEmpty) return _buildEmptyState('هیچ رزرو فعالی ندارید.');
      return _buildList(_currentBookings, _buildBookingItemCard);
    } else if (tabName == 'رزروهای قبلی') {
      if (_isLoadingPreviousBookings) return _buildLoadingIndicator();
      if (_previousBookings.isEmpty) return _buildEmptyState('هیچ رزرو قبلی یافت نشد.');
      return _buildList(_previousBookings, _buildPreviousBookingItemCard);
    }
    return const SizedBox.shrink();
  }

  Widget _buildLoadingIndicator() {
    return const Center(
        child: Padding(
            padding: EdgeInsets.all(30.0),
            child: CircularProgressIndicator(color: kPrimaryColor)));
  }

  Widget _buildEmptyState(String message) {
    return Center(
        child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: kLightTextColor))));
  }

  Widget _buildList<T>(List<T> items, Widget Function(T item) itemBuilder) {
    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: items.length,
      itemBuilder: (context, index) => itemBuilder(items[index]),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
    );
  }

  Widget _buildPreviousBookingItemCard(PreviousBookingModel item) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: kCardBackground,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                    width: 80,
                    height: 80,
                    color: kPageBackground,
                    child: Icon(Icons.image_not_supported_outlined,
                        color: kLighterTextColor.withOpacity(0.7))),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.hotelName,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                          item.userRating?.toStringAsFixed(1) ?? 'بدون امتیاز',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: item.userRating != null
                                  ? kLightTextColor
                                  : kLighterTextColor)),
                      if (item.userRating != null) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.thumb_up_alt_outlined,
                            size: 15, color: kLightTextColor)
                      ]
                    ],
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () => _ratePreviousBooking(item.id),
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star_outline_rounded,
                              color: kAccentColor, size: 18),
                          const SizedBox(width: 6),
                          Text('ثبت نظر و امتیاز',
                              style: TextStyle(
                                  color: kAccentColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600))
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingItemCard(BookingModel booking) {
    return Card(
      elevation: 1.5,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: kCardBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Image.network(
                booking.imageUrl,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                    height: 160,
                    color: kPageBackground,
                    child: Center(
                        child: Icon(Icons.broken_image_outlined,
                            color: kLighterTextColor.withOpacity(0.7), size: 40))),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: _buildRatingBadge(booking.userRating.toStringAsFixed(1)),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.hotelName,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                    children: List.generate(
                        5,
                            (index) => Icon(
                            index < booking.starRating
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: Colors.amber,
                            size: 18))),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.location_on_outlined, booking.location),
                const SizedBox(height: 4),
                _buildInfoRow(Icons.monetization_on_outlined,
                    '${booking.priceDisplay} ${booking.currency} (پرداخت شده)'),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    icon: Icon(Icons.receipt_long_outlined,
                        color: kPrimaryColor, size: 18),
                    label: Text('مشاهده جزئیات',
                        style: TextStyle(
                            color: kPrimaryColor,
                            fontSize: 13,
                            fontWeight: FontWeight.bold)),
                    onPressed: () => _viewBookingDetails(booking.id),
                    style: TextButton.styleFrom(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      backgroundColor: kPrimaryColor.withOpacity(0.08),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
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

  Widget _buildFavoriteItemCard(FavoriteHotelModel hotel) {
    return Card(
      elevation: 1.5,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: kCardBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Image.network(
                hotel.imageUrl,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                    height: 160,
                    color: kPageBackground,
                    child: Center(
                        child: Icon(Icons.broken_image_outlined,
                            color: kLighterTextColor.withOpacity(0.7), size: 40))),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: InkWell(
                  onTap: () => _toggleFavoriteStatus(hotel.id, hotel.isFavorite),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                        color: kCardBackground.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 1))
                        ]),
                    child: Icon(
                        hotel.isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: hotel.isFavorite ? Colors.redAccent : kPrimaryColor,
                        size: 22),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: _buildRatingBadge(hotel.userRating.toStringAsFixed(1)),
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
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                    children: List.generate(
                        5,
                            (index) => Icon(
                            index < hotel.starRating
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: Colors.amber,
                            size: 18))),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.location_on_outlined, hotel.location),
                const SizedBox(height: 4),
                _buildInfoRow(Icons.sell_outlined,
                    'شروع قیمت از ${hotel.priceDisplay} ${hotel.currency}'),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton(
                    onPressed: () => _reserveFavoriteHotel(hotel.id),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        textStyle: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    child: const Text('رزرو این هتل'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBadge(String rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(rating,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
          const SizedBox(width: 3),
          const Icon(Icons.thumb_up_alt_rounded, color: Colors.white, size: 13)
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: kIconColor, size: 16),
        const SizedBox(width: 6),
        Expanded(
            child: Text(text,
                style: TextStyle(fontSize: 13, color: kLightTextColor),
                overflow: TextOverflow.ellipsis))
      ],
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverTabBarDelegate(this.tabBar, this.backgroundColor);

  final TabBar tabBar;
  final Color backgroundColor;

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: backgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}