import 'dart:convert';
import 'package:bookit/core/models/hotel_model.dart';
import 'package:bookit/features/auth/data/services/auth_service.dart';
import 'package:bookit/features/manager/hotel_management/presentation/pages/room_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/utils/custom_shamsi_date_picker.dart';
import '../../data/services/manager_api_service.dart';
import '../widgets/hotel_card.dart';
import 'add_hotel_screen.dart';

class HotelListScreen extends StatefulWidget {
  const HotelListScreen({super.key});

  @override
  State<HotelListScreen> createState() => _HotelListScreenState();
}

class _HotelListScreenState extends State<HotelListScreen> {
  late final ManagerApiService _managerApiService;
  List<Hotel> _hotels = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AuthService>(context, listen: false);
    _managerApiService = ManagerApiService(authService);
    _fetchHotelsFromBackend();
  }

  Future<void> _fetchHotelsFromBackend() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final String? token = authService.token;

      if (token == null) {
        throw 'توکن احراز هویت یافت نشد.';
      }

      final response = await http.get(
        Uri.parse('https://fbookit.darkube.app/hotel-api/hotel/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (!mounted) return;
      print(response.body);

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(utf8.decode(response.bodyBytes));
        final hotelListData = (decodedData['data'] as List)
            .map((data) => Hotel.fromJson(data))
            .toList();
        setState(() => _hotels = hotelListData);
      } else {
        throw 'خطا در دریافت اطلاعات. کد وضعیت: ${response.statusCode}';
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _downloadLicense(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در باز کردن لینک: $url')),
        );
      }
    }
  }

  Future<void> _applyDiscount(
      Hotel hotel, Jalali startDate, Jalali endDate, int discount) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final String? token = authService.token;
    if (token == null) return;

    final requestBody = {
      'hotel_id': hotel.id,
      'discount': discount,
      'discount_start_date':
      startDate.toGregorian().toDateTime().toIso8601String().split('T').first,
      'discount_end_date':
      endDate.toGregorian().toDateTime().toIso8601String().split('T').first,
    };

    final response = await http.post(
      Uri.parse(
          'https://fbookit.darkube.app/hotelManager-api/hotel_manager/activate_discount/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(requestBody),
    );

    if (mounted && (response.statusCode == 200 || response.statusCode == 201)) {
      _fetchHotelsFromBackend();
    }
  }

  void _showDiscountDialog(Hotel hotel) {
    Jalali? startDate;
    Jalali? endDate;
    final discountController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text("اعمال تخفیف برای ${hotel.name}"),
          content: Form(
            key: formKey,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              ListTile(
                title: Text(startDate == null
                    ? "تاریخ شروع"
                    : startDate!.formatter.y+"/"+startDate!.formatter.m+"/"+startDate!.formatter.d),
                onTap: () async {
                  final picked = await showCustomShamsiDatePickerDialog(
                      context,
                      initialDate: Jalali.now(),
                      firstDate: Jalali.now());
                  if (picked != null) {
                    setStateDialog(() => startDate = picked);
                  }
                },
              ),
              ListTile(
                enabled: startDate != null,
                title: Text(
                    endDate == null ? "تاریخ پایان" : endDate!.formatter.y+"/"+endDate!.formatter.m+"/"+endDate!.formatter.d),
                onTap: () async {
                  if (startDate == null) return;
                  final picked = await showCustomShamsiDatePickerDialog(
                      context,
                      initialDate: startDate!,
                      firstDate: startDate!);
                  if (picked != null) setStateDialog(() => endDate = picked);
                },
              ),
              TextFormField(
                controller: discountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "درصد تخفیف"),
                validator: (v) => (v == null || v.isEmpty)
                    ? 'لطفا درصد تخفیف را وارد کنید'
                    : null,
              )
            ]),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("انصراف")),
            ElevatedButton(
              onPressed: () {
                if (startDate != null &&
                    endDate != null &&
                    formKey.currentState!.validate()) {
                  Navigator.pop(context);
                  _applyDiscount(hotel, startDate!, endDate!,
                      int.parse(discountController.text));
                }
              },
              child: const Text("اعمال"),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteHotel(String hotelId) async {
    final success = await _managerApiService.deleteHotel(hotelId);
    if (success) {
      _fetchHotelsFromBackend();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مدیریت هتل‌ها')),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddHotelScreen()));
          if (result == true) _fetchHotelsFromBackend();
        },
        label: const Text('افزودن هتل'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null) {
      return Center(
          child:
          Text(_errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)));
    }
    if (_hotels.isEmpty) {
      return const Center(child: Text('هتلی برای نمایش وجود ندارد.'));
    }

    return RefreshIndicator(
      onRefresh: _fetchHotelsFromBackend,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 420,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: _hotels.length,
        itemBuilder: (context, index) {
          final hotel = _hotels[index];
          return HotelCard(
            hotel: hotel,
            onHotelUpdated: () async {
              final result = await Navigator.push(context,
                  MaterialPageRoute(builder: (_) => AddHotelScreen(hotel: hotel)));
              if (result == true) _fetchHotelsFromBackend();
            },
            onManageRooms: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => RoomListScreen(
                        hotelId: hotel.id.toString(), hotelName: hotel.name))),
            onApplyDiscount: () => _showDiscountDialog(hotel),
            onDeleteHotel: () => _deleteHotel(hotel.id.toString()),
            onDownloadLicense: () => _downloadLicense(hotel.licenseImageUrl),
          );
        },
      ),
    );
  }
}