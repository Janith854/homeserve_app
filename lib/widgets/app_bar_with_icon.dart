import 'package:flutter/material.dart';
import 'package:homeserve_app/theme/app_theme.dart';

/// Matches CSS `.appbar` — custom app bar row with optional back/menu icon,
/// title, and trailing action buttons.
class AppBarWithIcon extends StatelessWidget {
  final String title;
  final IconData? leadingIcon;
  final VoidCallback? onLeadingTap;
  final VoidCallback? onLeadingPressed;
  final IconData? trailingIcon;
  final VoidCallback? onTrailingPressed;
  final bool showBadge;
  final List<Widget>? actions;

  const AppBarWithIcon({
    super.key,
    required this.title,
    this.leadingIcon = Icons.arrow_back_rounded,
    this.onLeadingTap,
    this.onLeadingPressed,
    this.trailingIcon,
    this.onTrailingPressed,
    this.showBadge = false,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveLeadingCallback = onLeadingPressed ?? onLeadingTap;

    return Row(
      children: [
        if (leadingIcon != null) ...[
          IconBtn(
            icon: leadingIcon!,
            onTap: effectiveLeadingCallback,
          ),
          const SizedBox(width: AppSpacing.lg),
        ],
        Expanded(
          child: Text(title, style: AppTextStyles.appBarTitle),
        ),
        if (actions != null)
          ...actions!
        else if (trailingIcon != null)
          IconBtn(
            icon: trailingIcon!,
            hasBadge: showBadge,
            onTap: onTrailingPressed,
          )
        else if (leadingIcon != null)
          const SizedBox(width: 32),
      ],
    );
  }
}

/// Matches CSS `.iconbtn` — 32×32 circular icon button with border.
class IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool hasBadge;

  const IconBtn({
    super.key,
    required this.icon,
    this.onTap,
    this.hasBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(icon, size: AppIconSize.standard, color: AppColors.text),
          ),
          // Notification badge dot — matches .iconbtn.badge::after
          if (hasBadge)
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.danger,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
