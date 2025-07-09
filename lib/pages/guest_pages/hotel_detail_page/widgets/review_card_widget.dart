import 'package:flutter/material.dart';
import '../data/models/review_model.dart';
import '../utils/constants.dart';

class ReviewCardWidget extends StatelessWidget {
  final Review review;

  const ReviewCardWidget({Key? key, required this.review}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Colors.grey.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const Divider(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (review.positiveFeedback != null && review.positiveFeedback!.isNotEmpty) ...[
                      _buildFeedbackPointDisplay(context,
                          icon: Icons.add_circle_outline_rounded,
                          text: review.positiveFeedback!,
                          color: Colors.green.shade700),
                      const SizedBox(height: 8),
                    ],
                    if (review.negativeFeedback != null && review.negativeFeedback!.isNotEmpty) ...[
                      _buildFeedbackPointDisplay(context,
                          icon: Icons.remove_circle_outline_rounded,
                          text: review.negativeFeedback!,
                          color: Colors.red.shade600),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: kPrimaryColor.withOpacity(0.1),
          child: const Icon(Icons.person_outline, size: 22, color: kPrimaryColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                review.userName,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
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
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.amber.shade900, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackPointDisplay(BuildContext context,
      {required IconData icon, required String text, required Color color}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54, height: 1.5, fontSize: 13),
          ),
        ),
      ],
    );
  }
}