import 'package:flutter/material.dart';

class ImageBanner extends StatelessWidget {
  final PageController controller;
  final List<String> images; // List of image URLs

  const ImageBanner({
    super.key,
    required this.controller,
    required this.images,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100, // Adjust banner height
      child: PageView.builder(
        controller: controller,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.network(
                images[index],
                fit: BoxFit.cover,
                // Placeholder and error handling for network images
                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                  return Container(
                    color: Colors.grey.shade300,
                    child: const Center(child: Icon(Icons.error_outline, color: Colors.red, size: 40)),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}