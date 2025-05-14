import 'package:flutter/material.dart';

// ... (مدل‌های ManagerProfileModel, ReviewModel بدون تغییر) ...
// TODO: این مدل‌ها را بر اساس داده‌های واقعی سرور خود تکمیل یا جایگزین کنید
class ManagerProfileModel {
  final String name;
  final String email;
  final String? avatarUrl;

  ManagerProfileModel({required this.name, required this.email, this.avatarUrl});
// TODO: factory ManagerProfileModel.fromJson(Map<String, dynamic> json)
}

// RuleModel برای نمایش لازم است، اما برای ویرایش با TextField بزرگ، مستقیما با رشته کار می‌کنیم
class RuleModel {
  String id;
  String title;
  String description;

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
  String _selectedTab = 'قوانین و مقررات';

  ManagerProfileModel? _managerProfile;
  List<RuleModel> _rules = []; // برای نمایش
  String _rulesAsTextForEditing = ""; // برای ذخیره متن خام قوانین هنگام ویرایش
  List<ReviewModel> _reviews = [];

  bool _isLoadingProfile = true;
  bool _isLoadingRules = true;
  bool _isLoadingReviews = false;

  String? _replyingToReviewId;
  final TextEditingController _replyController = TextEditingController();
  final FocusNode _replyFocusNode = FocusNode();

  // برای ویرایش قوانین با یک TextField بزرگ
  bool _isEditingRules = false;
  final TextEditingController _rulesTextController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  @override
  void dispose() {
    _replyController.dispose();
    _replyFocusNode.dispose();
    _rulesTextController.dispose(); // پاکسازی کنترلر قوانین
    super.dispose();
  }

  Future<void> _fetchInitialData() async {
    await _fetchManagerProfile();
    if (_selectedTab == 'قوانین و مقررات') {
      await _fetchRules();
    } else if (_selectedTab == 'پاسخگویی به نظرات') {
      await _fetchReviews();
    }
  }

  Future<void> _fetchManagerProfile() async { /* ... بدون تغییر ... */
    setState(() { _isLoadingProfile = true; });
    try {
      await Future.delayed(const Duration(seconds: 1));
      _managerProfile = ManagerProfileModel(name: 'تقی تقوی', email: 'taghitaghavi@gmail.com');
    } catch (e) { /* TODO: Handle error */ }
    finally { if (mounted) setState(() { _isLoadingProfile = false; }); }
  }

  // تابع برای تبدیل List<RuleModel> به یک رشته برای نمایش در TextField
  String _convertRulesListToText(List<RuleModel> rules) {
    return rules.map((rule) => '${rule.title}: ${rule.description}').join('\n\n'); // دو بار \n برای فاصله بیشتر بین قوانین
  }

  // تابع برای تبدیل متن ویرایش شده به List<RuleModel> (ساده شده، ممکن است نیاز به بهبود داشته باشد)
  List<RuleModel> _convertTextToRulesList(String text) {
    final List<RuleModel> newRules = [];
    final lines = text.split('\n');
    int ruleCounter = 1;
    String currentTitle = "";
    String currentDescription = "";

    for (String line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      // تلاش برای پیدا کردن فرمت "عدد. عنوان: توضیحات"
      RegExpMatch? match = RegExp(r'^(\d+\.\s*[^:]+):\s*(.*)$').firstMatch(line);
      if (match != null && match.groupCount == 2) {
        if (currentTitle.isNotEmpty) { // ذخیره قانون قبلی اگر وجود داشت
          newRules.add(RuleModel(id: 'local${ruleCounter-1}', title: currentTitle.trim(), description: currentDescription.trim()));
          currentDescription = ""; // ریست توضیحات
        }
        currentTitle = match.group(1)!;
        currentDescription = match.group(2)!;
        ruleCounter++;
      } else {
        // اگر فرمت بالا نبود، به توضیحات قانون فعلی اضافه کن
        if (currentTitle.isNotEmpty) { // فقط اگر عنوانی داریم
          currentDescription += (currentDescription.isEmpty ? "" : "\n") + line;
        } else {
          // اگر اولین خط فرمت نداشت، آن را به عنوان قانون اول بدون شماره در نظر بگیر
          currentTitle = "قانون ${ruleCounter}";
          currentDescription = line;
          ruleCounter++;
        }
      }
    }
    // اضافه کردن آخرین قانون خوانده شده
    if (currentTitle.isNotEmpty) {
      newRules.add(RuleModel(id: 'local${ruleCounter-1}', title: currentTitle.trim(), description: currentDescription.trim()));
    }
    return newRules;
  }


