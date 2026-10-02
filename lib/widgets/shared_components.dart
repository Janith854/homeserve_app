import 'package:flutter/material.dart';
import 'package:homeserve_app/theme/app_theme.dart';

/// Matches CSS `.warnbanner` — danger/warning banner.
class WarningBanner extends StatelessWidget {
  final String message;
  final IconData icon;

  const WarningBanner({
    super.key,
    required this.message,
    this.icon = Icons.warning_amber_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.warningBannerBg,
        border: Border.all(color: AppColors.danger),
        borderRadius: BorderRadius.circular(AppRadius.btn),
      ),
      child: Row(
        children: [
          Icon(icon, size: AppIconSize.standard, color: AppColors.danger),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Text(message, style: AppTextStyles.warnBanner),
          ),
        ],
      ),
    );
  }
}

/// Matches CSS `.card` — generic content card.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Axis direction;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.direction = Axis.horizontal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: child,
    );
  }
}

/// Matches CSS `.field` / `.field.filled` — form field container.
class AppField extends StatelessWidget {
  final String text;
  final bool isFilled;
  final Widget? suffixIcon;

  const AppField({
    super.key,
    required this.text,
    this.isFilled = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.btn),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: isFilled ? AppTextStyles.fieldFilled : AppTextStyles.field,
            ),
          ),
          ?suffixIcon,
        ],
      ),
    );
  }
}

/// Matches CSS `.mapbox` — map placeholder.
class MapBox extends StatelessWidget {
  final double height;
  final String? label;

  const MapBox({
    super.key,
    this.height = 130,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.card),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEEF4F2), Color(0xFFE3EDE9)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.location_on,
              color: AppColors.danger,
              size: 24,
            ),
            if (label != null)
              Text(
                label!,
                style: AppTextStyles.meta,
              ),
          ],
        ),
      ),
    );
  }
}

/// Matches CSS `.photo` — provider/service photo placeholder.
class PhotoPlaceholder extends StatelessWidget {
  final double width;
  final double height;
  final IconData icon;
  final bool isCircular;

  const PhotoPlaceholder({
    super.key,
    this.width = 56,
    this.height = 56,
    this.icon = Icons.build,
    this.isCircular = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: isCircular
            ? null
            : BorderRadius.circular(AppRadius.btnSmall),
        shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryLight, AppColors.photoGradientEnd],
        ),
      ),
      child: Center(
        child: Icon(
          icon,
          size: width * 0.4,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
