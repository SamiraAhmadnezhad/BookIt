// lib/pages/manager_pages/reports_page.dart

import 'dart:math';
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
  // === تعریف پالت رنگی ===
  static const Color primaryColor = Color(0xFF542545);
  static const Color accentColor = Color(0xFF8e44ad);
  static const Color compareColor = Color(0xFF00897B); // رنگ جدید برای حالت مقایسه
  static const Color backgroundColor = Color(0xFFF4F6F9);
  static const Color cardColor = Colors.white;

  // === متغیرهای وضعیت ===
  final ReportService _reportService = ReportService();
  bool _isLoading = false;
  String? _errorMessage;

  // -- حالت مقایسه --
  bool _isCompareMode = false;

  // -- بازه زمانی اول --
  Jalali? _startDateJalali;
  Jalali? _endDateJalali;
  ReservationStats? _statsData;

  // -- بازه زمانی دوم (برای مقایسه) --
  Jalali? _compareStartDateJalali;
  Jalali? _compareEndDateJalali;
  ReservationStats? _compareStatsData;

  // === توابع منطقی ===
  Future<void> _selectShamsiDate(BuildContext context, {required bool isStartDate, bool isCompare = false}) async {
    Jalali? initial = Jalali.now();
    if (isCompare) {
      initial = isStartDate ? _compareStartDateJalali : _compareEndDateJalali;
    } else {
      initial = isStartDate ? _startDateJalali : _endDateJalali;
    }

    final Jalali? picked = await showCustomShamsiDatePickerDialog(
      context,
      initialDate: initial ?? Jalali.now(),
      firstDate: Jalali(Jalali.now().year - 10),
      lastDate: Jalali(Jalali.now().year + 2),
      titleText: isStartDate ? "انتخاب تاریخ شروع" : "انتخاب تاریخ پایان",
    );
    if (picked != null) {
      setState(() {
        if (isCompare) {
          isStartDate ? _compareStartDateJalali = picked : _compareEndDateJalali = picked;
        } else {
          isStartDate ? _startDateJalali = picked : _endDateJalali = picked;
        }
      });
    }
  }

  bool _validateDates(Jalali? start, Jalali? end, String periodName) {
    if (start == null || end == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('لطفاً بازه زمانی "$periodName" را کامل انتخاب کنید.')));
      return false;
    }
    if (start.toGregorian().toDateTime().isAfter(end.toGregorian().toDateTime())) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('در بازه "$periodName"، تاریخ شروع نمی‌تواند بعد از تاریخ پایان باشد.')));
      return false;
    }
    return true;
  }

  Future<void> _fetchReport() async {
    // پاک کردن نتایج قبلی
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _statsData = null;
      _compareStatsData = null;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    final token = authService.token;
    if (token == null) {
      setState(() { _isLoading = false; _errorMessage = "خطای احراز هویت. لطفاً دوباره وارد شوید."; });
      return;
    }

    // اعتبارسنجی بازه اول
    if (!_validateDates(_startDateJalali, _endDateJalali, "اول")) return;

    try {
      if (_isCompareMode) {
        // اعتبارسنجی بازه دوم
        if (!_validateDates(_compareStartDateJalali, _compareEndDateJalali, "دوم")) return;

        // اجرای همزمان دو درخواست
        final results = await Future.wait([
          _reportService.fetchReservationStats(
            startDate: _startDateJalali!.toGregorian().toDateTime(),
            endDate: _endDateJalali!.toGregorian().toDateTime(),
            token: token,
          ),
          _reportService.fetchReservationStats(
            startDate: _compareStartDateJalali!.toGregorian().toDateTime(),
            endDate: _compareEndDateJalali!.toGregorian().toDateTime(),
            token: token,
          ),
        ]);
        setState(() {
          _statsData = results[0];
          _compareStatsData = results[1];
        });
      } else {
        // اجرای درخواست تکی
        final stats = await _reportService.fetchReservationStats(
          startDate: _startDateJalali!.toGregorian().toDateTime(),
          endDate: _endDateJalali!.toGregorian().toDateTime(),
          token: token,
        );
        setState(() => _statsData = stats);
      }
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
        title: const Text('داشبورد گزارش فروش', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "انتخاب بازه زمانی",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: primaryColor),
                ),
                Row(
                  children: [
                    Text("مقایسه", style: TextStyle(color: Colors.grey[700])),
                    const SizedBox(width: 4),
                    Switch(
                      value: _isCompareMode,
                      onChanged: (value) => setState(() => _isCompareMode = value),
                      activeColor: primaryColor,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDatePickerRow("بازه اول", _startDateJalali, _endDateJalali, (ctx, isStart) => _selectShamsiDate(context, isStartDate: isStart)),

            // بخش انتخاب بازه دوم که با انیمیشن ظاهر می‌شود
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _isCompareMode
                  ? Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: _buildDatePickerRow(
                  "بازه دوم (مقایسه)",
                  _compareStartDateJalali,
                  _compareEndDateJalali,
                      (ctx, isStart) => _selectShamsiDate(context, isStartDate: isStart, isCompare: true),
                  isCompare: true,
                ),
              )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePickerRow(String title, Jalali? startDate, Jalali? endDate, Function(BuildContext, bool) onTap, {bool isCompare = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isCompare ? compareColor : Colors.black87)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildDatePickerTile('از تاریخ', startDate, (ctx) => onTap(ctx, true), isCompare: isCompare)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Icon(Icons.arrow_forward, color: Colors.grey),
            ),
            Expanded(child: _buildDatePickerTile('تا تاریخ', endDate, (ctx) => onTap(ctx, false), isCompare: isCompare)),
          ],
        ),
      ],
    );
  }

  Widget _buildDatePickerTile(String title, Jalali? date, Function(BuildContext) onTap, {required bool isCompare}) {
    return InkWell(
      onTap: () => onTap(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isCompare ? compareColor.withOpacity(0.5) : Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined, color: isCompare ? compareColor : primaryColor, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(
                    date == null ? 'انتخاب' : date.formatter.y+"/"+date.formatter.m+"/"+date.formatter.d,
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

  // دکمه نمایش گزارش (بدون تغییر)
  Widget _buildFetchButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: _isLoading ? const SizedBox.shrink() : const Icon(Icons.bar_chart_rounded, color: Colors.white),
        label: _isLoading
            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
            : const Text('نمایش گزارش'),
        onPressed: (_isLoading || _startDateJalali == null || _endDateJalali == null || (_isCompareMode && (_compareStartDateJalali == null || _compareEndDateJalali == null))) ? null : _fetchReport,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          disabledBackgroundColor: Colors.grey.shade400,
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
        return FadeTransition(opacity: animation, child: SizeTransition(sizeFactor: animation, child: child));
      },
      child: _isLoading
          ? const Center(key: ValueKey('loading'), child: CircularProgressIndicator(color: primaryColor))
          : _errorMessage != null
          ? _buildErrorState()
          : (_statsData == null)
          ? _buildInitialState()
          : _buildSuccessState(),
    );
  }

  // حالت اولیه (بدون تغییر)
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
            'برای مشاهده گزارش، یک یا دو بازه زمانی انتخاب کرده و دکمه "نمایش گزارش" را بزنید.',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // حالت خطا (بدون تغییر)
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

  // ویجت اصلی نمایش نتایج
  Widget _buildSuccessState() {
    final currencyFormat = NumberFormat.currency(locale: 'fa_IR', symbol: ' تومان', decimalDigits: 0);

    // بررسی وجود هتل در هر دو بازه
    final bool hasAnyHotelData = _statsData!.hotels.isNotEmpty || (_compareStatsData?.hotels.isNotEmpty ?? false);

    return Column(
      key: const ValueKey('success'),
      children: [
        // حل مشکل سایز با استفاده از Column به جای GridView
        _isCompareMode && _compareStatsData != null
            ? _buildCompareTotalStats(currencyFormat)
            : _buildSingleTotalStats(currencyFormat),
        const SizedBox(height: 24),
        if (hasAnyHotelData) ...[
          _isCompareMode && _compareStatsData != null
              ? _buildCompareBarChartSection()
              : _buildSingleBarChartSection(),
          const SizedBox(height: 24),
          // بخش لیست جزئیات هنوز می‌تواند تک حالته باشد یا مقایسه‌ای شود (برای سادگی فعلا تکی)
          _buildHotelBreakdownList(currencyFormat),
        ] else
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.orange.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
            child: const Center(child: Text("در بازه‌های زمانی انتخاب شده، هیچ رزروی ثبت نشده است.", style: TextStyle(fontSize: 16))),
          ),
      ],
    );
  }

  // === ویجت‌های نمایش آمار (تکی و مقایسه‌ای) ===

  // -- حالت تکی
  Widget _buildSingleTotalStats(NumberFormat currencyFormat) {
    return Column(
      children: [
        _buildStatCard(
            label: "جمع درآمد", value: currencyFormat.format(_statsData!.totalRevenue), icon: Icons.monetization_on_outlined, color: Colors.green.shade600),
        const SizedBox(height: 16),
        _buildStatCard(
            label: "تعداد رزروها", value: _statsData!.totalReservations.toString(), icon: Icons.book_online_outlined, color: Colors.blue.shade600),
      ],
    );
  }

  // -- حالت مقایسه‌ای
  Widget _buildCompareTotalStats(NumberFormat currencyFormat) {
    return Column(
      children: [
        _buildCompareStatCard(
          label: "جمع درآمد",
          value1: _statsData!.totalRevenue,
          value2: _compareStatsData!.totalRevenue,
          formatter: currencyFormat,
          icon: Icons.monetization_on_outlined,
          color: Colors.green.shade600,
        ),
        const SizedBox(height: 16),
        _buildCompareStatCard(
          label: "تعداد رزروها",
          value1: _statsData!.totalReservations.toDouble(),
          value2: _compareStatsData!.totalReservations.toDouble(),
          formatter: NumberFormat.decimalPattern('fa_IR'), // فرمت‌کننده برای عدد صحیح
          icon: Icons.book_online_outlined,
          color: Colors.blue.shade600,
        ),
      ],
    );
  }

  // کارت آمار تکی
  Widget _buildStatCard({required String label, required String value, required IconData icon, required Color color}) {
    return Card(
      elevation: 2, color: cardColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // کارت آمار مقایسه‌ای
  Widget _buildCompareStatCard({required String label, required double value1, required double value2, required NumberFormat formatter, required IconData icon, required Color color}) {
    final double change = (value1 == 0) ? (value2 > 0 ? 100.0 : 0.0) : ((value2 - value1) / value1) * 100;

    return Card(
      elevation: 2, color: cardColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: color, size: 32),
                ),
                const SizedBox(width: 16),
                Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                _buildPercentageChange(change),
              ],
            ),
            const Divider(height: 24, thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildValueColumn("بازه اول", formatter.format(value1), primaryColor),
                _buildValueColumn("بازه دوم", formatter.format(value2), compareColor),
              ],
            )
          ],
        ),
      ),
    );
  }

  // === ویجت‌های کمکی برای کارت‌های مقایسه ===
  Widget _buildValueColumn(String title, String value, Color color) {
    return Column(
      children: [
        Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildPercentageChange(double change) {
    if (change.isInfinite || change.isNaN) {
      return const SizedBox.shrink();
    }
    final bool isIncrease = change > 0;
    final bool isNeutral = change == 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isNeutral ? Colors.grey.shade200 : (isIncrease ? Colors.green.shade50 : Colors.red.shade50),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isNeutral ? Icons.remove : (isIncrease ? Icons.arrow_upward : Icons.arrow_downward),
            size: 16,
            color: isNeutral ? Colors.grey.shade700 : (isIncrease ? Colors.green.shade700 : Colors.red.shade700),
          ),
          const SizedBox(width: 4),
          Text(
            '${change.abs().toStringAsFixed(1)}%',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isNeutral ? Colors.grey.shade800 : (isIncrease ? Colors.green.shade800 : Colors.red.shade800),
            ),
          ),
        ],
      ),
    );
  }

  // === ویجت‌های نمودار (تکی و مقایسه‌ای) ===

  // -- نمودار تکی
  Widget _buildSingleBarChartSection() {
    final List<Color> barColors = [ primaryColor, accentColor, primaryColor.withOpacity(0.7), accentColor.withOpacity(0.7), Colors.grey.shade600,];
    return Card(
      elevation: 4, shadowColor: Colors.black.withOpacity(0.1), color: cardColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("مقایسه درآمد هتل‌ها", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: primaryColor)),
            const SizedBox(height: 28),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  // ... (کد نمودار تکی شما، بدون تغییر)
                  barGroups: _statsData!.hotels.asMap().map((index, hotel) => MapEntry(index, BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: hotel.revenue,
                        color: barColors[index % barColors.length],
                        width: 22,
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
                      ),
                    ],
                  ))).values.toList(),
                  // ... بقیه تنظیمات
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -- نمودار مقایسه‌ای (گروهی)
  // -- نمودار مقایسه‌ای (گروهی)
  Widget _buildCompareBarChartSection() {
    // ایجاد لیست جامع از همه هتل‌ها در هر دو بازه
    final allHotelNames = {..._statsData!.hotels.map((h) => h.hotelName), ..._compareStatsData!.hotels.map((h) => h.hotelName)}.toList();

    return Card(
      elevation: 4, shadowColor: Colors.black.withOpacity(0.1), color: cardColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("مقایسه درآمد هتل‌ها", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: primaryColor)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildChartLegend("بازه اول", primaryColor),
                const SizedBox(width: 24),
                _buildChartLegend("بازه دوم", compareColor),
              ],
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barTouchData: BarTouchData(touchTooltipData: BarTouchTooltipData()), // Tooltip ساده
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final index = value.toInt();
                          if (index >= allHotelNames.length) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(allHotelNames[index], style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 11), overflow: TextOverflow.ellipsis),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: allHotelNames.asMap().entries.map((entry) {
                    final index = entry.key;
                    final hotelName = entry.value;

                    // <<< اصلاح شد: اضافه کردن 'hotelId' الزامی در بخش orElse
                    final hotel1 = _statsData!.hotels.firstWhere((h) => h.hotelName == hotelName, orElse: () => HotelStats(hotelId: 1, hotelName: hotelName, revenue: 0, reservationCount: 0));
                    final hotel2 = _compareStatsData!.hotels.firstWhere((h) => h.hotelName == hotelName, orElse: () => HotelStats(hotelId: 2, hotelName: hotelName, revenue: 0, reservationCount: 0));

                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(toY: hotel1.revenue, color: primaryColor, width: 15, borderRadius: BorderRadius.circular(4)),
                        BarChartRodData(toY: hotel2.revenue, color: compareColor, width: 15, borderRadius: BorderRadius.circular(4)),
                      ],
                      showingTooltipIndicators: [0, 1],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartLegend(String text, Color color) {
    return Row(
      children: [
        Container(width: 16, height: 16, color: color),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }

  // بخش لیست جزئیات (برای سادگی فقط اطلاعات بازه اول را نمایش می‌دهد، اما می‌توان آن را هم مقایسه‌ای کرد)
  Widget _buildHotelBreakdownList(NumberFormat currencyFormat) {
    // ... این بخش می‌تواند مثل قبل باقی بماند یا برای نمایش مقایسه توسعه داده شود ...
    final hotels = _statsData!.hotels;
    if (hotels.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
          child: Text("جزئیات فروش (بازه اول)", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: primaryColor)),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: hotels.length,
          itemBuilder: (context, index) {
            final hotel = hotels[index];
            final color = [primaryColor, accentColor, compareColor][index % 3]; // استفاده از رنگ‌های متنوع
            return Card(
              elevation: 1, margin: const EdgeInsets.symmetric(vertical: 6), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                leading: CircleAvatar(
                    backgroundColor: color.withOpacity(0.15),
                    foregroundColor: color,
                    child: Text((index + 1).toString(), style: const TextStyle(fontWeight: FontWeight.bold))),
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