import 'package:flutter/material.dart';

class FilterChipRow extends StatelessWidget { // تبدیل به StatelessWidget چون دیگر state داخلی ندارد
  final List<String> items; // تغییر نام از chips به items برای وضوح بیشتر

  const FilterChipRow({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink(); // یا Container()
    }

    return SizedBox(
      height: 40, // ارتفاع مورد نظر برای ردیف متن‌ها، می‌توانید تنظیم کنید
      child: ListView.builder( // استفاده از ListView.builder برای بهینگی بهتر
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0), // پدینگ راست و چپ برای کل لیست
        itemCount: items.length,
        itemBuilder: (context, index) {
          final label = items[index];
          return Padding(
           padding: EdgeInsetsDirectional.only(
              start: index == 0 ? 0 : 8.0,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0), // پدینگ داخلی هر آیتم
              decoration: BoxDecoration(
                color: Colors.white, // رنگ پس‌زمینه هر آیتم
                borderRadius: BorderRadius.circular(20.0), // گرد کردن گوشه‌ها
              ),
              child: Center( // برای وسط‌چین کردن متن در کانتینر
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.black, // رنگ متن
                    fontSize: 13, // اندازه فونت
                    fontFamily: 'Vazirmatn', // فونت
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}