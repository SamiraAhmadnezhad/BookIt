class Review {
  final int id;
  final String userName;
  final String? userImageUrl;
  final String comment;
  final double rating;
  final String createdAt;

  Review({
    required this.id,
    required this.userName,
    this.userImageUrl,
    required this.comment,
    required this.rating,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? 0,
      userName: json['user_name'] ?? 'کاربر مهمان',
      userImageUrl: json['user_image'],
      comment: json['comment'] ?? 'نظری ثبت نشده است.',
      rating: (json['rate'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] ?? '',
    );
  }
}