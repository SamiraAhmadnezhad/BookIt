import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final List<NavBarItemData> itemsData; // لیست داده‌های آیتم‌ها

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.itemsData,
  });

  @override
  Widget build(BuildContext context) {
    final Color navBarBackgroundColor = Colors.white;
    const double navBarHeight = 65.0;
    const double itemHorizontalPadding = 10.0;
    final Color selectedItemColor = const Color(0xFF542545);
    final Color unselectedItemColor = Colors.grey.shade500;
    final Color selectedPillColor = selectedItemColor.withOpacity(0.12); // رنگ پس‌زمینه آیتم فعال

    final double screenWidth = MediaQuery.of(context).size.width;
    // عرض هر آیتم به طور مساوی تقسیم می‌شود
    final double itemWidth = screenWidth / itemsData.length;

    return Container(
      height: navBarHeight,
      decoration: BoxDecoration(
        color: navBarBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, -2),
          ),
        ],
        // اگر می‌خواهید فقط گوشه‌های بالای کانتینر اصلی گرد باشد:
        // borderRadius: const BorderRadius.only(
        //   topLeft: Radius.circular(20.0),
        //   topRight: Radius.circular(20.0),
        // ),
      ),
      child: Stack(
        children: [


          // آیتم‌های نوار ناوبری
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(itemsData.length, (index) {
              final item = itemsData[index];
              final bool isSelected = selectedIndex == index;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onItemTapped(index),
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox( // SizedBox برای کنترل بهتر فضای قابل تپ
                    height: navBarHeight,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        AnimatedTheme(
                          data: ThemeData(
                            iconTheme: IconThemeData(
                              color: isSelected ? selectedItemColor : unselectedItemColor,
                              size: 26, // اندازه آیکون
                            ),
                          ),
                          duration: const Duration(milliseconds: 250),
                          child: isSelected && item.activeIcon != null
                              ? item.activeIcon!
                              : item.icon,
                        ),

                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: ScaleTransition(scale: animation, child: child),
                            );
                          },
                          child: isSelected
                              ? Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Text(
                              item.label,
                              key: ValueKey<String>(item.label),
                              style: TextStyle(
                                color: selectedItemColor,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Vazirmatn',
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          )
                              : SizedBox(key: ValueKey<String>('empty_${item.label}')),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class NavBarItemData {
  final String label;
  final Icon icon;
  final Icon? activeIcon; // آیکون اختیاری برای حالت فعال

  NavBarItemData({
    required this.label,
    required this.icon,
    this.activeIcon,
  });
}