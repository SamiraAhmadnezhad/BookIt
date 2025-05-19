import 'package:flutter/material.dart';

import '../data/models/amenity_model.dart';
import '../utils/constants.dart'; // Import constants

class AmenityItemWidget extends StatelessWidget {
  final Amenity amenity;

  const AmenityItemWidget({Key? key, required this.amenity}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox( // Using SizedBox instead of Container for sizing constraints
      width: (MediaQuery.of(context).size.width - 32 - 30) / 4, // For 4 items per row (32 for padding, 30 for total spacing)
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kLightGrayColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(amenity.icon, size: 26, color: kPrimaryColor.withOpacity(0.8)),
          ),
          const SizedBox(height: 5),
          Text(
            amenity.name,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54, fontSize: 10.5, height: 1.3),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}