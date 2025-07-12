import 'package:flutter/material.dart';

class NavBarItemData {
  final String label;
  final Icon icon;
  final Icon? activeIcon;

  NavBarItemData({
    required this.label,
    required this.icon,
    this.activeIcon,
  });
}

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final List<NavBarItemData> itemsData;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.itemsData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    const navBarHeight = 65.0;

    return Container(
      height: navBarHeight,
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(itemsData.length, (index) {
          final item = itemsData[index];
          final bool isSelected = selectedIndex == index;

          return Expanded(
            child: GestureDetector(
              onTap: () => onItemTapped(index),
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                height: navBarHeight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    IconTheme(
                      data: IconThemeData(
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.onSurface.withOpacity(0.6),
                        size: 26,
                      ),
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
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
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
    );
  }
}