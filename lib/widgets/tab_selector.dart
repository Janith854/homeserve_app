import 'package:flutter/material.dart';
import 'package:homeserve_app/theme/app_theme.dart';

/// Matches CSS `.tab` / `.tab.active` — segmented tab bar.
class TabSelector extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int>? onTap;

  const TabSelector({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(tabs.length, (index) {
        final isActive = index == selectedIndex;
        return Expanded(
          child: GestureDetector(
            onTap: () => onTap?.call(index),
            child: Container(
              margin: EdgeInsets.only(
                right: index < tabs.length - 1 ? AppSpacing.md : 0,
              ),
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.surface,
                border: Border.all(
                  color: isActive ? AppColors.primary : AppColors.border,
                ),
                borderRadius: BorderRadius.circular(AppRadius.btnSmall),
              ),
              child: Text(
                tabs[index],
                textAlign: TextAlign.center,
                style: AppTextStyles.tab.copyWith(
                  color: isActive ? Colors.white : AppColors.muted,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
