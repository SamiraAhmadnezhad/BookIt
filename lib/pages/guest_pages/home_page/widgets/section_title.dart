import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final bool showViewAll;
  final String? viewAllText;
  final VoidCallback? onViewAllPressed;

  const SectionTitle({
    super.key,
    required this.title,
    this.showViewAll = false,
    this.viewAllText,
    this.onViewAllPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
            ),
          ),
          if (showViewAll && viewAllText != null)
            TextButton(
              onPressed: onViewAllPressed,
              child: Text(
                viewAllText!,
                style: TextStyle(color: Color(0xFF542545), fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}