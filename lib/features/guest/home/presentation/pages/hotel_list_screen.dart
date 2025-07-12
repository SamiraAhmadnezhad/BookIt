import 'package:bookit/core/models/hotel_model.dart';
import 'package:bookit/features/guest/home/presentation/widgets/hotel_card.dart';
import 'package:bookit/features/guest/hotel_detail/presentation/pages/hotel_detail_screen.dart';
import 'package:flutter/material.dart';

class HotelListScreen extends StatelessWidget {
  final String title;
  final List<Hotel> hotels;

  const HotelListScreen({
    super.key,
    required this.title,
    required this.hotels,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 400.0,
          childAspectRatio: 0.8,
          mainAxisSpacing: 16.0,
          crossAxisSpacing: 16.0,
        ),
        itemCount: hotels.length,
        itemBuilder: (context, index) {
          final hotel = hotels[index];
          return HotelCard(
            hotel: hotel,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HotelDetailScreen(hotel: hotel),
                ),
              );
            },
          );
        },
      ),
    );
  }
}