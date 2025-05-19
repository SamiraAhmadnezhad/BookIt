import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import '../data/models/review_model.dart';
import '../data/models/room_model.dart';
import '../utils/constants.dart';

class AddReviewFormWidget extends StatefulWidget {
  final Future<List<Room>>? roomsFuture;
  final Function(Review reviewData) onSubmit;
  final String hotelId; // Needed if submit logic remains or for context
  final String? currentToken; // Needed for submission if API call is here

  const AddReviewFormWidget({
    Key? key,
    required this.roomsFuture,
    required this.onSubmit,
    required this.hotelId,
    this.currentToken,
  }) : super(key: key);

  @override
  _AddReviewFormWidgetState createState() => _AddReviewFormWidgetState();
}

class _AddReviewFormWidgetState extends State<AddReviewFormWidget> {
  double _newReviewRating = 3.0;
  Room? _selectedRoomForReview;
  List<TextEditingController> _positiveFeedbackControllers = [TextEditingController()];
  List<TextEditingController> _negativeFeedbackControllers = [TextEditingController()];
  List<Room> _availableRooms = [];

  @override
  void initState() {
    super.initState();
    _loadInitialRoomSelection();
  }

  Future<void> _loadInitialRoomSelection() async {
    if (widget.roomsFuture != null) {
      final rooms = await widget.roomsFuture!;
      if (mounted && rooms.isNotEmpty) {
        setState(() {
          _availableRooms = rooms;
          _selectedRoomForReview = rooms.first;
        });
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _positiveFeedbackControllers) {
      controller.dispose();
    }
    for (var controller in _negativeFeedbackControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addPositiveFeedbackField() {
    setState(() {
      _positiveFeedbackControllers.add(TextEditingController());
    });
  }

  void _removePositiveFeedbackField(int index) {
    if (_positiveFeedbackControllers.length > 1) {
      setState(() {
        _positiveFeedbackControllers[index].dispose();
        _positiveFeedbackControllers.removeAt(index);
      });
    } else {
      _positiveFeedbackControllers[index].clear();
    }
  }

  void _addNegativeFeedbackField() {
    setState(() {
      _negativeFeedbackControllers.add(TextEditingController());
    });
  }

  void _removeNegativeFeedbackField(int index) {
    if (_negativeFeedbackControllers.length > 1) {
      setState(() {
        _negativeFeedbackControllers[index].dispose();
        _negativeFeedbackControllers.removeAt(index);
      });
    } else {
      _negativeFeedbackControllers[index].clear();
    }
  }

  void _handleFormSubmission() {
    String positiveFeedbacks = _positiveFeedbackControllers
        .where((c) => c.text.trim().isNotEmpty)
        .map((c) => c.text.trim())
        .join("\n");

    String negativeFeedbacks = _negativeFeedbackControllers
        .where((c) => c.text.trim().isNotEmpty)
        .map((c) => c.text.trim())
        .join("\n");

    if (positiveFeedbacks.isEmpty && negativeFeedbacks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("لطفا حداقل یک نکته مثبت یا منفی وارد کنید.", textDirection: TextDirection.rtl)),
      );
      return;
    }

    if (_selectedRoomForReview == null && _availableRooms.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("لطفا اتاق محل اقامت خود را انتخاب کنید.", textDirection: TextDirection.rtl)),
      );
      return;
    }


    final reviewData = Review(
      userId: "currentUser", // Replace with actual user ID
      userName: "شما (اتاق: ${_selectedRoomForReview?.name ?? 'نامشخص'})",
      date: intl.DateFormat('d MMMM yyyy', 'en_US').format(DateTime.now()),
      positiveFeedback: positiveFeedbacks,
      negativeFeedback: negativeFeedbacks,
      rating: _newReviewRating,
    );

    widget.onSubmit(reviewData); // Pass data to parent for API call

    // Clear fields after submission (parent will handle UI update for review list)
    _positiveFeedbackControllers.forEach((c) => c.clear());
    if (_positiveFeedbackControllers.length > 1) {
      var firstController = _positiveFeedbackControllers.first;
      _positiveFeedbackControllers.skip(1).forEach((c) => c.dispose());
      setState(() {
        _positiveFeedbackControllers = [firstController];
      });
    }

