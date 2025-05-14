import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// فرض می‌کنیم این فایل‌ها وجود دارند و به درستی پیاده‌سازی شده‌اند
import 'custom_bottom_nav_bar.dart';
import 'widgets/filter_chip_row.dart';
import 'widgets/hotel_card.dart';
import 'widgets/image_banner.dart';
import 'widgets/section_title.dart';
import 'widgets/stay_card.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _bannerController = PageController();

  // Dummy data (replace with actual data from API or state management)
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

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFFEEEEEE), // رنگ ثابت AppBar
          // foregroundColor: Color(0xFF542545), // رنگ آیکون‌ها و متن پیش‌فرض AppBar
          elevation: 0,
          leadingWidth: 120, // کمی بیشتر فضا برای "مکان"
          leading: Padding(
            padding: const EdgeInsets.only(left:16.0, right: 16.0), // برای فارسی، left پدینگ اصلی است
            child: Row(
              mainAxisSize: MainAxisSize.min, // برای جلوگیری از کشیده شدن بیش از حد
              children: [
                Icon(Icons.location_on, color: Color(0xFF542545), size: 22,),
                const SizedBox(width: 4),
                Text(
                  'تهران',
                  style: TextStyle(
                      color: Colors.grey.shade800, // کمی تیره‌تر برای خوانایی بهتر
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Vazirmatn' 
                  ),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.notifications_none_outlined, color: Color(0xFF542545), size: 28),
              onPressed: () {
                // Notification action
              },
            ),
            const SizedBox(width: 8), // این SizedBox برای ایجاد فاصله از لبه صفحه است
          ],
        ),
        body: Align(
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: Container(
              color: Color(0xFFEEEEEE),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner
                  ImageBanner(
                    controller: _bannerController,
                    images: bannerImages,
                  ),
                  Center(
                    child: SmoothPageIndicator(
                      controller: _bannerController,
                      count: bannerImages.length,
                      effect: WormEffect(
                        dotHeight: 8,
                        dotWidth: 8,
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
                  const SizedBox(height: 20),
                  const SectionTitle(
                    title: 'قدم بزنی، می‌رسی',
                    showViewAll: true,
                    viewAllText: 'مشاهده همه',
                    onViewAllPressed: null,
                  ),
                  FilterChipRow(
                    chips: const [
                      'هتل اسپیناس پالاس تهران',
                      'هتل آزادی تهران',
                      'هتل ونوس',
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Section: هتل‌های لوکس با قیمت جیب‌دوست
                  const SectionTitle(title: 'هتل‌های لوکس با قیمت جیب‌دوست'),
                  SizedBox(
                    height: 330,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      padding: const EdgeInsetsDirectional.symmetric(horizontal: 16.0),
                      itemCount: hotels.length,
                      itemBuilder: (context, index) {
                        final hotel = hotels[index];
                        return Padding(
                          padding: const EdgeInsetsDirectional.only(start: 0.0, bottom: 16.0),
                          child: HotelCard(
                            imageUrl: hotel['imageUrl']!,
                            name: hotel['name']!,
                            location: hotel['location']!,
                            rating: (hotel['rating']! as num).toDouble(), // اطمینان از نوع double
                            isFavorite: hotel['isFavorite']!,           // مقدار isFavorite از state خوانده می‌شود
                            discount: (hotel['discount']! as num).toInt(), // اطمینان از نوع int
                            onTap: () {
                              // Handle hotel tap
                              print('Tapped on ${hotel['name']}');
                            },
                            onFavoriteToggle: () {

                            },
                            onReserveTap: () {
                              // Handle reserve tap
                              print('Reserve tapped for ${hotel['name']}');
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const SectionTitle(
                    title: 'ستاره‌های اقامت',
                    showViewAll: true,
                    viewAllText: 'مشاهده همه',
                    onViewAllPressed: null,
                  ),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      padding: const EdgeInsetsDirectional.symmetric(horizontal: 16.0),
                      itemCount: stays.length,
                      itemBuilder: (context, index) {
                        final stay = stays[index];
                        return Padding(
                          padding: const EdgeInsetsDirectional.only(start: 12.0),
                          child: StayCard( // فرض می‌کنم StayCard همان tay_card است
                            imageUrl: stay['imageUrl']!,
                            name: stay['name']!,
                            price: stay['price']!,
                            rating: stay['rating']!,
                            onTap: () {
                              // Handle stay tap
                            },
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
        bottomNavigationBar: CustomBottomNavBar(selectedIndex: 0, onItemTapped: (int ) {  },),
      ),
    );
  }



  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }
}