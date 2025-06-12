// فایل: models/facility_enum.dart
import 'package:flutter/material.dart';

enum Facility {
  Wifi,
  Parking,
  Restaurant,
  CoffeShop,
  RoomService,
  LaundryService,
  SupportAgent,
  Elevator,
  SafeBox,
  Tv,
  FreeBreakFast,
  MeetingRoom,
  ChildCare,
  Pool,
  Gym,
  Taxi,
  PetsAllowed,
  ShoppingMall,
}

extension FacilityExtension on Facility {
  String get userDisplayName {
    // ... (این بخش بدون تغییر باقی می‌ماند)
    switch (this) {
      case Facility.Wifi: return "وای فای";
      case Facility.Parking: return "پارکینگ";
      case Facility.Restaurant: return "رستوران";
      case Facility.CoffeShop: return "کافی شاپ";
      case Facility.RoomService: return "سرویس اتاق";
      case Facility.LaundryService: return "خشکشویی";
      case Facility.SupportAgent: return "پشتیبانی";
      case Facility.Elevator: return "آسانسور";
      case Facility.SafeBox: return "صندوق امانات";
      case Facility.Tv: return "تلویزیون";
      case Facility.FreeBreakFast: return "صبحانه رایگان";
      case Facility.MeetingRoom: return "اتاق جلسه";
      case Facility.ChildCare: return "مراقبت از کودک";
      case Facility.Pool: return "استخر";
      case Facility.Gym: return "باشگاه ورزشی";
      case Facility.Taxi: return "سرویس تاکسی";
      case Facility.PetsAllowed: return "ورود حیوانات مجاز";
      case Facility.ShoppingMall: return "مرکز خرید";
    }
  }

  String get apiValue {
    // ... (این بخش بدون تغییر باقی می‌ماند)
    switch (this) {
      case Facility.Wifi: return "Wi-Fi";
      case Facility.Parking: return "Parking";
      case Facility.Restaurant: return "Restaurant";
      case Facility.CoffeShop: return "CoffeShop";
      case Facility.RoomService: return "Room Service";
      case Facility.LaundryService: return "Laundry Service";
      case Facility.SupportAgent: return "Support Agent";
      case Facility.Elevator: return "Elevator";
      case Facility.SafeBox: return "Safebox";
      case Facility.Tv: return "TV";
      case Facility.FreeBreakFast: return "FreeBreakFast";
      case Facility.MeetingRoom: return "Meeting Room";
      case Facility.ChildCare: return "Child Care";
      case Facility.Pool: return "Pool";
      case Facility.Gym: return "Gym";
      case Facility.Taxi: return "Taxi";
      case Facility.PetsAllowed: return "Pets Allowed";
      case Facility.ShoppingMall: return "Shopping Mall";
    }
  }

  // *** بخش جدید: اضافه کردن آیکون برای هر امکانات ***
  IconData get iconData {
    switch (this) {
      case Facility.Wifi: return Icons.wifi;
      case Facility.Parking: return Icons.local_parking;
      case Facility.Restaurant: return Icons.restaurant;
      case Facility.CoffeShop: return Icons.local_cafe;
      case Facility.RoomService: return Icons.room_service;
      case Facility.LaundryService: return Icons.local_laundry_service;
      case Facility.SupportAgent: return Icons.support_agent;
      case Facility.Elevator: return Icons.elevator;
      case Facility.SafeBox: return Icons.lock_outline;
      case Facility.Tv: return Icons.tv;
      case Facility.FreeBreakFast: return Icons.free_breakfast;
      case Facility.MeetingRoom: return Icons.meeting_room;
      case Facility.ChildCare: return Icons.child_care;
      case Facility.Pool: return Icons.pool;
      case Facility.Gym: return Icons.fitness_center;
      case Facility.Taxi: return Icons.local_taxi;
      case Facility.PetsAllowed: return Icons.pets;
      case Facility.ShoppingMall: return Icons.store_mall_directory;
    }
  }

  static Facility? fromApiValue(String? value) {
    if (value == null) return null;
    final lowercasedValue = value.toLowerCase();
    for (var facility in Facility.values) {
      if (facility.apiValue.toLowerCase() == lowercasedValue) {
        return facility;
      }
    }
    print("Warning: Unknown facility received from API: '$value'");
    return null;
  }
}