// lib/pages/manger_pages/manager_account_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../../features/auth/data/services/auth_service.dart';
import '../../guest_pages/account_page/models/user_profile_model.dart';
import 'edit_manager_profile_page.dart';
import '../../../features/auth/presentation/pages/authentication_screen.dart';
import '../../../core/models/hotel_reservation_model.dart';
import '../../../core/widgets/hotel_reservation_card.dart';
const Color kPrimaryColor = Color(0xFF542545);
const Color kAccentColor = Color(0xFF7E3F6B);
const Color kPageBackground = Color(0xFFF4F6F8);
const Color kCardBackground = Colors.white;
const Color kLightTextColor = Color(0xFF606060);
const Color kLighterTextColor = Color(0xFF888888);
const Color kPositiveColor = Color(0xFF28a745);
const Color kNegativeColor = Color(0xFFdc3545);


class ReviewModel {
  final String id;
  final String date;
  final String userName;
  final String roomInfo;
  final List<String> positivePoints;
  final List<String> negativePoints;
  final double rating;
  String? managerReplyText;
  ReviewModel(
      {required this.id,
        required this.date,
        required this.userName,
        required this.roomInfo,
        required this.positivePoints,
        required this.negativePoints,
        required this.rating,
        this.managerReplyText});
}

class ManagerAccountPage extends StatefulWidget {
  const ManagerAccountPage({super.key});

  @override
  State<ManagerAccountPage> createState() => _ManagerAccountPageState();
}

