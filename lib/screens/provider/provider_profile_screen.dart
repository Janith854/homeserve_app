// Screen 4 — Provider Profile
// Implements: FR04 — Service Provider Profile (Member 2)

import 'package:flutter/material.dart';
import 'package:homeserve_app/theme/app_theme.dart';
import 'package:homeserve_app/widgets/widgets.dart';

/// Screen 4: Provider Profile — FR04
class ProviderProfileScreen extends StatelessWidget {
  final String providerId;
  final VoidCallback? onBookNow;
  final VoidCallback? onBack;

  const ProviderProfileScreen({
    super.key,
    this.providerId = 'p1',
    this.onBookNow,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl + 2, // 14px
            vertical: AppSpacing.xxl + 2, // 14px
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom -
                  28,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Bar
                  AppBarWithIcon(
                    title: 'Profile',
                    onLeadingPressed: onBack ?? () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Provider Profile Header
                  Center(
                    child: Column(
                      children: [
                        const PhotoPlaceholder(
                          width: 70,
                          height: 70,
                          icon: Icons.build_rounded,
                          isCircular: true,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'Rohan De Silva',
                          style: AppTextStyles.h1.copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        const StatusBadge.verified(
                          label: 'Verified Provider',
                          icon: Icons.verified_user_rounded,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const RatingStars(rating: 4.0),
                            const SizedBox(width: AppSpacing.md),
                            Text('(32 reviews)', style: AppTextStyles.meta),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Skill Category Chips
                  const Row(
                    children: [
                      ChipFilter(label: 'Plumbing', isActive: false),
                      SizedBox(width: AppSpacing.md),
                      ChipFilter(label: 'Pipe Repairs', isActive: false),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // About Section
                  Text(
                    'About',
                    style: AppTextStyles.meta.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '8 years experience fixing residential plumbing issues across Colombo suburbs.',
                    style: AppTextStyles.meta.copyWith(color: AppColors.text, height: 1.4),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Reviews Section
                  Text(
                    'Reviews',
                    style: AppTextStyles.meta.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(AppRadius.card),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '"Very punctual and professional."',
                          style: AppTextStyles.name.copyWith(fontSize: 11.5),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        const RatingStars(rating: 5.0, size: 11),
                      ],
                    ),
                  ),

                  const Spacer(),
                  const SizedBox(height: AppSpacing.xxl),

                  // Book Now Primary Button
                  PrimaryButton(
                    label: 'Book Now',
                    onPressed: onBookNow ?? () {
                      // TODO: Navigate to Price Estimate (Screen 5)
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
