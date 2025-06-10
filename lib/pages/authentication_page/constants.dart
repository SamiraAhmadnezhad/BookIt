import 'package:flutter/material.dart';

const Color primaryLoginColor = Color(0xFF542545);
const Color secondaryLoginColor = Color(0xFFCECECE);
const Color primarySignupColor =Color(0xFF542545);
const Color secondarySignupColor = Color(0xFFCECECE);

const Color textPrimaryLoginColor = Colors.black;
const Color textSecondaryLoginColor = Colors.white;
const Color textPrimarySignupColor = Colors.black;
const Color textSecondarySignupColor = Colors.white;

const Color pageBackgroundColor = Colors.white;
const Color topTextColor = Colors.black;

Color getPrimaryColor(int selectedTab) {
  return (selectedTab == 0) ? primaryLoginColor : primarySignupColor;
}

Color getSecondaryColor(int selectedTab) {
  return (selectedTab == 0) ? secondaryLoginColor : secondarySignupColor;
}

Color getPrimaryTextColorInsideCard(int selectedTab) {
  return (selectedTab == 0) ? textPrimaryLoginColor : textPrimarySignupColor;
}

Color getSecondaryTextColorForButton(int selectedTab) {
  return (selectedTab == 0) ? textSecondaryLoginColor : textSecondarySignupColor;
}