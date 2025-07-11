

import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? viewAllText;
  final VoidCallback? onViewAllPressed;

  const SectionHeader({
    super.key,
    required this.title,
    this.viewAllText,
    this.onViewAllPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: theme.textTheme.titleLarge),
          if (viewAllText != null)
            TextButton(
              onPressed: onViewAllPressed,
              child: Text(
                viewAllText!,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}