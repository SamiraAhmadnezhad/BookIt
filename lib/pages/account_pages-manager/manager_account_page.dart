import 'package:flutter/material.dart';

// TODO: این مدل‌ها را بر اساس داده‌های واقعی سرور خود تکمیل یا جایگزین کنید
class ManagerProfileModel {
  final String name;
  final String email;
  final String? avatarUrl;

  ManagerProfileModel({required this.name, required this.email, this.avatarUrl});
// TODO: factory ManagerProfileModel.fromJson(Map<String, dynamic> json)
}

class RuleModel {
  final String id;
  final String title; // مثلا "1. قانون اول"
  final String description; // "توضیحات"

  RuleModel({required this.id, required this.title, required this.description});
// TODO: factory RuleModel.fromJson(Map<String, dynamic> json)
}

class ReviewModel {
  final String id;
  final String date;
  final String userName;
  final String roomInfo; // مثلا "اتاق ۵ تخته"
  final List<String> positivePoints;
  final List<String> negativePoints;
  final double rating;
  String? managerReplyText; // پاسخ مدیر، می‌تواند null باشد

  ReviewModel({
    required this.id,
    required this.date,
    required this.userName,
    required this.roomInfo,
    required this.positivePoints,
    required this.negativePoints,
    required this.rating,
    this.managerReplyText,
  });
// TODO: factory ReviewModel.fromJson(Map<String, dynamic> json)
}


class ManagerAccountPage extends StatefulWidget {
  const ManagerAccountPage({super.key});

  @override
  State<ManagerAccountPage> createState() => _ManagerAccountPageState();
}

class _ManagerAccountPageState extends State<ManagerAccountPage> {
  final Color primaryPurple = const Color(0xFF542545);
  String _selectedTab = 'قوانین و مقررات'; // تب پیش‌فرض

  ManagerProfileModel? _managerProfile;
  List<RuleModel> _rules = [];
  List<ReviewModel> _reviews = [];

  bool _isLoadingProfile = true;
  bool _isLoadingRules = true;
  bool _isLoadingReviews = false; // فقط وقتی تب فعال می‌شود لود می‌شود

