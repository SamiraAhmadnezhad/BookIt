import 'package:flutter/material.dart';
import 'dart:io'; // For File
import 'package:image_picker/image_picker.dart'; // For image picking

// --- Constants ---
const Color kManagerPrimaryColor = Color(0xFF542545);
const Color kPageBackgroundColor = Color(0xFFF0F0F0); // طوسی روشن
const Color kCardBackgroundColor = Colors.white;
const Color kTextFieldFillColor = Color(0xFFF5F5F5); // یک طوسی خیلی روشن برای فیلدها

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

  int _selectedBottomNavIndex = 2; // پیش‌فرض روی "اتاق"

  List<XFile> _selectedImages = []; // برای نگهداری تصاویر انتخاب شده
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
    // مثال با یک پکیج http فرضی:
    // for (var imageFile in images) {
    //   var request = http.MultipartRequest('POST', Uri.parse('YOUR_SERVER_UPLOAD_ENDPOINT'));
    //   request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    //   var response = await request.send();
    //   if (response.statusCode == 200) {
    //     final responseBody = await response.stream.bytesToString();
    //     final imageUrl = jsonDecode(responseBody)['imageUrl']; // بسته به پاسخ سرور
    //     uploadedImageUrls.add(imageUrl);
    //   } else {
    //     debugPrint('Failed to upload image: ${imageFile.name}');
    //   }
    // }
    // شبیه‌سازی آپلود و دریافت URL
    await Future.delayed(const Duration(seconds: 1));
    for (int i = 0; i < images.length; i++) {
      uploadedImageUrls.add('https://picsum.photos/seed/uploaded${i + 1}/200/300');
    }
    return uploadedImageUrls;
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        imageQuality: 80, // کاهش کیفیت برای حجم کمتر
      );
      if (pickedFiles.isNotEmpty) {
        setState(() {
          _selectedImages = pickedFiles;
        });
        debugPrint("Picked ${_selectedImages.length} images.");
      }
    } catch (e) {
      debugPrint("Error picking images: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خطا در انتخاب تصویر. لطفا دسترسی‌ها را بررسی کنید.')),
        );
      }
    }
  }

  // TODO: تابع برای ذخیره اطلاعات اتاق و URL تصاویر در سرور
  Future<void> _saveRoomData() async {
    debugPrint("Attempting to save room data...");
    if (_selectedRoomType == null || _roomNameController.text.isEmpty || _priceController.text.isEmpty || _roomCountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لطفا تمامی فیلدهای اجباری را پر کنید.')),
      );
      return;
    }

    List<String> imageUrls = [];
    if (_selectedImages.isNotEmpty) {
      imageUrls = await _uploadImagesToServer(_selectedImages);
      if (imageUrls.isEmpty && _selectedImages.isNotEmpty) { // اگر آپلود ناموفق بود
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('خطا در آپلود تصاویر. لطفا دوباره تلاش کنید.')),
          );
        }
        return;
      }
    }

    final roomData = {
      "roomType": _selectedRoomType,
      "name": _roomNameController.text,
      "pricePerNight": double.tryParse(_priceController.text) ?? 0.0,
      "roomCount": int.tryParse(_roomCountController.text) ?? 0,
      "amenities": {
        "tv": _hasTv,
        "fridge": _hasFridge,
        "safeBox": _hasSafeBox,
        "view": _hasView,
      },
      "imageUrls": imageUrls,
    };

    debugPrint("TODO: Send this data to server: $roomData");
    // مثال با یک تابع فرضی برای ارسال به سرور:
    // bool success = await ApiService.addRoom(roomData);
    // if (success) {
    //   if (mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اتاق با موفقیت اضافه شد!')));
    //     Navigator.pop(context); // بازگشت به صفحه قبل
    //   }
    // } else {
    //   if (mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('خطا در ذخیره اطلاعات اتاق.')));
    //   }
    // }
    // شبیه‌سازی موفقیت
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اطلاعات اتاق با موفقیت برای ذخیره‌سازی ارسال شد (شبیه‌سازی).')),
      );
      // Navigator.pop(context); // Uncomment to navigate back on successful "save"
    }
  }


  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
      child: Text(
        title,
        textAlign: TextAlign.right, // اطمینان از راست‌چین بودن
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildRoomTypeSelector(ThemeData theme) {
    final roomTypes = ["یک تخته", "دو تخته", "سوییت", "...."]; // "...." همانطور که در فیگماست
    return Column(
      children: roomTypes.map((type) {
        bool isSelected = _selectedRoomType == type;
        return Container(
          height: 48, // ارتفاع ثابت برای آیتم‌های نوع اتاق مطابق فیگما
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          decoration: BoxDecoration(
            border: Border.all(color: isSelected ? kManagerPrimaryColor : Colors.grey.shade400, width: 1.0),
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
              borderRadius: BorderRadius.circular(7.0),
              child: Center( // برای وسط‌چین کردن متن
                child: Text(
                  type,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: isSelected ? kManagerPrimaryColor : Colors.black87,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            flex: 7, // فیلد ورودی فضای بیشتری بگیرد
            child: SizedBox( // ارتفاع ثابت برای فیلدهای ورودی
              height: 48,
              child: TextFormField(
                controller: controller,
                keyboardType: keyboardType,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: kTextFieldFillColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // تنظیم پدینگ داخلی
                ),
                style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black87),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3, // لیبل فضای کمتری بگیرد
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[800], fontWeight: FontWeight.w500),
              textAlign: TextAlign.right,
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
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0), // کمی پدینگ عمودی بیشتر
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end, // برای اطمینان از راست‌چین بودن کل ردیف
            children: [
              Expanded(
                child: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(bottom: 1), // برای ایجاد فاصله برای خط زیرین
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 0.8)), // خط زیرین نازک‌تر
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0), // پدینگ برای متن تا روی خط نیفتد
                    child: Text(
                      title,
                      style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black87),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12), // فاصله بین متن و چک‌باکس
              SizedBox( // اندازه ثابت برای چک‌باکس برای هم‌ترازی بهتر
                width: 24,
                height: 24,
                child: Checkbox(
                  value: value,
                  onChanged: onChanged,
                  activeColor: kManagerPrimaryColor,
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  side: BorderSide(color: Colors.grey.shade600, width: 1.5), // کمی تیره‌تر کردن بوردر
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedImagesPreview() {
    if (_selectedImages.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      height: 80,
      margin: const EdgeInsets.only(top: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedImages.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(left: 8.0), // فاصله بین تصاویر در حالت RTL (چپ)
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(_selectedImages[index].path),
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }


  Widget _buildBottomNavigationBar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0),),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 0, blurRadius: 15, offset: const Offset(0, -5),),],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0),),
        child: BottomNavigationBar(
          currentIndex: _selectedBottomNavIndex,
          onTap: (index) {
            // TODO: Implement actual navigation or state change for bottom bar items
            setState(() { _selectedBottomNavIndex = index; });
            debugPrint("TODO: BottomNav tapped: $index");
            if (index == 0) { //  اگر تب "بررسی" (لیست اتاق‌ها) انتخاب شد
              if (Navigator.canPop(context)) {
                // Navigator.pop(context); // اگر این صفحه از صفحه لیست اتاق‌ها باز شده
              } else {
                // Navigator.pushReplacementNamed(context, '/hotel_info'); // اگر مستقیم به این صفحه آمده
              }
            }
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: kManagerPrimaryColor,
          unselectedItemColor: Colors.grey[500],
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 10),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          backgroundColor: Colors.white,
          elevation: 0,
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
          child: Column( // استفاده از Column برای قرار دادن SingleChildScrollView و BottomNavBar
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0), // پدینگ از همه طرف
                  child: Center(
                    child: ConstrainedBox( // برای محدود کردن عرض کارت در صفحات بزرگتر
                      constraints: const BoxConstraints(maxWidth: 500), // عرض حداکثر کارت
                      child: Container( // Container به جای Card برای کنترل دقیق‌تر padding و margin
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                        decoration: BoxDecoration(
                          color: kCardBackgroundColor,
                          borderRadius: BorderRadius.circular(16.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch, // آیتم‌ها تمام عرض را بگیرند
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "اطلاعات اتاق",
                              textAlign: TextAlign.center, // عنوان وسط‌چین
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            _buildSectionTitle("نوع اتاق", theme),
                            _buildRoomTypeSelector(theme),

                            const SizedBox(height: 8), // کاهش فاصله
                            _buildLabeledTextField(controller: _roomNameController, label: "نام اتاق", theme: theme),
                            _buildLabeledTextField(controller: _priceController, label: "قیمت یک شب", theme: theme, keyboardType: TextInputType.number),
                            _buildLabeledTextField(controller: _roomCountController, label: "تعداد اتاق", theme: theme, keyboardType: TextInputType.number),

                            _buildSectionTitle("امکانات", theme),
                            _buildCheckboxItem("تلویزیون", _hasTv, (val) => setState(() => _hasTv = val!), theme),
                            _buildCheckboxItem("یخچال", _hasFridge, (val) => setState(() => _hasFridge = val!), theme),
                            _buildCheckboxItem("safe box", _hasSafeBox, (val) => setState(() => _hasSafeBox = val!), theme),
                            _buildCheckboxItem("ویو", _hasView, (val) => setState(() => _hasView = val!), theme),

                            const SizedBox(height: 24),
                            Row( // برای قرار دادن دکمه آپلود در سمت راست
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: _pickImages,
                                  icon: Icon(Icons.attach_file_rounded, color: Colors.grey[700], size: 20, textDirection: TextDirection.ltr),
                                  label: Text(
                                    "آپلود تصاویر",
                                    style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[800], fontWeight: FontWeight.w500),
                                  ),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                              ],
                            ),
                            _buildSelectedImagesPreview(), // نمایش تصاویر انتخاب شده
                            const SizedBox(height: 20),

                            SizedBox( // ارتفاع ثابت برای دکمه ذخیره
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _saveRoomData,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kManagerPrimaryColor,
                                  foregroundColor: Colors.white,
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
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(theme),
      ),
    );
  }
}