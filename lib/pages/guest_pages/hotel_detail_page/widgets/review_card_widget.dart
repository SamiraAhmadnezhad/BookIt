import 'package:flutter/material.dart';
import '../data/models/review_model.dart';
import '../utils/constants.dart'; // Import constants

class ReviewCardWidget extends StatelessWidget {
  final Review review;

  const ReviewCardWidget({Key? key, required this.review}) : super(key: key);

  Widget _buildFeedbackPointDisplay(BuildContext context, {required IconData icon, required String text, required Color color}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: color),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54, height: 1.4, fontSize: 11.5))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(child: Text(review.userName, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 13), overflow: TextOverflow.ellipsis)),
                Text(review.date, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600], fontSize: 10.5)),
              ],
            ),
            const SizedBox(height: 10),
            if (review.positiveFeedback.isNotEmpty) ...[
              _buildFeedbackPointDisplay(context, icon: Icons.add_circle_outline_rounded, text: review.positiveFeedback, color: Colors.green.shade700),
              const SizedBox(height: 4),
            ],
            if (review.negativeFeedback.isNotEmpty) ...[
              _buildFeedbackPointDisplay(context, icon: Icons.remove_circle_outline_rounded, text: review.negativeFeedback, color: Colors.red.shade600),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                Icon(Icons.thumb_up_alt_outlined, size: 15, color: kPrimaryColor),
                const SizedBox(width: 4),
                Text(
                  review.rating.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}