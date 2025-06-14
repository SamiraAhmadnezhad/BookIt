import 'package:flutter/material.dart';
import '../constants.dart';

class AuthTabBar extends StatelessWidget {
  final int selectedTab;
  final ValueChanged<int> onTabChanged;

  const AuthTabBar({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            _buildTabButton(context, 'ورود', 0),
            _buildTabButton(context, 'ثبت‌نام مدیر هتل', 1),
            _buildTabButton(context, 'ثبت‌نام مهمان', 2),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(BuildContext context, String text, int index) {
    final bool isActive = selectedTab == index;
    final Color buttonBgColor = isActive ? getSecondaryColor(selectedTab) : Colors.white;
    final Color buttonTextColor=Colors.black;


    return Expanded(
      child: GestureDetector(
        onTap: () => onTabChanged(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: buttonBgColor,
            borderRadius: BorderRadius.circular(30),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: buttonTextColor,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}