  Future<void> _fetchRules() async {
    if (_isEditingRules) return;
    setState(() { _isLoadingRules = true; });
    try {
      await Future.delayed(const Duration(seconds: 1));
      // TODO: از سرور، یا متن خام قوانین را بگیرید یا لیست RuleModel
      // اگر متن خام گرفتید:
      // _rulesAsTextForEditing = "1. قانون اول: توضیحات اولیه.\n\n2. قانون دوم: توضیحات بیشتر.";
      // _rules = _convertTextToRulesList(_rulesAsTextForEditing);
      // یا اگر لیست گرفتید:
      _rules = [
        RuleModel(id: '1', title: '1. قانون اول', description: 'توضیحات مربوط به قانون اول که می‌تواند طولانی باشد و چند خط را اشغال کند.'),
        RuleModel(id: '2', title: '2. قانون دوم', description: 'توضیحات قانون دوم در اینجا قرار می‌گیرد.'),
        RuleModel(id: '3', title: '3. قانون سوم', description: 'جزئیات بیشتر برای قانون سوم.'),
      ];
      _rulesAsTextForEditing = _convertRulesListToText(_rules); // برای نمایش در حالت ویرایش
    } catch (e) { /* TODO: Handle error */ }
    finally { if (mounted) setState(() { _isLoadingRules = false; }); }
  }

