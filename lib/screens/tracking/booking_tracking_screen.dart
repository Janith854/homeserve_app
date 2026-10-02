// Screen 8 — Booking Status Tracking
// Implements: FR08 — Real-Time Booking Status Tracking (Member 3)

import 'package:flutter/material.dart';
import 'package:homeserve_app/theme/app_theme.dart';
import 'package:homeserve_app/widgets/widgets.dart';

/// Screen 8: Booking Status Tracking — FR08
class BookingTrackingScreen extends StatelessWidget {
  final String bookingId;
  final VoidCallback? onCancelBooking;
  final VoidCallback? onCallProvider;
  final VoidCallback? onBack;

  const BookingTrackingScreen({
    super.key,
    this.bookingId = 'b1',
    this.onCancelBooking,
    this.onCallProvider,
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
                    title: 'Track Booking',
                    onLeadingPressed: onBack ?? () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // 4-Step Progress Stepper
                  const StepperProgress(
                    steps: ['Pending', 'Confirmed', 'On the Way', 'Done'],
                    currentStep: 2, // 0-indexed: 2 is step 3 ("On the Way")
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Live Map View Box
                  const MapBox(
                    height: 140,
                    label: 'Live map view',
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Assigned Provider Card with Quick Call Action
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
                          isCircular: true,
                        ),
                        const SizedBox(width: AppSpacing.xl),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Rohan De Silva', style: AppTextStyles.name),
                              const SizedBox(height: AppSpacing.xs),
                              Text('Arriving in 12 min', style: AppTextStyles.meta),
                            ],
                          ),
                        ),
                        // Call Provider Button
                        GestureDetector(
                          onTap: onCallProvider ?? () {
                            // TODO: Launch phone dialer / in-app voice call
                          },
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                            ),
                            child: const Icon(
                              Icons.phone,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),
                  const SizedBox(height: AppSpacing.xxl),

                  // Cancel Booking Danger Button
                  DangerButton(
                    label: 'Cancel Booking',
                    isOutline: true,
                    onPressed: onCancelBooking ?? () {
                      // TODO: Firebase Firestore update booking status to 'cancelled'
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
