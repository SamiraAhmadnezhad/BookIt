import 'package:flutter/material.dart';

class HotelImageWidget extends StatelessWidget {
  final String imageUrl;
  final double rating;

  const HotelImageWidget({
    Key? key,
    required this.imageUrl,
    this.rating = 0.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget image;
    if (imageUrl.isNotEmpty && Uri.tryParse(imageUrl)?.isAbsolute == true) {
      image = Image.network(
        imageUrl, // فقط از این URL استفاده می‌شود
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