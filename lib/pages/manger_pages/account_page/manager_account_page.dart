import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// مسیر صحیح AuthService را وارد کنید، فرض می‌کنیم در پوشه authentication_page است
import '../../authentication_page/auth_service.dart';
import 'edit_manager_profile_page.dart';
// اگر صفحه لاگین شما AuthenticationPage نام دارد و در پوشه authentication_page است:
import '../../authentication_page/authentication_page.dart';


// ... (کلاس‌های مدل ManagerProfileModel, RuleModel, ReviewModel بدون تغییر) ...
class ManagerProfileModel {
  final String name;
  final String email;
  final String? avatarUrl;
  ManagerProfileModel({required this.name, required this.email, this.avatarUrl});
}
class RuleModel {
  String id;
  String title;
  String description;
  RuleModel({required this.id, required this.title, required this.description});
}
class ReviewModel {
  final String id;
  final String date;
  final String userName;
  final String roomInfo;
  final List<String> positivePoints;
  final List<String> negativePoints;
  final double rating;
  String? managerReplyText;
  ReviewModel({required this.id, required this.date, required this.userName, required this.roomInfo, required this.positivePoints, required this.negativePoints, required this.rating, this.managerReplyText,});
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
  List<RuleModel> _rules = [];
  String _rulesAsTextForEditing = "";
  List<ReviewModel> _reviews = [];

  bool _isLoadingProfile = true;
  bool _isLoadingRules = true;
  bool _isLoadingReviews = false;
  // bool _isLoggingOut = false; // این متغیر دیگر لازم نیست چون از authService.isLoading استفاده می‌کنیم

  String? _replyingToReviewId;
  final TextEditingController _replyController = TextEditingController();
  final FocusNode _replyFocusNode = FocusNode();

  bool _isEditingRules = false;
  final TextEditingController _rulesTextController = TextEditingController();


  @override
  void initState() {
    super.initState();
    print("ManagerAccountPage: initState - Fetching initial data...");
    _fetchInitialData();
  }

  @override
  void dispose() {
    print("ManagerAccountPage: dispose");
    _replyController.dispose();
    _replyFocusNode.dispose();
    _rulesTextController.dispose();
    super.dispose();
  }

  Future<void> _fetchInitialData() async {
    await _fetchManagerProfile();
    // فقط در صورتی که ویجت هنوز mount است، ادامه بده
    if (!mounted) return;
    if (_selectedTab == 'قوانین و مقررات') {
      await _fetchRules();
    } else if (_selectedTab == 'پاسخگویی به نظرات') {
      await _fetchReviews();
    }
  }

  Future<void> _fetchManagerProfile() async {
    print("ManagerAccountPage: _fetchManagerProfile started.");
    if (!mounted) return;
    setState(() { _isLoadingProfile = true; });
    try {
      // TODO: Fetch real profile data using AuthService for token
      await Future.delayed(const Duration(seconds: 1)); // Mock
      if (!mounted) return;
      _managerProfile = ManagerProfileModel(name: 'تقی تقوی', email: 'taghitaghavi@gmail.com');
      print("ManagerAccountPage: Profile data mocked.");
    } catch (e) {
      print("ManagerAccountPage: Error fetching manager profile: $e");
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطا در بارگذاری پروفایل: ${e.toString()}'), backgroundColor: Colors.red));
    }
    finally {
      if (mounted) {
        setState(() { _isLoadingProfile = false; });
        print("ManagerAccountPage: _fetchManagerProfile finished. _isLoadingProfile: $_isLoadingProfile");
      }
    }
  }

