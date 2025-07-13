// lib/pages/profile_pages/user_account_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../../features/auth/data/services/auth_service.dart';
import 'edit_profile_page.dart';
import '../../../features/auth/presentation/pages/authentication_screen.dart';
import 'models/user_profile_model.dart';
import 'models/reservation_model.dart';
import 'widgets/active_reservation_card.dart';
import 'widgets/previous_reservation_card.dart';

const Color kPrimaryColor = Color(0xFF542545);
const Color kAccentColor = Color(0xFF7E3F6B);
const Color kPageBackground = Color(0xFFF4F6F8);
const Color kCardBackground = Colors.white;
const Color kLightTextColor = Color(0xFF606060);
const Color kLighterTextColor = Color(0xFF888888);
const Color kIconColor = Color(0xFF404040);

class UserAccountPage extends StatefulWidget {
  const UserAccountPage({super.key});
  @override
  State<UserAccountPage> createState() => _UserAccountPageState();
}

class _UserAccountPageState extends State<UserAccountPage> with SingleTickerProviderStateMixin {
  String _selectedTab = 'علاقه‌مندی‌ها';
  TabController? _tabController;

  UserProfileModel? _userProfile;
  List<dynamic> _favoriteHotels = []; // Placeholder
  List<ReservationModel> _allBookings = [];
  List<ReservationModel> _currentBookings = [];
  List<ReservationModel> _previousBookings = [];

  bool _isLoadingProfile = true;
  bool _isLoadingFavorites = true;
  bool _isLoadingCurrentBookings = false;
  bool _isLoadingPreviousBookings = false;

  final List<String> _tabs = const ['علاقه‌مندی‌ها', 'لیست رزروها', 'رزروهای قبلی'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController!.addListener(_handleTabSelection);
    _fetchDataForPage();
  }

  void _handleTabSelection() {
    if (_tabController!.indexIsChanging || _selectedTab == _tabs[_tabController!.index]) return;
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
    } else if (_selectedTab == 'لیست رزروها' || _selectedTab == 'رزروهای قبلی') {
      if (_allBookings.isEmpty) {
        await _fetchReservations();
      }
    }
  }

  Future<void> _fetchUserProfile() async {
    if (!mounted) return;
    setState(() => _isLoadingProfile = true);
    final authService = Provider.of<AuthService>(context, listen: false);
    final token = authService.token;

    if (token == null) {
      _showErrorSnackBar('شما وارد نشده‌اید.');
      setState(() => _isLoadingProfile = false);
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
          _userProfile = UserProfileModel.fromJson(data);
        });
      } else {
        throw Exception('Failed to load profile (Code: ${response.statusCode})');
      }
    } catch (e) {
      _showErrorSnackBar('خطا در بارگذاری پروفایل: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoadingProfile = false);
    }
  }

  Future<void> _fetchFavoriteHotels() async {
    setState(() => _isLoadingFavorites = true);
    await Future.delayed(const Duration(seconds: 1));
    _favoriteHotels = [];
    if(mounted) setState(() => _isLoadingFavorites = false);
  }

  Future<void> _fetchReservations() async {
    if (!mounted) return;

    if (_selectedTab == 'لیست رزروها') {
      setState(() => _isLoadingCurrentBookings = true);
    } else if (_selectedTab == 'رزروهای قبلی') {
      setState(() => _isLoadingPreviousBookings = true);
    }

    final authService = Provider.of<AuthService>(context, listen: false);
    final token = authService.token;

    if (token == null) {
      _showErrorSnackBar('برای مشاهده رزروها، ابتدا وارد شوید.');
      if (mounted) {
        setState(() {
          _isLoadingCurrentBookings = false;
          _isLoadingPreviousBookings = false;
        });
      }
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('https://fbookit.darkube.app/reservation-api/reservation/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (!mounted) return;
      if (response.statusCode == 200) {

        print('--- Reservations Response Body ---');
        print(utf8.decode(response.bodyBytes));
        print('----------------------------------');

        final Map<String, dynamic> responseJson = jsonDecode(utf8.decode(response.bodyBytes));

        final Map<String, dynamic> dataObject = responseJson['data'];

        final List<dynamic> futureList = dataObject['future'] ?? [];
        _currentBookings = futureList.map((json) => ReservationModel.fromJson(json)).toList();

        final List<dynamic> pastList = dataObject['past'] ?? [];
        _previousBookings = pastList.map((json) => ReservationModel.fromJson(json)).toList();

      } else {
        throw Exception('Failed to load reservations (Code: ${response.statusCode})');
      }
    } catch (e) {
      _showErrorSnackBar('خطا در بارگذاری رزروها: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCurrentBookings = false;
          _isLoadingPreviousBookings = false;
        });
      }
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
    await authService.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const AuthenticationScreen()),
          (Route<dynamic> route) => false,
    );
  }

  void _editProfile() {
    if (_userProfile == null) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => EditProfilePage(initialProfileData: _userProfile!),
    )).then((value) {
      if (value == true && mounted) {
        _fetchUserProfile();
      }
    });
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
            child: Icon(Icons.person_outline, size: 50, color: kPrimaryColor.withOpacity(0.8)),
          ),
          const SizedBox(height: 16),
          Text(
            '${_userProfile?.name ?? ''} ${_userProfile?.lastName ?? ''}',
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 6),
          if (_userProfile?.email.isNotEmpty ?? false)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _userProfile!.email,
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
            onPressed: _editProfile,
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
    if (tabName == 'علاقه‌مندی‌ها') {
      if (_isLoadingFavorites) return _buildLoadingIndicator();
      if (_favoriteHotels.isEmpty) return _buildEmptyState('موردی در علاقه‌مندی‌ها یافت نشد.');
      return Container(); // Placeholder
    } else if (tabName == 'لیست رزروها') {
      if (_isLoadingCurrentBookings) return _buildLoadingIndicator();
      if (_currentBookings.isEmpty) return _buildEmptyState('هیچ رزرو فعالی ندارید.');
      return ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        itemCount: _currentBookings.length,
        itemBuilder: (context, index) {
          return ActiveReservationCard(reservation: _currentBookings[index]);
        },
      );
    } else if (tabName == 'رزروهای قبلی') {
      if (_isLoadingPreviousBookings) return _buildLoadingIndicator();
      if (_previousBookings.isEmpty) return _buildEmptyState('هیچ رزرو قبلی یافت نشد.');
      return ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        itemCount: _previousBookings.length,
        itemBuilder: (context, index) {
          return PreviousReservationCard(reservation: _previousBookings[index]);
        },
      );
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
    return Container(color: backgroundColor, child: tabBar);
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar || backgroundColor != oldDelegate.backgroundColor;
  }
}