class HotelInRoom {
  final String id;
  final String name;
  final String location;

  HotelInRoom({
    required this.id,
    required this.name,
    required this.location,
  });

  factory HotelInRoom.fromJson(Map<String, dynamic> json) {
    return HotelInRoom(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? 'نام هتل نامشخص',
      location: json['location'] as String? ?? 'مکان نامشخص',
    );
  }
}