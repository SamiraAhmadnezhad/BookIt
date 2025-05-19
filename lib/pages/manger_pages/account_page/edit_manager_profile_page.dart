import 'package:flutter/material.dart';

class UserEditableProfileModel {
  String name;
  String? password;
  String email;
  String nationalId;
  String birthDate;
  String cardNumber;
  String phoneCountryCode;
  String phoneNumber;
  String? avatarUrl;

  UserEditableProfileModel({
    required this.name,
    this.password,
    required this.email,
    required this.nationalId,
    required this.birthDate,
    required this.cardNumber,
    required this.phoneCountryCode,
    required this.phoneNumber,
    this.avatarUrl,
  });
// TODO: toJson و fromJson
}


class EditManagerProfilePage extends StatefulWidget {
  // TODO: اطلاعات اولیه مدیر را از صفحه قبل پاس دهید
  // final ManagerProfileModel? initialManagerData;
  // const EditManagerProfilePage({super.key, this.initialManagerData});

  const EditManagerProfilePage({super.key});


  @override
  State<EditManagerProfilePage> createState() => _EditManagerProfilePageState();
}

class _EditManagerProfilePageState extends State<EditManagerProfilePage> {
  final Color primaryPurple = const Color(0xFF542545);
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _passwordController;
  late TextEditingController _emailController;
  late TextEditingController _nationalIdController;
  late TextEditingController _birthDateController;
  late TextEditingController _cardNumberController;
  late TextEditingController _phoneNumberController;

  String _selectedCountryCode = '+98 (IRI)';
  final List<String> _countryCodes = ['+98 (IRI)', '+1 (USA)', '+44 (UK)'];

