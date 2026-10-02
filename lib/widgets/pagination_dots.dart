import 'package:flutter/material.dart';
import 'package:homeserve_app/theme/app_theme.dart';

/// Matches CSS `.dots` / `.dotp` — onboarding pagination dots.
class PaginationDots extends StatelessWidget {
  final int total;
  final int current;

  const PaginationDots({
    super.key,
    required this.total,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (index) {
        final isActive = index == current;
        return Container(
          margin: EdgeInsets.only(right: index < total - 1 ? 5 : 0),
          width: isActive ? 16 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.border,
            borderRadius: BorderRadius.circular(AppRadius.checkbox),
          ),
        );
      }),
    );
  }
}
