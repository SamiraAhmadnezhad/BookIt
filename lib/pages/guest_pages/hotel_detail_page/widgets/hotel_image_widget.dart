// lib/pages/guest_pages/hotel_detail_page/widgets/hotel_image_widget.dart

import 'package:flutter/material.dart';

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
    // <<< اصلاح اصلی: اطمینان از اینکه فقط از imageUrl استفاده می‌شود >>>
    // و هیچ پیشوندی به آن اضافه نمی‌شود.
    Widget image;
    if (imageUrl.isNotEmpty && Uri.tryParse(imageUrl)?.hasAbsolutePath == true) {
      image = Image.network(
        imageUrl, // مستقیماً از URL کامل استفاده کن
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        },
      );
    } else {
      image = _buildErrorPlaceholder();
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        image,
        // ... (بقیه کد ویجت شما برای نمایش rating و غیره)
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
              stops: const [0.5, 1.0],
            ),
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.yellow, size: 16),
                const SizedBox(width: 4),
                Text(
                  rating.toStringAsFixed(1),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: Colors.grey.shade300,
      child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
    );
  }
}