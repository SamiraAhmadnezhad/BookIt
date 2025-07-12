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

    final facilityNames = _selectedAmenities.map((f) => f.apiValue).toList();

    request.fields.addAll({
      'name': _nameController.text,
      'location': _locationController.text,
      'description': _descriptionController.text,
      'hotel_iban_number': _ibanController.text,
      'facilities': jsonEncode(facilityNames),
    });

    if (_selectedMainImageData != null) {
      request.files.add(http.MultipartFile.fromBytes('image',
          _selectedMainImageData!,
          filename: _mainImageName, contentType: MediaType('image', 'jpeg')));
    }
    if (_selectedLicenseImageData != null) {
      request.files.add(http.MultipartFile.fromBytes(
          'hotel_license', _selectedLicenseImageData!,
          filename: _licenseImageName, contentType: MediaType('image', 'jpeg')));
    }

    final response = await request.send();
    if (response.statusCode == 200 || response.statusCode == 201) {
      Navigator.pop(context, true);
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'ویرایش هتل' : 'افزودن هتل')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'نام هتل')),
              TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(labelText: 'آدرس')),
              TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'توضیحات')),
              TextFormField(
                  controller: _ibanController,
                  decoration: const InputDecoration(labelText: 'شماره شبا')),
              const SizedBox(height: 16),
              _buildImagePicker(isMainImage: true),
              const SizedBox(height: 16),
              _buildImagePicker(isMainImage: false),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8.0,
                children: Facility.values.map((facility) {
                  return FilterChip(
                    label: Text(facility.userDisplayName),
                    selected: _selectedAmenities.contains(facility),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedAmenities.add(facility);
                        } else {
                          _selectedAmenities.remove(facility);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitHotelData,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(_isEditing ? 'ذخیره' : 'افزودن'),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker({required bool isMainImage}) {
    final imageData =
    isMainImage ? _selectedMainImageData : _selectedLicenseImageData;
    final existingUrl =
    isMainImage ? _existingMainImageUrl : _existingLicenseImageUrl;

    return Column(
      children: [
        Text(isMainImage ? 'عکس اصلی هتل' : 'عکس مجوز'),
        Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
          child: (imageData != null)
              ? Image.memory(imageData, fit: BoxFit.cover)
              : (existingUrl != null && existingUrl.isNotEmpty)
              ? Image.network(existingUrl, fit: BoxFit.cover)
              : const Center(child: Text('عکسی انتخاب نشده')),
        ),
        ElevatedButton(
            onPressed: () => _pickImage(isMainImage: isMainImage),
            child: const Text('انتخاب عکس'))
      ],
    );
  }
}