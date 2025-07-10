// lib/pages/manager_pages/add_facilities_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../features/auth/data/services/auth_service.dart';
import 'hotel_info_page/models/facility_enum.dart';

// --- ثابت‌ها ---
const String BASE_URL = 'https://fbookit.darkube.app';
const String ADD_FACILITY_ENDPOINT = '/hotel-api/add-fac/';

class AddFacilitiesPage extends StatefulWidget {
  const AddFacilitiesPage({super.key});

  @override
  State<AddFacilitiesPage> createState() => _AddFacilitiesPageState();
}

class _AddFacilitiesPageState extends State<AddFacilitiesPage> {
  // متغیرهای وضعیت برای مدیریت UI
  bool _isLoading = false;
  // برای نگهداری وضعیت هر facility (موفق، ناموفق، در حال انتظار)
  Map<Facility, String> _results = {};

  @override
  void initState() {
    super.initState();
    // مقداردهی اولیه وضعیت برای همه امکانات
    for (var facility in Facility.values) {
      _results[facility] = "در انتظار";
    }
  }

  // --- تابع اصلی برای ارسال تمام امکانات به سرور ---
  Future<void> _seedFacilities() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      // ریست کردن وضعیت‌ها قبل از شروع عملیات جدید
      for (var facility in Facility.values) {
        _results[facility] = "در حال ارسال...";
      }
    });

    // دریافت توکن احراز هویت با استفاده از Provider
    final authService = Provider.of<AuthService>(context, listen: false);
    final String? token = authService.token;

    if (token == null) {
      _showSnackBar('توکن احراز هویت یافت نشد. لطفاً دوباره وارد شوید.', isError: true);
      setState(() => _isLoading = false);
      return;
    }

    // آماده‌سازی URL و هدرهای مشترک
    final url = Uri.parse('$BASE_URL$ADD_FACILITY_ENDPOINT');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    // حلقه روی تمام امکانات و ارسال درخواست برای هر کدام
    for (var facility in Facility.values) {
      if (!mounted) return; // اگر ویجت از درخت حذف شده بود، ادامه نده

      final body = json.encode({'name': facility.apiValue});

      try {
        final response = await http.post(url, headers: headers, body: body);

        if (!mounted) return;

        // کد 201 یعنی با موفقیت ایجاد شده
        // کد 400 (Bad Request) در این سناریو یعنی "این facility از قبل وجود دارد" که آن را هم موفقیت‌آمیز در نظر می‌گیریم.
        if (response.statusCode == 201 || response.statusCode == 400) {
          setState(() {
            _results[facility] = 'موفق';
          });
        } else {
          // برای خطاهای دیگر، متن خطا را ذخیره می‌کنیم
          setState(() {
            _results[facility] = 'خطا: ${response.statusCode}';
          });
        }
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _results[facility] = 'خطای اتصال';
        });
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
      _showSnackBar('عملیات به پایان رسید. وضعیت هر مورد را در لیست زیر بررسی کنید.', isError: false);
    }
  }

  // متد کمکی برای نمایش SnackBar
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('افزودن امکانات پیش‌فرض'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // بخش بالایی برای توضیحات و دکمه
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'این عملیات، امکانات پیش‌فرض را به دیتابیس اضافه می‌کند. امکاناتی که از قبل موجود باشند، نادیده گرفته می‌شوند.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.black54),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : const Icon(Icons.cloud_upload_outlined),
                  label: Text(_isLoading ? 'در حال انجام...' : 'افزودن همه امکانات'),
                  onPressed: _seedFacilities,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 16, fontFamily: 'Vazir', fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          // بخش پایینی برای نمایش لیست و نتایج
          Expanded(
            child: ListView.builder(
              itemCount: Facility.values.length,
              itemBuilder: (context, index) {
                final facility = Facility.values[index];
                final status = _results[facility] ?? "نامشخص";

                Icon statusIcon;
                Color statusColor;

                switch (status) {
                  case 'موفق':
                    statusIcon = const Icon(Icons.check_circle, color: Colors.green);
                    statusColor = Colors.green;
                    break;
                  case 'در حال ارسال...':
                    statusIcon = const Icon(Icons.check_circle, color: Colors.green);
                    statusColor = Colors.blue;
                    break;
                  case 'در انتظار':
                    statusIcon = const Icon(Icons.hourglass_empty, color: Colors.grey);
                    statusColor = Colors.grey;
                    break;
                  default: // هر نوع خطا
                    statusIcon = const Icon(Icons.error, color: Colors.red);
                    statusColor = Colors.red;
                }

                return ListTile(
                  title: Text(facility.userDisplayName, style: const TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text('مقدار ارسالی: ${facility.apiValue}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      statusIcon,
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}