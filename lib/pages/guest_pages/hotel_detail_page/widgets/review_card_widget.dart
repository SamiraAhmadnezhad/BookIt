// lib/pages/guest_pages/hotel_detail_page/widgets/review_card_widget.dart

import 'package:flutter/material.dart';
import '../data/models/review_model.dart';
import '../utils/constants.dart';

class ReviewCardWidget extends StatelessWidget {
  final Review review;

  const ReviewCardWidget({Key? key, required this.review}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const Divider(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (review.positiveFeedback != null && review.positiveFeedback!.isNotEmpty) ...[
                    _buildFeedbackPointDisplay(context, icon: Icons.add_circle_outline_rounded, text: review.positiveFeedback!, color: Colors.green.shade700),
                    const SizedBox(height: 8),
                  ],
                  if (review.negativeFeedback != null && review.negativeFeedback!.isNotEmpty) ...[
                    _buildFeedbackPointDisplay(context, icon: Icons.remove_circle_outline_rounded, text: review.negativeFeedback!, color: Colors.red.shade600),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: kPrimaryColor.withOpacity(0.1),
          child: const Icon(Icons.person_outline, size: 24, color: kPrimaryColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                review.userName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                review.date,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.star, size: 16, color: Colors.amber.shade800),
              const SizedBox(width: 4),
              Text(
                review.rating.toStringAsFixed(1),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.amber.shade900, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackPointDisplay(BuildContext context, {required IconData icon, required String text, required Color color}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54, height: 1.5),
          ),
        ),
      ],
    );
  }
}