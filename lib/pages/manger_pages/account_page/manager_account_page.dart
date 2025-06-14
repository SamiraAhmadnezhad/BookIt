import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../authentication_page/auth_service.dart';
import 'edit_manager_profile_page.dart';
import '../../authentication_page/authentication_page.dart';

const Color kPrimaryColor = Color(0xFF542545);
const Color kAccentColor = Color(0xFF7E3F6B);
const Color kPageBackground = Color(0xFFF4F6F8);
const Color kCardBackground = Colors.white;
const Color kLightTextColor = Color(0xFF606060);
const Color kLighterTextColor = Color(0xFF888888);
const Color kIconColor = Color(0xFF404040);
const Color kPositiveColor = Color(0xFF28a745);
const Color kNegativeColor = Color(0xFFdc3545);

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
  ReviewModel(
      {required this.id,
        required this.date,
        required this.userName,
        required this.roomInfo,
        required this.positivePoints,
        required this.negativePoints,
        required this.rating,
        this.managerReplyText});
}

class ManagerAccountPage extends StatefulWidget {
  const ManagerAccountPage({super.key});

  @override
  State<ManagerAccountPage> createState() => _ManagerAccountPageState();
}

class _ManagerAccountPageState extends State<ManagerAccountPage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  String _selectedTab = 'قوانین و مقررات';

  ManagerProfileModel? _managerProfile;
  List<RuleModel> _rules = [];
  List<ReviewModel> _reviews = [];

  bool _isLoadingProfile = true;
  bool _isLoadingRules = true;
  bool _isLoadingReviews = false;

  String? _replyingToReviewId;
  final TextEditingController _replyController = TextEditingController();
  final FocusNode _replyFocusNode = FocusNode();

  bool _isEditingRules = false;
  final TextEditingController _rulesTextController = TextEditingController();

  final List<String> _tabs = const ['قوانین و مقررات', 'پاسخگویی به نظرات'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController!.addListener(_handleTabSelection);
    _fetchInitialData();
  }

  void _handleTabSelection() {
    if (_tabController!.indexIsChanging ||
        _selectedTab == _tabs[_tabController!.index]) return;

    if (mounted) {
      setState(() {
        _selectedTab = _tabs[_tabController!.index];
        _replyingToReviewId = null;
        _replyController.clear();
        if (_isEditingRules) _cancelEditRules();
      });
      _fetchDataForSelectedTab();
    }
  }

  @override
  void dispose() {
    _tabController?.removeListener(_handleTabSelection);
    _tabController?.dispose();
    _replyController.dispose();
    _replyFocusNode.dispose();
    _rulesTextController.dispose();
    super.dispose();
  }

  Future<void> _fetchInitialData() async {
    await _fetchManagerProfile();
    _fetchDataForSelectedTab();
  }

  Future<void> _fetchDataForSelectedTab() async {
    if (!mounted) return;
    if (_selectedTab == 'قوانین و مقررات') {
      await _fetchRules();
    } else if (_selectedTab == 'پاسخگویی به نظرات') {
      await _fetchReviews();
    }
  }

  Future<void> _fetchManagerProfile() async {
    if (!mounted) return;
    setState(() => _isLoadingProfile = true);
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      _managerProfile = ManagerProfileModel(
          name: 'تقی تقوی',
          email: 'taghitaghavi@gmail.com',
          avatarUrl: 'https://i.pravatar.cc/150?u=taghitaghavi');
    } catch (e) {
      _showErrorSnackBar('خطا در بارگذاری پروفایل: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoadingProfile = false);
    }
  }

  String _convertRulesListToText(List<RuleModel> rules) {
    return rules
        .map((rule) => '${rule.title.trim()}: ${rule.description.trim()}')
        .join('\n\n');
  }

  List<RuleModel> _convertTextToRulesList(String text) {
    final List<RuleModel> newRules = [];
    if (text.trim().isEmpty) return newRules;

    final ruleEntries = text.split(RegExp(r'\n\s*\n+'));
    int ruleCounter = 1;

    for (String entry in ruleEntries) {
      if (entry.trim().isEmpty) continue;
      int colonIndex = entry.indexOf(':');
      if (colonIndex != -1) {
        String title = entry.substring(0, colonIndex).trim();
        String description = entry.substring(colonIndex + 1).trim();
        if (title.isNotEmpty || description.isNotEmpty) {
          newRules.add(RuleModel(
              id: 'local${ruleCounter++}',
              title: title.isEmpty ? "قانون $ruleCounter" : title,
              description: description));
        }
      } else {
        newRules.add(RuleModel(
            id: 'local${ruleCounter++}',
            title: "قانون $ruleCounter",
            description: entry.trim()));
      }
    }
    return newRules;
  }

  Future<void> _fetchRules() async {
    if (_isEditingRules || !mounted || _isLoadingRules) return;
    setState(() => _isLoadingRules = true);
    try {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      _rules = [
        RuleModel(
            id: '1',
            title: '۱. زمان ورود و خروج',
            description:
            'زمان ورود به اتاق ساعت ۱۴:۰۰ و زمان خروج ساعت ۱۲:۰۰ ظهر می‌باشد.'),
        RuleModel(
            id: '2',
            title: '۲. مدارک شناسایی',
            description:
            'ارائه کارت ملی و شناسنامه برای تمامی میهمانان الزامی است.'),
        RuleModel(
            id: '3',
            title: '۳. استعمال دخانیات',
            description:
            'استعمال دخانیات در تمامی فضاهای داخلی هتل ممنوع می‌باشد.'),
      ];
      _rulesTextController.text = _convertRulesListToText(_rules);
    } catch (e) {
      _showErrorSnackBar('خطا در بارگذاری قوانین: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoadingRules = false);
    }
  }

  Future<void> _fetchReviews() async {
    if (!mounted || _isLoadingReviews) return;
    setState(() => _isLoadingReviews = true);
    try {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      _reviews = [
        ReviewModel(
            id: 'rev1',
            date: '۱۴ تیر ۱۴۰۲',
            userName: 'سارا احمدی',
            roomInfo: 'اتاق دو تخته دابل',
            positivePoints: ['نظافت عالی اتاق‌ها', 'برخورد خوب پرسنل'],
            negativePoints: ['تنوع کم صبحانه'],
            rating: 4.2,
            managerReplyText:
            'از اقامت شما سپاسگزاریم. نظرات شما برای بهبود خدمات ما ارزشمند است.'),
        ReviewModel(
            id: 'rev2',
            date: '۱۲ تیر ۱۴۰۲',
            userName: 'رضا محمدی',
            roomInfo: 'سوییت یک خوابه',
            positivePoints: ['منظره زیبای اتاق', 'دسترسی مناسب به مرکز شهر'],
            negativePoints: ['صدای زیاد از راهرو'],
            rating: 3.8),
      ];
    } catch (e) {
      _showErrorSnackBar('خطا در بارگذاری نظرات: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoadingReviews = false);
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating));
  }

  Future<void> _submitReply(String reviewId, String replyText) async {
    if (replyText.trim().isEmpty) {
      _showErrorSnackBar("متن پاسخ نمی‌تواند خالی باشد.");
      return;
    }
    setState(() => _isLoadingReviews = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() {
      final index = _reviews.indexWhere((r) => r.id == reviewId);
      if (index != -1) _reviews[index].managerReplyText = replyText.trim();
      _replyingToReviewId = null;
      _replyController.clear();
      _isLoadingReviews = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('پاسخ با موفقیت ثبت شد.'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating));
  }

  void _editManagerProfile() {
    Navigator.of(context)
        .push(MaterialPageRoute(
        builder: (context) => const EditManagerProfilePage()))
        .then((value) {
      if (value == true && mounted) {
        _fetchManagerProfile();
      }
    });
  }

  void _toggleReplyForm(String reviewId) {
    if (!mounted) return;
    setState(() {
      final review = _reviews.firstWhere((r) => r.id == reviewId);
      if (_replyingToReviewId == reviewId) {
        _replyingToReviewId = null;
        _replyController.clear();
        FocusScope.of(context).unfocus();
      } else {
        _replyingToReviewId = reviewId;
        _replyController.text = review.managerReplyText ?? '';
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) FocusScope.of(context).requestFocus(_replyFocusNode);
        });
      }
    });
  }

  Future<void> _logoutUser() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (authService.isLoading) return;
    try {
      await authService.logout();
      if (!mounted) return;
      if (authService.errorMessage != null &&
          authService.errorMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('توجه: ${authService.errorMessage}'),
            backgroundColor: Colors.orangeAccent,
            behavior: SnackBarBehavior.floating));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('شما با موفقیت از حساب کاربری خود خارج شدید.'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating));
      }
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthenticationPage()),
            (Route<dynamic> route) => false,
      );
    } catch (e) {
      _showErrorSnackBar('خطای پیش‌بینی نشده هنگام خروج: ${e.toString()}');
    }
  }

  void _toggleEditRulesMode() {
    if (!mounted) return;
    setState(() {
      _isEditingRules = !_isEditingRules;
      if (_isEditingRules) {
        _rulesTextController.text = _convertRulesListToText(_rules);
      }
    });
  }

  void _cancelEditRules() {
    if (!mounted) return;
    setState(() {
      _isEditingRules = false;
      _rulesTextController.text = _convertRulesListToText(_rules);
    });
  }

  Future<void> _saveRules() async {
    final newRulesText = _rulesTextController.text;
    if (newRulesText.trim().isEmpty && _rules.isNotEmpty) {
      _showErrorSnackBar("متن قوانین نمی‌تواند خالی باشد اگر قبلا قانونی ثبت شده است.");
      return;
    }
    setState(() => _isLoadingRules = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() {
      _rules = _convertTextToRulesList(newRulesText);
      _isEditingRules = false;
      _isLoadingRules = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('قوانین با موفقیت ذخیره شد.'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: kPageBackground,
        appBar: AppBar(
          backgroundColor: kCardBackground,
          elevation: 0.5,
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'حساب کاربری مدیر',
              style: theme.textTheme.titleLarge
                  ?.copyWith(color: kPrimaryColor, fontWeight: FontWeight.bold),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 8.0),
              child: IconButton(
                icon:
                Icon(Icons.logout_outlined, color: kPrimaryColor, size: 26),
                onPressed: authService.isLoading ? null : _logoutUser,
                tooltip: 'خروج از حساب',
              ),
            )
          ],
        ),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(child: _buildProfileHeader(theme)),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverTabBarDelegate(
                  TabBar(
                    controller: _tabController,
                    indicatorColor: kPrimaryColor,
                    labelColor: kPrimaryColor,
                    unselectedLabelColor: kLightTextColor,
                    indicatorWeight: 2.5,
                    labelStyle: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                    unselectedLabelStyle: theme.textTheme.titleSmall,
                    tabs: _tabs.map((String name) => Tab(text: name)).toList(),
                  ),
                  kCardBackground,
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: _tabs.map((String tabName) {
              return RefreshIndicator(
                  onRefresh: _fetchDataForSelectedTab,
                  color: kPrimaryColor,
                  child: _buildSelectedTabContent(tabName));
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 24.0),
      color: kCardBackground,
      child: _isLoadingProfile
          ? const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 40.0),
            child: CircularProgressIndicator(color: kPrimaryColor),
          ))
          : Column(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: kPrimaryColor.withOpacity(0.1),
            backgroundImage: _managerProfile?.avatarUrl != null
                ? NetworkImage(_managerProfile!.avatarUrl!)
                : null,
            child: _managerProfile?.avatarUrl == null
                ? Icon(Icons.business_center_outlined,
                size: 50, color: kPrimaryColor.withOpacity(0.8))
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            _managerProfile?.name ?? 'مدیر هتل',
            style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 6),
          if (_managerProfile?.email.isNotEmpty ?? false)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _managerProfile!.email,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: kLightTextColor),
                ),
                const SizedBox(width: 6),
                Icon(Icons.verified_user_outlined,
                    color: Colors.green[600], size: 16)
              ],
            ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('ویرایش پروفایل'),
            onPressed: _editManagerProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              textStyle: theme.textTheme.labelLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedTabContent(String tabName) {
    if (tabName == 'قوانین و مقررات') {
      if (_isLoadingRules && !_isEditingRules) return _buildLoadingIndicator();
      if (_rules.isEmpty && !_isEditingRules && !_isLoadingRules) {
        return _buildEmptyStateWithButton(
            'هیچ قانونی ثبت نشده است.', 'افزودن قوانین', _toggleEditRulesMode);
      }
      return _buildRulesContent();
    } else if (tabName == 'پاسخگویی به نظرات') {
      if (_isLoadingReviews) return _buildLoadingIndicator();
      if (_reviews.isEmpty) return _buildEmptyState('هیچ نظری برای پاسخگویی یافت نشد.');
      return _buildList(_reviews, _buildReviewItem);
    }
    return const SizedBox.shrink();
  }

  Widget _buildRulesContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text('قوانین و مقررات هتل',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold, color: kPrimaryColor)),
              ),
              TextButton.icon(
                onPressed: _isEditingRules ? _saveRules : _toggleEditRulesMode,
                icon: Icon(
                    _isEditingRules
                        ? Icons.save_outlined
                        : Icons.edit_outlined,
                    size: 18,
                    color: _isEditingRules ? kPositiveColor : kAccentColor),
                label: Text(_isEditingRules ? 'ذخیره' : 'ویرایش',
                    style: TextStyle(
                        color: _isEditingRules ? kPositiveColor : kAccentColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
              ),
              if (_isEditingRules)
                TextButton(
                  onPressed: _cancelEditRules,
                  child: const Text('لغو',
                      style: TextStyle(
                          color: kNegativeColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isEditingRules)
            TextFormField(
                controller: _rulesTextController,
                maxLines: null,
                minLines: 8,
                keyboardType: TextInputType.multiline,
                style: TextStyle(
                    fontSize: 14, color: Colors.grey[850], height: 1.6),
                decoration: InputDecoration(
                    hintText:
                    'قوانین را اینجا وارد کنید. هر قانون با عنوان و توضیحات (مثال: ۱. زمان ورود: ساعت ۱۴). برای جدا کردن قوانین، از یک خط خالی استفاده کنید.',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300)),
                    contentPadding: const EdgeInsets.all(12)))
          else if (!_isLoadingRules)
            _rules.isEmpty
                ? const Text("هنوز قانونی ثبت نشده است.")
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _rules.map((rule) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: RichText(
                    textAlign: TextAlign.justify,
                    text: TextSpan(
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                          color: kLightTextColor, height: 1.6),
                      children: <TextSpan>[
                        TextSpan(
                            text: '${rule.title}: ',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87)),
                        TextSpan(text: rule.description),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
        child: Padding(
            padding: EdgeInsets.all(30.0),
            child: CircularProgressIndicator(color: kPrimaryColor)));
  }

  Widget _buildEmptyState(String message) {
    return Center(
        child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: kLightTextColor))));
  }

  Widget _buildEmptyStateWithButton(
      String message, String buttonText, VoidCallback onPressed) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: kLightTextColor)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_circle_outline, size: 20),
              label: Text(buttonText),
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: kAccentColor,
                foregroundColor: Colors.white,
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildList<T>(List<T> items, Widget Function(T item) itemBuilder) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 80.0),
      itemCount: items.length,
      itemBuilder: (context, index) => itemBuilder(items[index]),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
    );
  }

  Widget _buildReviewItem(ReviewModel review) {
    bool isReplying = _replyingToReviewId == review.id;
    return Card(
      elevation: 1.5,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: kCardBackground,
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(review.userName,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
                Text(review.date,
                    style:
                    TextStyle(fontSize: 12, color: kLighterTextColor)),
              ],
            ),
            Text(review.roomInfo,
                style: TextStyle(fontSize: 12, color: kLightTextColor)),
            const SizedBox(height: 10),
            if (review.positivePoints.isNotEmpty) ...[
              const Text("نکات مثبت:",
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: kPositiveColor)),
              ...review.positivePoints
                  .map((point) => _buildPointRow(point, true)),
              const SizedBox(height: 6),
            ],
            if (review.negativePoints.isNotEmpty) ...[
              const Text("نکات منفی:",
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: kNegativeColor)),
              ...review.negativePoints
                  .map((point) => _buildPointRow(point, false)),
              const SizedBox(height: 6),
            ],
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Icon(Icons.star_rounded,
                        size: 20, color: Colors.amber[600]),
                    const SizedBox(width: 4),
                    Text(review.rating.toStringAsFixed(1),
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: kLightTextColor)),
                  ],
                ),
                TextButton.icon(
                  onPressed: () => _toggleReplyForm(review.id),
                  icon: Icon(
                      review.managerReplyText != null && !isReplying
                          ? Icons.edit_note_outlined
                          : Icons.reply_outlined,
                      size: 18,
                      color: kAccentColor),
                  label: Text(
                      review.managerReplyText != null && !isReplying
                          ? 'ویرایش پاسخ'
                          : (isReplying ? 'بستن' : 'ثبت پاسخ'),
                      style: TextStyle(
                          color: kAccentColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                  style: TextButton.styleFrom(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
                ),
              ],
            ),
            if (review.managerReplyText != null && !isReplying) ...[
              const Divider(height: 20, thickness: 0.5),
              Text('پاسخ شما:',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor)),
              const SizedBox(height: 4),
              Text(review.managerReplyText!,
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[800],
                      fontStyle: FontStyle.italic,
                      height: 1.5)),
            ],
            if (isReplying) _buildReplyForm(review),
          ],
        ),
      ),
    );
  }

  Widget _buildPointRow(String point, bool isPositive) {
    return Padding(
      padding: const EdgeInsets.only(top: 3.0, bottom: 1.0, right: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
              isPositive
                  ? Icons.check_circle_outline_rounded
                  : Icons.highlight_off_rounded,
              size: 16,
              color: isPositive ? kPositiveColor : kNegativeColor),
          const SizedBox(width: 6),
          Expanded(
              child: Text(point,
                  style: TextStyle(fontSize: 13, color: Colors.grey[800]))),
        ],
      ),
    );
  }

  Widget _buildReplyForm(ReviewModel review) {
    return Container(
      margin: const EdgeInsets.only(top: 12.0),
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 12.0),
      decoration: BoxDecoration(
          color: kPrimaryColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kPrimaryColor.withOpacity(0.2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('پاسخ به نظر ${review.userName}:',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kPrimaryColor)),
          const SizedBox(height: 10),
          TextField(
              controller: _replyController,
              focusNode: _replyFocusNode,
              maxLines: 3,
              minLines: 3,
              textInputAction: TextInputAction.newline,
              style: TextStyle(fontSize: 13.5, color: Colors.grey[850]),
              decoration: InputDecoration(
                  hintText: 'پاسخ خود را اینجا بنویسید...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: kAccentColor, width: 1.5)),
                  contentPadding: const EdgeInsets.all(10))),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoadingReviews
                  ? null
                  : () => _submitReply(review.id, _replyController.text),
              style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0)),
                  textStyle: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold)),
              child: _isLoadingReviews
                  ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
                  : const Text('ثبت پاسخ'),
            ),
          )
        ],
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverTabBarDelegate(this.tabBar, this.backgroundColor);

  final TabBar tabBar;
  final Color backgroundColor;

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: backgroundColor,
      child: Material(
        elevation: overlapsContent || (shrinkOffset > maxExtent - minExtent) ? 2.0 : 0.0,
        color: backgroundColor,
        child: tabBar,
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}