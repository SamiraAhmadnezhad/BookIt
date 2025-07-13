import 'dart:convert';
import 'package:bookit/core/models/room_model.dart';
import 'package:bookit/features/auth/data/services/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';

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

class AddRoomScreen extends StatefulWidget {
  final String hotelId;
  final Room? room;

  const AddRoomScreen({super.key, required this.hotelId, this.room});

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
  bool get _isEditing => widget.room != null;

  Uint8List? _selectedImageData;
  String? _imageName;
  String? _existingImageUrl;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final room = widget.room!;
      _nameController.text = room.name;
      _roomNumberController.text = room.roomNumber;
      _priceController.text = room.price.toInt().toString();
      _selectedRoomType = room.roomType;
      _existingImageUrl = room.imageUrl;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roomNumberController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
    await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImageData = bytes;
        _imageName = pickedFile.name;
        _existingImageUrl = null;
      });
    }
  }

  Future<void> _submitRoomData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (!_isEditing && _selectedImageData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('انتخاب عکس برای اتاق جدید الزامی است.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authService = Provider.of<AuthService>(context, listen: false);
    final token = authService.token;
    if (token == null) {
      setState(() => _isLoading = false);
      return;
    }

    final uri = Uri.parse(_isEditing
        ? 'https://fbookit.darkube.app/room-api/room/'
        : 'https://fbookit.darkube.app/room-api/create/');

    var request = http.MultipartRequest(_isEditing ? 'PATCH' : 'POST', uri);
    request.headers['Authorization'] = 'Bearer $token';

    if (_isEditing){
    request.fields.addAll({
      'room_id' : widget.room!.id,
      'hotel': widget.hotelId,
      'name': _nameController.text,
      'room_type': _selectedRoomType!,
      'price': _priceController.text,
      'room_number': _roomNumberController.text,
    });
    } else{
      request.fields.addAll({
        'hotel': widget.hotelId,
        'name': _nameController.text,
        'room_type': _selectedRoomType!,
        'price': _priceController.text,
        'room_number': _roomNumberController.text,
      });
    }

    if (_selectedImageData != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        _selectedImageData!,
        filename: _imageName ?? 'room_image.jpg',
        contentType: MediaType('image', 'jpeg'),
      ));
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) Navigator.pop(context, true);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطا: ${response.body}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطای شبکه: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
          title: Text(_isEditing ? 'ویرایش اتاق' : 'افزودن اتاق جدید',
              style: const TextStyle(color: AppColors.white)),
          backgroundColor: AppColors.primary,
          iconTheme: const IconThemeData(color: AppColors.white)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Card(
                elevation: 0,
                color: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('اطلاعات اتاق',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDark)),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _nameController,
                        decoration:
                        inputDecorationTheme.copyWith(labelText: 'نام اتاق'),
                        validator: (value) => value == null || value.isEmpty
                            ? 'نام اتاق الزامی است'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      _buildDropdown(inputDecorationTheme),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _roomNumberController,
                              decoration: inputDecorationTheme.copyWith(
                                  labelText: 'شماره اتاق'),
                              keyboardType: TextInputType.number,
                              validator: (value) => value == null || value.isEmpty
                                  ? 'شماره اتاق الزامی است'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _priceController,
                              decoration: inputDecorationTheme.copyWith(
                                  labelText: 'قیمت هر شب'),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'قیمت الزامی است';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'عدد معتبر وارد کنید';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildImagePicker(),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isLoading ? null : _submitRoomData,
                        child: _isLoading
                            ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                              color: AppColors.white),
                        )
                            : Text(
                          _isEditing ? 'ذخیره تغییرات' : 'ذخیره اتاق',
                          style: const TextStyle(
                              fontSize: 16, color: AppColors.white),
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
    );
  }

  Widget _buildDropdown(InputDecoration baseDecoration) {
    final Map<String, String> roomTypes = {
      'یک تخته': 'Single',
      'دو تخته': 'Double',
      'سه تخته': 'Triple',
    };
    return DropdownButtonFormField<String>(
      value: _selectedRoomType,
      hint: const Text('نوع اتاق را انتخاب کنید'),
      decoration: baseDecoration.copyWith(labelText: 'نوع اتاق *'),
      items: roomTypes.entries.map((entry) {
        return DropdownMenuItem(value: entry.value, child: Text(entry.key));
      }).toList(),
      onChanged: (value) => setState(() => _selectedRoomType = value),
      validator: (value) =>
      value == null ? 'انتخاب نوع اتاق الزامی است' : null,
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('عکس اتاق',
            style: TextStyle(
                color: AppColors.darkGrey,
                fontSize: 16,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        Container(
          height: 200,
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
              border: Border.all(color: AppColors.formBackgroundGrey),
              borderRadius: BorderRadius.circular(12)),
          child: (_selectedImageData != null)
              ? Image.memory(_selectedImageData!, fit: BoxFit.cover)
              : (_existingImageUrl != null)
              ? Image.network(_existingImageUrl!, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.broken_image_outlined,
                      color: AppColors.grey)))
              : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.image_search,
                    size: 48, color: AppColors.grey),
                SizedBox(height: 8),
                Text('عکسی انتخاب نشده',
                    style: TextStyle(color: AppColors.darkGrey)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          icon: const Icon(Icons.upload_outlined, size: 20),
          onPressed: _pickImage,
          style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8))),
          label: const Text('انتخاب عکس'),
        )
      ],
    );
  }
}