class _ManagerAccountPageState extends State<ManagerAccountPage> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  String _selectedTab = 'اطلاعات رزروها';

  UserProfileModel? _managerProfile;
  List<HotelReservationModel> _hotelReservations = [];
  List<ReviewModel> _reviews = [];

  bool _isLoadingProfile = true;
  bool _isLoadingHotelReservations = true;
  bool _isLoadingReviews = false;

  String? _replyingToReviewId;
  final TextEditingController _replyController = TextEditingController();
  final FocusNode _replyFocusNode = FocusNode();

  final List<String> _tabs = const ['اطلاعات رزروها', 'پاسخگویی به نظرات'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController!.addListener(_handleTabSelection);
    _fetchInitialData();
  }

  void _handleTabSelection() {
    if (_tabController!.indexIsChanging || _selectedTab == _tabs[_tabController!.index]) return;
    if (mounted) {
      setState(() {
        _selectedTab = _tabs[_tabController!.index];
        _replyingToReviewId = null;
        _replyController.clear();
      });
      _fetchDataForSelectedTab();
    }
  }

  @override
  void dispose() {
    _tabController?.removeListener(_handleTabSelection);
    _tabController?.dispose();
    _replyController.dispose();
    _replyFocusNode.dispose();
    super.dispose();
  }

  Future<void> _fetchInitialData() async {
    await _fetchManagerProfile();
    _fetchDataForSelectedTab();
  }

  Future<void> _fetchDataForSelectedTab() async {
    if (!mounted) return;
    if (_selectedTab == 'اطلاعات رزروها') {
      await _fetchHotelReservations();
    } else if (_selectedTab == 'پاسخگویی به نظرات') {
      await _fetchReviews();
    }
  }

  Future<void> _fetchManagerProfile() async {
    if (!mounted) return;
    setState(() => _isLoadingProfile = true);
    final authService = Provider.of<AuthService>(context, listen: false);
    final token = authService.token;
    if (token == null) {
      _showErrorSnackBar('شما وارد نشده‌اید.');
      if (mounted) setState(() => _isLoadingProfile = false);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('https://fbookit.darkube.app/auth/users/profile/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          _managerProfile = UserProfileModel.fromJson(data);
        });
      } else {
        throw Exception('Failed to load manager profile (Code: ${response.statusCode})');
      }
    } catch (e) {
      _showErrorSnackBar('خطا در بارگذاری پروفایل مدیر: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoadingProfile = false);
    }
  }

  Future<void> _fetchHotelReservations() async {
    if (!mounted) return;
    setState(() => _isLoadingHotelReservations = true);

    final authService = Provider.of<AuthService>(context, listen: false);
    final token = authService.token;

    if (token == null) {
      _showErrorSnackBar('برای مشاهده رزروها، ابتدا وارد شوید.');
      if (mounted) setState(() => _isLoadingHotelReservations = false);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('https://fbookit.darkube.app/hotelManager-api/hotel_manager/hotel-reservations/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {

        /*print('--- Reservations Response Body ---');
        print(utf8.decode(response.bodyBytes));
        print('----------------------------------');*/

        final Map<String, dynamic> responseJson = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> hotelsList = responseJson['data'] ?? [];
        final List<HotelReservationModel> allReservations = [];

        for (var hotelJson in hotelsList) {
          final String hotelName = hotelJson['name'] ?? 'نام هتل نامشخص';
          final String hotelLocation = hotelJson['location'] ?? 'آدرس نامشخص';

          final List<dynamic> reservationsInThisHotel = hotelJson['reservations'] ?? [];

          for (var reservationJson in reservationsInThisHotel) {
            allReservations.add(HotelReservationModel.fromJson(
              reservationJson,
              parentHotelName: hotelName,
              parentHotelLocation: hotelLocation,
            ));
          }
        }

        setState(() {
          _hotelReservations = allReservations;
        });

      } else {
        throw Exception('Failed to load hotel reservations (Code: ${response.statusCode})');
      }
    } catch (e) {
      print('Error fetching reservations: $e');
      _showErrorSnackBar('خطا در بارگذاری اطلاعات رزروها: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoadingHotelReservations = false);
    }
  }

  Future<void> _fetchReviews() async {
    if (!mounted || _isLoadingReviews) return;
    setState(() => _isLoadingReviews = true);
    try {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      _reviews = [
        ReviewModel(id: 'rev1', date: '۱۴ تیر ۱۴۰۲', userName: 'سارا احمدی', roomInfo: 'اتاق دو تخته دابل', positivePoints: ['نظافت عالی اتاق‌ها', 'برخورد خوب پرسنل'], negativePoints: ['تنوع کم صبحانه'], rating: 4.2, managerReplyText: 'از اقامت شما سپاسگزاریم.'),
        ReviewModel(id: 'rev2', date: '۱۲ تیر ۱۴۰۲', userName: 'رضا محمدی', roomInfo: 'سوییت یک خوابه', positivePoints: ['منظره زیبای اتاق', 'دسترسی مناسب به مرکز شهر'], negativePoints: ['صدای زیاد از راهرو'], rating: 3.8),
      ];
    } catch (e) {
      _showErrorSnackBar('خطا در بارگذاری نظرات: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoadingReviews = false);
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating));
  }

  Future<void> _submitReply(String reviewId, String replyText) async {
    if (replyText.trim().isEmpty) {
      _showErrorSnackBar("متن پاسخ نمی‌تواند خالی باشد.");
      return;
    }
    setState(() => _isLoadingReviews = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() {
      final index = _reviews.indexWhere((r) => r.id == reviewId);
      if (index != -1) _reviews[index].managerReplyText = replyText.trim();
      _replyingToReviewId = null;
      _replyController.clear();
      _isLoadingReviews = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('پاسخ با موفقیت ثبت شد.'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating));
  }

  void _editManagerProfile() {
    if (_managerProfile == null) return;
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => EditManagerProfilePage(initialProfileData: _managerProfile!)))
        .then((value) {
      if (value == true && mounted) {
        _fetchManagerProfile();
      }
    });
  }

  void _toggleReplyForm(String reviewId) {
    if (!mounted) return;
    setState(() {
      final review = _reviews.firstWhere((r) => r.id == reviewId);
      if (_replyingToReviewId == reviewId) {
        _replyingToReviewId = null;
        _replyController.clear();
        FocusScope.of(context).unfocus();
      } else {
        _replyingToReviewId = reviewId;
        _replyController.text = review.managerReplyText ?? '';
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) FocusScope.of(context).requestFocus(_replyFocusNode);
        });
      }
    });
  }

  Future<void> _logoutUser() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const AuthenticationScreen()),
          (Route<dynamic> route) => false,
    );
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
              'حساب کاربری مدیر',
              style: theme.textTheme.titleLarge?.copyWith(color: kPrimaryColor, fontWeight: FontWeight.bold),
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
                    labelStyle: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
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
      padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 24.0),
      color: kCardBackground,
      child: _isLoadingProfile
          ? const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 40.0),
            child: CircularProgressIndicator(color: kPrimaryColor),
          ))
          : Column(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: kPrimaryColor.withOpacity(0.1),
            child: Icon(Icons.business_center_outlined, size: 50, color: kPrimaryColor.withOpacity(0.8)),
          ),
          const SizedBox(height: 16),
          Text(
            '${_managerProfile?.name ?? ''} ${_managerProfile?.lastName ?? ''}',
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 6),
          if (_managerProfile?.email.isNotEmpty ?? false)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _managerProfile!.email,
                  style: theme.textTheme.bodyMedium?.copyWith(color: kLightTextColor),
                ),
                const SizedBox(width: 6),
                Icon(Icons.verified_user_outlined, color: Colors.green[600], size: 16)
              ],
            ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('ویرایش پروفایل'),
            onPressed: _editManagerProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              textStyle: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedTabContent(String tabName) {
    if (tabName == 'اطلاعات رزروها') {
      if (_isLoadingHotelReservations) return _buildLoadingIndicator();
      if (_hotelReservations.isEmpty) return _buildEmptyState('هیچ رزروی برای هتل شما یافت نشد.');
      return _buildList(_hotelReservations, (reservation) => HotelReservationCard(reservation: reservation));
    } else if (tabName == 'پاسخگویی به نظرات') {
      if (_isLoadingReviews) return _buildLoadingIndicator();
      if (_reviews.isEmpty) return _buildEmptyState('هیچ نظری برای پاسخگویی یافت نشد.');
      return _buildList(_reviews, _buildReviewItem);
    }
    return const SizedBox.shrink();
  }

  Widget _buildLoadingIndicator() {
    return const Center(child: Padding(padding: EdgeInsets.all(30.0), child: CircularProgressIndicator(color: kPrimaryColor)));
  }

  Widget _buildEmptyState(String message) {
    return Center(child: Padding(padding: const EdgeInsets.all(30.0), child: Text(message, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: kLightTextColor))));
  }

  Widget _buildEmptyStateWithButton(String message, String buttonText, VoidCallback onPressed) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(message, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: kLightTextColor)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_circle_outline, size: 20),
              label: Text(buttonText),
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: kAccentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildList<T>(List<T> items, Widget Function(T item) itemBuilder) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 80.0),
      itemCount: items.length,
      itemBuilder: (context, index) => itemBuilder(items[index]),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
    );
  }

  Widget _buildReviewItem(ReviewModel review) {
    bool isReplying = _replyingToReviewId == review.id;
    return Card(
      elevation: 1.5,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: kCardBackground,
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(review.userName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
                Text(review.date, style: TextStyle(fontSize: 12, color: kLighterTextColor)),
              ],
            ),
            Text(review.roomInfo, style: TextStyle(fontSize: 12, color: kLightTextColor)),
            const SizedBox(height: 10),
            if (review.positivePoints.isNotEmpty) ...[
              const Text("نکات مثبت:", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kPositiveColor)),
              ...review.positivePoints.map((point) => _buildPointRow(point, true)),
              const SizedBox(height: 6),
            ],
            if (review.negativePoints.isNotEmpty) ...[
              const Text("نکات منفی:", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kNegativeColor)),
              ...review.negativePoints.map((point) => _buildPointRow(point, false)),
              const SizedBox(height: 6),
            ],
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Icon(Icons.star_rounded, size: 20, color: Colors.amber[600]),
                    const SizedBox(width: 4),
                    Text(review.rating.toStringAsFixed(1), style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: kLightTextColor)),
                  ],
                ),
                TextButton.icon(
                  onPressed: () => _toggleReplyForm(review.id),
                  icon: Icon(review.managerReplyText != null && !isReplying ? Icons.edit_note_outlined : Icons.reply_outlined, size: 18, color: kAccentColor),
                  label: Text(review.managerReplyText != null && !isReplying ? 'ویرایش پاسخ' : (isReplying ? 'بستن' : 'ثبت پاسخ'), style: TextStyle(color: kAccentColor, fontSize: 13, fontWeight: FontWeight.w600)),
                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
                ),
              ],
            ),
            if (review.managerReplyText != null && !isReplying) ...[
              const Divider(height: 20, thickness: 0.5),
              Text('پاسخ شما:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: kPrimaryColor)),
              const SizedBox(height: 4),
              Text(review.managerReplyText!, style: TextStyle(fontSize: 13, color: Colors.grey[800], fontStyle: FontStyle.italic, height: 1.5)),
            ],
            if (isReplying) _buildReplyForm(review),
          ],
        ),
      ),
    );
  }

  Widget _buildPointRow(String point, bool isPositive) {
    return Padding(
      padding: const EdgeInsets.only(top: 3.0, bottom: 1.0, right: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(isPositive ? Icons.check_circle_outline_rounded : Icons.highlight_off_rounded, size: 16, color: isPositive ? kPositiveColor : kNegativeColor),
          const SizedBox(width: 6),
          Expanded(child: Text(point, style: TextStyle(fontSize: 13, color: Colors.grey[800]))),
        ],
      ),
    );
  }

  Widget _buildReplyForm(ReviewModel review) {
    return Container(
      margin: const EdgeInsets.only(top: 12.0),
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 12.0),
      decoration: BoxDecoration(
          color: kPrimaryColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kPrimaryColor.withOpacity(0.2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('پاسخ به نظر ${review.userName}:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kPrimaryColor)),
          const SizedBox(height: 10),
          TextField(
              controller: _replyController,
              focusNode: _replyFocusNode,
              maxLines: 3,
              minLines: 3,
              textInputAction: TextInputAction.newline,
              style: TextStyle(fontSize: 13.5, color: Colors.grey[850]),
              decoration: InputDecoration(
                  hintText: 'پاسخ خود را اینجا بنویسید...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: kAccentColor, width: 1.5)),
                  contentPadding: const EdgeInsets.all(10))),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoadingReviews ? null : () => _submitReply(review.id, _replyController.text),
              style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                  textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              child: _isLoadingReviews ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('ثبت پاسخ'),
            ),
          )
        ],
      ),
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
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: backgroundColor, child: Material(elevation: overlapsContent || (shrinkOffset > maxExtent - minExtent) ? 2.0 : 0.0, color: backgroundColor, child: tabBar));
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar || backgroundColor != oldDelegate.backgroundColor;
  }
}