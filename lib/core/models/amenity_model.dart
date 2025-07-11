class Amenity {
  final String name;

  Amenity({required this.name});

  factory Amenity.fromJson(Map<String, dynamic> json) {
    return Amenity(
      name: json['name'] ?? 'نامشخص',
    );
  }
}