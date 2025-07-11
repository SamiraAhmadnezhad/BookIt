import 'package:bookit/pages/guest_pages/account_page/user_account_page.dart';
import 'package:bookit/features/guest/home/presentation/pages/home_screen.dart';
import 'package:bookit/features/guest/home/presentation/pages/hotel_list_screen.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/custom_bottom_nav_bar.dart';
import '../../../../pages/guest_pages/search_page/hotel_search_page.dart';

class GuestMainWrapper extends StatefulWidget {
  const GuestMainWrapper({super.key});

  @override
  State<GuestMainWrapper> createState() => _GuestMainWrapperState();
}

class _GuestMainWrapperState extends State<GuestMainWrapper> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    HomeScreen(),
    HotelSearchPage(),
    UserAccountPage(),
  ];

  final List<NavBarItemData> _navBarItems = [
    NavBarItemData(
      label: 'خانه',
      icon: const Icon(Icons.home_outlined),
      activeIcon: const Icon(Icons.home),
    ),
    NavBarItemData(
      label: 'جستجو',
      icon: const Icon(Icons.search_outlined),
      activeIcon: const Icon(Icons.search),
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