import 'package:bookit/core/models/hotel_model.dart';
import 'package:bookit/features/auth/data/services/auth_service.dart';
import 'package:bookit/features/guest/home/presentation/pages/hotel_list_screen.dart';
import 'package:bookit/features/guest/home/presentation/widgets/category_card.dart';
import 'package:bookit/features/guest/home/presentation/widgets/hotel_card.dart';
import 'package:bookit/features/guest/home/presentation/widgets/image_banner.dart';
import 'package:bookit/features/guest/home/presentation/widgets/location_selection_modal.dart';
import 'package:bookit/features/guest/home/presentation/widgets/section_header.dart';
import 'package:bookit/features/guest/hotel_detail/presentation/pages/hotel_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/services/hotel_api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeApiService _apiService;
  Future<List<List<Hotel>>>? _allDataFuture;
  String _selectedCity = 'تهران';
  final List<String> _allCities = [
    'تهران',
    'مشهد',
    'اصفهان',
    'شیراز',
    'تبریز',
    'کیش',
    'قشم'
  ];
  final List<String> _bannerImages = [
    'https://picsum.photos/seed/banner1/800/400',
    'https://picsum.photos/seed/banner2/800/400',
    'https://picsum.photos/seed/banner3/800/400'
  ];

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AuthService>(context, listen: false);
    _apiService = HomeApiService(authService);
    _loadData();
  }

  void _loadData() {
    setState(() {
      _allDataFuture = Future.wait([
        _apiService.fetchHotelsByLocation(_selectedCity),
        _apiService.fetchHotelsWithDiscount(),
        _apiService.fetchTopRatedHotels(),
      ]);
    });
  }

  void _onCityChanged(String newCity) {
    if (newCity == _selectedCity) return;
    setState(() {
      _selectedCity = newCity;
    });
    _loadData();
  }

  void _showLocationModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) => LocationSelectionModal(
        allCities: _allCities,
        currentCity: _selectedCity,
        onCitySelected: _onCityChanged,
      ),
    );
  }

  void _navigateToHotelList(String title, List<Hotel> hotels) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HotelListScreen(title: title, hotels: hotels),
      ),
    );
  }

  void _navigateToHotelDetail(Hotel hotel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HotelDetailScreen(hotel: hotel),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context),
            FutureBuilder<List<List<Hotel>>>(
              future: _allDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()));
                }
                if (snapshot.hasError) {
                  return SliverFillRemaining(
                      child: Center(
                          child:
                          Text('خطا در دریافت اطلاعات: ${snapshot.error}')));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SliverFillRemaining(
                      child: Center(child: Text('اطلاعاتی برای نمایش یافت نشد.')));
                }

                final hotelsByCity = snapshot.data![0];
                final discountedHotels = snapshot.data![1];
                final topRatedHotels = snapshot.data![2];

                return SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      const SizedBox(height: 16),
                      ImageBanner(images: _bannerImages),
                      const SizedBox(height: 32),
                      const SectionHeader(title: 'انتخاب نوع اقامتگاه'),
                      const SizedBox(height: 16),
                      _buildCategories(),
                      const SizedBox(height: 32),
                      SectionHeader(
                          title: 'هتل‌های شهر $_selectedCity',
                          viewAllText: 'مشاهده همه',
                          onViewAllPressed: () => _navigateToHotelList(
                              'هتل‌های شهر $_selectedCity', hotelsByCity)),
                      const SizedBox(height: 16),
                      _buildHotelList(hotelsByCity),
                      const SizedBox(height: 32),
                      SectionHeader(
                          title: 'هتل‌های جیب‌دوست',
                          viewAllText: 'مشاهده همه',
                          onViewAllPressed: () => _navigateToHotelList(
                              'هتل‌های جیب‌دوستز', discountedHotels)),
                      const SizedBox(height: 16),
                      _buildHotelList(discountedHotels),
                      const SizedBox(height: 32),
                      SectionHeader(
                          title: 'ستاره‌های اقامت',
                          viewAllText: 'مشاهده همه',
                          onViewAllPressed: () =>
                              _navigateToHotelList('ستاره‌های اقامت', topRatedHotels)),
                      const SizedBox(height: 16),
                      _buildHotelList(topRatedHotels),
                      const SizedBox(height: 32),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    return SliverAppBar(
      pinned: true,
      floating: true,
      backgroundColor: theme.scaffoldBackgroundColor.withOpacity(0.85),
      elevation: 0.5,
      surfaceTintColor: Colors.transparent,
      title: InkWell(
        onTap: _showLocationModal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on_outlined,
                color: theme.colorScheme.primary, size: 22),
            const SizedBox(width: 8),
            Text(_selectedCity, style: theme.textTheme.titleMedium),
            const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 20),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_none_outlined,
              color: theme.colorScheme.primary, size: 28),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildCategories() {
    final categories = [
      {'icon': Icons.hotel, 'label': 'هتل', 'color': Colors.blue},
      {'icon': Icons.house_rounded, 'label': 'ویلا', 'color': Colors.green},
      {'icon': Icons.landscape, 'label': 'بوم‌گردی', 'color': Colors.orange},
      {'icon': Icons.apartment, 'label': 'آپارتمان', 'color': Colors.purple},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: categories
            .map((cat) => CategoryCard(
          icon: cat['icon'] as IconData,
          label: cat['label'] as String,
          color: cat['color'] as Color,
          onTap: () {},
        ))
            .toList(),
      ),
    );
  }

  Widget _buildHotelList(List<Hotel> hotels) {
    if (hotels.isEmpty) {
      return const SizedBox(
          height: 100, child: Center(child: Text('هتلی برای نمایش یافت نشد.')));
    }
    return SizedBox(
      height: 400.0,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: hotels.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: HotelCard(
              hotel: hotels[index],
              onTap: () => _navigateToHotelDetail(hotels[index]),
            ),
          );
        },
      ),
    );
  }
}