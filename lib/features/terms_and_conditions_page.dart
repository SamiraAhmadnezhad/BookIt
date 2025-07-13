import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// --- پالت رنگی تعریف شده توسط شما ---
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
// ------------------------------------

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.lightGrey,
        appBar: AppBar(
          title: const Text('قوانین و مقررات'),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 1,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                context,
                'مقدمه و شرایط کلی',
                [
                  'به اپلیکیشن رزرو هتل «بوکیت» خوش آمدید. استفاده شما از این اپلیکیشن به منزله پذیرش کامل تمامی شرایط و قوانین ذکر شده در این صفحه است.',
                  'این قوانین ممکن است در طول زمان تغییر کنند و استفاده مستمر شما از اپلیکیشن به معنای پذیرش تغییرات جدید خواهد بود.',
                ],
              ),
              _buildSection(
                context,
                'حساب کاربری',
                [
                  'برای استفاده از تمامی امکانات بوکیت، از جمله رزرو، کاربر باید با ارائه اطلاعات صحیح و معتبر ثبت‌نام کند.',
                  'مسئولیت حفظ و نگهداری از نام کاربری و رمز عبور بر عهده کاربر است و بوکیت هیچ مسئولیتی در قبال سوءاستفاده از حساب کاربری شما ندارد.',
                  'هر کاربر تنها مجاز به داشتن یک حساب کاربری است و بوکیت می‌تواند حساب‌های کاربری جعلی یا تکراری را مسدود کند.',
                ],
              ),
              _buildSection(
                context,
                'قوانین رزرو',
                [
                  'رزرو اتاق تنها پس از پرداخت موفق و دریافت تأییدیه از سوی بوکیت نهایی محسوب می‌شود.',
                  'ارائه کارت شناسایی معتبر (کارت ملی یا شناسنامه) هنگام مراجعه به هتل الزامی است و هتل از پذیرش افراد بدون مدارک شناسایی معذور است.',
                  'قیمت‌های نمایش داده شده در اپلیکیشن نهایی بوده و شامل تمام عوارض و مالیات‌ها می‌باشد.',
                ],
              ),
              _buildSection(
                context,
                'قوانین استرداد و لغو رزرو',
                [
                  'قوانین لغو رزرو و استرداد وجه برای هر هتل و هر نوع اتاق ممکن است متفاوت باشد. این قوانین به طور کامل در صفحه جزئیات هتل و قبل از پرداخت نهایی به شما نمایش داده می‌شود.',
                  'در صورت لغو رزرو، مبلغ جریمه طبق قوانین هتل از مبلغ پرداختی کسر و مابقی آن طی ۷ الی ۱۴ روز کاری به حساب شما بازگردانده خواهد شد.',
                  'برخی از پیشنهادها و رزروهای تخفیف‌دار ممکن است غیرقابل استرداد (Non-refundable) باشند که این موضوع در زمان رزرو به اطلاع شما خواهد رسید.',
                ],
              ),
              // بخش نحوه لینک‌دار کردن متن
              _buildLinkExampleSection(context),
            ],
          ),
        ),
      ),
    );
  }

  // ویجت کمکی برای ساختن هر بخش از قوانین
  Widget _buildSection(
      BuildContext context, String title, List<String> paragraphs) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.headlineSmall?.copyWith(
                color: AppColors.primaryDark, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...paragraphs.map((text) => _buildParagraph(text, context)),
        ],
      ),
    );
  }

  Widget _buildParagraph(String text, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6.0, left: 8.0),
            child: Icon(Icons.circle, size: 8, color: AppColors.primaryLight),
          ),
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.justify,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: AppColors.darkGrey, height: 1.7),
            ),
          ),
        ],
      ),
    );
  }

  // این ویجت برای نمایش مثال لینک‌دار کردن متن است
  Widget _buildLinkExampleSection(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    const String url = 'https://www.google.com';

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'پشتیبانی و اطلاعات بیشتر',
            style: textTheme.headlineSmall?.copyWith(
                color: AppColors.primaryDark, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          RichText(
            textAlign: TextAlign.justify,
            text: TextSpan(
              style: textTheme.bodyLarge
                  ?.copyWith(color: AppColors.darkGrey, height: 1.7),
              children: [
                const TextSpan(
                  text:
                  'برای اطلاعات بیشتر در مورد قوانین یا پیگیری مشکلات، می‌توانید با بخش پشتیبانی ما در تماس باشید. برای مشاهده وب‌سایت ما روی ',
                ),
                TextSpan(
                  text: 'این لینک کلیک کنید.',
                  style: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.bold,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      if (await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(Uri.parse(url));
                      }
                    },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}