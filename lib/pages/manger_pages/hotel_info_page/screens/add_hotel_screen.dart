import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:http_parser/http_parser.dart';

// توجه: برای اجرای این کد، فایل‌های زیر باید در پروژه شما موجود باشند:
import '../models/hotel_model.dart';      // مدل داده برای هتل
import '../models/facility_enum.dart';   // Enum برای امکانات هتل
import '../../../authentication_page/auth_service.dart'; // سرویس برای مدیریت توکن احراز هویت

// --- ثابت‌های مربوط به رنگ و استایل ---
const Color kPrimaryColor = Color(0xFF542545);
const Color kAccentColor = Color(0xFF7E3F6B);
const Color kPageBackground = Color(0xFFF4F6F8);
const Color kCardBackground = Colors.white;
const Color kTextFieldBackground = Color(0xFFFAFAFA);
const Color kHintColor = Colors.grey;
const Color kIconColor = Colors.grey;
const Color kErrorColor = Colors.redAccent;
const Color kInputBorderColor = Color(0xFFD0D0D0);

// --- آدرس‌های API ---
const String ADD_HOTEL_ENDPOINT = 'https://fbookit.darkube.app/hotel-api/hotel/';
const String EDIT_HOTEL_ENDPOINT_PREFIX = 'https://fbookit.darkube.app/hotel-api/hotel/';

class AddHotelScreen extends StatefulWidget {
  // اگر هتل برای ویرایش ارسال شود، این متغیر مقدار خواهد داشت
  final Hotel? hotel;

  const AddHotelScreen({super.key, this.hotel});

  @override
  State<AddHotelScreen> createState() => _AddHotelScreenState();
}

