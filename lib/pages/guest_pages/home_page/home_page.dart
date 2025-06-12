// فایل: pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../authentication_page/auth_service.dart';
import 'hotel_api_service.dart';
import 'model/hotel_model.dart';
import 'widgets/category_card.dart';
import 'widgets/hotel_card.dart';
import 'widgets/image_banner.dart';
import 'widgets/section_title.dart';
import 'location_selection_modal.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HotelApiService _apiService;

  // *** تغییر: برای هر لیست، یک متغیر خطا و وضعیت لودینگ جداگانه در نظر می‌گیریم ***
  List<Hotel>? _hotelsByCity;
  List<Hotel>? _discountedHotels;
  List<Hotel>? _topRatedHotels;

  bool _isCityLoading = true;
  bool _isDiscountLoading = true;
  bool _isTopRatedLoading = true;

  String? _globalErrorMessage;

  String _selectedCity = 'تهران';
  final List<String> _allCities = ['تهران', 'مشهد', 'اصفهان', 'شیراز', 'تبریز', 'کیش', 'قشم'];

  final PageController _bannerController = PageController();
  final List<String> bannerImages = ['https://picsum.photos/seed/banner1/800/400', 'https://picsum.photos/seed/banner2/800/400', 'https://picsum.photos/seed/banner3/800/400'];
  final List<Map<String, dynamic>> categories = [
    {'icon': Icons.hotel, 'label': 'هتل', 'color': Colors.blue}, {'icon': Icons.house_rounded, 'label': 'ویلا', 'color': Colors.green},
    {'icon': Icons.landscape, 'label': 'بوم‌گردی', 'color': Colors.orange}, {'icon': Icons.apartment, 'label': 'آپارتمان', 'color': Colors.purple},
  ];

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AuthService>(context, listen: false);
    _apiService = HotelApiService(authService);
    _fetchInitialData();
  }

  // *** بخش کلیدی: بازنویسی کامل این تابع برای مدیریت مستقل درخواست‌ها ***
  Future<void> _fetchInitialData() async {
    setState(() {
      _isCityLoading = true;
      _isDiscountLoading = true;
      _isTopRatedLoading = true;
      _globalErrorMessage = null;
    });

    // --- دریافت هتل‌های شهر ---
    try {
      final cityHotels = await _apiService.fetchHotelsByLocation(_selectedCity);
      if (mounted) setState(() => _hotelsByCity = cityHotels);
    } catch (e) {
      print("Error fetching city hotels: $e");
      if (mounted) setState(() => _hotelsByCity = null); // null به معنی خطا است
    } finally {
      if (mounted) setState(() => _isCityLoading = false);
    }

    // --- دریافت هتل‌های تخفیف‌دار ---
    try {
      final discountHotels = await _apiService.fetchHotelsWithDiscount();
      if (mounted) setState(() => _discountedHotels = discountHotels);
    } catch (e) {
      print("Error fetching discount hotels: $e");
      if (mounted) setState(() => _discountedHotels = null);
    } finally {
      if (mounted) setState(() => _isDiscountLoading = false);
    }

    // --- دریافت هتل‌های برتر (این بخش همچنان خطا خواهد داد تا بک‌اند اصلاح شود) ---
    try {
      final topHotels = await _apiService.fetchTopRatedHotels();
      if (mounted) setState(() => _topRatedHotels = topHotels);
    } catch (e) {
      print("Error fetching top rated hotels: $e");
      if (mounted) setState(() => _topRatedHotels = null);
    } finally {
      if (mounted) setState(() => _isTopRatedLoading = false);
    }
  }

  void _onCityChanged(String newCity) {
    if (newCity == _selectedCity) return;
    setState(() {
      _selectedCity = newCity;
      _isCityLoading = true; // نمایش لودر فقط برای لیست شهر
      _hotelsByCity = [];
    });

    _apiService.fetchHotelsByLocation(newCity).then((hotels) {
      if (mounted) setState(() => _hotelsByCity = hotels);
    }).catchError((e) {
      if (mounted) {
        setState(() => _hotelsByCity = null); // مدیریت خطا
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطا در دریافت هتل‌های شهر: $e')));
      }
    }).whenComplete(() {
      if (mounted) setState(() => _isCityLoading = false);
    });
  }

  // بقیه متدها بدون تغییر...
  void _showLocationModal() {
    showModalBottomSheet<String>(
      context: context, isScrollControlled: true, backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
      builder: (modalContext) => LocationSelectionModal(
        allCities: _allCities, currentCity: _selectedCity, onCitySelected: _onCityChanged,
      ),
    );
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF542545);
    const Color backgroundColor = Color(0xFFF8F9FA);

    bool showGlobalLoader = _isCityLoading && _isDiscountLoading && _isTopRatedLoading;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: showGlobalLoader
            ? const Center(child: CircularProgressIndicator(color: primaryColor))
            : _globalErrorMessage != null
            ? Center(child: Text(_globalErrorMessage!)) // اینجا خطای کلی نمایش داده می‌شود
            : Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width > 1200 ? 1200 : MediaQuery.of(context).size.width),
            child: RefreshIndicator(
              onRefresh: _fetchInitialData,
              child: CustomScrollView(
                slivers: [
                  _buildSliverAppBar(primaryColor),
                  SliverToBoxAdapter(child: _buildBodyContent(primaryColor)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ... (متدهای _buildSliverAppBar و _buildBodyContent بدون تغییر)
  SliverAppBar _buildSliverAppBar(Color primaryColor) {
    return SliverAppBar(
      pinned: true, floating: true, snap: true,
      backgroundColor: Colors.white.withOpacity(0.85),
      elevation: 1, shadowColor: Colors.black.withOpacity(0.1),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.zero,
        centerTitle: true,
        title: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: _showLocationModal,
                  child: Row(
                    children: [
                      Icon(Icons.location_on_outlined, color: primaryColor, size: 22),
                      const SizedBox(width: 8),
                      Text(_selectedCity, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 20),
                    ],
                  ),
                ),
                IconButton(icon: Icon(Icons.notifications_none_outlined, color: primaryColor, size: 28), onPressed: () {}),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBodyContent(Color primaryColor) {
    return AnimationLimiter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: AnimationConfiguration.toStaggeredList(
          duration: const Duration(milliseconds: 375),
          childAnimationBuilder: (widget) => SlideAnimation(verticalOffset: 50.0, child: FadeInAnimation(child: widget)),
          children: [
            const SizedBox(height: 16),
            ImageBanner(controller: _bannerController, images: bannerImages),
            const SizedBox(height: 12),
            Center(child: SmoothPageIndicator(controller: _bannerController, count: bannerImages.length, effect: ExpandingDotsEffect(dotHeight: 8, dotWidth: 8, activeDotColor: primaryColor, dotColor: Colors.grey.shade300))),
            const SizedBox(height: 32),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 24.0), child: SectionTitle(title: 'انتخاب نوع اقامتگاه')),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(categories.length, (index) => _buildAnimatedListItem(index: index, isHorizontal: false, child: CategoryCard(icon: categories[index]['icon'], label: categories[index]['label'], color: categories[index]['color'], onTap: () {}))),
              ),
            ),
            const SizedBox(height: 32),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 24.0), child: SectionTitle(title: 'هتل‌های شهر $_selectedCity')),
            const SizedBox(height: 16),
            _buildHotelList(_hotelsByCity, _isCityLoading), // پاس دادن وضعیت لودینگ

            const SizedBox(height: 32),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 24.0), child: SectionTitle(title: 'پیشنهادهای شگفت‌انگیز')),
            const SizedBox(height: 16),
            _buildHotelList(_discountedHotels, _isDiscountLoading),

            const SizedBox(height: 32),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 24.0), child: SectionTitle(title: 'محبوب‌ترین‌ها')),
            const SizedBox(height: 16),
            _buildHotelList(_topRatedHotels, _isTopRatedLoading),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }


  // *** بخش کلیدی: بازنویسی این تابع برای مدیریت حالت‌های مختلف هر لیست ***
  Widget _buildHotelList(List<Hotel>? hotelList, bool isLoading) {
    const listHeight = 310.0;

    if (isLoading) {
      return const SizedBox(height: listHeight, child: Center(child: CircularProgressIndicator()));
    }

    if (hotelList == null) {
      // حالت خطا برای این لیست خاص
      return const SizedBox(height: 100, child: Center(child: Text('خطا در دریافت اطلاعات این بخش')));
    }

    if (hotelList.isEmpty) {
      // حالت لیست خالی
      return const SizedBox(height: 100, child: Center(child: Text('هتلی برای نمایش یافت نشد.')));
    }

    return SizedBox(
      height: listHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: hotelList.length,
        itemBuilder: (context, index) {
          final hotel = hotelList[index];
          return _buildAnimatedListItem(
            index: index,
            child: HotelCard(hotel: hotel),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedListItem({required int index, required Widget child, bool isHorizontal = true}) {
    return AnimationConfiguration.staggeredList(
      position: index,
      duration: const Duration(milliseconds: 375),
      child: SlideAnimation(
        horizontalOffset: isHorizontal ? 50.0 : 0,
        verticalOffset: isHorizontal ? 0 : 50.0,
        child: FadeInAnimation(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0), child: child)),
      ),
    );
  }
}