  String? _replyingToReviewId; // ID نظری که در حال پاسخ به آن هستیم
  final TextEditingController _replyController = TextEditingController();
  final FocusNode _replyFocusNode = FocusNode();


  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    await _fetchManagerProfile();
    if (_selectedTab == 'قوانین و مقررات') {
      await _fetchRules();
    } else if (_selectedTab == 'پاسخگویی به نظرات') {
      await _fetchReviews();
    }
  }

  // TODO: تابع دریافت اطلاعات پروفایل مدیر از سرور
  Future<void> _fetchManagerProfile() async {
    setState(() { _isLoadingProfile = true; });
    try {
      await Future.delayed(const Duration(seconds: 1));
      _managerProfile = ManagerProfileModel(name: 'تقی تقوی', email: 'taghitaghavi@gmail.com');
    } catch (e) { /* TODO: Handle error */ }
    finally { if (mounted) setState(() { _isLoadingProfile = false; }); }
  }

  // TODO: تابع دریافت قوانین و مقررات از سرور
  Future<void> _fetchRules() async {
    if (_selectedTab != 'قوانین و مقررات' && _rules.isNotEmpty && !_isLoadingRules) return;
    setState(() { _isLoadingRules = true; });
    try {
      await Future.delayed(const Duration(seconds: 1));
      _rules = [
        RuleModel(id: '1', title: '1. قانون اول', description: 'توضیحات مربوط به قانون اول که می‌تواند طولانی باشد و چند خط را اشغال کند.'),
        RuleModel(id: '2', title: '2. قانون دوم', description: 'توضیحات قانون دوم در اینجا قرار می‌گیرد.'),
        RuleModel(id: '3', title: '3. قانون سوم', description: 'جزئیات بیشتر برای قانون سوم.'),
      ];
    } catch (e) { /* TODO: Handle error */ }
    finally { if (mounted) setState(() { _isLoadingRules = false; }); }
  }

  // TODO: تابع دریافت نظرات از سرور
  Future<void> _fetchReviews() async {
    if (_selectedTab != 'پاسخگویی به نظرات' && _reviews.isNotEmpty && !_isLoadingReviews) return;
    setState(() { _isLoadingReviews = true; });
    try {
      await Future.delayed(const Duration(seconds: 1));
      _reviews = [
        ReviewModel(id: 'rev1', date: '۱۴ تیر ۱۴۰۲', userName: 'اسم اشخاص', roomInfo: 'اتاق ۵ تخته', positivePoints: ['نکته مثبت اول', 'نکته مثبت دوم خیلی طولانی که ممکن است در چند خط نمایش داده شود'], negativePoints: ['نکته منفی اول'], rating: 4.5),
        ReviewModel(id: 'rev2', date: '۱۲ تیر ۱۴۰۲', userName: 'کاربر دیگر', roomInfo: 'سوییت', positivePoints: ['تمیزی عالی بود'], negativePoints: ['صبحانه می‌توانست بهتر باشد', 'صدای اتاق کناری کمی می‌آمد'], rating: 4.0, managerReplyText: 'از نظر شما سپاسگزاریم. موارد ذکر شده بررسی خواهد شد.'),
        ReviewModel(id: 'rev3', date: '۱۰ تیر ۱۴۰۲', userName: 'مسافر راضی', roomInfo: 'اتاق ۲ تخته', positivePoints: ['همه چیز عالی بود', 'برخورد پرسنل فوق‌العاده'], negativePoints: [], rating: 5.0),
      ];
    } catch (e) { /* TODO: Handle error */ }
    finally { if (mounted) setState(() { _isLoadingReviews = false; }); }
  }

  // TODO: تابع برای ذخیره پاسخ مدیر به نظر در سرور
  Future<void> _submitReply(String reviewId, String replyText) async {
    if (replyText.isEmpty) return;
    // TODO: ارسال پاسخ به سرور
    print('Submitting reply for $reviewId: $replyText');
    await Future.delayed(const Duration(seconds: 1)); // شبیه‌سازی API call
    setState(() {
      final index = _reviews.indexWhere((r) => r.id == reviewId);
      if (index != -1) {
        _reviews[index].managerReplyText = replyText;
      }
      _replyingToReviewId = null; // بستن فرم پاسخ
      _replyController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('پاسخ با موفقیت ثبت شد.'), backgroundColor: Colors.green,));
  }


  void _handleTabChange(String newTab) {
    if (_selectedTab != newTab) {
      setState(() {
        _selectedTab = newTab;
        _replyingToReviewId = null; // بستن فرم پاسخ هنگام تغییر تب
        _replyController.clear();
        // ریست کردن وضعیت لودینگ سایر تب‌ها (در صورت نیاز)
      });
      if (newTab == 'قوانین و مقررات' && (_rules.isEmpty || _isLoadingRules)) {
        _fetchRules();
      } else if (newTab == 'پاسخگویی به نظرات' && (_reviews.isEmpty || _isLoadingReviews)) {
        _fetchReviews();
      }
    }
  }

  // TODO: تابع برای هدایت به صفحه ویرایش اطلاعات مدیر
  void _editManagerProfile() {
    // Navigator.of(context).push(MaterialPageRoute(builder: (context) => EditManagerProfilePage(...)));
    print('Edit manager profile tapped');
  }

  // TODO: تابع برای هدایت به صفحه ویرایش قوانین یا نمایش دیالوگ
  void _editRules() {
    print('Edit rules tapped');
  }

  void _toggleReplyForm(String reviewId) {
    setState(() {
      if (_replyingToReviewId == reviewId) {
        _replyingToReviewId = null; // بستن فرم اگر دوباره کلیک شد
        _replyController.clear();
        FocusScope.of(context).unfocus(); // بستن کیبورد
      } else {
        _replyingToReviewId = reviewId;
        _replyController.clear();
        // تاخیر کوچک برای اطمینان از رندر شدن فرم قبل از فوکوس
        Future.delayed(const Duration(milliseconds: 100), () {
          FocusScope.of(context).requestFocus(_replyFocusNode);
        });
      }
    });
  }


  Future<void> _logoutUser() async { /* TODO: Implement */ }

  Widget _buildTabButton(String title) {
    bool isSelected = _selectedTab == title;
    return Expanded(
      child: GestureDetector(
        onTap: () => _handleTabChange(title),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12), margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(color: isSelected ? primaryPurple : Colors.white, borderRadius: BorderRadius.circular(8), border: isSelected ? null : Border.all(color: Colors.grey.shade300)),
          child: Text(title, textAlign: TextAlign.center, style: TextStyle(color: isSelected ? Colors.white : primaryPurple, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white, elevation: 0, automaticallyImplyLeading: false,
          leading: IconButton(icon: Icon(Icons.notifications_none_outlined, color: primaryPurple, size: 28), onPressed: () { /* TODO: Notification action */ }),
          actions: [Padding(padding: const EdgeInsets.only(left: 16.0, right: 8.0, top: 8.0, bottom: 8.0), child: ElevatedButton(onPressed: _logoutUser, style: ElevatedButton.styleFrom(backgroundColor: primaryPurple, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))), child: const Text('خروج از حساب کاربری', style: TextStyle(fontSize: 12))))],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: _isLoadingProfile ? const Center(child: CircularProgressIndicator()) : Column(children: [Icon(Icons.account_circle, size: 100, color: primaryPurple.withOpacity(0.8)), const SizedBox(height: 12), Text(_managerProfile?.name ?? 'مدیر', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)), const SizedBox(height: 4), Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(_managerProfile?.email ?? '', style: TextStyle(fontSize: 14, color: Colors.grey[600])), const SizedBox(width: 4), if (_managerProfile?.email.isNotEmpty ?? false) Icon(Icons.check_circle, color: Colors.green[600], size: 16)])]),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: const BorderRadius.only(topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0))),
                child: ListView( // ListView اصلی برای اسکرول دکمه ویرایش، تب‌ها و محتوای تب‌ها
                  padding: const EdgeInsets.only(top:16.0, bottom: 16.0),
                  children: [
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0), child: InkWell(onTap: _editManagerProfile, child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('ویرایش اطلاعات', style: TextStyle(fontSize: 15, color: Colors.black87)), Icon(Icons.keyboard_arrow_down, color: Colors.grey[600])])))),
                    const SizedBox(height: 20),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0), child: Row(children: [_buildTabButton('پاسخگویی به نظرات'), _buildTabButton('قوانین و مقررات')])),
                    const SizedBox(height: 24),
                    _buildSelectedTabContent(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedTabContent() {
    if (_selectedTab == 'قوانین و مقررات') {
      if (_isLoadingRules) return const Center(child: CircularProgressIndicator());
      if (_rules.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(30.0), child: Text('هیچ قانونی ثبت نشده است.', style: TextStyle(fontSize: 16, color: Colors.grey))));

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('قوانین و مقرراتی که مسافران برای اقامت در هتل موظفند رعایت کنند:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
                TextButton.icon(
                  onPressed: _editRules,
                  icon: Icon(Icons.edit_outlined, size: 18, color: primaryPurple),
                  label: Text('ویرایش', style: TextStyle(color: primaryPurple, fontSize: 13)),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                )
              ],
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _rules.length,
              itemBuilder: (context, index) {
                final rule = _rules[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text('${rule.title}: ${rule.description}', style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5)),
                );
              },
            ),
          ],
        ),
      );
    }
    else if (_selectedTab == 'پاسخگویی به نظرات') {
      if (_isLoadingReviews) return const Center(child: CircularProgressIndicator());
      if (_reviews.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(30.0), child: Text('هیچ نظری برای پاسخگویی وجود ندارد.', style: TextStyle(fontSize: 16, color: Colors.grey))));

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: _reviews.length,
        itemBuilder: (context, index) {
          final review = _reviews[index];
          return _buildReviewItem(review);
        },
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildReviewItem(ReviewModel review) {
    bool isReplying = _replyingToReviewId == review.id;
    return Column(
      children: [
        Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(review.userName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                    Text(review.date, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
                Text(review.roomInfo, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                const SizedBox(height: 10),
                if (review.positivePoints.isNotEmpty)
                  ...review.positivePoints.map((point) => _buildPointRow(point, true)),
                if (review.negativePoints.isNotEmpty)
                  ...review.negativePoints.map((point) => _buildPointRow(point, false)),

                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [Icon(Icons.thumb_up_alt_outlined, size: 18, color: Colors.grey[700]), const SizedBox(width: 4), Text(review.rating.toString(), style: TextStyle(fontSize: 14, color: Colors.grey[700]))]),
                    TextButton.icon(
                      onPressed: () => _toggleReplyForm(review.id),
                      icon: Icon(Icons.reply_outlined, size: 18, color: primaryPurple),
                      label: Text(review.managerReplyText != null ? 'ویرایش پاسخ' : 'ثبت پاسخ', style: TextStyle(color: primaryPurple, fontSize: 13, fontWeight: FontWeight.w600)),
                      style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
                    ),
                  ],
                ),
                if (review.managerReplyText != null && !isReplying) ...[ // نمایش پاسخ مدیر اگر فرم پاسخ باز نیست
                  const Divider(height: 20, thickness: 0.5),
                  Text('پاسخ شما:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: primaryPurple)),
                  const SizedBox(height: 4),
                  Text(review.managerReplyText!, style: TextStyle(fontSize: 13, color: Colors.grey[800], fontStyle: FontStyle.italic)),
                ]
              ],
            ),
          ),
        ),
        if (isReplying) _buildReplyForm(review),
      ],
    );
  }

  Widget _buildPointRow(String point, bool isPositive) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(isPositive ? Icons.add_circle_outline : Icons.remove_circle_outline, size: 16, color: isPositive ? Colors.green[600] : Colors.red[600]),
          const SizedBox(width: 6),
          Expanded(child: Text(point, style: TextStyle(fontSize: 13, color: Colors.grey[800]))),
        ],
      ),
    );
  }

  Widget _buildReplyForm(ReviewModel review) {
    if (_replyingToReviewId != review.id) return const SizedBox.shrink();

    // اگر نظری قبلا پاسخ داده شده، متن آن را در کنترلر قرار بده
    if (review.managerReplyText != null && _replyController.text.isEmpty && _replyFocusNode.hasFocus == false) {
      _replyController.text = review.managerReplyText!;
    }


    return Container(
      margin: const EdgeInsets.only(bottom: 20.0, top: 0), // فاصله زیر فرم پاسخ
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 1, blurRadius: 3)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('پاسخ خود را به نظر فوق بنویسید:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
          const SizedBox(height: 12),
          TextField(
            controller: _replyController,
            focusNode: _replyFocusNode,
            maxLines: 3,
            minLines: 3,
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(
              hintText: 'پاسخ شما...',
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.all(10),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _submitReply(review.id, _replyController.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryPurple,
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
              child: const Text('ثبت پاسخ', style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

}