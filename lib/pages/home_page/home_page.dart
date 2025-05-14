import 'dart:math';
import 'dart:ui' show lerpDouble; // For smoother interpolation

import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'custom_bottom_nav_bar.dart'; // Assuming this exists
import 'widgets/filter_chip_row.dart'; // Assuming this exists
import 'widgets/hotel_card.dart';
import 'widgets/image_banner.dart'; // Assuming this exists
import 'widgets/section_title.dart'; // Assuming this exists
import 'widgets/stay_card.dart'; // Assuming this exists

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _bannerController = PageController();
  late PageController _hotelPageController; // For the hotel carousel

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
    {
      'imageUrl': 'https://picsum.photos/seed/hotel4/400/300',
      'name': 'هتل چهارم برای تست',
      'location': 'کنار دریا',
      'rating': 4.2,
      'isFavorite': false,
      'discount': 15,
    },
    {
      'imageUrl': 'https://picsum.photos/seed/hotel5/400/300',
      'name': 'هتل پنجم لوکس',
      'location': 'کوهستان',
      'rating': 4.9,
      'isFavorite': true,
      'discount': 30,
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

  int _currentHotelPage = 0; // To keep track of the centered hotel item

  @override
  void initState() {
    super.initState();
     _currentHotelPage = hotels.isNotEmpty ? (hotels.length ~/ 2) : 0;
    _hotelPageController = PageController(
      initialPage: _currentHotelPage,
      viewportFraction: 0.75, // Adjust this to control how much of the next/prev items are visible
    );
    // Listener to update current page for other UI elements if needed, or just for state
    _hotelPageController.addListener(() {
      int nextPage = _hotelPageController.page?.round() ?? _currentHotelPage;
      if (nextPage != _currentHotelPage) {
        // setState(() { // Not strictly needed for scaling if using AnimatedBuilder properly
        //   _currentHotelPage = nextPage;
        // });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFEEEEEE),
          elevation: 0,
          surfaceTintColor: Color(0xFFEEEEEE),
          leadingWidth: 120,
          leading: Padding(
            padding: const EdgeInsets.only(left:16.0, right: 16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on, color: Color(0xFF542545), size: 22,),
                const SizedBox(width: 4),
                Text(
                  'تهران',
                  style: TextStyle(
                      color: Colors.grey.shade800,
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
              icon: const Icon(Icons.notifications_none_outlined, color: Color(0xFF542545), size: 28),
              onPressed: () {},
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Align(
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: Container(
              color: const Color(0xFFEEEEEE),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                        activeDotColor: Color(0xFF542545),
                        dotColor: Colors.grey.shade300,
                      ),
                      onDotClicked: (index) => _bannerController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const SectionTitle(
                    title: 'قدم بزنی، می‌رسی',
                    showViewAll: true,
                    viewAllText: 'مشاهده همه',
                  ),
                   FilterChipRow(
                     items: [
                       'هتل اسپیناس پالاس تهران',
                       'هتل آزادی تهران',
                       'هتل ونوس',
                       'هتل اسپیناس پالاس تهران',
                       'هتل آزادی تهران',
                       'هتل ونوس',
                       'هتل ونوس',
                     ],
                  ),
                  const SizedBox(height: 10),
                  const SectionTitle(title: 'هتل‌های لوکس با قیمت جیب‌دوست'),
                  SizedBox(
                    height: 320, // Increased height slightly to accommodate scaled card and padding
                    child: PageView.builder(
                      reverse: true,
                      controller: _hotelPageController,
                      itemCount: hotels.length,
                      // reverse: true, // PageView handles LTR/RTL based on Directionality
                      onPageChanged: (int page) {
                        setState(() {
                          _currentHotelPage = page;
                        });
                      },
                      itemBuilder: (context, index) {
                        final hotel = hotels[index];
                        // AnimatedBuilder is used to listen to PageController and rebuild
                        // only the transforming part, which is more efficient.
                        return AnimatedBuilder(
                          animation: _hotelPageController,
                          builder: (context, child) {
                            double value = 0.0;
                            if (_hotelPageController.position.haveDimensions) {
                              value = (_hotelPageController.page ?? _hotelPageController.initialPage.toDouble()) - index;
                              // We want a value from 0 (centered) to 1 (one page away)
                              value = value.abs();
                              // Clamp value to prevent extreme scaling beyond adjacent items
                              value = value.clamp(0.0, 1.0);
                            }

                            // Define max and min scale
                            const double maxScale = 1.0;  // Scale for the centered item
                            const double minScale = 0.85; // Scale for adjacent items

                            // Interpolate scale: maxScale when value is 0, minScale when value is 1
                            final double scale = lerpDouble(maxScale, minScale, value)!;

                            // Add vertical padding to give space when card is scaled up
                            // Add horizontal padding to create space between cards
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.0, // Space between cards
                                vertical: lerpDouble(0,0, 1-scale)! , // More vertical padding for smaller items
                              ),
                              child: Transform.scale(
                                scale: scale,
                                alignment: Alignment.center, // Ensure scaling is from the center
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
                              // If not centered, animate to it
                              if (index != _currentHotelPage) {
                                _hotelPageController.animateToPage(
                                  index,
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOut,
                                );
                              } else {
                                // Handle hotel tap when it's already centered
                                print('Tapped on centered ${hotel['name']}');
                              }
                            },
                            onFavoriteToggle: () {
                              // Example: Update favorite state
                              setState(() {
                                hotels[index]['isFavorite'] = !hotels[index]['isFavorite'];
                              });
                              print('Favorite toggled for ${hotel['name']}');
                            },
                            onReserveTap: () {
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
                  ),
                  SizedBox(
                    height: 115,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      reverse: false,
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
    _hotelPageController.dispose(); // Don't forget to dispose this!
    super.dispose();
  }
}
