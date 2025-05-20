import 'package:flutter/material.dart';

import 'add_hotel_info.dart';

// Helper to create MaterialColor from a single Color
MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}

final Color customPurple = Color(0xFF542545);
final MaterialColor customPurpleSwatch = createMaterialColor(customPurple);


// مدل داده برای هتل
class Hotel {
  final String id;
  final String imageUrl;
  final String title;
  final int roomCount;
  final String price;
  final String location;
  final double rating;

  Hotel({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.roomCount,
    required this.price,
    required this.location,
    required this.rating,
  });
}

class HotelListScreen extends StatefulWidget {
  const HotelListScreen({super.key});

  @override
  State<HotelListScreen> createState() => _HotelListScreenState();
}

class _HotelListScreenState extends State<HotelListScreen> {
  List<Hotel> _hotels = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchHotels();
  }

  Future<void> _fetchHotels() async {
    setState(() {
      _isLoading = true;
    });
    // شبیه‌سازی تاخیر شبکه
    await Future.delayed(const Duration(seconds: 1));

    // داده‌های نمونه - در یک برنامه واقعی، این داده‌ها از سرور می‌آیند
    // هر بار فراخوانی، می‌تواند داده‌های متفاوتی برگرداند یا لیست را آپدیت کند
    // برای تست، یک timestamp به عنوان بخشی از عنوان اضافه می‌کنیم تا تغییرات مشخص شود
    final timestamp = DateTime.now().second;
    setState(() {
      _hotels = [
        Hotel(
          id: '1',
          imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Nnx8aG90ZWx8ZW58MHx8MHx8fDA%3D&w=1000&q=80',
          title: 'هتل نمونه اول ($timestamp)',
          roomCount: 5,
          price: '3,200,000',
          location: 'تهران، خیابان آزادی',
          rating: 4.5,
        ),
        Hotel(
          id: '2',
          imageUrl: 'https://images.unsplash.com/photo-1582719508461-905c673771fd?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8aG90ZWwlMjByb29tfGVufDB8fDB8fHww&w=1000&q=80',
          title: 'هتل نمونه دوم ($timestamp)',
          roomCount: 3,
          price: '2,500,000',
          location: 'شیراز، بلوار کریمخان',
          rating: 4.2,
        ),
        Hotel(
          id: '3',
          imageUrl: 'https://plus.unsplash.com/premium_photo-1678297270020-60a70a1d4e45?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8aG90ZWwlMjByb29tfGVufDB8fDB8fHww',
          title: 'هتل نمونه سوم ($timestamp)',
          roomCount: 8,
          price: '5,100,000',
          location: 'اصفهان، میدان نقش جهان',
          rating: 4.8,
        ),
      ];
      _isLoading = false;
    });
    print("لیست هتل‌ها به‌روز شد.");
  }

  void _navigateAndRefresh(BuildContext context) async {
    // ناوبری به صفحه افزودن/ویرایش هتل
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddHotelInfo()),
    );

    // پس از بازگشت از صفحه HotelInfoPage، لیست هتل‌ها را دوباره بارگذاری کن
    // این شرط می‌تواند برای بررسی اینکه آیا تغییری رخ داده یا نه هم استفاده شود
    // if (result == true) { // مثلا اگر صفحه info در صورت ذخیره true برگرداند
    _fetchHotels();
    // }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('هتل های شما'), // فونت از theme گرفته می‌شود
        backgroundColor: Colors.grey[100],
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator( // برای کشیدن به پایین و رفرش کردن
        onRefresh: _fetchHotels,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 80.0), // فضا برای FAB
          itemCount: _hotels.length,
          itemBuilder: (context, index) {
            final hotel = _hotels[index];
            return HotelCard(
              hotel: hotel,
            );
          },
          separatorBuilder: (context, index) => const SizedBox(height: 20),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat, // در RTL: راست-پایین
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _navigateAndRefresh(context);
        },
        label: const Text('افزودن هتل'), // فونت از theme گرفته می‌شود
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class HotelCard extends StatelessWidget {
  final Hotel hotel;

  const HotelCard({
    super.key,
    required this.hotel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // در RTL، از راست شروع می‌شود
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12.0),
                  topRight: Radius.circular(12.0),
                ),
                child: Image.network(
                  hotel.imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 180,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, color: Colors.grey, size: 50),
                    );
                  },
                ),
              ),
              Positioned(
                top: 8,
                right: 8, // در RTL، این به معنی سمت راست است
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        hotel.rating.toStringAsFixed(1),
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.thumb_up_alt_rounded, color: Colors.white, size: 14),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // در RTL، از راست شروع می‌شود
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        hotel.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start, // در RTL، از راست شروع می‌شود
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '+ ${hotel.roomCount} اتاق',
                      style: TextStyle(
                          color: Colors.deepPurple, // یا customPurple.withOpacity(0.7)
                          fontWeight: FontWeight.w500
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${hotel.price} تومان',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'شروع قیمت از',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.monetization_on_outlined,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded( // برای اینکه متن مکان طولانی هم جا شود
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: Colors.deepPurple, // یا customPurple.withOpacity(0.7)
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              hotel.location,
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.start, // در RTL، از راست شروع می‌شود
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8), // فاصله بین مکان و دکمه
                    InkWell(
                      onTap: () {
                        // TODO: ناوبری به صفحه ویرایش این هتل خاص
                        print('تغییر اطلاعات برای ${hotel.title} فشرده شد');
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AddHotelInfo()), // ارسال هتل برای ویرایش
                        ).then((_){
                          // اگر نیاز بود پس از بازگشت از ویرایش هم صفحه اصلی رفرش شود
                          // (context as Element).markNeedsBuild(); // یک راه ساده برای رفرش stateful والد اگر تغییر از طریق state مدیریت نشود
                          // یا فراخوانی متد رفرش از والد
                        });
                      },
                      child: Row(
                        children: [
                          Text(
                            'تغییر اطلاعات',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_back_ios_new, // در RTL به چپ اشاره می‌کند
                            color: Colors.grey[700],
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
