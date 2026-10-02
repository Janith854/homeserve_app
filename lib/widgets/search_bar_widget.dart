import 'package:flutter/material.dart';
import 'package:homeserve_app/theme/app_theme.dart';

/// Matches CSS `.searchbar` — search input with icon.
class SearchBarWidget extends StatelessWidget {
  final String placeholder;
  final String? hintText;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  const SearchBarWidget({
    super.key,
    this.placeholder = 'Search services...',
    this.hintText,
    this.onTap,
    this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveHint = hintText ?? placeholder;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.xl,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.search,
              size: AppIconSize.standard,
              color: AppColors.muted,
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: controller != null || onChanged != null
                  ? TextField(
                      controller: controller,
                      onChanged: onChanged,
                      style: AppTextStyles.searchBar.copyWith(
                        color: AppColors.text,
                      ),
                      decoration: InputDecoration(
                        hintText: effectiveHint,
                        hintStyle: AppTextStyles.searchBar,
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    )
                  : Text(effectiveHint, style: AppTextStyles.searchBar),
            ),
          ],
        ),
      ),
    );
  }
}
