// guest_main_screen.dart
import 'package:bookit/pages/guest_pages/search_page/hotel_search_page.dart';
import 'package:flutter/material.dart';
import '../guest_pages/custom_bottom_nav_bar.dart';
import 'account_page/manager_account_page.dart';
import 'hotel_info_page/screens/hotel_list_screen.dart';
class ManagerMainScreen extends StatefulWidget {
  const ManagerMainScreen({super.key});

  @override
  State<ManagerMainScreen> createState() => _ManagerMainScreenState();
}

class _ManagerMainScreenState extends State<ManagerMainScreen> {
  int _selectedIndex = 0; // ایندکس صفحه انتخاب شده

 static final List<Widget> _widgetOptions = <Widget>[
    HotelListScreen(),
   ManagerAccountPage(),
    ManagerAccountPage(),
  ];

  final List<NavBarItemData> _navBarItemsData = [
    NavBarItemData(
      label: 'افزودن هتل',
      icon: const Icon(Icons.add_home_work_outlined),
      activeIcon: const Icon(Icons.add_home_work_sharp), // یا Icons.home
    ),
    NavBarItemData(
      label: 'گزارشات',
      icon: const Icon(Icons.library_books_outlined), // یا فقط Icons.search
      activeIcon: const Icon(Icons.library_books_rounded), // آیکون متفاوت برای فعال
    ),
    NavBarItemData(
      label: 'پروفایل',
      icon: const Icon(Icons.person_outline),
      activeIcon: const Icon(Icons.person),
    ),
    // می‌توانید آیتم‌های بیشتری اضافه کنید
    // NavBarItemData(
    //   label: 'موارد دلخواه',
    //   icon: const Icon(Icons.favorite_border),
    //   activeIcon: const Icon(Icons.favorite),
    // ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality( // مهم برای پشتیبانی از RTL
      textDirection: TextDirection.rtl,
      child: Scaffold( // AppBar بر اساس صفحه فعلی
        body: IndexedStack( // از IndexedStack برای حفظ وضعیت صفحات استفاده کنید
          index: _selectedIndex,
          children: _widgetOptions,
        ),
        // body: Center( // روش ساده‌تر بدون حفظ وضعیت صفحات
        //   child: _widgetOptions.elementAt(_selectedIndex),
        // ),
        bottomNavigationBar: CustomBottomNavBar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
          itemsData: _navBarItemsData,
        ),
      ),
    );
  }
}