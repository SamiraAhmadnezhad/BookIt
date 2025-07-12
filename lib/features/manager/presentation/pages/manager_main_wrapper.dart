
import 'package:bookit/pages/manger_pages/report_page/pages/reports_page.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/custom_bottom_nav_bar.dart';
import '../../../../pages/manger_pages/account_page/manager_account_page.dart';
import '../../../../pages/manger_pages/hotel_info_page/screens/hotel_list_screen.dart';

class ManagerMainWrapper extends StatefulWidget {
  const ManagerMainWrapper({super.key});

  @override
  State<ManagerMainWrapper> createState() => _ManagerMainWrapperState();
}

class _ManagerMainWrapperState extends State<ManagerMainWrapper> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    HotelListScreen(),
    ReportsPage(),
    ManagerAccountPage(),
  ];

  final List<NavBarItemData> _navBarItems = [
    NavBarItemData(
      label: 'هتل‌ها',
      icon: const Icon(Icons.hotel_outlined),
      activeIcon: const Icon(Icons.hotel),
    ),
    NavBarItemData(
      label: 'گزارشات',
      icon: const Icon(Icons.library_books_outlined),
      activeIcon: const Icon(Icons.library_books),
    ),
    NavBarItemData(
      label: 'پروفایل',
      icon: const Icon(Icons.person_outline),
      activeIcon: const Icon(Icons.person),
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
        bottomNavigationBar: CustomBottomNavBar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
          itemsData: _navBarItems,
        ),
      ),
    );
  }
}