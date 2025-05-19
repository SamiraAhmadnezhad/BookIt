import 'package:flutter/material.dart';
import '../utils/constants.dart'; // Import constants

class HotelImageWidget extends StatelessWidget {
  final String imageUrl;
  final double rating;

  const HotelImageWidget({
    Key? key,
    required this.imageUrl,
    required this.rating,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: kLightGrayColor,
            child: Icon(Icons.broken_image, size: 60, color: kPrimaryColor.withOpacity(0.7)),
          ),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: kLightGrayColor,
              child: Center(
                child: CircularProgressIndicator(
                  color: kPrimaryColor,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
        ),
        Positioned(
          bottom: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  rating.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.thumb_up,
                  color: kPrimaryColor,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}