import 'package:flutter/material.dart';
import 'package:homeserve_app/theme/app_theme.dart';

/// Status badge types matching various CSS classes.
enum StatusBadgeType {
  verified,   // .badge-verified
  highSev,    // .sevtag.high
  medSev,     // .sevtag.med
  lowSev,     // .sevtag.low
}

/// Matches CSS `.badge-verified` and `.sevtag.*` — status pills.
class StatusBadge extends StatelessWidget {
  final String label;
  final StatusBadgeType type;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    this.type = StatusBadgeType.verified,
    this.icon,
  });

  const StatusBadge.verified({
    super.key,
    this.label = 'Verified Provider',
    this.type = StatusBadgeType.verified,
    this.icon = Icons.verified_user_rounded,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    double radius;
    EdgeInsets padding;
    TextStyle textStyle;

    switch (type) {
      case StatusBadgeType.verified:
        bgColor = AppColors.primaryLight;
        textColor = AppColors.primaryDark;
        radius = AppRadius.pill;
        padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4);
        textStyle = AppTextStyles.badgeVerified;
        break;
      case StatusBadgeType.highSev:
        bgColor = AppColors.warningBannerBg;
        textColor = AppColors.warningBannerText;
        radius = AppRadius.severityTag;
        padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 3);
        textStyle = AppTextStyles.severityTag;
        break;
      case StatusBadgeType.medSev:
        bgColor = AppColors.severityMedBg;
        textColor = AppColors.severityMedText;
        radius = AppRadius.severityTag;
        padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 3);
        textStyle = AppTextStyles.severityTag;
        break;
      case StatusBadgeType.lowSev:
        bgColor = AppColors.primaryLight;
        textColor = AppColors.primaryDark;
        radius = AppRadius.severityTag;
        padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 3);
        textStyle = AppTextStyles.severityTag;
        break;
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: AppIconSize.badgeVerified, color: textColor),
            const SizedBox(width: AppSpacing.sm),
          ],
          Text(label, style: textStyle.copyWith(color: textColor)),
        ],
      ),
    );
  }
}
