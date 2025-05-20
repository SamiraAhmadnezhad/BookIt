import 'package:flutter/material.dart';
import 'dart:io'; // For File
import 'package:image_picker/image_picker.dart';

const Color kManagerPrimaryColor = Color(0xFF542545);
const Color kPageBackgroundColor = Color(0xFFF0F0F0);
const Color kCardBackgroundColor = Colors.white;
const Color kTextFieldFillColor = Color(0xFFF5F5F5);

class AddRoomScreen extends StatefulWidget {
  const AddRoomScreen({Key? key}) : super(key: key);

  @override
  State<AddRoomScreen> createState() => _AddRoomScreenState();
}

class _AddRoomScreenState extends State<AddRoomScreen> {
  String? _selectedRoomType;
  final _roomNameController = TextEditingController();
  final _priceController = TextEditingController();
  final _roomCountController = TextEditingController();

  bool _hasTv = false;
  bool _hasFridge = false;
  bool _hasSafeBox = false;
  bool _hasView = false;


  List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _roomNameController.dispose();
    _priceController.dispose();
    _roomCountController.dispose();
    super.dispose();
  }

  // TODO: تابع برای ارسال تصاویر به سرور و دریافت URL آن‌ها
  Future<List<String>> _uploadImagesToServer(List<XFile> images) async {
    if (images.isEmpty) return [];
    List<String> uploadedImageUrls = [];
    debugPrint("TODO: Implement uploading ${images.length} images to server.");
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    for (int i = 0; i < images.length; i++) {
      uploadedImageUrls.add('https://picsum.photos/seed/uploaded_img_${i + DateTime.now().millisecondsSinceEpoch}/200/300');
    }
    return uploadedImageUrls;
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(imageQuality: 80);
      if (pickedFiles.isNotEmpty) {
        setState(() { _selectedImages = pickedFiles; });
        debugPrint("Picked ${_selectedImages.length} images.");
      }
    } catch (e) {
      debugPrint("Error picking images: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('خطا در انتخاب تصویر. لطفا دسترسی‌ها را بررسی کنید.')));
      }
    }
  }

  // TODO: تابع برای ذخیره اطلاعات اتاق و URL تصاویر در سرور
  Future<void> _saveRoomData() async {
    debugPrint("Attempting to save room data...");
    if (_selectedRoomType == null || _roomNameController.text.isEmpty || _priceController.text.isEmpty || _roomCountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لطفا تمامی فیلدهای اجباری را پر کنید.')));
      return;
    }
    List<String> imageUrls = [];
    if (_selectedImages.isNotEmpty) {
      imageUrls = await _uploadImagesToServer(_selectedImages);
      if (imageUrls.isEmpty && _selectedImages.isNotEmpty) {
        if (mounted) {ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('خطا در آپلود تصاویر. لطفا دوباره تلاش کنید.')));}
        return;
      }
    }
    final roomData = {
      "roomType": _selectedRoomType, "name": _roomNameController.text, "pricePerNight": double.tryParse(_priceController.text) ?? 0.0, "roomCount": int.tryParse(_roomCountController.text) ?? 0,
      "amenities": {"tv": _hasTv, "fridge": _hasFridge, "safeBox": _hasSafeBox, "view": _hasView,},
      "imageUrls": imageUrls,
    };
    debugPrint("TODO: Send this data to server: $roomData");
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اطلاعات اتاق با موفقیت برای ذخیره‌سازی ارسال شد (شبیه‌سازی).')));
    }
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
      child: Text(title, textAlign: TextAlign.right, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: Colors.grey[700],),),
    );
  }

  Widget _buildRoomTypeSelector(ThemeData theme) {
    final roomTypes = ["یک تخته", "دو تخته", "سوییت", "سایر"];
    return Column(
      children: roomTypes.map((type) {
        bool isSelected = _selectedRoomType == type;
        return Container(
          height: 48, margin: const EdgeInsets.symmetric(vertical: 4.0),
          decoration: BoxDecoration(border: Border.all(color: isSelected ? kManagerPrimaryColor : Colors.grey.shade400, width: 1.0), borderRadius: BorderRadius.circular(8.0), color: isSelected ? kManagerPrimaryColor.withOpacity(0.05) : Colors.transparent,),
          child: Material(color: Colors.transparent, child: InkWell(onTap: () { setState(() { _selectedRoomType = type; }); }, borderRadius: BorderRadius.circular(7.0), child: Center(child: Text(type, style: theme.textTheme.bodyLarge?.copyWith(color: isSelected ? kManagerPrimaryColor : Colors.black87, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,),),),),),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[800], fontWeight: FontWeight.w500),
                textAlign: TextAlign.right,
              ),
            ),
          ),
          Expanded(
            flex: 7,
            child: SizedBox(
              height: 48,
              child: TextFormField(
                controller: controller, keyboardType: keyboardType, textAlign: TextAlign.right,
                decoration: InputDecoration(
                  filled: true, fillColor: kTextFieldFillColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide.none,),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                ),
                style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxItem(String title, bool value, ValueChanged<bool?> onChanged, ThemeData theme) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(!value), borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(bottom: 1),
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 0.8)),),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0, right: 0),
                    child: Text(title, style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black87),),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(width: 24, height: 24,
                child: Checkbox(value: value, onChanged: onChanged, activeColor: kManagerPrimaryColor, visualDensity: VisualDensity.compact, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, side: BorderSide(color: Colors.grey.shade600, width: 1.5),),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedImagesPreview() {
    if (_selectedImages.isEmpty) return const SizedBox.shrink();
    return Container(
      height: 80, margin: const EdgeInsets.only(top: 10, bottom: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal, itemCount: _selectedImages.length,
        itemBuilder: (context, index) {
          return Padding(padding: const EdgeInsets.only(left: 8.0), child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(_selectedImages[index].path), width: 80, height: 80, fit: BoxFit.cover,),),);
        },
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
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                        decoration: BoxDecoration(color: kCardBackgroundColor, borderRadius: BorderRadius.circular(16.0), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 2),),],),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("اطلاعات اتاق", textAlign: TextAlign.center, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87,),),
                            _buildSectionTitle("نوع اتاق", theme),
                            _buildRoomTypeSelector(theme),
                            const SizedBox(height: 8),
                            _buildLabeledTextField(controller: _roomNameController, label: "نام اتاق", theme: theme),
                            _buildLabeledTextField(controller: _priceController, label: "قیمت یک شب", theme: theme, keyboardType: TextInputType.number),
                            _buildLabeledTextField(controller: _roomCountController, label: "تعداد اتاق", theme: theme, keyboardType: TextInputType.number),
                            _buildSectionTitle("امکانات", theme),
                            _buildCheckboxItem("تلویزیون", _hasTv, (val) => setState(() => _hasTv = val!), theme),
                            _buildCheckboxItem("یخچال", _hasFridge, (val) => setState(() => _hasFridge = val!), theme),
                            _buildCheckboxItem("safe box", _hasSafeBox, (val) => setState(() => _hasSafeBox = val!), theme),
                            _buildCheckboxItem("ویو", _hasView, (val) => setState(() => _hasView = val!), theme),
                            const SizedBox(height: 16),
                            Row( // دکمه آپلود سمت راست
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                TextButton.icon(
                                  onPressed: _pickImages,
                                  icon: Icon(Icons.attach_file_rounded, color: Colors.grey[700], size: 20, textDirection: TextDirection.ltr),
                                  label: Text("آپلود تصاویر", style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[800], fontWeight: FontWeight.w500),),
                                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0), tapTargetSize: MaterialTapTargetSize.shrinkWrap,),
                                ),
                              ],
                            ),
                            _buildSelectedImagesPreview(),
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 44,
                              child: ElevatedButton(
                                onPressed: _saveRoomData,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kManagerPrimaryColor, foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  textStyle: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
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
            ],
          ),
        ),
      ),
    );
  }
}