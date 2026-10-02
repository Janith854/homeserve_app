import 'package:flutter/material.dart';
import 'package:homeserve_app/theme/app_theme.dart';

/// Matches CSS `.bottomnav` — bottom navigation bar.
class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final List<BottomNavItem> items;
  final ValueChanged<int>? onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    this.items = const [
      BottomNavItem(icon: Icons.home_rounded, label: 'Home'),
      BottomNavItem(icon: Icons.calendar_today_rounded, label: 'Bookings'),
      BottomNavItem(icon: Icons.person_outline_rounded, label: 'Profile'),
    ],
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final isActive = index == currentIndex;
            return GestureDetector(
              onTap: () => onTap?.call(index),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    items[index].icon,
                    size: AppIconSize.nav,
                    color: isActive ? AppColors.primary : AppColors.muted,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    items[index].label,
                    style: isActive
                        ? AppTextStyles.navItemActive
                        : AppTextStyles.navItem,
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

/// Data class for bottom nav items.
class BottomNavItem {
  final IconData icon;
  final String label;

  const BottomNavItem({
    required this.icon,
    required this.label,
  });
}
