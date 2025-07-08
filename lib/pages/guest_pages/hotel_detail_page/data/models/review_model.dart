// lib/pages/guest_pages/hotel_detail_page/data/models/review_model.dart

class Review {
  final String userId;
  final String userName;
  final String date;
  final String? positiveFeedback;
  final String? negativeFeedback;
  final String? comment;
  final double rating;

  Review({
    required this.userId,
    required this.userName,
    required this.date,
    this.positiveFeedback,
    this.negativeFeedback,
    this.comment,
    required this.rating,
  });

  // <<< این بخش باید در فایل شما وجود داشته باشد >>>
  // داده‌های نمونه برای استفاده موقت در بخش نظرات
  static final List<Review> sampleReviews = [
    Review(
      userId: "user1_sample",
      userName: "سارا محمدی",
      date: "۱۵ مرداد ۱۴۰۲",
      positiveFeedback: "تمیزی اتاق‌ها و برخورد خوب کارکنان واقعا عالی بود.",
      negativeFeedback: "کیفیت غذای رستوران می‌توانست بهتر باشد.",
      rating: 4.0,
    ),
    Review(
      userId: "user2_sample",
      userName: "رضا حسینی",
      date: "۲۰ مرداد ۱۴۰۲",
      positiveFeedback: "دسترسی هتل به مراکز خرید و دریا فوق‌العاده است.",
      negativeFeedback: "سرعت اینترنت در طبقات بالا کمی پایین بود.",
      rating: 4.5,
    ),
  ];
}