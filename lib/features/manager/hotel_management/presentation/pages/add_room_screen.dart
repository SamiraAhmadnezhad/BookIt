import 'dart:convert';
import 'package:bookit/features/auth/data/services/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';

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

  Uint8List? _selectedImageData;
  String? _imageName;
  final ImagePicker _picker = ImagePicker();

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
      });
    }
  }

  Future<void> _submitRoomData() async {
    if (!_formKey.currentState!.validate() || _selectedImageData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('لطفاً تمام فیلدها را پر کرده و یک عکس انتخاب کنید.')),
      );
      return;
    }
    setState(() => _isLoading = true);

    final authService = Provider.of<AuthService>(context, listen: false);
    final token = authService.token;
    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خطای احراز هویت. لطفاً دوباره وارد شوید.')),
        );
      }
      setState(() => _isLoading = false);
      return;
    }

    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse('https://fbookit.darkube.app/room-api/create/'));
      request.headers['Authorization'] = 'Bearer $token';

      request.fields.addAll({
        'hotel': widget.hotelId,
        'name': _nameController.text,
        'room_type': _selectedRoomType!,
        'price': _priceController.text,
        'room_number': _roomNumberController.text,
      });

      request.files.add(http.MultipartFile.fromBytes(
        'image',
        _selectedImageData!,
        filename: _imageName ?? 'room_image.jpg',
        contentType: MediaType('image', 'jpeg'),
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        debugPrint('Failed to create room. Status code: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطا در ذخیره اتاق: ${response.body}')),
          );
        }
      }
    } catch (e) {
      debugPrint('An error occurred: $e');
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
    return Scaffold(
      appBar: AppBar(title: const Text('افزودن اتاق جدید')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'نام اتاق'),
                validator: (value) =>
                value == null || value.isEmpty ? 'نام اتاق الزامی است' : null,
              ),
              const SizedBox(height: 16),
              _buildDropdown(),
              const SizedBox(height: 16),
              TextFormField(
                controller: _roomNumberController,
                decoration: const InputDecoration(labelText: 'شماره اتاق'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty
                    ? 'شماره اتاق الزامی است'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'قیمت هر شب'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'قیمت الزامی است';
                  }
                  if (int.tryParse(value) == null) {
                    return 'لطفاً یک عدد معتبر وارد کنید';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildImagePicker(),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: _isLoading ? null : _submitRoomData,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('ذخیره اتاق'),
              ),
            ],
          ),
        ),
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
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'نوع اتاق *',
      ),
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
        Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: _selectedImageData != null
              ? ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.memory(_selectedImageData!, fit: BoxFit.cover),
          )
              : const Center(child: Text('عکسی انتخاب نشده است')),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          icon: const Icon(Icons.image),
          onPressed: _pickImage,
          label: const Text('انتخاب عکس'),
        )
      ],
    );
  }
}