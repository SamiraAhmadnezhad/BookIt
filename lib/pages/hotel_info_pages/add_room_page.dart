import 'package:flutter/material.dart';

// --- Constants (can be in a separate file if used widely) ---
const Color kManagerPrimaryColor = Color(0xFF542545);
const Color kPageBackgroundColor = Color(0xFFF0F0F0);
const Color kCardBackgroundColor = Colors.white;

class AddRoomPage extends StatefulWidget {
  const AddRoomPage({Key? key}) : super(key: key);

  @override
  State<AddRoomPage> createState() => _AddRoomPageState();
}

class _AddRoomPageState extends State<AddRoomPage> {
  String? _selectedRoomType;
  final _roomNameController = TextEditingController();
  final _priceController = TextEditingController();
  final _roomCountController = TextEditingController();

  bool _hasTv = false;
  bool _hasFridge = false;
  bool _hasSafeBox = false;
  bool _hasView = false;

  int _selectedBottomNavIndex = 2; // Default to "اتاق" or similar

  @override
  void dispose() {
    _roomNameController.dispose();
    _priceController.dispose();
    _roomCountController.dispose();
    super.dispose();
  }

  // TODO: Implement image picking logic from device gallery or camera
  void _pickImages() {
    debugPrint("TODO: Implement image picking logic");
  }

  // TODO: Implement logic to save room data to backend/database
  void _saveRoomData() {
    debugPrint("TODO: Implement save room data logic");
    // Access data like:
    // _selectedRoomType
    // _roomNameController.text
    // _priceController.text
    // _roomCountController.text
    // _hasTv, _hasFridge, _hasSafeBox, _hasView
    // After successful save, maybe navigate back or show a success message
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildRoomTypeSelector(ThemeData theme) {
    final roomTypes = ["یک تخته", "دو تخته", "سوییت", "...."];
    return Column(
      children: roomTypes.map((type) {
        bool isSelected = _selectedRoomType == type;
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 3.0),
          decoration: BoxDecoration(
            border: Border.all(color: isSelected ? kManagerPrimaryColor.withOpacity(0.7) : Colors.grey.shade400, width: isSelected ? 1.5 : 1.0),
            borderRadius: BorderRadius.circular(8.0),
            color: isSelected ? kManagerPrimaryColor.withOpacity(0.05) : Colors.transparent,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedRoomType = type;
                });
              },
              borderRadius: BorderRadius.circular(7.0), // Slightly smaller to be inside border
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                child: Text(
                  type,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: isSelected ? kManagerPrimaryColor : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLabeledTextField({
    required TextEditingController controller,
    required String label,
    required ThemeData theme,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 3, // Text field takes more space
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[100], // Very light grey for text field
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none, // No border for the text field itself
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            ),
            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black87),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2, // Label takes less space
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[800], fontWeight: FontWeight.w500),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildCheckboxItem(String title, bool value, ValueChanged<bool?> onChanged, ThemeData theme) {
    // For RTL, visual order is Checkbox (left), Text (right)
    // Row children order: [Text, Checkbox] so visually it's [Checkbox, Text]
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Row(
          children: [
            Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: kManagerPrimaryColor,
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              side: BorderSide(color: Colors.grey.shade500, width: 1.5),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(bottom: 1),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 1.0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 6.0), // Space for underline
                  child: Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black87),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 0,
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedBottomNavIndex,
          onTap: (index) {
            // TODO: Implement actual navigation or state change for bottom bar items
            setState(() {
              _selectedBottomNavIndex = index;
            });
            if (index == 0 && ModalRoute.of(context)?.settings.name != '/hotel_info') {
              // Example: Navigate to HotelInfoPage if not already there
              // Navigator.pushReplacementNamed(context, '/hotel_info');
            }
            debugPrint("TODO: BottomNav tapped: $index");
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: kManagerPrimaryColor,
          unselectedItemColor: Colors.grey[500],
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 10),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          backgroundColor: Colors.white,
          elevation: 0, // Shadow is handled by the container
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.manage_search_outlined), label: "بررسی"),
            BottomNavigationBarItem(icon: Icon(Icons.apartment_outlined), label: "هتل‌ها"),
            BottomNavigationBarItem(icon: Icon(Icons.king_bed_outlined), label: "اتاق"),
            BottomNavigationBarItem(icon: Icon(Icons.insights_outlined), label: "آمار"),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: "حساب"),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: kPageBackgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0), // No bottom padding for scroll view
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 550),
                child: Card(
                  color: kCardBackgroundColor,
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: 16), // Margin for card if content is short
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: Text(
                            "اطلاعات اتاق",
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        _buildSectionTitle("نوع اتاق", theme),
                        _buildRoomTypeSelector(theme),

                        const SizedBox(height: 12),
                        _buildLabeledTextField(controller: _roomNameController, label: "نام اتاق", theme: theme),
                        const SizedBox(height: 12),
                        _buildLabeledTextField(controller: _priceController, label: "قیمت یک شب", theme: theme, keyboardType: TextInputType.number),
                        const SizedBox(height: 12),
                        _buildLabeledTextField(controller: _roomCountController, label: "تعداد اتاق", theme: theme, keyboardType: TextInputType.number),

                        _buildSectionTitle("امکانات", theme),
                        _buildCheckboxItem("تلویزیون", _hasTv, (val) => setState(() => _hasTv = val!), theme),
                        _buildCheckboxItem("یخچال", _hasFridge, (val) => setState(() => _hasFridge = val!), theme),
                        _buildCheckboxItem("safe box", _hasSafeBox, (val) => setState(() => _hasSafeBox = val!), theme),
                        _buildCheckboxItem("ویو", _hasView, (val) => setState(() => _hasView = val!), theme),

                        const SizedBox(height: 24),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: _pickImages,
                            icon: Icon(Icons.attach_file_rounded, color: Colors.grey[700], size: 20, textDirection: TextDirection.ltr), // Icon itself shouldn't flip
                            label: Text(
                              "آپلود تصاویر",
                              style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[800], fontWeight: FontWeight.w500),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _saveRoomData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kManagerPrimaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14.0),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                              textStyle: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            child: const Text("ذخیره‌ی تغییرات"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}