  Future<void> _fetchReviews() async { /* ... بدون تغییر ... */
    if (_selectedTab != 'پاسخگویی به نظرات' && _reviews.isNotEmpty && !_isLoadingReviews) return;
    setState(() { _isLoadingReviews = true; });
    try {
      await Future.delayed(const Duration(seconds: 1));
      _reviews = [
        ReviewModel(id: 'rev1', date: '۱۴ تیر ۱۴۰۲', userName: 'اسم اشخاص', roomInfo: 'اتاق ۵ تخته', positivePoints: ['نکته مثبت اول', 'نکته مثبت دوم خیلی طولانی که ممکن است در چند خط نمایش داده شود'], negativePoints: ['نکته منفی اول'], rating: 4.5),
        ReviewModel(id: 'rev2', date: '۱۲ تیر ۱۴۰۲', userName: 'کاربر دیگر', roomInfo: 'سوییت', positivePoints: ['تمیزی عالی بود'], negativePoints: ['صبحانه می‌توانست بهتر باشد', 'صدای اتاق کناری کمی می‌آمد'], rating: 4.0, managerReplyText: 'از نظر شما سپاسگزاریم. موارد ذکر شده بررسی خواهد شد.'),
      ];
    } catch (e) { /* TODO: Handle error */ }
    finally { if (mounted) setState(() { _isLoadingReviews = false; }); }
  }
  Future<void> _submitReply(String reviewId, String replyText) async { /* ... بدون تغییر ... */
    if (replyText.isEmpty) return;
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      final index = _reviews.indexWhere((r) => r.id == reviewId);
      if (index != -1) _reviews[index].managerReplyText = replyText;
      _replyingToReviewId = null; _replyController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('پاسخ با موفقیت ثبت شد.'), backgroundColor: Colors.green,));
  }

  void _handleTabChange(String newTab) { /* ... بدون تغییر در منطق اصلی ... */
    if (_selectedTab != newTab) {
      setState(() {
        _selectedTab = newTab;
        _replyingToReviewId = null; _replyController.clear();
        if (_isEditingRules) _cancelEditRules(); // لغو ویرایش قوانین اگر تب عوض شد
      });
      if (newTab == 'قوانین و مقررات' && (_rules.isEmpty || _isLoadingRules)) _fetchRules();
      else if (newTab == 'پاسخگویی به نظرات' && (_reviews.isEmpty || _isLoadingReviews)) _fetchReviews();
    }
  }
  void _editManagerProfile() { /* ... بدون تغییر ... */ }
  void _toggleReplyForm(String reviewId) { /* ... بدون تغییر ... */
    setState(() {
      final review = _reviews.firstWhere((r) => r.id == reviewId);
      if (_replyingToReviewId == reviewId) {
        _replyingToReviewId = null; _replyController.clear(); FocusScope.of(context).unfocus();
      } else {
        _replyingToReviewId = reviewId; _replyController.text = review.managerReplyText ?? '';
        Future.delayed(const Duration(milliseconds: 100), () => FocusScope.of(context).requestFocus(_replyFocusNode));
      }
    });
  }
  Future<void> _logoutUser() async { /* ... بدون تغییر ... */ }

  // توابع مربوط به ویرایش قوانین
  void _toggleEditRulesMode() {
    setState(() {
      _isEditingRules = !_isEditingRules;
      if (_isEditingRules) {
        _rulesTextController.text = _convertRulesListToText(_rules); // یا _rulesAsTextForEditing اگر از سرور متن خام گرفته‌اید
      }
      // نیازی به dispose کنترلر اینجا نیست چون یکبار در dispose کلی کلاس انجام می‌شود.
    });
  }

  void _cancelEditRules() {
    setState(() {
      _isEditingRules = false;
      // نیازی به بازگرداندن متن کنترلر نیست چون با خروج از حالت ویرایش، دوباره از _rules خوانده می‌شود.
    });
  }

  // TODO: تابع برای ذخیره متن قوانین ویرایش شده در سرور
  Future<void> _saveRules() async {
    final newRulesText = _rulesTextController.text;

    // TODO: اینجا کد واقعی فراخوانی API برای ارسال newRulesText به سرور قرار می‌گیرد
    print('Saving rules text: $newRulesText');
    await Future.delayed(const Duration(seconds: 2)); // شبیه‌سازی ذخیره

    setState(() {
      _rulesAsTextForEditing = newRulesText; // ذخیره متن خام ویرایش شده
      _rules = _convertTextToRulesList(newRulesText); // تبدیل متن به لیست برای نمایش
      _isEditingRules = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('قوانین با موفقیت ذخیره شد.'), backgroundColor: Colors.green,));
  }

  Widget _buildTabButton(String title) { /* ... بدون تغییر ... */
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
  Widget build(BuildContext context) { /* ... بدون تغییر (تا بخش TabContent) ... */
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
                child: ListView(
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
      if (_isLoadingRules && !_isEditingRules) return const Center(child: CircularProgressIndicator());
      if (_rules.isEmpty && !_isEditingRules && !_isLoadingRules) return const Center(child: Padding(padding: EdgeInsets.all(30.0), child: Text('هیچ قانونی ثبت نشده است.', style: TextStyle(fontSize: 16, color: Colors.grey))));

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Flexible(child: Text('قوانین و مقرراتی که مسافران برای اقامت در هتل موظفند رعایت کنند:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87))),
                if (!_isEditingRules)
                  TextButton.icon(
                    onPressed: _toggleEditRulesMode,
                    icon: Icon(Icons.edit_outlined, size: 18, color: primaryPurple),
                    label: Text('ویرایش', style: TextStyle(color: primaryPurple, fontSize: 13)),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  )
                else
                  Row(
                    children: [
                      TextButton(onPressed: _saveRules, child: Text('ذخیره', style: TextStyle(color: Colors.green[700], fontSize: 13, fontWeight: FontWeight.bold))),
                      TextButton(onPressed: _cancelEditRules, child: Text('لغو', style: TextStyle(color: Colors.red[700], fontSize: 13))),
                    ],
                  )
              ],
            ),
            const SizedBox(height: 16),
            if (_isEditingRules)
              TextFormField(
                controller: _rulesTextController,
                maxLines: 10, // تعداد خطوط دلخواه برای نمایش
                minLines: 5,
                keyboardType: TextInputType.multiline,
                style: TextStyle(fontSize: 14, color: Colors.grey[800], height: 1.5),
                decoration: InputDecoration(
                  hintText: 'قوانین را اینجا وارد کنید، هر قانون در یک خط جدید...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                  contentPadding: const EdgeInsets.all(12),
                ),
              )
            else if (!_isLoadingRules) // فقط اگر لودینگ تمام شده قوانین را نمایش بده
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _rules.length,
                itemBuilder: (context, index) {
                  final rule = _rules[index];
                  return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: RichText(
                        text: TextSpan(
                          style: DefaultTextStyle.of(context).style.copyWith(fontSize: 14, color: Colors.grey[800], height: 1.5),
                          children: <TextSpan>[
                            TextSpan(text: rule.title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                            TextSpan(text: ': ${rule.description}'),
                          ],
                        ),
                      )
                  );
                },
              ),
          ],
        ),
      );
    }
    else if (_selectedTab == 'پاسخگویی به نظرات') { /* ... بدون تغییر ... */
      if (_isLoadingReviews) return const Center(child: CircularProgressIndicator());
      if (_reviews.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(30.0), child: Text('هیچ نظری برای پاسخگویی وجود ندارد.', style: TextStyle(fontSize: 16, color: Colors.grey))));

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: _reviews.length,
        itemBuilder: (context, index) => _buildReviewItem(_reviews[index]),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildReviewItem(ReviewModel review) { /* ... بدون تغییر ... */
    bool isReplying = _replyingToReviewId == review.id;
    return Column(
      children: [
        Card(
          elevation: 2, margin: const EdgeInsets.only(bottom: 12.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(review.userName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)), Text(review.date, style: TextStyle(fontSize: 12, color: Colors.grey[600]))]),
                Text(review.roomInfo, style: TextStyle(fontSize: 12, color: Colors.grey[700])), const SizedBox(height: 10),
                if (review.positivePoints.isNotEmpty) ...review.positivePoints.map((point) => _buildPointRow(point, true)),
                if (review.negativePoints.isNotEmpty) ...review.negativePoints.map((point) => _buildPointRow(point, false)),
                const SizedBox(height: 10),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Row(children: [Icon(Icons.thumb_up_alt_outlined, size: 18, color: Colors.grey[700]), const SizedBox(width: 4), Text(review.rating.toString(), style: TextStyle(fontSize: 14, color: Colors.grey[700]))]), TextButton.icon(onPressed: () => _toggleReplyForm(review.id), icon: Icon(Icons.reply_outlined, size: 18, color: primaryPurple), label: Text(review.managerReplyText != null ? 'ویرایش پاسخ' : 'ثبت پاسخ', style: TextStyle(color: primaryPurple, fontSize: 13, fontWeight: FontWeight.w600)), style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)))]),
                if (review.managerReplyText != null && !isReplying) ...[const Divider(height: 20, thickness: 0.5), Text('پاسخ شما:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: primaryPurple)), const SizedBox(height: 4), Text(review.managerReplyText!, style: TextStyle(fontSize: 13, color: Colors.grey[800], fontStyle: FontStyle.italic))]
              ],
            ),
          ),
        ),
        if (isReplying) _buildReplyForm(review),
      ],
    );
  }

  Widget _buildPointRow(String point, bool isPositive) { /* ... بدون تغییر ... */
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(isPositive ? Icons.add_circle_outline : Icons.remove_circle_outline, size: 16, color: isPositive ? Colors.green[600] : Colors.red[600]), const SizedBox(width: 6), Expanded(child: Text(point, style: TextStyle(fontSize: 13, color: Colors.grey[800])))]),
    );
  }

  Widget _buildReplyForm(ReviewModel review) { /* ... بدون تغییر ... */
    if (_replyingToReviewId != review.id) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 20.0, top: 0), padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 1, blurRadius: 3)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('پاسخ خود را به نظر فوق بنویسید:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)), const SizedBox(height: 12),
          TextField(controller: _replyController, focusNode: _replyFocusNode, maxLines: 3, minLines: 3, textInputAction: TextInputAction.newline, decoration: InputDecoration(hintText: 'پاسخ شما...', filled: true, fillColor: Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none), contentPadding: const EdgeInsets.all(10))),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => _submitReply(review.id, _replyController.text), style: ElevatedButton.styleFrom(backgroundColor: primaryPurple, padding: const EdgeInsets.symmetric(vertical: 12.0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))), child: const Text('ثبت پاسخ', style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold)))),
        ],
      ),
    );
  }

}