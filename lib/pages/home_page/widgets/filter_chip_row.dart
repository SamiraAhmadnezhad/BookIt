import 'package:flutter/material.dart';

class FilterChipRow extends StatefulWidget {
  final List<String> chips;
  final String? showViewAllText; // Text for the "View All" on the far left
  final VoidCallback? onViewAll; // Action for "View All"

  const FilterChipRow({
    super.key,
    required this.chips,
    this.showViewAllText,
    this.onViewAll,
  });

  @override
  State<FilterChipRow> createState() => _FilterChipRowState();
}

class _FilterChipRowState extends State<FilterChipRow> {
  String? _selectedChip;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50, // Adjust height as needed
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: [
          if (widget.showViewAllText != null && widget.onViewAll != null)
            Padding(
              padding: const EdgeInsets.only(left: 8.0), // `left` because of RTL
              child: ActionChip(
                label: Text(widget.showViewAllText!),
                backgroundColor: Colors.grey[200],
                onPressed: widget.onViewAll,
              ),
            ),
          ...widget.chips.map((label) {
            final isSelected = _selectedChip == label;
            return Padding(
              padding: const EdgeInsets.only(left: 8.0), // `left` because of RTL
              child: ChoiceChip(
                label: Text(label),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedChip = selected ? label : null;
                  });
                  // Handle chip selection
                },
                selectedColor: Colors.deepPurple.shade100,
                backgroundColor: Colors.grey[200],
                labelStyle: TextStyle(
                  color: isSelected ? Colors.deepPurple.shade700 : Colors.black54,
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}