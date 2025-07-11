import 'package:bookit/core/models/review_model.dart';
import 'package:flutter/material.dart';

class ReviewCard extends StatelessWidget {
  final Review review;
  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme),
            const Divider(height: 24),
            Expanded(
              child: ListView(
                children: [
                  ..._buildFeedbackList(
                    'نکات مثبت',
                    review.goodThings,
                    Icons.add_circle_outline_rounded,
                    Colors.green.shade700,
                  ),
                  const SizedBox(height: 12),
                  ..._buildFeedbackList(
                    'نکات منفی',
                    review.badThings,
                    Icons.remove_circle_outline_rounded,
                    Colors.red.shade700,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
          child:
          Icon(Icons.person_outline, color: theme.colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(review.userName, style: theme.textTheme.titleSmall),
              Text(review.createdAt, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.star, size: 14, color: Colors.amber.shade800),
              const SizedBox(width: 4),
              Text(
                review.rating.toStringAsFixed(1),
                style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.amber.shade900, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildFeedbackList(
      String title, List<String> items, IconData icon, Color color) {
    if (items.isEmpty) return [];
    return [
      Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      ...items.map(
            (item) => Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Expanded(child: Text(item)),
            ],
          ),
        ),
      )
    ];
  }
}