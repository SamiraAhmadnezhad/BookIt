// lib/pages/manager_pages/reports_page.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../../authentication_page/auth_service.dart';
import '../../../guest_pages/search_page/widgets/custom_shamsi_date_picker.dart';
import '../models/report_models.dart';
import '../services/report_service.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  // === تعریف پالت رنگی بر اساس درخواست شما ===
  static const Color primaryColor = Color(0xFF542545);
  static const Color accentColor = Color(0xFF8e44ad);
  static const Color backgroundColor = Color(0xFFF4F6F9); // یک خاکستری بسیار روشن
  static const Color cardColor = Colors.white;

  // === منطق کد شما (بدون تغییر) ===
  final ReportService _reportService = ReportService();
  Jalali? _startDateJalali;
  Jalali? _endDateJalali;
  bool _isLoading = false;
  ReservationStats? _statsData;
  String? _errorMessage;

  Future<void> _selectShamsiDate(BuildContext context, bool isStartDate) async {
    final currentYear = Jalali.now().year;
    final Jalali? picked = await showCustomShamsiDatePickerDialog(
      context,
      initialDate: (isStartDate ? _startDateJalali : _endDateJalali) ?? Jalali.now(),
      firstDate: Jalali(currentYear - 10),
      lastDate: Jalali(currentYear + 2),
    );
    if (picked != null) {
      setState(() => isStartDate ? _startDateJalali = picked : _endDateJalali = picked);
    }
  }

  Future<void> _fetchReport() async {
    if (_startDateJalali == null || _endDateJalali == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لطفاً بازه زمانی را به طور کامل انتخاب کنید.')));
      return;
    }
    if (_startDateJalali!.toGregorian().toDateTime().isAfter(_endDateJalali!.toGregorian().toDateTime())) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تاریخ شروع نمی‌تواند بعد از تاریخ پایان باشد.')));
      return;
    }
    setState(() { _isLoading = true; _errorMessage = null; _statsData = null; });
    final authService = Provider.of<AuthService>(context, listen: false);
    final token = authService.token;
    if (token == null) {
      setState(() { _isLoading = false; _errorMessage = "خطای احراز هویت. لطفاً دوباره وارد شوید."; });
      return;
    }
    try {
      final stats = await _reportService.fetchReservationStats(
        startDate: _startDateJalali!.toGregorian().toDateTime(),
        endDate: _endDateJalali!.toGregorian().toDateTime(),
        token: token,
      );
      setState(() => _statsData = stats);
    } catch (e) {
      setState(() => _errorMessage = e.toString().replaceAll("Exception: ", ""));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // === بخش UI (طراحی جدید و زیبا) ===
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'داشبورد گزارش فروش',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light, // <<< برای تیره شدن آیکون‌های نوار وضعیت
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildDateSelectionSection(),
          const SizedBox(height: 20),
          _buildFetchButton(),
          const SizedBox(height: 24),
          _buildResultsSection(),
        ],
      ),
    );
  }

  Widget _buildDateSelectionSection() {
    return Card(
      elevation: 2,
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "انتخاب بازه زمانی",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildDatePickerTile('از تاریخ', _startDateJalali, (ctx) => _selectShamsiDate(ctx, true))),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(Icons.arrow_forward, color: Colors.grey),
                ),
                Expanded(child: _buildDatePickerTile('تا تاریخ', _endDateJalali, (ctx) => _selectShamsiDate(ctx, false))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePickerTile(String title, Jalali? date, Function(BuildContext) onTap) {
    return InkWell(
      onTap: () => onTap(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, color: primaryColor, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(
                    date == null ? 'انتخاب کنید' : date.formatter.y+"/"+date.formatter.m+"/"+date.formatter.d, // <<< فرمت زیباتر تاریخ
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFetchButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: _isLoading ? const SizedBox.shrink() : const Icon(Icons.bar_chart_rounded, color: Colors.white),
        label: _isLoading
            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
            : const Text('نمایش گزارش'),
        onPressed: _isLoading ? null : _fetchReport,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 18, fontFamily: 'Vazir', fontWeight: FontWeight.bold),
          elevation: 4,
          shadowColor: primaryColor.withOpacity(0.4),
        ),
      ),
    );
  }

  Widget _buildResultsSection() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SizeTransition(sizeFactor: animation, child: child),
        );
      },
      child: _isLoading
          ? const Center(key: ValueKey('loading'), child: CircularProgressIndicator(color: primaryColor))
          : _errorMessage != null
          ? _buildErrorState()
          : _statsData == null
          ? _buildInitialState()
          : _buildSuccessState(),
    );
  }

  Widget _buildInitialState() {
    return Container(
      key: const ValueKey('initial'),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.insights_rounded, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            'برای مشاهده گزارش، یک بازه زمانی انتخاب کرده و دکمه "نمایش گزارش" را بزنید.',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      key: const ValueKey('error'),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 60, color: Colors.redAccent),
          const SizedBox(height: 16),
          const Text(
            'خطا در دریافت اطلاعات',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.redAccent),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? "یک مشکل نامشخص رخ داده است.",
            style: const TextStyle(color: Colors.black54, fontSize: 15),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState() {
    final currencyFormat = NumberFormat.currency(locale: 'fa_IR', symbol: ' تومان', decimalDigits: 0);
    // <<< تعریف لیست رنگ‌های هماهنگ برای نمودار >>>
    final List<Color> barColors = [
      primaryColor,
      accentColor,
      primaryColor.withOpacity(0.7),
      accentColor.withOpacity(0.7),
      Colors.grey.shade600,
    ];

    return Column(
      key: ValueKey('success'),
      children: [
        _buildTotalStatsGrid(currencyFormat),
        const SizedBox(height: 24),
        if (_statsData!.hotels.isNotEmpty) ...[
          _buildBarChartSection(barColors),
          const SizedBox(height: 24),
          _buildHotelBreakdownList(currencyFormat, barColors),
        ] else
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(child: Text("در این بازه زمانی، هیچ رزروی ثبت نشده است.", style: TextStyle(fontSize: 16))),
          ),
      ],
    );
  }

  Widget _buildTotalStatsGrid(NumberFormat currencyFormat) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.7, // <<< تنظیم نسبت برای زیبایی بیشتر
      children: [
        _buildStatCard(
            "جمع درآمد", currencyFormat.format(_statsData!.totalRevenue), Icons.monetization_on_outlined, Colors.green.shade600),
        _buildStatCard(
            "تعداد رزروها", _statsData!.totalReservations.toString(), Icons.book_online_outlined, Colors.blue.shade600),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChartSection(List<Color> barColors) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "مقایسه درآمد هتل‌ها",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final hotel = _statsData!.hotels[groupIndex];
                            return BarTooltipItem(
                              '${hotel.hotelName}\n',
                              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                              children: [
                                TextSpan(
                                  text: NumberFormat.currency(locale: 'fa_IR', symbol: ' تومان', decimalDigits: 0).format(rod.toY),
                                  style: const TextStyle(color: Colors.yellow, fontWeight: FontWeight.w500, fontSize: 13),
                                ),
                              ],
                            );
                          }
                      )
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40, // <<< فضای بیشتر برای نام‌های طولانی‌تر
                        // ==================== شروع اصلاحیه اصلی سایز ====================
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final index = value.toInt();
                          if (index >= _statsData!.hotels.length) return const SizedBox.shrink();

                          final hotel = _statsData!.hotels[index];
                          // <<< نمایش نام هتل به صورت امن و خوانا >>>
                          final String text = hotel.hotelName;

                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              text,
                              style: const TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        },
                        // ===================== پایان اصلاحیه اصلی سایز =====================
                      ),
                    ),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: _statsData!.hotels
                      .asMap()
                      .map((index, hotel) => MapEntry(
                      index,
                      BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                              toY: hotel.revenue,
                              color: barColors[index % barColors.length], // <<< استفاده از پالت رنگی هماهنگ
                              width: 22,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(6),
                                topRight: Radius.circular(6),
                              )
                          ),
                        ],
                      )))
                      .values
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHotelBreakdownList(NumberFormat currencyFormat, List<Color> barColors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
          child: Text(
            "لیست جزئیات فروش",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _statsData!.hotels.length,
          itemBuilder: (context, index) {
            final hotel = _statsData!.hotels[index];
            final color = barColors[index % barColors.length]; // <<< هماهنگ‌سازی رنگ با نمودار
            return Card(
              elevation: 1,
              margin: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                leading: CircleAvatar(
                    backgroundColor: color.withOpacity(0.15),
                    foregroundColor: color,
                    child: Text((index + 1).toString(), style: const TextStyle(fontWeight: FontWeight.bold))
                ),
                title: Text(hotel.hotelName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                subtitle: Text('تعداد رزرو: ${hotel.reservationCount}'),
                trailing: Text(
                  currencyFormat.format(hotel.revenue),
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}