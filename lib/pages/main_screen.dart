// main_screen.dart
import 'package:flutter/material.dart';

import 'custom_bottom_nav_bar.dart';
import 'home_page/home_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // ایندکس صفحه انتخاب شده

 static const List<Widget> _widgetOptions = <Widget>[
    HomePage(), // محتوای صفحه اصلی شما
    // SearchPage(),
    // ProfilePage(),
  ];

  final List<NavBarItemData> _navBarItemsData = [
    NavBarItemData(
      label: 'خانه',
      icon: const Icon(Icons.home_outlined),
      activeIcon: const Icon(Icons.home_filled), // یا Icons.home
    ),
    NavBarItemData(
      label: 'جستجو',
      icon: const Icon(Icons.search_outlined), // یا فقط Icons.search
      activeIcon: const Icon(Icons.search_sharp), // آیکون متفاوت برای فعال
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