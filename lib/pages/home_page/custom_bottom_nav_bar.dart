import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'خانه',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search_outlined),
          activeIcon: Icon(Icons.search),
          label: 'جستجو',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.widgets_outlined), // Or a custom category icon
          activeIcon: Icon(Icons.widgets),
          label: 'دسته‌بندی',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'پروفایل',
        ),
      ],
      currentIndex: selectedIndex,
      selectedItemColor: Colors.deepPurple, // Color for selected item
      unselectedItemColor: Colors.grey, // Color for unselected items
      showUnselectedLabels: true, // To show labels for unselected items
      type: BottomNavigationBarType.fixed, // Ensures all items are visible
      onTap: onItemTapped,
    );
  }
}