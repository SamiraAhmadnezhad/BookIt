import 'dart:io'; // برای کار با File
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // برای انتخاب تصویر
import '../models/hotel_model.dart';
import '../models/facility_enum.dart'; // enum امکانات

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
  late TextEditingController _ratingController;
  late TextEditingController _ibanController;
  late TextEditingController _roomCountController;

  String? _mainImageSource;
  String? _licenseImageSource;

  XFile? _selectedMainImageFile;
  XFile? _selectedLicenseImageFile;

  Set<Facility> _selectedAmenities = {};

  final Color _customPurpleColor = const Color(0xFF542545);
  bool get _isEditing => widget.hotel != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.hotel?.name);
    _ratingController = TextEditingController(text: widget.hotel?.rating.toString());
    _ibanController = TextEditingController(text: widget.hotel?.iban);
    _roomCountController = TextEditingController(text: widget.hotel?.roomCount?.toString() ?? '');

    _descriptionController = TextEditingController(text: widget.hotel?.description ?? '');
    _locationController = TextEditingController(text: widget.hotel?.location ?? ''); //  مقداردهی اولیه با فرض non-null

    if (_isEditing && widget.hotel != null) {
      _selectedAmenities = widget.hotel!.amenities.toSet();
      _mainImageSource = widget.hotel!.imageUrl;
      _licenseImageSource = widget.hotel!.licenseImageUrl;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _ratingController.dispose();
    _ibanController.dispose();
    _roomCountController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source, {required bool isMainImage}) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source, imageQuality: 70);
      if (pickedFile != null) {
        setState(() {
          if (isMainImage) {
            _selectedMainImageFile = pickedFile;
            _mainImageSource = pickedFile.path;
          } else {
            _selectedLicenseImageFile = pickedFile;
            _licenseImageSource = pickedFile.path;
          }
        });
      }
    } catch (e) {
      print("خطا در انتخاب تصویر: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در انتخاب تصویر: $e')),
        );
      }
    }
  }

  void _showImageSourceActionSheet({required bool isMainImage}) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('گالری'),
                onTap: () {
                  _pickImage(ImageSource.gallery, isMainImage: isMainImage);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('دوربین'),
                onTap: () {
                  _pickImage(ImageSource.camera, isMainImage: isMainImage);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.link),
                title: const Text('وارد کردن URL'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showUrlInputDialog(isMainImage: isMainImage);
                },
              ),
              if ((isMainImage && _mainImageSource != null) || (!isMainImage && _licenseImageSource != null))
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text('حذف تصویر', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    setState(() {
                      if (isMainImage) {
                        _selectedMainImageFile = null;
                        _mainImageSource = null;
                      } else {
                        _selectedLicenseImageFile = null;
                        _licenseImageSource = null;
                      }
                    });
                    Navigator.of(context).pop();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _showUrlInputDialog({required bool isMainImage}) {
    TextEditingController urlController = TextEditingController();
    if (isMainImage && _mainImageSource != null && Uri.tryParse(_mainImageSource!)?.isAbsolute == true) {
      urlController.text = _mainImageSource!;
    } else if (!isMainImage && _licenseImageSource != null && Uri.tryParse(_licenseImageSource!)?.isAbsolute == true) {
      urlController.text = _licenseImageSource!;
    }

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(isMainImage ? 'URL عکس اصلی' : 'URL عکس مجوز'),
            content: TextField(
              controller: urlController,
              decoration: const InputDecoration(hintText: "https://example.com/image.png"),
              keyboardType: TextInputType.url,
            ),
            actions: [
              TextButton(
                child: const Text("لغو"),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: const Text("تایید"),
                onPressed: () {
                  if (Uri.tryParse(urlController.text)?.hasAbsolutePath ?? false) {
                    setState(() {
                      if (isMainImage) {
                        _mainImageSource = urlController.text;
                        _selectedMainImageFile = null;
                      } else {
                        _licenseImageSource = urlController.text;
                        _selectedLicenseImageFile = null;
                      }
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('آدرس URL وارد شده معتبر نیست.'), backgroundColor: Colors.red),
                    );
                  }
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }


  Future<void> _saveHotelInfo() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String? finalMainImageUrl = _mainImageSource;
      String? finalLicenseImageUrl = _licenseImageSource;

      if (_selectedMainImageFile != null) {
        print("عکس اصلی برای آپلود: ${_selectedMainImageFile!.path}");
        // finalMainImageUrl = await uploadImageAndGetUrl(_selectedMainImageFile!); // تابع فرضی آپلود
      }
      if (_selectedLicenseImageFile != null) {
        print("عکس مجوز برای آپلود: ${_selectedLicenseImageFile!.path}");
        // finalLicenseImageUrl = await uploadImageAndGetUrl(_selectedLicenseImageFile!); // تابع فرضی آپلود
      }

      final newHotel = Hotel(
        id: _isEditing ? widget.hotel!.id : DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        imageUrl: finalMainImageUrl,
        description: _descriptionController.text,
        location: _locationController.text, //  مقداردهی location با توجه به ضروری بودن
        amenities: _selectedAmenities.toList(),
        rating: double.tryParse(_ratingController.text) ?? 0.0,
        iban: _ibanController.text,
        licenseImageUrl: finalLicenseImageUrl,
        roomCount: int.tryParse(_roomCountController.text),
      );

      if (mounted) {
        Navigator.pop(context, newHotel);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لطفاً خطاهای فرم را برطرف کنید.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildImagePicker(
      {required String label, required bool isMainImage, String? currentImageSource, XFile? selectedFile}) {
    Widget imageWidget;
    if (selectedFile != null) {
      imageWidget = Image.file(File(selectedFile.path), fit: BoxFit.cover);
    } else if (currentImageSource != null && Uri.tryParse(currentImageSource)?.isAbsolute == true) {
      imageWidget = Image.network(currentImageSource, fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 40, color: Colors.grey),
      );
    } else if (currentImageSource != null) {
      try {
        imageWidget = Image.file(File(currentImageSource), fit: BoxFit.cover);
      } catch (e) {
        imageWidget = const Icon(Icons.broken_image, size: 40, color: Colors.grey);
      }
    }
    else {
      imageWidget = const Icon(Icons.image_search, size: 40, color: Colors.grey);
    }

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
        InkWell(
          onTap: () => _showImageSourceActionSheet(isMainImage: isMainImage),
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11.0),
              child: imageWidget,
            ),
          ),
        ),
        if(isMainImage && (_mainImageSource == null && _selectedMainImageFile == null))
          Padding(
            padding: const EdgeInsets.only(top: 4.0, right: 4.0),
            child: Text('عکس اصلی هتل الزامی است.', style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
          ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildCustomTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
    double fieldHeight = 55.0,
    bool isLtr = false,
    bool isOptional = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 4.0, bottom: 8.0),
          child: Text(
            label + (isOptional ? ' (اختیاری)' : ''),
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
            keyboardType: keyboardType,
            maxLines: maxLines,
            textAlign: isLtr ? TextAlign.left : TextAlign.right,
            textDirection: isLtr ? TextDirection.ltr : TextDirection.rtl,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                vertical: maxLines > 1 ? 12.0 : (fieldHeight - 28) / 2,
                horizontal: 16.0,
              ),
              hintText: isLtr ? 'Enter $label' : null,
              hintStyle: const TextStyle(color: Colors.grey),
            ),
            validator: validator ?? (value) { //  از validator پیش‌فرض استفاده می‌شود
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'ویرایش اطلاعات هتل' : 'افزودن هتل جدید', style: TextStyle(color: _customPurpleColor, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: _customPurpleColor),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _buildCustomTextField(
                    label: 'نام هتل',
                    controller: _nameController,
                  ),
                  _buildImagePicker(
                    label: 'عکس اصلی هتل',
                    isMainImage: true,
                    currentImageSource: _mainImageSource,
                    selectedFile: _selectedMainImageFile,
                  ),
                  _buildCustomTextField(
                    label: 'توضیحات هتل',
                    controller: _descriptionController,
                    maxLines: 3,
                    isOptional: true,
                  ),
                  _buildCustomTextField(
                    label: 'موقعیت مکانی',
                    controller: _locationController,
                    maxLines: 2,
                    isOptional: false, // موقعیت الزامی
                    // ولیدیتور، به صورت پیش‌فرض به درستی عمل می‌کند، اما می‌توانید سفارشی‌سازی کنید
                  ),
                  const Padding(
                    padding: EdgeInsets.only(right: 4.0, bottom: 8.0, top: 10.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'امکانات',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ),
                  ),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 0.0,
                    alignment: WrapAlignment.end,
                    children: Facility.values.map((facility) {
                      return SizedBox(
                        width: MediaQuery.of(context).size.width * 0.42,
                        child: CheckboxListTile(
                          title: Text(facility.displayName, style: const TextStyle(fontSize: 14)),
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
                          activeColor: _customPurpleColor,
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                        ),
                      );
                    }).toList(),
                  ),
                  ValueListenableBuilder<Set<Facility>>(
                    valueListenable: ValueNotifier(_selectedAmenities),
                    builder: (context, value, child) {
                      if (value.isEmpty && (_formKey.currentState != null && !_formKey.currentState!.validate() && ModalRoute.of(context)?.isCurrent == true)) {
                        // خطای امکانات
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  const SizedBox(height: 20),
                  _buildCustomTextField(
                    label: 'امتیاز (0 تا 5)',
                    controller: _ratingController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    isLtr: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'امتیاز الزامی است';
                      final val = double.tryParse(value);
                      if (val == null) return 'امتیاز باید عددی باشد';
                      if (val < 0 || val > 5) return 'امتیاز باید بین 0 و 5 باشد';
                      return null;
                    },
                  ),
                  _buildCustomTextField(
                    label: 'تعداد اتاق‌ها',
                    controller: _roomCountController,
                    keyboardType: TextInputType.number,
                    isLtr: true,
                    isOptional: true,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final val = int.tryParse(value);
                        if (val == null) return 'تعداد اتاق باید عدد صحیح باشد';
                        if (val < 0) return 'تعداد اتاق نمی‌تواند منفی باشد';
                      }
                      return null;
                    },
                  ),
                  _buildCustomTextField(
                    label: 'شماره شبا (IBAN)',
                    controller: _ibanController,
                    keyboardType: TextInputType.text,
                    isLtr: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'شماره شبا الزامی است';
                      if (!RegExp(r'^IR[0-9]{24}$').hasMatch(value.toUpperCase())) {
                        return 'فرمت شماره شبا صحیح نیست (مثال: IR120120000000001234567890)';
                      }
                      return null;
                    },
                  ),
                  _buildImagePicker(
                    label: 'عکس مجوز هتل',
                    isMainImage: false,
                    currentImageSource: _licenseImageSource,
                    selectedFile: _selectedLicenseImageFile,
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
                      onPressed: () {
                        if (_selectedAmenities.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('لطفاً حداقل یک امکان برای هتل انتخاب کنید.'), backgroundColor: Colors.red),
                          );
                          return;
                        }
                        _saveHotelInfo();
                      },
                      child: Text(_isEditing ? 'ذخیره‌ی تغییرات' : 'افزودن هتل'),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}