    _negativeFeedbackControllers.forEach((c) => c.clear());
    if (_negativeFeedbackControllers.length > 1) {
      var firstController = _negativeFeedbackControllers.first;
      _negativeFeedbackControllers.skip(1).forEach((c) => c.dispose());
      setState(() {
        _negativeFeedbackControllers = [firstController];
      });
    }
    setState(() {
      _newReviewRating = 3.0;
      if (_availableRooms.isNotEmpty) {
        _selectedRoomForReview = _availableRooms.first;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!, width: 0.8),
      ),
      color: kScaffoldContentColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<List<Room>>(
              future: widget.roomsFuture,
              builder: (context, roomSnapshot) {
                if (roomSnapshot.connectionState == ConnectionState.waiting && _selectedRoomForReview == null) {
                  return const Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 1.5, color: kPrimaryColor)));
                }
                if (!roomSnapshot.hasData || roomSnapshot.data!.isEmpty) {
                  return Text("اتاقی برای انتخاب موجود نیست.", style: TextStyle(color: Colors.grey[700], fontSize: 12.5));
                }
                // _availableRooms is already set in initState or when future completes
                // if (_selectedRoomForReview == null && _availableRooms.isNotEmpty) {
                //   WidgetsBinding.instance.addPostFrameCallback((_) {
                //     if (mounted) {
                //       setState(() { _selectedRoomForReview = _availableRooms.first; });
                //     }
                //   });
                // }
                return DropdownButtonFormField<Room>(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    hintText: "انتخاب اتاق محل اقامت",
                    hintStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: kPrimaryColor, size: 26),
                  value: _selectedRoomForReview,
                  items: _availableRooms.map((Room room) {
                    return DropdownMenuItem<Room>(
                      value: room,
                      child: Text(room.name, style: const TextStyle(fontSize: 13, color: Colors.black87), overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (Room? newValue) {
                    setState(() {
                      _selectedRoomForReview = newValue;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("امتیاز شما", style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 13)),
                const Icon(Icons.more_horiz_rounded, color: kPrimaryColor, size: 22),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    index < _newReviewRating.round() ? Icons.star_rounded : Icons.star_border_rounded,
                    color: kPrimaryColor,
                    size: 30,
                  ),
                  onPressed: () {
                    setState(() {
                      _newReviewRating = index + 1.0;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 20),
            _buildFeedbackEntrySection(
              title: "افزودن نکته مثبت",
              controllers: _positiveFeedbackControllers,
              onAddField: _addPositiveFeedbackField,
              onRemoveField: _removePositiveFeedbackField,
              hintTextPrefix: "نکته مثبت",
            ),
            const SizedBox(height: 20),
            _buildFeedbackEntrySection(
              title: "افزودن نکته منفی",
              controllers: _negativeFeedbackControllers,
              onAddField: _addNegativeFeedbackField,
              onRemoveField: _removeNegativeFeedbackField,
              hintTextPrefix: "نکته منفی",
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: kPrimaryColor, size: 26),
                onPressed: _handleFormSubmission,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackEntrySection({
    required String title,
    required List<TextEditingController> controllers,
    required VoidCallback onAddField,
    required Function(int) onRemoveField,
    required String hintTextPrefix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            InkWell(
              onTap: onAddField,
              child: const Icon(Icons.add_circle_outline_rounded, color: kPrimaryColor, size: 20),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controllers.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                        controller: controllers[index],
                        decoration: InputDecoration(
                          hintText: "$hintTextPrefix ${index + 1}",
                          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 12),
                          filled: true,
                          fillColor: kLightGrayColor.withOpacity(0.7),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                        minLines: 1,
                        maxLines: 3,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(fontSize: 13, color: Colors.black87)),
                  ),
                  if (controllers.length > 1)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: InkWell(
                        onTap: () => onRemoveField(index),
                        child: Icon(Icons.remove_circle_outline_rounded, color: kPrimaryColor.withOpacity(0.6), size: 20),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}