class Review {
  final int id;
  final String userName;
  final List<String> goodThings;
  final List<String> badThings;
  final double rating;
  final String createdAt;

  Review({
    required this.id,
    required this.userName,
    required this.goodThings,
    required this.badThings,
    required this.rating,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    List<String> parseThings(String? things) {
      if (things == null || things.isEmpty) return [];
      return things.split(',').map((e) => e.trim()).toList();
    }

    return Review(
      id: json['id'] ?? 0,
      userName: json['user_name'] ?? 'کاربر مهمان',
      goodThings: parseThings(json['good_thing']),
      badThings: parseThings(json['bad_thing']),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] ?? '',
    );
  }
}