  String _convertRulesListToText(List<RuleModel> rules) {
    return rules.map((rule) => '${rule.title}: ${rule.description}').join('\n\n');
  }
  List<RuleModel> _convertTextToRulesList(String text) {
    final List<RuleModel> newRules = [];
    final lines = text.split('\n');
    int ruleCounter = 1;
    String currentTitle = "";
    String currentDescription = "";
    for (String line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;
      RegExpMatch? match = RegExp(r'^(\d+\.\s*[^:]+):\s*(.*)$').firstMatch(line);
      if (match != null && match.groupCount == 2) {
        if (currentTitle.isNotEmpty) {
          newRules.add(RuleModel(id: 'local${ruleCounter-1}', title: currentTitle.trim(), description: currentDescription.trim()));
          currentDescription = "";
        }
        currentTitle = match.group(1)!;
        currentDescription = match.group(2)!;
        ruleCounter++;
      } else {
        if (currentTitle.isNotEmpty) {
          currentDescription += (currentDescription.isEmpty ? "" : "\n") + line;
        } else {
          currentTitle = "قانون ${ruleCounter}";
          currentDescription = line;
          ruleCounter++;
        }
      }
    }
    if (currentTitle.isNotEmpty) {
      newRules.add(RuleModel(id: 'local${ruleCounter-1}', title: currentTitle.trim(), description: currentDescription.trim()));
    }
    return newRules;
  }

  Future<void> _fetchRules() async {
    print("ManagerAccountPage: _fetchRules started.");
    if (_isEditingRules || !mounted) return;
    setState(() { _isLoadingRules = true; });
    try {
      // TODO: Fetch real rules data using AuthService for token
      await Future.delayed(const Duration(seconds: 1)); // Mock
      if (!mounted) return;
      _rules = [
        RuleModel(id: '1', title: '1. قانون اول', description: 'توضیحات مربوط به قانون اول که می‌تواند طولانی باشد و چند خط را اشغال کند.'),
        RuleModel(id: '2', title: '2. قانون دوم', description: 'توضیحات قانون دوم در اینجا قرار می‌گیرد.'),
      ];
      _rulesAsTextForEditing = _convertRulesListToText(_rules);
      print("ManagerAccountPage: Rules data mocked.");
    } catch (e) {
      print("ManagerAccountPage: Error fetching rules: $e");
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطا در بارگذاری قوانین: ${e.toString()}'), backgroundColor: Colors.red));
    }
    finally {
      if (mounted) {
        setState(() { _isLoadingRules = false; });
        print("ManagerAccountPage: _fetchRules finished. _isLoadingRules: $_isLoadingRules");
      }
    }
  }

  Future<void> _fetchReviews() async {
    print("ManagerAccountPage: _fetchReviews started.");
    if ((_selectedTab != 'پاسخگویی به نظرات' && _reviews.isNotEmpty && !_isLoadingReviews) || !mounted) return;
    setState(() { _isLoadingReviews = true; });
    try {
      // TODO: Fetch real reviews data using AuthService for token
      await Future.delayed(const Duration(seconds: 1)); // Mock
      if (!mounted) return;
      _reviews = [
        ReviewModel(id: 'rev1', date: '۱۴ تیر ۱۴۰۲', userName: 'اسم اشخاص', roomInfo: 'اتاق ۵ تخته', positivePoints: ['نکته مثبت اول'], negativePoints: ['نکته منفی اول'], rating: 4.5),
        ReviewModel(id: 'rev2', date: '۱۲ تیر ۱۴۰۲', userName: 'کاربر دیگر', roomInfo: 'سوییت', positivePoints: ['تمیزی عالی بود'], negativePoints: ['صبحانه می‌توانست بهتر باشد'], rating: 4.0, managerReplyText: 'از نظر شما سپاسگزاریم.'),
      ];
      print("ManagerAccountPage: Reviews data mocked.");
    } catch (e) {
      print("ManagerAccountPage: Error fetching reviews: $e");
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطا در بارگذاری نظرات: ${e.toString()}'), backgroundColor: Colors.red));
    }
    finally {
      if (mounted) {
        setState(() { _isLoadingReviews = false; });
        print("ManagerAccountPage: _fetchReviews finished. _isLoadingReviews: $_isLoadingReviews");
      }
    }
  }

