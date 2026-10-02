import 'package:flutter/material.dart';
import 'package:homeserve_app/theme/app_theme.dart';

/// Matches CSS `.btn.primary` — full-width primary teal button.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isSmall;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isSmall = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isSmall ? null : double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.7),
          elevation: 0,
          padding: EdgeInsets.symmetric(
            horizontal: isSmall ? 10 : 12,
            vertical: isSmall ? 8 : 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              isSmall ? AppRadius.btnSmall : AppRadius.btn,
            ),
          ),
          textStyle: isSmall ? AppTextStyles.buttonSmall : AppTextStyles.button,
        ),
        child: isLoading
            ? SizedBox(
                width: isSmall ? 14 : 18,
                height: isSmall ? 14 : 18,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisSize: isSmall ? MainAxisSize.min : MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: isSmall ? 13 : 16),
                    const SizedBox(width: AppSpacing.md),
                  ],
                  Text(label),
                ],
              ),
      ),
    );
  }
}

/// Matches CSS `.btn.outline` — outline-styled button.
class OutlineAppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isSmall;

  const OutlineAppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isSmall ? null : double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          elevation: 0,
          padding: EdgeInsets.symmetric(
            horizontal: isSmall ? 10 : 12,
            vertical: isSmall ? 8 : 12,
          ),
          side: const BorderSide(color: AppColors.primary, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              isSmall ? AppRadius.btnSmall : AppRadius.btn,
            ),
          ),
          textStyle: isSmall
              ? AppTextStyles.buttonSmall.copyWith(color: AppColors.primary)
              : AppTextStyles.button.copyWith(color: AppColors.primary),
        ),
        child: Row(
          mainAxisSize: isSmall ? MainAxisSize.min : MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: isSmall ? 13 : 16),
              const SizedBox(width: AppSpacing.md),
            ],
            Text(label),
          ],
        ),
      ),
    );
  }
}

/// Matches CSS `.btn.danger-outline` and `.btn.danger`.
class DangerButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isSmall;
  final bool isOutline;

  const DangerButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isSmall = false,
    this.isOutline = true,
  });

  @override
  Widget build(BuildContext context) {
    final style = isOutline
        ? OutlinedButton.styleFrom(
            foregroundColor: AppColors.danger,
            backgroundColor: Colors.white,
            elevation: 0,
            padding: EdgeInsets.symmetric(
              horizontal: isSmall ? 10 : 12,
              vertical: isSmall ? 8 : 12,
            ),
            side: const BorderSide(color: AppColors.danger, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                isSmall ? AppRadius.btnSmall : AppRadius.btn,
              ),
            ),
            textStyle: isSmall
                ? AppTextStyles.buttonSmall.copyWith(color: AppColors.danger)
                : AppTextStyles.button.copyWith(color: AppColors.danger),
          )
        : ElevatedButton.styleFrom(
            backgroundColor: AppColors.danger,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: EdgeInsets.symmetric(
              horizontal: isSmall ? 10 : 12,
              vertical: isSmall ? 8 : 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                isSmall ? AppRadius.btnSmall : AppRadius.btn,
              ),
            ),
            textStyle:
                isSmall ? AppTextStyles.buttonSmall : AppTextStyles.button,
          );

    final child = Row(
      mainAxisSize: isSmall ? MainAxisSize.min : MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: isSmall ? 13 : 16),
          const SizedBox(width: AppSpacing.md),
        ],
        Text(label),
      ],
    );

    return SizedBox(
      width: isSmall ? null : double.infinity,
      child: isOutline
          ? OutlinedButton(onPressed: onPressed, style: style, child: child)
          : ElevatedButton(onPressed: onPressed, style: style, child: child),
    );
  }
}
