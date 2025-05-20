// lib/screens/add_hotel_info.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddHotelInfo extends StatefulWidget {
  const AddHotelInfo({super.key});

  @override
  State<AddHotelInfo> createState() => _AddHotelInfoState();
}

class _AddHotelInfoState extends State<AddHotelInfo> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _descriptionController;

  bool _hasWifi = false;
  bool _hasBreakfast = false;
  bool _hasParking = false;
  bool _hasPool = false;

  final Color _customPurpleColor = const Color(0xFF542545);

  final List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _addressController = TextEditingController();
    _descriptionController = TextEditingController();
    _loadHotelInfo();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadHotelInfo() async {
    // TODO: Implement API call to fetch hotel information
    print("TODO: Load hotel info from server");
  }

  Future<void> _saveHotelInfo() async {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement API call to save hotel information
      print("نام: ${_nameController.text}");
      print("آدرس: ${_addressController.text}");
      print("توضیحات: ${_descriptionController.text}");
      print("Wi-Fi: $_hasWifi");
      print("صبحانه: $_hasBreakfast");
      print("پارکینگ: $_hasParking");
      print("استخر: $_hasPool");
      if (_selectedImages.isNotEmpty) {
        print("تصاویر انتخاب شده: ${_selectedImages.length} عدد");
        for (var img in _selectedImages) {
          print("مسیر تصویر: ${img.path}");
        }
        // TODO: اینجا منطق آپلود فایل‌ها به سرور را اضافه کنید
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اطلاعات با موفقیت (به صورت ظاهری) ذخیره شد!')),
      );
    }
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        imageQuality: 80,
        // maxWidth: 1000,
        // maxHeight: 1000,
      );

      if (pickedFiles.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(pickedFiles);
        });
      }
    } catch (e) {
      print("خطا در انتخاب تصویر: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا در انتخاب تصویر: $e')),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Widget _buildCustomTextField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    double fieldHeight = 50.0,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 4.0, bottom: 8.0),
          child: Text(
            label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87),
          ),
        ),
        Container(
          height: maxLines > 1 ? null : fieldHeight,
          constraints: maxLines > 1 ? BoxConstraints(minHeight: fieldHeight * 1.5) : null,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            textAlign: TextAlign.right,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              filled: false,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                vertical: maxLines > 1 ? 12.0 : (fieldHeight - 24) / 2,
                horizontal: 16.0,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '$label نمی‌تواند خالی باشد';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildCheckboxRow(String title, bool value, ValueChanged<bool?> onChanged) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 15, color: Colors.black87)),
            Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: _customPurpleColor,
              checkColor: Colors.white,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Card(
            elevation: 4,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Align(
                      alignment: Alignment.center,
                      child: Text(
                        'اطلاعات هتل',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 28),

                    _buildCustomTextField(
                      label: 'نام',
                      controller: _nameController,
                      fieldHeight: 55.0,
                    ),
                    _buildCustomTextField(
                      label: 'آدرس',
                      controller: _addressController,
                      maxLines: 4,
                      fieldHeight: 120.0,
                    ),
                    _buildCustomTextField(
                      label: 'توضیحات',
                      controller: _descriptionController,
                      maxLines: 6,
                      fieldHeight: 150.0,
                    ),

                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'امکانات',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildCheckboxRow('Wi-Fi', _hasWifi, (val) => setState(() => _hasWifi = val!)),
                    const Divider(height: 1, thickness: 0.5),
                    _buildCheckboxRow('صبحانه', _hasBreakfast, (val) => setState(() => _hasBreakfast = val!)),
                    const Divider(height: 1, thickness: 0.5),
                    _buildCheckboxRow('پارکینگ', _hasParking, (val) => setState(() => _hasParking = val!)),
                    const Divider(height: 1, thickness: 0.5),
                    _buildCheckboxRow('استخر', _hasPool, (val) => setState(() => _hasPool = val!)),
                    const Divider(height: 1, thickness: 0.5),

                    const SizedBox(height: 24),
                    InkWell(
                      onTap: _pickImages,
                      borderRadius: BorderRadius.circular(8.0),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: const [
                            Text(
                              'آپلود تصاویر',
                              style: TextStyle(fontSize: 15, color: Colors.black54, fontWeight: FontWeight.w500),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.file_upload_outlined, color: Colors.black54, size: 28),
                          ],
                        ),
                      ),
                    ),
                    if (_selectedImages.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                        child: SizedBox(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _selectedImages.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10.0),
                                      child: Image.file(
                                        File(_selectedImages[index].path),
                                        width: 100,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: InkWell(
                                        onTap: () => _removeImage(index),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.6),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.close, color: Colors.white, size: 16),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                    const SizedBox(height: 30),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _customPurpleColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 14),
                          textStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        onPressed: _saveHotelInfo,
                        child: const Text('ذخیره‌ی تغییرات'),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}