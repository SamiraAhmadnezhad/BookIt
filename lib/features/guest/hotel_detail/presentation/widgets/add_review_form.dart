import 'package:flutter/material.dart';

class AddReviewForm extends StatefulWidget {
  final Future<void> Function({
  required double rating,
  required List<String> goodThings,
  required List<String> badThings,
  }) onSubmit;

  const AddReviewForm({super.key, required this.onSubmit});

  @override
  State<AddReviewForm> createState() => _AddReviewFormState();
}

class _AddReviewFormState extends State<AddReviewForm> {
  double _rating = 3.0;
  final List<TextEditingController> _goodThings = [TextEditingController()];
  final List<TextEditingController> _badThings = [TextEditingController()];
  bool _isLoading = false;

  void _addTextField(List<TextEditingController> controllers) {
    setState(() => controllers.add(TextEditingController()));
  }

  void _removeTextField(List<TextEditingController> controllers, int index) {
    if (controllers.length > 1) {
      setState(() {
        controllers[index].dispose();
        controllers.removeAt(index);
      });
    } else {
      controllers[index].clear();
    }
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    final goodPoints =
    _goodThings.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();
    final badPoints =
    _badThings.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();

    await widget.onSubmit(
        rating: _rating, goodThings: goodPoints, badThings: badPoints);

    if (mounted) {
      setState(() {
        _isLoading = false;
        _rating = 3.0;
        _goodThings.forEach((c) => c.clear());
        _badThings.forEach((c) => c.clear());
      });
    }
  }

  @override
  void dispose() {
    for (var c in _goodThings) {
      c.dispose();
    }
    for (var c in _badThings) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildRatingSelector(),
            const Divider(height: 32),
            _buildFeedbackSection(
              'نکات مثبت',
              _goodThings,
                  () => _addTextField(_goodThings),
                  (index) => _removeTextField(_goodThings, index),
            ),
            const SizedBox(height: 24),
            _buildFeedbackSection(
              'نکات منفی',
              _badThings,
                  () => _addTextField(_badThings),
                  (index) => _removeTextField(_badThings, index),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('ثبت نظر'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSelector() {
    return Column(
      children: [
        Text('امتیاز شما به این اقامتگاه',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return IconButton(
              icon: Icon(
                index < _rating
                    ? Icons.star_rounded
                    : Icons.star_border_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 36,
              ),
              onPressed: () => setState(() => _rating = index + 1.0),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildFeedbackSection(
      String title,
      List<TextEditingController> controllers,
      VoidCallback onAdd,
      Function(int) onRemove,
      ) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            IconButton(
              onPressed: onAdd,
              icon: Icon(Icons.add_circle_outline_rounded,
                  color: theme.colorScheme.primary),
              tooltip: 'افزودن مورد جدید',
            ),
          ],
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controllers.length,
          itemBuilder: (context, index) {
            return Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controllers[index],
                    decoration: InputDecoration(
                      hintText: 'نظر خود را اینجا بنویسید...',
                      prefixIcon: Icon(
                        title == 'نکات مثبت'
                            ? Icons.thumb_up_alt_outlined
                            : Icons.thumb_down_alt_outlined,
                        size: 18,
                      ),
                    ),
                  ),
                ),
                if (controllers.length > 1)
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    color: Colors.redAccent.withOpacity(0.7),
                    tooltip: 'حذف این مورد',
                    onPressed: () => onRemove(index),
                  ),
              ],
            );
          },
          separatorBuilder: (_, __) => const SizedBox(height: 8),
        )
      ],
    );
  }
}