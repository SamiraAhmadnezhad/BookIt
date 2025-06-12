// مسیر: lib/models/facility_enum.dart

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
  /// این مقدار برای نمایش به کاربر در UI استفاده می‌شود.
  String get userDisplayName {
    switch (this) {
      case Facility.Wifi:
        return "وای فای";
      case Facility.Parking:
        return "پارکینگ";
      case Facility.Restaurant:
        return "رستوران";
      case Facility.CoffeShop:
        return "کافی شاپ";
      case Facility.RoomService:
        return "سرویس اتاق";
      case Facility.LaundryService:
        return "خشکشویی";
      case Facility.SupportAgent:
        return "پشتیبانی";
      case Facility.Elevator:
        return "آسانسور";
      case Facility.SafeBox:
        return "صندوق امانات";
      case Facility.Tv:
        return "تلویزیون";
      case Facility.FreeBreakFast:
        return "صبحانه رایگان";
      case Facility.MeetingRoom:
        return "اتاق جلسه";
      case Facility.ChildCare:
        return "مراقبت از کودک";
      case Facility.Pool:
        return "استخر";
      case Facility.Gym:
        return "باشگاه ورزشی";
      case Facility.Taxi:
        return "سرویس تاکسی";
      case Facility.PetsAllowed:
        return "ورود حیوانات خانگی مجاز";
      case Facility.ShoppingMall:
        return "مرکز خرید";
    }
  }

  /// این مقدار دقیقاً چیزی است که باید به سرور ارسال شود.
  String get apiValue {
    // این مقادیر باید دقیقاً با مقادیر `Facility.choices` در کد جنگو یکی باشند
    switch (this) {
      case Facility.Wifi:
        return "Wi-Fi";
      case Facility.Parking:
        return "Parking";
      case Facility.Restaurant:
        return "Restaurant";
      case Facility.CoffeShop:
        return "CoffeShop";
      case Facility.RoomService:
        return "Room Service";
      case Facility.LaundryService:
        return "Laundry Service";
      case Facility.SupportAgent:
        return "Support Agent";
      case Facility.Elevator:
        return "Elevator";
      case Facility.SafeBox:
        return "Safebox";
      case Facility.Tv:
        return "TV";
      case Facility.FreeBreakFast:
        return "FreeBreakFast";
      case Facility.MeetingRoom:
        return "Meeting Room";
      case Facility.ChildCare:
        return "Child Care";
      case Facility.Pool:
        return "Pool";
      case Facility.Gym:
        return "Gym";
      case Facility.Taxi:
        return "Taxi";
      case Facility.PetsAllowed:
        return "Pets Allowed";
      case Facility.ShoppingMall:
        return "Shopping Mall";
    }
  }

  /// این تابع برای تبدیل رشته‌ای که از سرور می‌آید به enum استفاده می‌شود.
  static Facility? fromApiValue(String? value) {
    if (value == null) return null;
    for (var facility in Facility.values) {
      if (facility.apiValue == value) {
        return facility;
      }
    }
    print("Warning: Facility string '$value' could not be mapped to a known Facility enum.");
    return null;
  }
}