  bool _isLoading = false;
  UserEditableProfileModel? _managerProfileDataToEdit; // استفاده از مدل قبلی برای سادگی


  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _passwordController = TextEditingController();
    _emailController = TextEditingController();
    _nationalIdController = TextEditingController();
    _birthDateController = TextEditingController();
    _cardNumberController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _loadInitialManagerData();
  }

  // TODO: تابع برای بارگذاری اطلاعات اولیه مدیر
  Future<void> _loadInitialManagerData() async {
    setState(() { _isLoading = true; });
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      // TODO: اطلاعات واقعی مدیر را اینجا از سرور یا widget.initialManagerData تنظیم کنید
      _managerProfileDataToEdit = UserEditableProfileModel( // استفاده از مدل کاربر برای نمونه
        name: 'تقی تقوی',
        password: 'password123',
        email: 'taghitaghavi@gmail.com',
        nationalId: '0441189034', // مطابق فیگمای جدید
        birthDate: '02/02/1979',  // مطابق فیگمای جدید
        cardNumber: '5022-2910-5068-7843', // مطابق فیگمای جدید
        phoneCountryCode: '+98 (IRI)',
        phoneNumber: '9121234567',
      );

      if (_managerProfileDataToEdit != null) {
        _nameController.text = _managerProfileDataToEdit!.name;
        _passwordController.text = _managerProfileDataToEdit!.password ?? '';
        _emailController.text = _managerProfileDataToEdit!.email;
        _nationalIdController.text = _managerProfileDataToEdit!.nationalId;
        _birthDateController.text = _managerProfileDataToEdit!.birthDate;
        _cardNumberController.text = _managerProfileDataToEdit!.cardNumber;
        _selectedCountryCode = _managerProfileDataToEdit!.phoneCountryCode;
        _phoneNumberController.text = _managerProfileDataToEdit!.phoneNumber;
      }
    } catch (e) { /* TODO: Handle error */ }
    finally { if (mounted) setState(() { _isLoading = false; }); }
  }

  @override
  void dispose() {
    _nameController.dispose(); _passwordController.dispose(); _emailController.dispose();
    _nationalIdController.dispose(); _birthDateController.dispose();
    _cardNumberController.dispose(); _phoneNumberController.dispose();
    super.dispose();
  }

  // TODO: تابع برای ذخیره تغییرات پروفایل مدیر در سرور
  Future<void> _saveManagerProfileChanges() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() { _isLoading = true; });
      try {
        final updatedProfile = UserEditableProfileModel( // استفاده از مدل کاربر برای نمونه
          name: _nameController.text,
          password: _passwordController.text.isNotEmpty ? _passwordController.text : null,
          email: _emailController.text,
          nationalId: _nationalIdController.text,
          birthDate: _birthDateController.text,
          cardNumber: _cardNumberController.text,
          phoneCountryCode: _selectedCountryCode,
          phoneNumber: _phoneNumberController.text,
          avatarUrl: _managerProfileDataToEdit?.avatarUrl,
        );
        // TODO: اینجا کد واقعی فراخوانی API برای ارسال updatedProfile (مخصوص مدیر) به سرور
        await Future.delayed(const Duration(seconds: 2));
        print('Manager profile saved: ${updatedProfile.name}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تغییرات با موفقیت ذخیره شد.'), backgroundColor: Colors.green));
          Navigator.of(context).pop(true); // true برای نشان دادن اینکه تغییرات ذخیره شده
        }
      } catch (e) { /* TODO: Handle error */ }
      finally { if (mounted) setState(() { _isLoading = false; }); }
    }
  }

  Widget _buildTextField({ required IconData icon, required String hintText, required TextEditingController controller, bool obscureText = false, TextInputType keyboardType = TextInputType.text, String? Function(String?)? validator, bool readOnly = false }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller, obscureText: obscureText, keyboardType: keyboardType, readOnly: readOnly,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          hintText: hintText, hintStyle: TextStyle(color: Colors.grey[600], fontSize: 15),
          prefixIcon: Icon(icon, color: primaryPurple.withOpacity(0.7), size: 22),
          filled: true, fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide(color: primaryPurple, width: 1.5)),
        ),
        validator: validator,
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
          elevation: 0, backgroundColor: Colors.white, foregroundColor: Colors.black87,
          leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: primaryPurple, size: 20), onPressed: () => Navigator.of(context).pop()),
          title: Text('ویرایش اطلاعات', style: TextStyle(color: primaryPurple, fontSize: 18, fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: Container(
          width: double.infinity, height: double.infinity,
          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: const BorderRadius.only(topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0))),
          child: _isLoading && _managerProfileDataToEdit == null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Icon(Icons.account_circle, size: 100, color: primaryPurple.withOpacity(0.8)),
                  const SizedBox(height: 24.0),
                  _buildTextField(icon: Icons.person_outline, hintText: 'نام و نام خانوادگی', controller: _nameController, validator: (v) => (v?.isEmpty ?? true) ? 'نام نمی‌تواند خالی باشد' : null),
                  _buildTextField(icon: Icons.lock_outline, hintText: 'رمز عبور (اختیاری)', controller: _passwordController, obscureText: true),
                  _buildTextField(icon: Icons.email, hintText: 'ایمیل', controller: _emailController, keyboardType: TextInputType.emailAddress, validator: (v) { if (v?.isEmpty ?? true) return 'ایمیل نمی‌تواند خالی باشد'; if (!(v?.contains('@') ?? false)) return 'فرمت ایمیل صحیح نیست'; return null; }),
                  _buildTextField(icon: Icons.perm_identity_outlined, hintText: 'کد ملی', controller: _nationalIdController, keyboardType: TextInputType.number),
                  _buildTextField(icon: Icons.calendar_today_outlined, hintText: 'تاریخ تولد (مثال: ۱۳۶۰/۰۱/۱۵)', controller: _birthDateController, keyboardType: TextInputType.datetime),
                  _buildTextField(icon: Icons.credit_card_outlined, hintText: 'شماره کارت بانکی', controller: _cardNumberController, keyboardType: TextInputType.number),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: _buildTextField(icon: Icons.phone_iphone_outlined, hintText: 'شماره موبایل', controller: _phoneNumberController, keyboardType: TextInputType.phone, validator: (v) => (v?.isEmpty ?? true) ? 'شماره موبایل نمی‌تواند خالی باشد' : null)),
                      const SizedBox(width: 8),
                      Expanded(flex: 1, child: DropdownButtonFormField<String>(
                        value: _selectedCountryCode, items: _countryCodes.map((String v) => DropdownMenuItem<String>(value: v, child: Text(v, style: const TextStyle(fontSize: 14)))).toList(),
                        onChanged: (String? nv) => setState(() => _selectedCountryCode = nv!),
                        style: const TextStyle(fontSize: 15, color: Colors.black87),
                        decoration: InputDecoration(filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10.0), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide(color: Colors.grey[300]!)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide(color: Colors.grey[300]!)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide(color: primaryPurple))),
                        icon: Icon(Icons.arrow_drop_down, color: primaryPurple.withOpacity(0.7)),
                      ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24.0),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveManagerProfileChanges,
                      style: ElevatedButton.styleFrom(backgroundColor: primaryPurple, padding: const EdgeInsets.symmetric(vertical: 14.0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))),
                      child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.0)) : const Text('ذخیره‌ی تغییرات', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}