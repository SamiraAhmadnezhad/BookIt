class Room {
  final String id;
  final String name;
  final String imageUrl;
  final int capacity;
  final bool hasBreakfast;
  final bool hasLunch;
  final bool hasDinner;
  final double pricePerNight;
  final double rating;

  Room({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.capacity,
    this.hasBreakfast = false,
    this.hasLunch = false,
    this.hasDinner = false,
    required this.pricePerNight,
    required this.rating,
  });

  String get mealInfo {
    List<String> meals = [];
    if (hasBreakfast) meals.add("صبحانه");
    if (hasLunch) meals.add("ناهار");
    if (hasDinner) meals.add("شام");
    if (meals.isEmpty) return "بدون وعده غذایی";
    return meals.join(" / ");
  }
}