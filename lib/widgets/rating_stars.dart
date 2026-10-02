import 'package:flutter/material.dart';
import 'package:homeserve_app/theme/app_theme.dart';

/// Matches CSS `.stars` — small rating stars row.
class RatingStars extends StatelessWidget {
  final double rating;
  final int maxStars;
  final bool isLarge;
  final double? size;
  final Color? color;

  const RatingStars({
    super.key,
    required this.rating,
    this.maxStars = 5,
    this.isLarge = false,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = size ?? (isLarge ? AppIconSize.starLarge : AppIconSize.star);
    final gap = isLarge ? AppSpacing.md : AppSpacing.xs;
    final starColor = color ?? AppColors.accent;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxStars, (index) {
        final isFilled = index < rating.floor();
        final isHalf = !isFilled && index < rating;

        return Padding(
          padding: EdgeInsets.only(right: index < maxStars - 1 ? gap : 0),
          child: Icon(
            isFilled
                ? Icons.star_rounded
                : isHalf
                    ? Icons.star_half_rounded
                    : Icons.star_border_rounded,
            size: iconSize,
            color: isFilled || isHalf ? starColor : AppColors.border,
          ),
        );
      }),
    );
  }
}
