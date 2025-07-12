import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ImageBanner extends StatelessWidget {
  final List<String> images;

  const ImageBanner({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = PageController(viewportFraction: 0.9);

    return AspectRatio(
      aspectRatio: 16 / 7,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: controller,
              itemCount: images.length,
              itemBuilder: (context, index) {
                return Card(
                  clipBehavior: Clip.antiAlias,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: Image.network(
                    images[index],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: theme.colorScheme.surface,
                      child: Icon(Icons.image_not_supported_outlined,
                          color: theme.colorScheme.onSurface.withOpacity(0.3)),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          SmoothPageIndicator(
            controller: controller,
            count: images.length,
            effect: ExpandingDotsEffect(
              dotHeight: 8,
              dotWidth: 8,
              activeDotColor: theme.colorScheme.primary,
              dotColor: Colors.grey.shade300,
            ),
          ),
        ],
      ),
    );
  }
}