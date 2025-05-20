enum Facility {
  Wifi, // تغییر به حرف بزرگ
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
  String get displayName {
    switch (this) {
      case Facility.Wifi: // تطبیق با نام جدید
        return "Wi-Fi";
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
    // default case دیگر لازم نیست چون همه مقادیر پوشش داده شده‌اند
    }
  }

  // برای تبدیل رشته ذخیره شده در مدل (یا آمده از API) به enum
  static Facility? fromString(String facilityString) {
    // ابتدا با displayName فارسی یا انگلیسی چک کن (انعطاف بیشتر برای ورودی)
    for (Facility facility in Facility.values) {
      if (facility.displayName.toLowerCase() == facilityString.toLowerCase()) {
        return facility;
      }
    }

    // سپس با نام enum (PascalCase) چک کن
    // این برای زمانی خوب است که رشته دقیقا با نام enum مطابقت دارد (مثلا "Wifi", "Pool")
    try {
      return Facility.values.byName(facilityString);
    } catch (e) {
      // اگر با byName پیدا نشد، سعی کن با تبدیل به PascalCase پیدا کنی
      // مثال: "wifi" یا "wi-fi" یا "Wi-Fi" باید به Facility.Wifi مپ شود
      String normalizedString = facilityString
          .replaceAll('-', '')
          .replaceAll('_', '')
          .toLowerCase();

      for (Facility facility in Facility.values) {
        // مقایسه نام enum (پس از تبدیل به حروف کوچک) با رشته نرمال شده
        if (facility.name.toLowerCase() == normalizedString) {
          return facility;
        }
        // مقایسه displayName انگلیسی (پس از تبدیل به حروف کوچک و حذف کاراکترهای خاص)
        // با رشته نرمال شده
        String normalizedDisplayName = '';
        if (facility == Facility.Wifi) normalizedDisplayName = "Wi-Fi";
        else if (facility == Facility.CoffeShop) normalizedDisplayName = "coffeeshop";
        else if (facility == Facility.RoomService) normalizedDisplayName = "roomservice";
        else if (facility == Facility.LaundryService) normalizedDisplayName = "laundryservice";
        else if (facility == Facility.SupportAgent) normalizedDisplayName = "supportagent";
        else if (facility == Facility.SafeBox) normalizedDisplayName = "safebox";
        else if (facility == Facility.FreeBreakFast) normalizedDisplayName = "freebreakfast";
        else if (facility == Facility.MeetingRoom) normalizedDisplayName = "meetingroom";
        else if (facility == Facility.ChildCare) normalizedDisplayName = "childcare";
        else if (facility == Facility.PetsAllowed) normalizedDisplayName = "petsallowed";
        else if (facility == Facility.ShoppingMall) normalizedDisplayName = "shoppingmall";
        else normalizedDisplayName = facility.name.toLowerCase(); // برای بقیه که یک کلمه ای هستند

        if (normalizedDisplayName == normalizedString) {
          return facility;
        }
      }
    }
    print("هشدار: رشته امکانات '$facilityString' به هیچ Facility شناخته شده‌ای مپ نشد.");
    return null; // اگر هیچکدام مطابقت نداشت
  }
}