  Future<void> _submitReply(String reviewId, String replyText) async {
    if (replyText.isEmpty) return;
    // TODO: Submit reply to server using AuthService for token
    print("ManagerAccountPage: Submitting reply for review $reviewId: $replyText");
    await Future.delayed(const Duration(seconds: 1)); // Mock
    if (!mounted) return;
    setState(() {
      final index = _reviews.indexWhere((r) => r.id == reviewId);
      if (index != -1) _reviews[index].managerReplyText = replyText;
      _replyingToReviewId = null; _replyController.clear();
    });
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('پاسخ با موفقیت ثبت شد.'), backgroundColor: Colors.green,));
  }

  void _handleTabChange(String newTab) {
    print("ManagerAccountPage: Tab changed to $newTab");
    if (_selectedTab != newTab) {
      if (!mounted) return;
      setState(() {
        _selectedTab = newTab;
        _replyingToReviewId = null; _replyController.clear();
        if (_isEditingRules) _cancelEditRules();
      });
      if (newTab == 'قوانین و مقررات' && (_rules.isEmpty || _isLoadingRules)) _fetchRules();
      else if (newTab == 'پاسخگویی به نظرات' && (_reviews.isEmpty || _isLoadingReviews)) _fetchReviews();
    }
  }
  void _editManagerProfile() {
    print("ManagerAccountPage: _editManagerProfile called");
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const EditManagerProfilePage()),
    ).then((value) {
      if (value == true && mounted) {
        print("ManagerAccountPage: Returned from edit profile with true, fetching profile...");
        _fetchManagerProfile();
      }
    });
  }

  void _toggleReplyForm(String reviewId) {
    if (!mounted) return;
    setState(() {
      final review = _reviews.firstWhere((r) => r.id == reviewId);
      if (_replyingToReviewId == reviewId) {
        _replyingToReviewId = null; _replyController.clear(); FocusScope.of(context).unfocus();
      } else {
        _replyingToReviewId = reviewId; _replyController.text = review.managerReplyText ?? '';
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) FocusScope.of(context).requestFocus(_replyFocusNode);
        });
      }
    });
  }

  Future<void> _logoutUser() async {
    print("ManagerAccountPage: _logoutUser called.");
    // _isLoggingOut دیگر لازم نیست، از authService.isLoading استفاده می‌کنیم
    // اما برای اینکه دکمه بلافاصله غیرفعال شود، می‌توانیم یک isLoading محلی هم داشته باشیم
    // یا به authService.isLoading تکیه کنیم. در اینجا به authService تکیه می‌کنیم.

    final authService = Provider.of<AuthService>(context, listen: false);

    // اگر AuthService از قبل در حال انجام عملیات دیگری است، صبر کن یا خطا بده
    if (authService.isLoading) {
      print("ManagerAccountPage: AuthService is already busy. Logout request ignored for now.");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('عملیات دیگری در حال انجام است، لطفا صبر کنید.'), backgroundColor: Colors.orange),
        );
      }
      return;
    }

    try {
      print("ManagerAccountPage: Calling authService.logout(). Current token: ${authService.token}");
      await authService.logout();
      print("ManagerAccountPage: authService.logout() completed. Error message from service: ${authService.errorMessage}");

      if (!mounted) return; // بررسی مجدد mount بودن بعد از await

      if (authService.errorMessage != null && authService.errorMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('توجه: ${authService.errorMessage}'), backgroundColor: Colors.orange),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('شما با موفقیت از حساب کاربری خود خارج شدید.'), backgroundColor: Colors.green),
        );
      }
      // هدایت به صفحه لاگین
      // مطمئن شوید که AuthenticationPage درست import شده
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthenticationPage()), // صفحه لاگین شما
            (Route<dynamic> route) => false, // همه صفحات قبلی را حذف کن
      );

    } catch (e) {
      print("ManagerAccountPage: Error in _logoutUser UI catch block: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطای پیش‌بینی نشده هنگام خروج (UI): ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
    // isLoading مربوط به AuthService در خود AuthService مدیریت می‌شود.
  }

  void _toggleEditRulesMode() {
    if (!mounted) return;
    setState(() {
      _isEditingRules = !_isEditingRules;
      if (_isEditingRules) _rulesTextController.text = _convertRulesListToText(_rules);
    });
  }
  void _cancelEditRules() {
    if (!mounted) return;
    setState(() { _isEditingRules = false; });
  }
  Future<void> _saveRules() async {
    final newRulesText = _rulesTextController.text;
    // TODO: Save rules to server using AuthService for token
    print('ManagerAccountPage: Saving rules text: $newRulesText');
    await Future.delayed(const Duration(seconds: 2)); // Mock
    if (!mounted) return;
    setState(() {
      _rulesAsTextForEditing = newRulesText;
      _rules = _convertTextToRulesList(newRulesText);
      _isEditingRules = false;
    });
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('قوانین با موفقیت ذخیره شد.'), backgroundColor: Colors.green,));
  }

  Widget _buildTabButton(String title) {
    bool isSelected = _selectedTab == title;
    return Expanded(child: GestureDetector(onTap: () => _handleTabChange(title), child: Container(padding: const EdgeInsets.symmetric(vertical: 12), margin: const EdgeInsets.symmetric(horizontal: 4), decoration: BoxDecoration(color: isSelected ? primaryPurple : Colors.white, borderRadius: BorderRadius.circular(8), border: isSelected ? null : Border.all(color: Colors.grey.shade300)), child: Text(title, textAlign: TextAlign.center, style: TextStyle(color: isSelected ? Colors.white : primaryPurple, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 13)))));
  }

  @override
  Widget build(BuildContext context) {
    // دسترسی به AuthService برای بررسی وضعیت لودینگ کلی آن (مخصوصا برای خروج)
    // استفاده از context.watch باعث می‌شود که این ویجت با هر بار notifyListeners() در AuthService دوباره build شود.
    final authService = context.watch<AuthService>();
    final bool isAuthServiceLoading = authService.isLoading;

    print("--- ManagerAccountPage Build Method ---");
    print("Selected Tab: $_selectedTab");
    print("AuthService isLoading: $isAuthServiceLoading, IsAuthenticated: ${authService.isAuthenticated}, Token: ${authService.token}");

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white, elevation: 0, automaticallyImplyLeading: false,
          leading: IconButton(icon: Icon(Icons.notifications_none_outlined, color: primaryPurple, size: 28), onPressed: () { /* TODO: Notification action */ }),
          actions: [
            Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 8.0, top: 8.0, bottom: 8.0),
                child: ElevatedButton(
                  // شرط onPressed حالا فقط به isAuthServiceLoading نگاه می‌کند
                  onPressed: isAuthServiceLoading ? null : _logoutUser,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: primaryPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                  ),
                  child: isAuthServiceLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                      : const Text('خروج از حساب کاربری', style: TextStyle(fontSize: 12)),
                )
            )
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: _isLoadingProfile
                  ? const Center(child: CircularProgressIndicator())
                  : Column(children: [
                Icon(Icons.account_circle, size: 100, color: primaryPurple.withOpacity(0.8)),
                const SizedBox(height: 12),
                Text(_managerProfile?.name ?? 'مدیر', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 4),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(_managerProfile?.email ?? '', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                  const SizedBox(width: 4),
                  if (_managerProfile?.email.isNotEmpty ?? false) Icon(Icons.check_circle, color: Colors.green[600], size: 16)
                ])
              ]),
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
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Flexible(child: Text('قوانین و مقرراتی که مسافران برای اقامت در هتل موظفند رعایت کنند:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87))), if (!_isEditingRules) TextButton.icon(onPressed: _toggleEditRulesMode, icon: Icon(Icons.edit_outlined, size: 18, color: primaryPurple), label: Text('ویرایش', style: TextStyle(color: primaryPurple, fontSize: 13)), style: TextButton.styleFrom(padding: EdgeInsets.zero),) else Row(children: [TextButton(onPressed: _saveRules, child: Text('ذخیره', style: TextStyle(color: Colors.green[700], fontSize: 13, fontWeight: FontWeight.bold))), TextButton(onPressed: _cancelEditRules, child: Text('لغو', style: TextStyle(color: Colors.red[700], fontSize: 13)))])]),
            const SizedBox(height: 16),
            if (_isEditingRules) TextFormField(controller: _rulesTextController, maxLines: 10, minLines: 5, keyboardType: TextInputType.multiline, style: TextStyle(fontSize: 14, color: Colors.grey[800], height: 1.5), decoration: InputDecoration(hintText: 'قوانین را اینجا وارد کنید، هر قانون در یک خط جدید...', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)), contentPadding: const EdgeInsets.all(12)))
            else if (!_isLoadingRules) ListView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: _rules.length, itemBuilder: (context, index) { final rule = _rules[index]; return Padding(padding: const EdgeInsets.only(bottom: 10.0), child: RichText(text: TextSpan(style: DefaultTextStyle.of(context).style.copyWith(fontSize: 14, color: Colors.grey[800], height: 1.5), children: <TextSpan>[TextSpan(text: rule.title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)), TextSpan(text: ': ${rule.description}')])));}),
          ],
        ),
      );
    } else if (_selectedTab == 'پاسخگویی به نظرات') {
      if (_isLoadingReviews) return const Center(child: CircularProgressIndicator());
      if (_reviews.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(30.0), child: Text('هیچ نظری برای پاسخگویی وجود ندارد.', style: TextStyle(fontSize: 16, color: Colors.grey))));
      return ListView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), padding: const EdgeInsets.symmetric(horizontal: 16.0), itemCount: _reviews.length, itemBuilder: (context, index) => _buildReviewItem(_reviews[index]));
    }
    return const SizedBox.shrink();
  }
  Widget _buildReviewItem(ReviewModel review) {
    bool isReplying = _replyingToReviewId == review.id;
    return Column(children: [Card(elevation: 2, margin: const EdgeInsets.only(bottom: 12.0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), color: Colors.white, child: Padding(padding: const EdgeInsets.all(12.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(review.userName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)), Text(review.date, style: TextStyle(fontSize: 12, color: Colors.grey[600]))]), Text(review.roomInfo, style: TextStyle(fontSize: 12, color: Colors.grey[700])), const SizedBox(height: 10), if (review.positivePoints.isNotEmpty) ...review.positivePoints.map((point) => _buildPointRow(point, true)), if (review.negativePoints.isNotEmpty) ...review.negativePoints.map((point) => _buildPointRow(point, false)), const SizedBox(height: 10), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Row(children: [Icon(Icons.thumb_up_alt_outlined, size: 18, color: Colors.grey[700]), const SizedBox(width: 4), Text(review.rating.toString(), style: TextStyle(fontSize: 14, color: Colors.grey[700]))]), TextButton.icon(onPressed: () => _toggleReplyForm(review.id), icon: Icon(Icons.reply_outlined, size: 18, color: primaryPurple), label: Text(review.managerReplyText != null ? 'ویرایش پاسخ' : 'ثبت پاسخ', style: TextStyle(color: primaryPurple, fontSize: 13, fontWeight: FontWeight.w600)), style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)))]), if (review.managerReplyText != null && !isReplying) ...[const Divider(height: 20, thickness: 0.5), Text('پاسخ شما:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: primaryPurple)), const SizedBox(height: 4), Text(review.managerReplyText!, style: TextStyle(fontSize: 13, color: Colors.grey[800], fontStyle: FontStyle.italic))]])),), if (isReplying) _buildReplyForm(review)]);
  }
  Widget _buildPointRow(String point, bool isPositive) {
    return Padding(padding: const EdgeInsets.only(bottom: 4.0), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(isPositive ? Icons.add_circle_outline : Icons.remove_circle_outline, size: 16, color: isPositive ? Colors.green[600] : Colors.red[600]), const SizedBox(width: 6), Expanded(child: Text(point, style: TextStyle(fontSize: 13, color: Colors.grey[800])))]));
  }
  Widget _buildReplyForm(ReviewModel review) {
    if (_replyingToReviewId != review.id) return const SizedBox.shrink();
    return Container(margin: const EdgeInsets.only(bottom: 20.0, top: 0), padding: const EdgeInsets.all(16.0), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 1, blurRadius: 3)]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('پاسخ خود را به نظر فوق بنویسید:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)), const SizedBox(height: 12), TextField(controller: _replyController, focusNode: _replyFocusNode, maxLines: 3, minLines: 3, textInputAction: TextInputAction.newline, decoration: InputDecoration(hintText: 'پاسخ شما...', filled: true, fillColor: Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none), contentPadding: const EdgeInsets.all(10))), const SizedBox(height: 16), SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => _submitReply(review.id, _replyController.text), style: ElevatedButton.styleFrom(backgroundColor: primaryPurple, padding: const EdgeInsets.symmetric(vertical: 12.0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))), child: const Text('ثبت پاسخ', style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold))))]));
  }
}