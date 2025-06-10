import 'package:bookit/pages/guest_pages/home_page/model/hotel_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'hotel_api_service.dart';
import 'widgets/category_card.dart';
import 'widgets/hotel_card.dart';
import 'widgets/image_banner.dart';
import 'widgets/section_title.dart';
import 'location_selection_modal.dart';
import '../hotel_detail_page/hotel_detail_page.dart';
import 'hotel_list_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _bannerController = PageController();
  final HotelApiService _apiService = HotelApiService();

  String _selectedCity = 'تهران';
  final List<String> _allCities = ['تهران', 'مشهد', 'اصفهان', 'شیراز', 'تبریز', 'کیش', 'قشم'];

  // State variables for data from server
  List<Hotel> _hotelsByCity = [];
  List<Hotel> _discountedHotels = [];
  List<Hotel> _topRatedHotels = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Mock data (for UI placeholders if needed)
  final List<String> bannerImages = ['https://picsum.photos/seed/banner1/800/400', 'https://picsum.photos/seed/banner2/800/400', 'https://picsum.photos/seed/banner3/800/400'];
  final List<Map<String, dynamic>> categories = [
    {'icon': Icons.hotel, 'label': 'هتل', 'color': Colors.blue}, {'icon': Icons.house_rounded, 'label': 'ویلا', 'color': Colors.green},
    {'icon': Icons.landscape, 'label': 'بوم‌گردی', 'color': Colors.orange}, {'icon': Icons.apartment, 'label': 'آپارتمان', 'color': Colors.purple},
  ];

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final results = await Future.wait([
        _apiService.fetchHotels(city: _selectedCity),
        _apiService.fetchHotels(hasDiscount: true),
        _apiService.fetchHotels(minRate: 4), // امتیاز بالای 4
      ]);
      if (mounted) {
        setState(() {
          _hotelsByCity = results[0];
          _discountedHotels = results[1];
          _topRatedHotels = results[2];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'خطا در دریافت اطلاعات: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _onCityChanged(String newCity) {
    if (newCity == _selectedCity) return;

    setState(() {
      _selectedCity = newCity;
      _hotelsByCity = []; // لیست را خالی می‌کنیم تا لودر نمایش داده شود
    });

    _apiService.fetchHotels(city: newCity).then((hotels) {
      if (mounted) {
        setState(() {
          _hotelsByCity = hotels;
        });
      }
    }).catchError((e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطا در دریافت هتل‌های شهر: $e')));
      }
    });
  }

  void _showLocationModal() {
    showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
      builder: (modalContext) => LocationSelectionModal(
        allCities: _allCities,
        currentCity: _selectedCity,
        onCitySelected: _onCityChanged,
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
    double maxContentWidth = MediaQuery.of(context).size.width > 1200 ? 1200 : MediaQuery.of(context).size.width;
    const Color primaryColor = Color(0xFF542545);
    const Color backgroundColor = Color(0xFFF8F9FA);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: primaryColor))
            : _errorMessage != null
            ? Center(child: Text(_errorMessage!))
            : Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: CustomScrollView(
              slivers: [
                _buildSliverAppBar(primaryColor),
                SliverToBoxAdapter(child: _buildBodyContent(primaryColor)),
              ],
            ),
          ),
        ),
      ),
    );
  }

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

            // لیست هتل‌های شهر انتخاب شده
            Padding(padding: const EdgeInsets.symmetric(horizontal: 24.0), child: SectionTitle(title: 'هتل‌های شهر $_selectedCity',)),
            const SizedBox(height: 16),
            _buildHotelList(_hotelsByCity),
            const SizedBox(height: 32),

            // لیست هتل‌های تخفیف‌دار
            Padding(padding: const EdgeInsets.symmetric(horizontal: 24.0), child: SectionTitle(title: 'پیشنهادهای شگفت‌انگیز',),),
            const SizedBox(height: 16),
            _buildHotelList(_discountedHotels),
            const SizedBox(height: 32),

            // لیست هتل‌های محبوب (امتیاز بالا)
            Padding(padding: const EdgeInsets.symmetric(horizontal: 24.0), child: SectionTitle(title: 'محبوب‌ترین‌ها',),),
            const SizedBox(height: 16),
            _buildHotelList(_topRatedHotels),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHotelList(List<Hotel> hotelList) {
    if (hotelList.isEmpty) {
      return const SizedBox(height: 100, child: Center(child: Text('هتلی برای نمایش یافت نشد.')));
    }
    return SizedBox(
      height: 310,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: hotelList.length,
        itemBuilder: (context, index) {
          final hotel = hotelList[index];
          return _buildAnimatedListItem(
            index: index,
            child: SizedBox(
              width: 280,
              child: HotelCard(
                imageUrl: hotel.imageUrl ?? 'https://picsum.photos/seed/${hotel.id}/400/300',
                name: hotel.name,
                location: hotel.location,
                // --- شروع تغییرات برای رفع خطا ---
                rating: 4.0, // مقدار ثابت چون hotel.rate وجود ندارد
                isFavorite: false, // مقدار ثابت چون hotel.isFavorite وجود ندارد
                discount: 0, // مقدار ثابت چون hotel.discount وجود ندارد
                // --- پایان تغییرات ---
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => HotelDetailsPage(hotelId: hotel.id.toString()))),
                onFavoriteToggle: () {
                  // این بخش کار نخواهد کرد تا زمانی که isFavorite به مدل اضافه شود
                  // setState(() => hotel.isFavorite = !hotel.isFavorite);
                },
                onReserveTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => HotelDetailsPage(hotelId: hotel.id.toString()))),
                id: hotel.id.toString(),
              ),
            ),
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