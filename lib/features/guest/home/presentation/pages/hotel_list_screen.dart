import 'package:bookit/core/models/hotel_model.dart';
import 'package:bookit/features/auth/data/services/auth_service.dart';
import 'package:bookit/features/guest/home/data/services/hotel_api_service.dart';
import 'package:bookit/features/guest/home/presentation/widgets/hotel_card.dart';
import 'package:bookit/features/guest/hotel_detail/presentation/pages/hotel_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HotelListScreen extends StatefulWidget {
  final String title;
  final List<Hotel> hotels;

  const HotelListScreen({
    super.key,
    required this.title,
    required this.hotels,
  });

  @override
  State<HotelListScreen> createState() => _HotelListScreenState();
}

class _HotelListScreenState extends State<HotelListScreen> {
  late final HomeApiService _apiService;
  late List<Hotel> _currentHotels;
  bool _isLoadingFavorites = true;

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AuthService>(context, listen: false);
    _apiService = HomeApiService(authService);
    _currentHotels = List.from(widget.hotels);
    _checkAllFavorites();
  }

  Future<void> _checkAllFavorites() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (authService.token == null) {
      setState(() => _isLoadingFavorites = false);
      return;
    }

    final favoriteChecks = _currentHotels.map((hotel) {
      return _apiService.isHotelFavorite(hotel.id).then((isFav) {
        if (mounted) {
          hotel.isFavorite = isFav;
        }
      });
    }).toList();

    await Future.wait(favoriteChecks);

    if (mounted) {
      setState(() {
        _isLoadingFavorites = false;
      });
    }
  }

  Future<void> _toggleFavoriteStatus(Hotel hotel) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (authService.token == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('برای افزودن به علاقه‌مندی‌ها باید وارد شوید.'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    setState(() {
      hotel.isFavorite = !hotel.isFavorite;
    });

    bool success;
    if (!hotel.isFavorite) {
      success = await _apiService.removeFavorite(hotel.id);
    } else {
      success = await _apiService.addFavorite(hotel.id);
    }

    if (mounted) {
      if (success) {
        await _checkAllFavorites();
        setState(() {});
      } else {
        setState(() {
          hotel.isFavorite = !hotel.isFavorite;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('خطا در بروزرسانی علاقه‌مندی‌ها.'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _isLoadingFavorites
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 400.0,
          childAspectRatio: 0.8,
          mainAxisSpacing: 16.0,
          crossAxisSpacing: 16.0,
        ),
        itemCount: _currentHotels.length,
        itemBuilder: (context, index) {
          final hotel = _currentHotels[index];
          return HotelCard(
            hotel: hotel,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HotelDetailScreen(hotel: hotel),
                ),
              );
              _checkAllFavorites();
            },
            onFavoritePressed: () => _toggleFavoriteStatus(hotel),
          );
        },
      ),
    );
  }
}