// Screen 5 — Price Estimate
// Implements: FR05 — Automated Cost Estimation (Member 2)

import 'package:flutter/material.dart';
import 'package:homeserve_app/theme/app_theme.dart';
import 'package:homeserve_app/widgets/widgets.dart';

/// Screen 5: Price Estimate — FR05
class PriceEstimateScreen extends StatelessWidget {
  final String providerId;
  final VoidCallback? onProceedToBooking;
  final VoidCallback? onBack;

  const PriceEstimateScreen({
    super.key,
    this.providerId = 'p1',
    this.onProceedToBooking,
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
                    title: 'Price Estimate',
                    onLeadingPressed: onBack ?? () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Selected Provider Summary Card
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(AppRadius.card),
                    ),
                    child: Row(
                      children: [
                        const PhotoPlaceholder(
                          width: 40,
                          height: 40,
                          icon: Icons.build_rounded,
                        ),
                        const SizedBox(width: AppSpacing.xl),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Rohan De Silva', style: AppTextStyles.name),
                              const SizedBox(height: AppSpacing.xs),
                              Text('Plumbing · Pipe Repair', style: AppTextStyles.meta),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Cost Breakdown Section
                  Text(
                    'Cost Breakdown',
                    style: AppTextStyles.meta.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Service Charge Row
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Service Charge', style: AppTextStyles.rowSplit),
                        Text('Rs. 1,200', style: AppTextStyles.rowSplit.copyWith(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),

                  // Call-out Fee Row
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Call-out Fee', style: AppTextStyles.rowSplit),
                        Text('Rs. 300', style: AppTextStyles.rowSplit.copyWith(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  const Divider(color: AppColors.border, thickness: 1),
                  const SizedBox(height: AppSpacing.md),

                  // Estimated Total Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Estimated Total', style: AppTextStyles.totalRow),
                      Text('Rs. 1,500', style: AppTextStyles.totalRow),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Disclaimer
                  Text(
                    'Final price may vary based on job scope',
                    style: AppTextStyles.meta,
                    textAlign: TextAlign.center,
                  ),

                  const Spacer(),
                  const SizedBox(height: AppSpacing.xxl),

                  // Proceed to Booking Primary Button
                  PrimaryButton(
                    label: 'Proceed to Booking',
                    onPressed: onProceedToBooking ?? () {
                      // TODO: Navigate to Booking & Scheduling (Screen 6)
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
