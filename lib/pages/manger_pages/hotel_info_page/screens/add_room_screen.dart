// فایل: screens/add_room_screen.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../authentication_page/auth_service.dart';

// Endpoint جدید مطابق با Swagger
const String ADD_ROOM_API_ENDPOINT = 'https://fbookit.darkube.app/room-api/create/';

const Color kManagerPrimaryColor = Color(0xFF542545);
const Color kPageBackgroundColor = Color(0xFFF4F6F8);

class AddRoomScreen extends StatefulWidget {
  final String hotelId;
  const AddRoomScreen({super.key, required this.hotelId});

  @override
  State<AddRoomScreen> createState() => _AddRoomScreenState();
}

class _AddRoomScreenState extends State<AddRoomScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _roomNumberController = TextEditingController();
  final _priceController = TextEditingController();

  String? _selectedRoomType;
  bool _isLoading = false;

  // برای نگهداری یک تصویر انتخاب شده
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _roomNumberController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.redAccent : Colors.green,
    ));
  }

  // تابع برای انتخاب یک تصویر
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 1024,
      );
      if (pickedFile != null) {
        setState(() => _selectedImage = pickedFile);
      }
    } catch (e) {
      _showSnackBar('خطا در انتخاب تصویر: $e', isError: true);
    }
  }

  Future<void> _submitRoomData() async {
    if (!_formKey.currentState!.validate()) {
      _showSnackBar('لطفا تمام فیلدها را به درستی پر کنید.', isError: true);
      return;
    }
    // اعتبارسنجی برای انتخاب تصویر
    if (_selectedImage == null) {
      _showSnackBar('انتخاب تصویر اتاق الزامی است.', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    final authService = Provider.of<AuthService>(context, listen: false);
    final token = authService.token;
    if (token == null) {
      _showSnackBar('توکن احراز هویت یافت نشد.', isError: true);
      setState(() => _isLoading = false);
      return;
    }

    // استفاده از MultipartRequest برای ارسال فایل و متن
    var request = http.MultipartRequest('POST', Uri.parse(ADD_ROOM_API_ENDPOINT));
    request.headers['Authorization'] = 'Bearer $token';

    // افزودن فیلدهای متنی
    request.fields.addAll({
      'hotel': widget.hotelId,
      'name': _nameController.text,
      'room_type': _selectedRoomType!,
      'price': _priceController.text,
      'room_number': _roomNumberController.text,
    });

    // افزودن فایل تصویر
    request.files.add(
        await http.MultipartFile.fromPath(
          'image', // نام فیلد در API
          _selectedImage!.path,
          contentType: MediaType('image', _selectedImage!.path.split('.').last),
        )
    );

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        _showSnackBar('اتاق با موفقیت اضافه شد.');
        if (mounted) Navigator.pop(context, true);
      } else {
        final error = jsonDecode(utf8.decode(response.bodyBytes));
        _showSnackBar('خطا: ${error.toString()}', isError: true);
      }
    } catch (e) {
      _showSnackBar('خطا در ارتباط با سرور: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPageBackgroundColor,
      appBar: AppBar(
        title: const Text('افزودن اتاق جدید'),
        backgroundColor: kManagerPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // کارت اطلاعات اصلی
              _buildSectionCard([
                _buildTextFormField(controller: _nameController, label: 'نام اتاق', keyboardType: TextInputType.text),
                const SizedBox(height: 16),
                _buildDropdown(),
                const SizedBox(height: 16),
                _buildTextFormField(controller: _roomNumberController, label: 'شماره اتاق', keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                _buildTextFormField(controller: _priceController, label: 'قیمت هر شب', keyboardType: TextInputType.number, suffixText: 'تومان'),
              ]),
              // کارت انتخاب تصویر
              _buildSectionCard([
                Text('تصویر اتاق *', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                _buildImagePicker(),
              ]),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _submitRoomData,
                icon: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.save_alt_outlined),
                label: const Text('ذخیره اتاق'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kManagerPrimaryColor, foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(List<Widget> children) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
      ),
    );
  }

  Widget _buildDropdown() {
    final Map<String, String> roomTypes = {
      'یک تخته': 'Single',
      'دو تخته': 'Double',
      'سه تخته': 'Triple',
    };
    return DropdownButtonFormField<String>(
      value: _selectedRoomType,
      hint: const Text('نوع اتاق را انتخاب کنید'),
      decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'نوع اتاق *'),
      items: roomTypes.entries.map((entry) {
        return DropdownMenuItem(value: entry.value, child: Text(entry.key));
      }).toList(),
      onChanged: (value) => setState(() => _selectedRoomType = value),
      validator: (value) => value == null ? 'انتخاب نوع اتاق الزامی است' : null,
    );
  }

  Widget _buildTextFormField({required TextEditingController controller, required String label, required TextInputType keyboardType, String? suffixText}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: '$label *',
        border: const OutlineInputBorder(),
        suffixText: suffixText,
      ),
      validator: (value) => value == null || value.isEmpty ? 'این فیلد نمی‌تواند خالی باشد' : null,
    );
  }

  Widget _buildImagePicker() {
    return Center(
      child: Column(
        children: [
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: _selectedImage != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(File(_selectedImage!.path), fit: BoxFit.cover),
            )
                : const Center(child: Icon(Icons.image_outlined, size: 50, color: Colors.grey)),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.add_a_photo_outlined),
            label: Text(_selectedImage == null ? 'انتخاب تصویر' : 'تغییر تصویر'),
          ),
        ],
      ),
    );
  }
}