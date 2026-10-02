import 'package:flutter/material.dart';
import 'package:homeserve_app/theme/app_theme.dart';

/// Matches CSS `.chip` / `.chip.active` — filter/tag chip.
class ChipFilter extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const ChipFilter({
    super.key,
    required this.label,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.surface,
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Text(
          label,
          style: AppTextStyles.chip.copyWith(
            color: isActive ? Colors.white : AppColors.text,
          ),
        ),
      ),
    );
  }
}
