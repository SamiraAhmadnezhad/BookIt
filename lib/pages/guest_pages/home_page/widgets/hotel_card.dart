import 'package:flutter/material.dart';

class HotelCard extends StatefulWidget {
  final String id;
  final String imageUrl;
  final String name;
  final String location;
  final double rating;
  final bool isFavorite;
  final int discount;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onReserveTap;

  const HotelCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.location,
    required this.rating,
    required this.isFavorite,
    required this.discount,
    required this.onTap,
    required this.onFavoriteToggle,
    required this.onReserveTap,
    required this.id,
  });

  @override
  State<HotelCard> createState() => _HotelCardState();
}

class _HotelCardState extends State<HotelCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    const Color customPurple = Color(0xFF542545);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          transform: _isHovering ? (Matrix4.identity()..scale(1.03)) : Matrix4.identity(),
          child: Card(
            color: Colors.white,
            elevation: _isHovering ? 8.0 : 3.0,
            shadowColor: Colors.black.withOpacity(0.2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Image.network(
                          widget.imageUrl,
                          height: 155,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 155,
                            alignment: Alignment.center,
                            child: const Icon(Icons.broken_image_rounded, size: 40, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 20,
                      left: 20,
                      child: GestureDetector(
                        onTap: widget.onFavoriteToggle,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 4, offset: const Offset(0, 2)),
                            ],
                          ),
                          child: Icon(Icons.favorite, color: widget.isFavorite ? customPurple : Colors.grey.shade400),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12.0, 0, 12.0, 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          widget.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                widget.location,
                                style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Row(
                              children: List.generate(5, (index) => Icon(
                                index < widget.rating.floor() ? Icons.star_rounded : (index < widget.rating ? Icons.star_half_rounded : Icons.star_border_rounded),
                                color: customPurple,
                                size: 15,
                              )),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (widget.discount > 0)
                              Row(
                                children: [
                                  const Icon(Icons.local_fire_department, size: 20, color: Colors.redAccent),
                                  const SizedBox(width: 3),
                                  Text(
                                    '${widget.discount}% تخفیف',
                                    style: const TextStyle(fontSize: 14, color: Colors.redAccent, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            InkWell(
                              onTap: widget.onReserveTap,
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
                                child: Row(
                                  children: const [
                                    Text('رزرو', style: TextStyle(fontSize: 14, color: customPurple, fontWeight: FontWeight.bold)),
                                    SizedBox(width: 2),
                                    Icon(Icons.arrow_forward, size: 20, color: customPurple),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}