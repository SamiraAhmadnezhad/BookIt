import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:http_parser/http_parser.dart';

import '../models/hotel_model.dart';
import '../models/facility_enum.dart';
import '../../../authentication_page/auth_service.dart'; // مسیر AuthService

// --- ثابت‌های رنگی و استایل ---
const Color kPrimaryColor = Color(0xFF542545);
const Color kAccentColor = Color(0xFF7E3F6B);
const Color kPageBackground = Color(0xFFF4F6F8);
const Color kCardBackground = Colors.white;
const Color kTextFieldBackground = Color(0xFFFAFAFA);
const Color kHintColor = Colors.grey;
const Color kIconColor = Colors.grey;
const Color kErrorColor = Colors.redAccent;
const Color kInputBorderColor = Color(0xFFD0D0D0);

// TODO: آدرس‌های واقعی API خود را برای افزودن/ویرایش هتل اینجا قرار دهید
const String ADD_HOTEL_ENDPOINT = 'https://bookit.darkube.app/hotel-api/create/'; // مثال: Endpoint برای ایجاد
const String EDIT_HOTEL_ENDPOINT_PREFIX = 'https://bookit.darkube.app/hotel-api/create/'; // پیشوند برای ویرایش، ID به آن اضافه می‌شود

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
  // این کنترلرها را نگه می‌داریم اما فعلاً در ارسال به سرور استفاده نمی‌شوند
  late TextEditingController _ratingController;
  late TextEditingController _roomCountController;


  XFile? _selectedMainImageFile;
  String? _existingMainImageUrl;

  XFile? _selectedLicenseImageFile;
  String? _existingLicenseImageUrl;

  Set<Facility> _selectedAmenities = {};
  bool _isLoading = false;

  bool get _isEditing => widget.hotel != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.hotel?.name ?? '');
    _descriptionController = TextEditingController(text: widget.hotel?.description ?? '');
    _locationController = TextEditingController(text: widget.hotel?.location ?? '');
    _ibanController = TextEditingController(text: widget.hotel?.iban ?? '');
    // مقداردهی اولیه برای فیلدهایی که فعلا ارسال نمی‌شوند
    _ratingController = TextEditingController(text: widget.hotel?.rating.toString() ?? '');
    _roomCountController = TextEditingController(text: widget.hotel?.roomCount?.toString() ?? '');


    if (_isEditing && widget.hotel != null) {
      _selectedAmenities = widget.hotel!.amenities.toSet();
      _existingMainImageUrl = widget.hotel!.imageUrl;
      _existingLicenseImageUrl = widget.hotel!.licenseImageUrl;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _ibanController.dispose();
    _ratingController.dispose();
    _roomCountController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false, int durationSeconds = 3}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError ? kErrorColor : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: durationSeconds),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source, {required bool isMainImage}) async {
    if (_isLoading) return;
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (pickedFile != null) {
        setState(() {
          if (isMainImage) {
            _selectedMainImageFile = pickedFile;
            _existingMainImageUrl = null;
          } else {
            _selectedLicenseImageFile = pickedFile;
            _existingLicenseImageUrl = null;
          }
        });
      }
    } catch (e) {
      debugPrint("خطا در انتخاب تصویر: $e");
      if (mounted) _showSnackBar('خطا در انتخاب تصویر. لطفاً دسترسی‌ها را بررسی کنید.', isError: true);
    }
  }

  void _showImageSourceActionSheet({required bool isMainImage}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined, color: kPrimaryColor),
                  title: const Text('انتخاب از گالری', style: TextStyle(fontWeight: FontWeight.w500)),
                  onTap: () {
                    _pickImage(ImageSource.gallery, isMainImage: isMainImage);
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined, color: kPrimaryColor),
                  title: const Text('گرفتن عکس با دوربین', style: TextStyle(fontWeight: FontWeight.w500)),
                  onTap: () {
                    _pickImage(ImageSource.camera, isMainImage: isMainImage);
                    Navigator.of(context).pop();
                  },
                ),
                if ((isMainImage && (_selectedMainImageFile != null || _existingMainImageUrl != null)) ||
                    (!isMainImage && (_selectedLicenseImageFile != null || _existingLicenseImageUrl != null)))
                  ListTile(
                    leading: const Icon(Icons.delete_outline, color: kErrorColor),
                    title: const Text('حذف تصویر', style: TextStyle(color: kErrorColor, fontWeight: FontWeight.w500)),
                    onTap: () {
                      setState(() {
                        if (isMainImage) {
                          _selectedMainImageFile = null;
                          _existingMainImageUrl = null;
                        } else {
                          _selectedLicenseImageFile = null;
                          _existingLicenseImageUrl = null;
                        }
                      });
                      Navigator.of(context).pop();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitHotelData() async {
    if (!_formKey.currentState!.validate()) {
      _showSnackBar('لطفاً تمام موارد الزامی را تکمیل کنید و خطاهای فرم را برطرف نمایید.', isError: true, durationSeconds: 4);
      return;
    }
    if (_selectedAmenities.isEmpty) {
      _showSnackBar('لطفاً حداقل یک امکان برای هتل انتخاب کنید.', isError: true);
      return;
    }
    if (_selectedMainImageFile == null && _existingMainImageUrl == null) {
      _showSnackBar('عکس اصلی هتل الزامی است.', isError: true);
      return;
    }
    if (_selectedLicenseImageFile == null && _existingLicenseImageUrl == null) {
      _showSnackBar('عکس مجوز هتل الزامی است.', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    final authService = Provider.of<AuthService>(context, listen: false);
    final String? token = authService.token;

    if (token == null) {
      _showSnackBar('توکن احراز هویت یافت نشد. لطفاً مجددا وارد شوید.', isError: true);
      setState(() => _isLoading = false);
      return;
    }

    String url = _isEditing ? '$EDIT_HOTEL_ENDPOINT_PREFIX${widget.hotel!.id}/' : ADD_HOTEL_ENDPOINT;
    var request = http.MultipartRequest(_isEditing ? 'PUT' : 'POST', Uri.parse(url));
    request.headers['Authorization'] = 'Bearer $token';

    request.fields['name'] = _nameController.text;
    request.fields['location'] = _locationController.text;
    request.fields['description'] = _descriptionController.text;
    request.fields['hotel_iban_number'] = _ibanController.text;
    request.fields['facilities'] = jsonEncode(_selectedAmenities.map((f) => f.name).toList());
    if (_selectedMainImageFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        _selectedMainImageFile!.path,
        contentType: MediaType('image', _selectedMainImageFile!.path.split('.').last),
      ));
    }

    if (_selectedLicenseImageFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'hotel_license',
        _selectedLicenseImageFile!.path,
        contentType: MediaType('image', _selectedLicenseImageFile!.path.split('.').last),
      ));
    }

    try {
      final streamedResponse = await request.send().timeout(const Duration(seconds: 45)); // افزایش تایم‌اوت
      final response = await http.Response.fromStream(streamedResponse);

      if (!mounted) return;

      final String responseBodyString = utf8.decode(response.bodyBytes);
      debugPrint("Submit Hotel Response Status: ${response.statusCode}");
      debugPrint("Submit Hotel Response Body: $responseBodyString");

      if (response.statusCode == 201 || response.statusCode == 200) {
        _showSnackBar(
          _isEditing ? 'اطلاعات هتل با موفقیت ویرایش شد.' : 'هتل جدید با موفقیت اضافه شد.',
          isError: false,
        );
        Navigator.pop(context, true); // بازگشت با مقدار true برای نشان دادن موفقیت
      } else {
        String errorMessage = 'خطا در ارسال اطلاعات هتل.';
        try {
          final errorData = jsonDecode(responseBodyString);
          if (errorData is Map && errorData.isNotEmpty) {
            errorMessage = errorData.entries.map((e) => '${e.key}: ${e.value is List ? (e.value as List).join(', ') : e.value}').join('\n');
          } else if (errorData is String) {
            errorMessage = errorData;
          }
        } catch (e) {
          errorMessage = responseBodyString;
        }
        _showSnackBar('$errorMessage (کد: ${response.statusCode})', isError: true, durationSeconds: 5);
      }
    } catch (e) {
      debugPrint("خطا در ارسال اطلاعات هتل: $e");
      if (mounted) _showSnackBar('خطا در برقراری ارتباط با سرور: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildFormSection({required String title, required List<Widget> children}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      color: kCardBackground,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: kPrimaryColor,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 16.0),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildCustomTextFormField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
    bool isLtr = false,
    IconData? prefixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        textAlign: isLtr ? TextAlign.left : TextAlign.right,
        textDirection: isLtr ? TextDirection.ltr : TextDirection.rtl,
        style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: '$labelText *',
          labelStyle: const TextStyle(color: kPrimaryColor, fontWeight: FontWeight.w500),
          hintText: hintText,
          hintStyle: const TextStyle(color: kHintColor),
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: kIconColor, textDirection: isLtr ? TextDirection.ltr : TextDirection.rtl) : null,
          filled: true,
          fillColor: kTextFieldBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: kInputBorderColor, width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: kInputBorderColor, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: kAccentColor, width: 1.8),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: kErrorColor, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: kErrorColor, width: 1.8),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$labelText نمی‌تواند خالی باشد';
          }
          return validator?.call(value);
        },
      ),
    );
  }

  Widget _buildImagePickerCard({
    required String title,
    required bool isMainImage,
    XFile? selectedFile,
    String? existingImageUrl,
  }) {
    Widget imageDisplay;
    bool hasImage = false;

    if (selectedFile != null) {
      imageDisplay = Image.file(File(selectedFile.path), fit: BoxFit.cover, key: ValueKey(selectedFile.path));
      hasImage = true;
    } else if (existingImageUrl != null && existingImageUrl.isNotEmpty) {
      imageDisplay = Image.network(existingImageUrl, fit: BoxFit.cover, key: ValueKey(existingImageUrl),
        errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image_outlined, size: 48, color: kHintColor.withOpacity(0.7)),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                : null,
            strokeWidth: 2.5,
            color: kAccentColor,
          ));
        },
      );
      hasImage = true;
    } else {
      imageDisplay = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_search_outlined, size: 48, color: kHintColor.withOpacity(0.7)),
          const SizedBox(height: 8),
          Text("تصویری انتخاب نشده", style: TextStyle(color: kHintColor.withOpacity(0.9))),
        ],
      );
      hasImage = false;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      color: kCardBackground,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$title *',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: kPrimaryColor, fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 12),
            AspectRatio(
              aspectRatio: 16 / 9,
              child: InkWell(
                onTap: () => _showImageSourceActionSheet(isMainImage: isMainImage),
                borderRadius: BorderRadius.circular(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: kTextFieldBackground,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: hasImage ? Colors.transparent : kInputBorderColor.withOpacity(0.7), width: 1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(7.0),
                    child: imageDisplay,
                  ),
                ),
              ),
            ),
            if (!hasImage && _formKey.currentState != null && !_formKey.currentState!.validate())
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text('این تصویر الزامی است.', style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
              ),
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
        backgroundColor: kPageBackground,
        appBar: AppBar(
          title: Text(
            _isEditing ? 'ویرایش اطلاعات هتل' : 'افزودن هتل جدید',
            style: const TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold),
          ),
          backgroundColor: kCardBackground,
          elevation: 1.5,
          iconTheme: const IconThemeData(color: kPrimaryColor),
          actions: [
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(kAccentColor)))),
              )
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _buildFormSection(
                        title: 'اطلاعات اصلی هتل',
                        children: [
                          _buildCustomTextFormField(
                            controller: _nameController,
                            labelText: 'نام هتل',
                            hintText: 'مثال: هتل بزرگ تهران',
                            prefixIcon: Icons.business_outlined,
                          ),
                          _buildCustomTextFormField(
                            controller: _locationController,
                            labelText: 'موقعیت مکانی',
                            hintText: 'مثال: تهران، خیابان ولیعصر',
                            prefixIcon: Icons.location_on_outlined,
                            maxLines: 2,
                          ),
                          _buildCustomTextFormField(
                            controller: _descriptionController,
                            labelText: 'توضیحات هتل',
                            hintText: 'توضیحاتی درباره هتل و امکانات آن بنویسید...',
                            prefixIcon: Icons.description_outlined,
                            maxLines: 3,
                          ),
                        ],
                      ),
                      _buildImagePickerCard(
                        title: 'عکس اصلی هتل',
                        isMainImage: true,
                        selectedFile: _selectedMainImageFile,
                        existingImageUrl: _existingMainImageUrl,
                      ),
                      _buildFormSection(
                        title: 'امکانات هتل',
                        children: [
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            childAspectRatio: 3.5,
                            mainAxisSpacing: 0,
                            crossAxisSpacing: 8,
                            children: Facility.values.map((facility) {
                              return CheckboxListTile(
                                title: Text(facility.displayName, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                                value: _selectedAmenities.contains(facility),
                                onChanged: (bool? value) {
                                  setState(() {
                                    if (value == true) {
                                      _selectedAmenities.add(facility);
                                    } else {
                                      _selectedAmenities.remove(facility);
                                    }
                                  });
                                },
                                activeColor: kPrimaryColor,
                                controlAffinity: ListTileControlAffinity.leading,
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                              );
                            }).toList(),
                          ),
                          if (_selectedAmenities.isEmpty && _formKey.currentState != null && !_formKey.currentState!.validate())
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'انتخاب حداقل یک امکان الزامی است.',
                                style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                              ),
                            ),
                        ],
                      ),
                      _buildFormSection(
                        title: 'اطلاعات مالی',
                        children: [
                          _buildCustomTextFormField(
                            controller: _ibanController,
                            labelText: 'شماره شبا',
                            hintText: 'مثال: 123456789012345678901234',
                            prefixIcon: Icons.account_balance_outlined,
                            keyboardType: TextInputType.number, // شماره شبا فقط عدد است
                            isLtr: true, // برای نمایش صحیح اعداد
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'شماره شبا الزامی است';
                              if (!RegExp(r'^[0-9]{24}$').hasMatch(value)) { // فقط ۲۴ رقم عددی
                                return 'فرمت شماره شبا صحیح نیست (۲۴ رقم)';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                      _buildImagePickerCard(
                        title: 'عکس مجوز هتل',
                        isMainImage: false,
                        selectedFile: _selectedLicenseImageFile,
                        existingImageUrl: _existingLicenseImageUrl,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        icon: _isLoading
                            ? Container(
                          width: 24,
                          height: 24,
                          padding: const EdgeInsets.all(2.0),
                          child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                        )
                            : Icon(_isEditing ? Icons.save_outlined : Icons.add_circle_outline_outlined),
                        label: Text(
                          _isEditing ? 'ذخیره‌ی تغییرات' : 'افزودن هتل',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 2,
                        ),
                        onPressed: _isLoading ? null : _submitHotelData,
                      ),
                      const SizedBox(height: 16),
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
}