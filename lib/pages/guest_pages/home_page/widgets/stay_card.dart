import 'package:flutter/material.dart';

class StayCard extends StatefulWidget {
  final String imageUrl;
  final String name;
  final String price;
  final double rating;
  final VoidCallback onTap;

  const StayCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.price,
    required this.rating,
    required this.onTap,
  });

  @override
  State<StayCard> createState() => _StayCardState();
}

class _StayCardState extends State<StayCard> {
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
          transform: _isHovering ? (Matrix4.identity()..translate(0, -5, 0)) : Matrix4.identity(),
          child: Card(
            color: Colors.white,
            elevation: _isHovering ? 6.0 : 2.0,
            shadowColor: Colors.black.withOpacity(0.15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            child: SizedBox(
              width: 285,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                      child: Image.network(
                        widget.imageUrl,
                        height: double.infinity,
                        width: 90,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 90,
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 0, 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.name,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.thumb_up_alt_outlined, size: 16, color: customPurple),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.rating.toString(),
                                    style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(fontFamily: 'Vazirmatn', color: Colors.black87),
                                  children: [
                                    TextSpan(text: widget.price, style: const TextStyle(fontSize: 14, color: customPurple, fontWeight: FontWeight.bold)),
                                    const TextSpan(text: ' تومان', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600)),
                                  ],
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
      ),
    );
  }
}