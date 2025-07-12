import 'dart:convert';
import 'package:bookit/core/models/hotel_model.dart';
import 'package:bookit/features/auth/data/services/auth_service.dart';
import 'package:bookit/pages/manger_pages/hotel_info_page/screens/room_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../../../core/utils/custom_shamsi_date_picker.dart';
import '../widgets/hotel_card.dart';
import 'add_hotel_screen.dart';

const String HOTELS_API_ENDPOINT = 'https://fbookit.darkube.app/hotel-api/hotel/';
const String DISCOUNT_API_ENDPOINT =
    'https://fbookit.darkube.app/hotelManager-api/hotel_manager/activate_discount/';

class HotelListScreen extends StatefulWidget {
  const HotelListScreen({super.key});

  @override
  State<HotelListScreen> createState() => _HotelListScreenState();
}

class _HotelListScreenState extends State<HotelListScreen> {
  List<Hotel> _hotels = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fetchHotelsFromBackend();
      }
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ),
    );
  }

  Future<void> _fetchHotelsFromBackend() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final authService = Provider.of<AuthService>(context, listen: false);
    final String? token = authService.token;

    if (token == null) {
      setState(() => _errorMessage = 'توکن احراز هویت یافت نشد.');
      _showSnackBar(_errorMessage!, isError: true);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(HOTELS_API_ENDPOINT),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 20));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(utf8.decode(response.bodyBytes));
        final hotelListData = (decodedData['data'] as List)
            .map((data) => Hotel.fromJson(data))
            .toList();
        setState(() => _hotels = hotelListData);
      } else {
        setState(() => _errorMessage = 'خطا در دریافت اطلاعات از سرور.');
      }
    } catch (e) {
      setState(() => _errorMessage = 'خطا در ارتباط با سرور.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
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

    debugPrint('--- [API Request] Applying Discount ---');
    debugPrint('URL: $DISCOUNT_API_ENDPOINT');
    debugPrint('Body: ${jsonEncode(requestBody)}');
    debugPrint('Token: Present');

    try {
      final response = await http.post(
        Uri.parse(DISCOUNT_API_ENDPOINT),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      debugPrint('Response Status: ${response.statusCode}');
      debugPrint('Response Body: ${utf8.decode(response.bodyBytes)}');

      if (!mounted) return;
      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnackBar('تخفیف با موفقیت اعمال شد.', isError: false);
        _fetchHotelsFromBackend();
      } else {
        _showSnackBar('خطا در اعمال تخفیف.', isError: true);
      }
    } catch (e) {
      if (mounted) _showSnackBar('خطا در ارتباط با سرور.', isError: true);
    }
  }

  void _showDiscountDialog(Hotel hotel) {
    Jalali? startDate;
    Jalali? endDate;
    final discountController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text("اعمال تخفیف برای ${hotel.name}"),
            content: Form(
              key: formKey,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                ListTile(
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: Text(startDate == null
                      ? "تاریخ شروع"
                      : startDate!.formatter.y+"/"+startDate!.formatter.m+"/"+startDate!.formatter.d),
                  onTap: () async {
                    final picked = await showCustomShamsiDatePickerDialog(
                        context,
                        initialDate: Jalali.now(),
                        firstDate: Jalali.now());
                    if (picked != null)
                      setStateDialog(() => startDate = picked);
                  },
                ),
                ListTile(
                  enabled: startDate != null,
                  leading: const Icon(Icons.event_available_outlined),
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
                const SizedBox(height: 16),
                TextFormField(
                  controller: discountController,
                  keyboardType: TextInputType.number,
                  decoration:
                  const InputDecoration(labelText: "درصد تخفیف (۱-۱۰۰)"),
                  validator: (v) => (v == null ||
                      v.isEmpty ||
                      int.tryParse(v) == null ||
                      int.parse(v) <= 0 ||
                      int.parse(v) > 100)
                      ? 'یک عدد بین ۱ تا ۱۰۰ وارد کنید'
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
          );
        });
      },
    );
  }

  void _navigateAndHandleAddEditHotel(BuildContext context,
      {Hotel? hotelToEdit}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddHotelScreen(hotel: hotelToEdit)),
    );
    if (result == true) _fetchHotelsFromBackend();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مدیریت هتل‌ها')),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateAndHandleAddEditHotel(context),
        label: const Text('افزودن هتل'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _hotels.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null && _hotels.isEmpty) {
      return Center(
          child:
          Text('خطا در بارگذاری: $_errorMessage', textAlign: TextAlign.center));
    }
    if (_hotels.isEmpty) {
      return const Center(child: Text('هتلی برای نمایش وجود ندارد.'));
    }

    return GridView.builder(
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
          onHotelUpdated: () =>
              _navigateAndHandleAddEditHotel(context, hotelToEdit: hotel),
          onManageRooms: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => RoomListScreen(
                      hotelId: hotel.id.toString(), hotelName: hotel.name))),
          onApplyDiscount: () => _showDiscountDialog(hotel),
        );
      },
    );
  }
}