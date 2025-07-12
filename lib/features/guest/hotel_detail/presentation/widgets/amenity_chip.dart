import 'package:bookit/core/models/facility_enum.dart';
import 'package:flutter/material.dart';

class AmenityChip extends StatelessWidget {
  final Facility facility;
  const AmenityChip({super.key, required this.facility});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Chip(
      avatar:
      Icon(facility.iconData, color: theme.colorScheme.primary, size: 18),
      label: Text(facility.userDisplayName),
      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
      labelStyle:
      theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}