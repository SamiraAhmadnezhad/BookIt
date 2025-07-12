import 'dart:convert';
import 'package:bookit/core/models/facility_enum.dart';
import 'package:bookit/core/models/hotel_model.dart';
import 'package:bookit/features/auth/data/services/auth_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';

// --- پالت رنگی تعریف شده توسط شما ---
class AppColors {
  static const Color primary = Color(0xFF542545);
  static const Color primaryLight = Color(0x80542545);
  static const Color primaryDark = Color(0xFF3D1B32);

  static const Color grey = Colors.grey;
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color formBackgroundGrey = Color(0xFFE0E0E0);
  static const Color darkGrey = Color(0xFF616161);

  static const Color white = Colors.white;
  static const Color black = Colors.black;
}
// ------------------------------------

class AddHotelScreen extends StatefulWidget {
  final Hotel? hotel;

  const AddHotelScreen({super.key, this.hotel});

  @override
  State<AddHotelScreen> createState() => _AddHotelScreenState();
}

class _AddHotelScreenState extends State<AddHotelScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _ibanController;

  Uint8List? _selectedMainImageData;
  String? _existingMainImageUrl;
  Uint8List? _selectedLicenseImageData;
  String? _existingLicenseImageUrl;
  String? _mainImageName;
  String? _licenseImageName;

  Set<Facility> _selectedAmenities = {};
  bool _isLoading = false;

  bool get _isEditing => widget.hotel != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.hotel?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.hotel?.description ?? '');
    _locationController =
        TextEditingController(text: widget.hotel?.address ?? '');
    _ibanController = TextEditingController(text: widget.hotel?.iban ?? '');

    if (_isEditing && widget.hotel != null) {
      _selectedAmenities = widget.hotel!.amenities.toSet();
      _existingMainImageUrl = widget.hotel!.imageUrl;
      _existingLicenseImageUrl = widget.hotel!.licenseImageUrl;
    }
  }

  Future<void> _pickImage({required bool isMainImage}) async {
    final XFile? pickedFile =
    await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        if (isMainImage) {
          _selectedMainImageData = bytes;
          _mainImageName = pickedFile.name;
          _existingMainImageUrl = null;
        } else {
          _selectedLicenseImageData = bytes;
          _licenseImageName = pickedFile.name;
          _existingLicenseImageUrl = null;
        }
      });
    }
  }

  Future<void> _submitHotelData() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final authService = Provider.of<AuthService>(context, listen: false);
    final String? token = authService.token;
    if (token == null) {
      setState(() => _isLoading = false);
      return;
    }

    final uri = Uri.parse(_isEditing
        ? 'https://fbookit.darkube.app/hotel-api/hotel/${widget.hotel!.id}/'
        : 'https://fbookit.darkube.app/hotel-api/hotel/');
    var request = http.MultipartRequest(_isEditing ? 'PATCH' : 'POST', uri);
    request.headers['Authorization'] = 'Bearer $token';

    final facilitiesString =
    _selectedAmenities.map((f) => f.apiValue).join(',');

    request.fields.addAll({
      'name': _nameController.text,
      'location': _locationController.text,
      'description': _descriptionController.text,
      'hotel_iban_number': _ibanController.text,
      'facilities': facilitiesString,
    });

    if (_selectedMainImageData != null) {
      request.files.add(http.MultipartFile.fromBytes('image',
          _selectedMainImageData!,
          filename: _mainImageName, contentType: MediaType('image', 'jpeg')));
    }
    if (_selectedLicenseImageData != null) {
      request.files.add(http.MultipartFile.fromBytes(
          'hotel_license', _selectedLicenseImageData!,
          filename: _licenseImageName,
          contentType: MediaType('image', 'jpeg')));
    }

    try {
      final response = await request.send();
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) Navigator.pop(context, true);
      } else {
        final respStr = await response.stream.bytesToString();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطا در ذخیره اطلاعات: $respStr')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('یک خطای پیش‌بینی نشده رخ داد: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final inputDecorationTheme = InputDecoration(
      border: const OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.formBackgroundGrey),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.formBackgroundGrey),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      labelStyle: const TextStyle(color: AppColors.darkGrey),
    );

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        title: Text(_isEditing ? 'ویرایش هتل' : 'افزودن هتل',
            style: const TextStyle(color: AppColors.white)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Card(
                elevation: 0,
                color: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('اطلاعات اصلی هتل',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDark)),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _nameController,
                        decoration: inputDecorationTheme.copyWith(labelText: 'نام هتل'),
                        validator: (v) =>
                        v!.isEmpty ? 'نام هتل الزامی است' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _locationController,
                        decoration: inputDecorationTheme.copyWith(labelText: 'آدرس'),
                        validator: (v) => v!.isEmpty ? 'آدرس الزامی است' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _ibanController,
                        decoration: inputDecorationTheme.copyWith(labelText: 'شماره شبا'),
                        validator: (v) =>
                        v!.isEmpty ? 'شماره شبا الزامی است' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: inputDecorationTheme.copyWith(labelText: 'توضیحات'),
                        maxLines: 4,
                        validator: (v) =>
                        v!.isEmpty ? 'توضیحات الزامی است' : null,
                      ),
                      const Divider(height: 48, color: AppColors.formBackgroundGrey),
                      const Text('تصاویر',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDark)),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildImagePicker(isMainImage: true)),
                          const SizedBox(width: 24),
                          Expanded(
                              child: _buildImagePicker(isMainImage: false)),
                        ],
                      ),
                      const Divider(height: 48, color: AppColors.formBackgroundGrey),
                      const Text('امکانات رفاهی',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDark)),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12.0,
                        runSpacing: 12.0,
                        children: Facility.values
                            .map((facility) => _buildFacilityChip(facility))
                            .toList(),
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: _isLoading
                              ? Container()
                              : const Icon(Icons.save, color: AppColors.white),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              elevation: 0,
                              padding:
                              const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              )),
                          onPressed: _isLoading ? null : _submitHotelData,
                          label: _isLoading
                              ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                                color: AppColors.white, strokeWidth: 3),
                          )
                              : Text(
                            _isEditing ? 'ذخیره تغییرات' : 'افزودن هتل',
                            style: const TextStyle(
                                fontSize: 16, color: AppColors.white),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFacilityChip(Facility facility) {
    final bool isSelected = _selectedAmenities.contains(facility);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedAmenities.remove(facility);
          } else {
            _selectedAmenities.add(facility);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 90,
        height: 80,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight.withOpacity(0.2) : AppColors.lightGrey,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.formBackgroundGrey,
              width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              facility.iconData,
              color: isSelected ? AppColors.primaryDark : AppColors.darkGrey,
              size: 28,
            ),
            const SizedBox(height: 6),
            Text(
              facility.userDisplayName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primaryDark : AppColors.darkGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker({required bool isMainImage}) {
    final imageData =
    isMainImage ? _selectedMainImageData : _selectedLicenseImageData;
    final existingUrl =
    isMainImage ? _existingMainImageUrl : _existingLicenseImageUrl;
    final title = isMainImage ? 'عکس اصلی هتل' : 'عکس مجوز';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title,
            style: const TextStyle(
                color: AppColors.darkGrey,
                fontSize: 16,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        Container(
          height: 180,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
              border: Border.all(color: AppColors.formBackgroundGrey),
              borderRadius: BorderRadius.circular(12)),
          child: (imageData != null)
              ? Image.memory(imageData, fit: BoxFit.cover)
              : (existingUrl != null && existingUrl.isNotEmpty)
              ? Image.network(existingUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
              const Center(child: Icon(Icons.broken_image_outlined, color: AppColors.grey)))
              : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.image_search,
                    size: 48, color: AppColors.grey),
                SizedBox(height: 8),
                Text('عکسی انتخاب نشده', style: TextStyle(color: AppColors.darkGrey)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
            icon: const Icon(Icons.upload_outlined, size: 20),
            onPressed: () => _pickImage(isMainImage: isMainImage),
            style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            label: const Text('انتخاب عکس'))
      ],
    );
  }
}