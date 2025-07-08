import 'package:flutter/material.dart'; // For Icons
import '../models/hotel_details_model.dart';
import '../models/amenity_model.dart';
import '../models/room_model.dart';
import '../models/review_model.dart';

class HotelApiService {
  Future<HotelDetails> fetchHotelDetails(String hotelId, String currentToken) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    bool fetchedIsFavorite = false; // In a real app, this would be fetched based on user & token
    return HotelDetails(
      id: hotelId,
      name: "نام هتل در حالت طولانی از سرویس",
      address: "آدرس در حالت طولانی از سرویس",
      imageUrl: "https://picsum.photos/seed/hotelSrv/1200/800",
      rating: 4.5,
      reviewCount: 120,
      description:
      "توضیحات کامل هتل از سرویس، به عنوان مثال: هتل سه ستاره رویال ششم واقع در خیابان فلسطین در سال ۱۳۹۵ فعالیت خود را آغاز نمود. ساختمان هتل در ۵ طبقه بنا و دارای ۴۱ باب اتاق و سوئیت اقامتی با امکانات رفاهی مناسب می‌باشد و همچنین دسترسی آسانی به خلیج نیلگون فارس و مراکز خرید جزیره از جمله بازار ستاره دارد. هتل رویال قشم با پرسنلی مجرب آماده پذیرایی از شما میهمانان گرامی می‌باشد.",
      amenities: [
        Amenity(name: "WiFi رایگان", icon: Icons.wifi),
        Amenity(name: "پارکینگ", icon: Icons.local_parking_outlined),
        Amenity(name: "رستوران", icon: Icons.restaurant_outlined),
        Amenity(name: "کافی شاپ", icon: Icons.local_cafe_outlined),
        Amenity(name: "سرویس اتاق", icon: Icons.room_service_outlined),
        Amenity(name: "خشکشویی", icon: Icons.local_laundry_service_outlined),
        Amenity(name: "پذیرش ۲۴ ساعته", icon: Icons.support_agent_outlined),
        Amenity(name: "آسانسور", icon: Icons.elevator_outlined),
        Amenity(name: "استخر", icon: Icons.pool_outlined),
        Amenity(name: "باشگاه بدنسازی", icon: Icons.fitness_center_outlined),
      ],
      isCurrentlyFavorite: fetchedIsFavorite,
    );
  }

  Future<List<Room>> fetchHotelRooms(String hotelId, String currentToken) async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      Room(
        id: "room1_srv",
        name: "اسم اتاق از سرویس...",
        imageUrl: "https://picsum.photos/seed/roomSrv1/400/300",
        roomNumber: '5',
        capacity: 5,
        hasBreakfast: true,
        hasDinner: true,
        pricePerNight: 3200000,
        rating: 4.5,
      ),
      Room(
        id: "room2_srv",
        name: "سوئیت مجلل با نمای شهر از سرویس",
        imageUrl: "https://picsum.photos/seed/roomSrv2/400/300",
        roomNumber: '6',
        capacity: 3,
        hasBreakfast: true,
        hasLunch: true,
        pricePerNight: 4500000,
        rating: 4.7,
      ),
    ];
  }

  Future<List<Review>> fetchHotelReviews(String hotelId, String currentToken) async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      Review(
        userId: "user1_srv",
        userName: "اسم اشخاص از سرویس",
        date: "تاریخ نظردهی از سرویس",
        positiveFeedback: "نکات مثبت از سرویس",
        negativeFeedback: "نکات منفی از سرویس",
        rating: 4.5,
      ),
    ];
  }

  Future<bool> submitReview(String hotelId, Review reviewData, String currentToken) async {
    print("Submitting review from service for hotel $hotelId: ${reviewData.userName}");
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  Future<bool> toggleFavoriteHotel(String hotelId, bool newFavoriteState, String currentToken) async {
    print("Toggling favorite from service for hotel $hotelId to $newFavoriteState");
    await Future.delayed(const Duration(milliseconds: 500));
    return newFavoriteState;
  }
}