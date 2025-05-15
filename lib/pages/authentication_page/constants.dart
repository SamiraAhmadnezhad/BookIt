import 'package:flutter/material.dart';

// Color constants based on selection state
// Note: These need context (selectedTab) which isn't ideal for pure constants.
// We'll pass the selectedTab to where these colors are needed.

const Color primaryLoginColor = Color(0xFF542545);
const Color secondaryLoginColor = Color(0xFFCECECE);
const Color primarySignupColor = Color(0xFFCECECE); // Inverted for signup
const Color secondarySignupColor = Color(0xFF542545); // Inverted for signup

const Color textPrimaryLoginColor = Colors.black;
const Color textSecondaryLoginColor = Colors.white;
const Color textPrimarySignupColor = Colors.white; // Inverted for signup
const Color textSecondarySignupColor = Colors.black; // Inverted for signup

const Color pageBackgroundColor = Colors.white;
const Color topTextColor = Colors.black;

// Helper functions to get colors based on the selected tab (0 for login, 1/2 for signup)
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