class _AddHotelScreenState extends State<AddHotelScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // --- کنترلرهای فرم ---
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _ibanController;
  late TextEditingController _ratingController;
  // late TextEditingController _roomCountController; // در فرم استفاده نشده است

  // --- متغیرهای مدیریت عکس ---
  XFile? _selectedMainImageFile;
  String? _existingMainImageUrl;
  XFile? _selectedLicenseImageFile;
  String? _existingLicenseImageUrl;

  // --- متغیرهای وضعیت ---
  Set<Facility> _selectedAmenities = {};
  bool _isLoading = false;

  // برای تشخیص حالت "ایجاد" یا "ویرایش"
  bool get _isEditing => widget.hotel != null;

  @override
  void initState() {
    super.initState();

    // --- مقداردهی اولیه کنترلرها ---
    _nameController = TextEditingController(text: widget.hotel?.name ?? '');
    _descriptionController = TextEditingController(text: widget.hotel?.description ?? '');
    _locationController = TextEditingController(text: widget.hotel?.location ?? '');
    _ibanController = TextEditingController(text: widget.hotel?.iban ?? '');

    // *** پیاده‌سازی خواسته مربوط به فیلد 'rate' ***
    // اگر در حالت ویرایش باشیم (widget.hotel != null)، مقدار rate از هتل خوانده می‌شود.
    // در غیر این صورت (حالت ایجاد)، مقدار پیش‌فرض '0' برای آن در نظر گرفته می‌شود.
    _ratingController = TextEditingController(text: widget.hotel?.rating.toString() ?? '0');
    // _roomCountController = TextEditingController(text: widget.hotel?.roomCount?.toString() ?? '');

    // اگر در حالت ویرایش هستیم، داده‌های موجود را بارگذاری کن
    if (_isEditing && widget.hotel != null) {
      _selectedAmenities = widget.hotel!.amenities.toSet();
      _existingMainImageUrl = widget.hotel!.imageUrl;
      _existingLicenseImageUrl = widget.hotel!.licenseImageUrl;
    }
  }

  @override
  void dispose() {
    // آزادسازی منابع کنترلرها
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _ibanController.dispose();
    _ratingController.dispose();
    // _roomCountController.dispose();
    super.dispose();
  }

  // --- تابع اصلی برای ارسال داده‌ها به سرور ---
  Future<void> _submitHotelData() async {
    // اعتبارسنجی فرم
    if (!_formKey.currentState!.validate()) {
      _showSnackBar('لطفاً تمام موارد الزامی را تکمیل کنید.', isError: true);
      return;
    }
    if (_selectedAmenities.isEmpty) {
      _showSnackBar('لطفاً حداقل یک امکان برای هتل انتخاب کنید.', isError: true);
      return;
    }
    // در حالت ایجاد، عکس اصلی الزامی است
    if (!_isEditing && _selectedMainImageFile == null) {
      _showSnackBar('عکس اصلی هتل الزامی است.', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    // دریافت توکن احراز هویت
    final authService = Provider.of<AuthService>(context, listen: false);
    final String? token = authService.token;
    if (token == null) {
      _showSnackBar('توکن احراز هویت یافت نشد. لطفاً مجددا وارد شوید.', isError: true);
      setState(() => _isLoading = false);
      return;
    }

    // *** پیاده‌سازی خواسته مربوط به URL ***
    // اگر در حالت ویرایش باشیم، شناسه هتل به انتهای URL اضافه می‌شود.
    final String url = _isEditing ? '$EDIT_HOTEL_ENDPOINT_PREFIX${widget.hotel!.id}/' : ADD_HOTEL_ENDPOINT;
    // متد درخواست نیز بر اساس حالت ویرایش (PATCH) یا ایجاد (POST) تعیین می‌شود.
    final String method = _isEditing ? 'PATCH' : 'POST';

    var request = http.MultipartRequest(method, Uri.parse(url));
    request.headers['Authorization'] = 'Bearer $token';

    // تبدیل لیست امکانات به یک رشته جدا شده با کاما (مطابق با پیاده‌سازی بک‌اند)
    final facilitiesString = _selectedAmenities.map((f) => f.apiValue).join(',');

    // آماده‌سازی فیلدهای متنی برای ارسال
    final Map<String, String> fields = {
      'name': _nameController.text,
      'location': _locationController.text,
      'description': _descriptionController.text,
      'hotel_iban_number': _ibanController.text,
      'facilities': facilitiesString,
      // فیلد rate همیشه ارسال می‌شود (با مقدار 0 در حالت ایجاد و مقدار موجود در حالت ویرایش)
      'rate': _ratingController.text,
    };

    request.fields.addAll(fields);

    // اضافه کردن فایل‌های عکس در صورت انتخاب شدن
    if (_selectedMainImageFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'image', // نام فیلد در API
        _selectedMainImageFile!.path,
        contentType: MediaType('image', _selectedMainImageFile!.path.split('.').last),
      ));
    }
    if (_selectedLicenseImageFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'hotel_license', // نام فیلد در API
        _selectedLicenseImageFile!.path,
        contentType: MediaType('image', _selectedLicenseImageFile!.path.split('.').last),
      ));
    }

    try {
      final streamedResponse = await request.send().timeout(const Duration(seconds: 45));
      final response = await http.Response.fromStream(streamedResponse);

      if (!mounted) return;

      final String responseBodyString = utf8.decode(response.bodyBytes);
      debugPrint("Submit Hotel Response Status: ${response.statusCode}");
      debugPrint("Submit Hotel Response Body: $responseBodyString");

      // کد وضعیت 200 (OK) برای ویرایش و 201 (Created) برای ایجاد موفقیت‌آمیز هستند
      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnackBar(
          _isEditing ? 'اطلاعات هتل با موفقیت ویرایش شد.' : 'هتل جدید با موفقیت اضافه شد.',
          isError: false,
        );
        Navigator.pop(context, true); // ارسال true برای رفرش صفحه قبل
      } else {
        // مدیریت خطا
        _handleErrorResponse(response.statusCode, responseBodyString);
      }
    } catch (e) {
      debugPrint("Error submitting hotel data: $e");
      if (mounted) _showSnackBar('خطا در برقراری ارتباط با سرور: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- متدهای کمکی برای UI و منطق ---

  void _handleErrorResponse(int statusCode, String body) {
    String errorMessage = 'خطا در ارسال اطلاعات هتل.';
    try {
      final errorData = jsonDecode(body);
      if (errorData is Map && errorData.isNotEmpty) {
        errorMessage = errorData.entries
            .map((e) => '${e.key}: ${e.value is List ? (e.value as List).join(', ') : e.value}')
            .join('\n');
      } else if (errorData is String) {
        errorMessage = errorData;
      }
    } catch (_) {
      errorMessage = body.isNotEmpty ? body : 'خطای نامشخص از سمت سرور.';
    }
    _showSnackBar('$errorMessage (کد: $statusCode)', isError: true, durationSeconds: 6);
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
            _existingMainImageUrl = null; // پاک کردن عکس قبلی
          } else {
            _selectedLicenseImageFile = pickedFile;
            _existingLicenseImageUrl = null; // پاک کردن عکس قبلی
          }
        });
      }
    } catch (e) {
      debugPrint("Image picking error: $e");
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

  // --- ویجت‌های ساخت UI ---

  @override
  Widget build(BuildContext context) {
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
                                title: Text(facility.userDisplayName, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
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
                        ],
                      ),
                      _buildFormSection(
                        title: 'اطلاعات مالی',
                        children: [
                          _buildCustomTextFormField(
                            controller: _ibanController,
                            labelText: 'شماره شبا (بدون IR)',
                            hintText: 'مثال: 012345678901234567890123',
                            prefixIcon: Icons.account_balance_outlined,
                            keyboardType: TextInputType.number,
                            isLtr: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'شماره شبا الزامی است';
                              if (!RegExp(r'^[0-9]{24}$').hasMatch(value)) {
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
                            ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
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
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: kIconColor, textDirection: TextDirection.ltr) : null,
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
          if (labelText.contains('*') && (value == null || value.isEmpty)) {
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

    // عکس اصلی الزامی است، اما عکس مجوز اختیاری است
    final bool isRequired = isMainImage || _isEditing == false;

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
              isRequired ? '$title *' : title,
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
          ],
        ),
      ),
    );
  }
}