import 'package:bookit/pages/home_page/widgets/hotel_list_card.dart';
import 'package:flutter/material.dart';

class HotelListPage extends StatefulWidget {
  const HotelListPage({super.key});

  @override
  State<HotelListPage> createState() => _HotelListPageState();
}

class _HotelListPageState extends State<HotelListPage> {
  // Sample data for the list
  late List<Map<String, dynamic>> hotelDataList;

  @override
  void initState() {
    super.initState();
    hotelDataList = [
      {
        "imageUrl": "https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=500&q=60",
        "name": "اسم هتل در حالت طولانی اسم هتل خیلی طولانی",
        "location": "تهران", // This 'location' is part of the data model
        "rating": 4.0,
        "isFavorite": true,
        "price": 3200000,
      },
      {
        "imageUrl": "https://images.unsplash.com/photo-1582719508461-905c673771fd?auto=format&fit=crop&w=500&q=60",
        "name": "هتل پنج ستاره لوکس و مدرن",
        "location": "شیراز",
        "rating": 4.8,
        "isFavorite": false,
        "price": 7500000,
      },
      {
        "imageUrl": "https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?auto=format&fit=crop&w=500&q=60",
        "name": "اقامتگاه سنتی دلنشین باصفا",
        "location": "اصفهان",
        "rating": 4.2,
        "isFavorite": true,
        "price": 4100000,
      },
      {
        "imageUrl": "bad_url_to_test_error.jpg", // To demonstrate errorBuilder
        "name": "هتل با تصویر خراب شده",
        "location": "یزد",
        "rating": 3.1,
        "isFavorite": false,
        "price": 1800000,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    const Color pageBackgroundColor = Color(0xFFEEEEEE); // Very light grey
    const Color appBarTextColor = Colors.black;    // Dark grey for title
    const Color appBarIconColor = Color(0xFF542545);   // Purple for back arrow

    return Scaffold(
      backgroundColor: pageBackgroundColor,
      appBar: AppBar(
        backgroundColor: pageBackgroundColor,
        elevation: 0,
        surfaceTintColor: pageBackgroundColor,// Subtle shadow for separation
        centerTitle: true,
        title: const Text(
          "ستاره های اقامت",
          style: TextStyle(
            color: appBarTextColor,
            fontWeight: FontWeight.bold,
            fontFamily: 'Vazirmatn', // Ensure this font is in your project
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: appBarIconColor),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0), // Padding for the list
        itemCount: hotelDataList.length,
        itemBuilder: (context, index) {
          final hotel = hotelDataList[index];
          return HotelListCard(
            imageUrl: hotel["imageUrl"]!,
            name: hotel["name"]!,
            location: hotel["location"]!,
            rating: hotel["rating"]!,
            isFavorite: hotel["isFavorite"]!,
            price: hotel["price"]!,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Tapped on ${hotel["name"]}", textDirection: TextDirection.rtl)),
              );
            },
            onFavoriteToggle: () {
              setState(() {
                // Toggle favorite status in the data
                hotelDataList[index]["isFavorite"] = !hotelDataList[index]["isFavorite"]!;
              });
            },
            onReserveTap: () {
              // Handle reserve button tap
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Reserve tapped for ${hotel["name"]}", textDirection: TextDirection.rtl)),
              );
            },
          );
        },
      ),
    );
  }
}