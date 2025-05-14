import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'widgets/filter_chip_row.dart';
import 'widgets/hotel_card.dart';
import 'widgets/image_banner.dart';
import 'widgets/section_title.dart';
import 'widgets/stay_card.dart';

// فایل مدال جدید را ایمپورت کنید
import 'location_selection_modal.dart'; // مطمئن شوید مسیر درست است

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _bannerController = PageController();
  late PageController _hotelPageController;

  // --- اضافه شده: وضعیت برای شهر انتخاب شده و لیست شهرها ---
  String _selectedCity = 'تهران'; // شهر پیش‌فرض
  final List<String> _allCities = [
    'تهران',
    'مشهد',
    'اصفهان',
    'شیراز',
    'تبریز',
    'کرج',
    'اهواز',
    'کرمانشاه',
    'رشت',
    'یزد',
    'کیش',
    'قشم',
    // شهرهای دیگر را اضافه کنید
  ];
  // --- پایان بخش اضافه شده ---

  // ... (بقیه داده‌های هتل‌ها، اقامتگاه‌ها و بنرها بدون تغییر) ...
  final List<Map<String, dynamic>> hotels = [
    {
      'imageUrl': 'https://picsum.photos/seed/hotel1/400/300',
      'name': 'اسم هتل در حالت طولانی اول',
      'location': 'مکان هتل',
      'rating': 4.0,
      'isFavorite': true,
      'discount': 73,
    },
    {
      'imageUrl': 'https://picsum.photos/seed/hotel2/400/300',
      'name': 'هتل زیبا و مدرن دوم',
      'location': 'مرکز شهر',
      'rating': 5.0,
      'isFavorite': false,
      'discount': 50,
    },
    {
      'imageUrl': 'https://picsum.photos/seed/hotel3/400/300',
      'name': 'اقامتگاه دنج سوم',
      'location': 'نزدیک به طبیعت',
      'rating': 3.5,
      'isFavorite': true,
      'discount': 20,
    },
  ];

  final List<Map<String, dynamic>> stays = [
    {
      'imageUrl': 'https://picsum.photos/seed/stay1/300/200',
      'name': 'اقامتگاه ستاره دار اول',
      'price': '3,200,000',
      'rating': 4.5,
    },
    {
      'imageUrl': 'https://picsum.photos/seed/stay2/300/200',
      'name': 'ویلا لوکس با استخر',
      'price': '5,500,000',
      'rating': 4.8,
    },
    {
      'imageUrl': 'https://picsum.photos/seed/stay3/300/200',
      'name': 'کلبه جنگلی آرام',
      'price': '2,100,000',
      'rating': 4.2,
    },
  ];

  final List<String> bannerImages = [
    'https://via.placeholder.com/600x250/ADD8E6/000000?Text=Hotel+Booking+Plugin+1',
    'https://via.placeholder.com/600x250/90EE90/000000?Text=Special+Offer+2',
    'https://via.placeholder.com/600x250/FFB6C1/000000?Text=New+Destinations+3',
  ];

  int _currentHotelPage = 0;


  @override
  void initState() {
    super.initState();
    _currentHotelPage = hotels.isNotEmpty ? (hotels.length ~/ 2) : 0;
    _hotelPageController = PageController(
      initialPage: _currentHotelPage,
      viewportFraction: 0.75,
    );
  }

  void _showLocationModal(BuildContext context) {
    showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(45.0)),
      ),
      builder: (BuildContext modalContext) {
        return LocationSelectionModal(
          allCities: _allCities,
          currentCity: _selectedCity,
          onCitySelected: (String city) {
            setState(() {
              _selectedCity = city;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFEEEEEE),
          elevation: 0,
          surfaceTintColor: const Color(0xFFEEEEEE),
          leadingWidth: 120,
          leading: GestureDetector(
            onTap: () => _showLocationModal(context),
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on, color: Color(0xFF542545), size: 22),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _selectedCity,
                      style: TextStyle(
                          color: Colors.grey.shade800,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Vazirmatn'),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_none_outlined, color: Color(0xFF542545), size: 28),
              onPressed: () {
                // Notification action
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            child: Container(
              color: const Color(0xFFEEEEEE),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: SmoothPageIndicator(
                      controller: _bannerController,
                      count: bannerImages.length,
                      effect: WormEffect(
                        dotHeight: 6,
                        dotWidth: 6,
                        activeDotColor: Colors.deepPurple.shade300,
                        dotColor: Colors.grey.shade300,
                      ),
                      onDotClicked: (index) => _bannerController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                    ),
                  ),
                  ImageBanner(
                    controller: _bannerController,
                    images: bannerImages,
                  ),
                  const SectionTitle(
                    title: 'قدم بزنی، می‌رسی',
                    showViewAll: true,
                    viewAllText: 'مشاهده همه',
                  ),
                  const SizedBox(height: 5),
                  FilterChipRow( // اگر از ورژن قبلی که فقط متن بود استفاده می‌کنید:
                    items: const [
                      'هتل اسپیناس پالاس تهران',
                      'هتل آزادی تهران',
                      'هتل ونوس',
                    ],
                  ),
                  const SizedBox(height: 15),
                  const SectionTitle(title: 'هتل‌های لوکس با قیمت جیب‌دوست'),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: 290,
                    child: PageView.builder(
                      controller: _hotelPageController,
                      itemCount: hotels.length,
                      onPageChanged: (int page) {
                        // setState(() {
                        //   _currentHotelPage = page;
                        // });
                      },
                      itemBuilder: (context, index) {
                        final hotel = hotels[index];
                        return AnimatedBuilder(
                          animation: _hotelPageController,
                          builder: (context, child) {
                            double value = 0.0;
                            if (_hotelPageController.position.haveDimensions) {
                              value = (_hotelPageController.page ?? _hotelPageController.initialPage.toDouble()) - index;
                              value = value.abs().clamp(0.0, 1.0);
                            }
                            const double maxScale = 1.0;
                            const double minScale = 0.85;
                            final double scale = (maxScale * (1 - value)) + (minScale * value);
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.0,
                                vertical: (1 - scale) * 20,
                              ),
                              child: Transform.scale(
                                scale: scale,
                                alignment: Alignment.center,
                                child: child,
                              ),
                            );
                          },
                          child: HotelCard(
                            imageUrl: hotel['imageUrl']!,
                            name: hotel['name']!,
                            location: hotel['location']!,
                            rating: (hotel['rating']! as num).toDouble(),
                            isFavorite: hotel['isFavorite']!,
                            discount: (hotel['discount']! as num).toInt(),
                            onTap: () {
                              // if (index != _currentHotelPage) { // _currentHotelPage دیگر مستقیم آپدیت نمی‌شود
                              //   _hotelPageController.animateToPage(
                              //     index,
                              //     duration: const Duration(milliseconds: 400),
                              //     curve: Curves.easeInOut,
                              //   );
                              // } else {
                              print('Tapped on centered ${hotel['name']}');
                              // }
                            },
                            onFavoriteToggle: () {
                              setState(() {
                                hotels[index]['isFavorite'] = !hotels[index]['isFavorite'];
                              });
                            },
                            onReserveTap: () {},
                          ),
                        );
                      },
                    ),
                  ),
                  const SectionTitle(
                    title: 'ستاره‌های اقامت',
                    showViewAll: true,
                    viewAllText: 'مشاهده همه',
                  ),
                  SizedBox(
                    height: 95,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      padding: const EdgeInsetsDirectional.symmetric(horizontal: 16.0),
                      itemCount: stays.length,
                      itemBuilder: (context, index) {
                        final stay = stays[index];
                        return Padding(
                          padding: const EdgeInsetsDirectional.only(start: 12.0),
                          child: StayCard(
                            imageUrl: stay['imageUrl']!,
                            name: stay['name']!,
                            price: stay['price']!,
                            rating: stay['rating']!,
                            onTap: () {},
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _bannerController.dispose();
    _hotelPageController.dispose();
    super.dispose();
  }
}

// اگر ویجت‌های دیگر (FilterChipRow, ImageBanner, HotelCard, StayCard, SectionTitle)
// در فایل‌های جداگانه نیستند، کدهای آن‌ها را هم اینجا قرار دهید یا مطمئن شوید که به درستی ایمپورت شده‌اند.