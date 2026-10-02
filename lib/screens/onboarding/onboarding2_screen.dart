// Screen 0b — Onboarding 2/3
// Implements: User Onboarding Flow (Member 1)

import 'package:flutter/material.dart';
import 'package:homeserve_app/theme/app_theme.dart';
import 'package:homeserve_app/widgets/widgets.dart';

/// Screen 0b: Onboarding 2/3
/// "Transparent Pricing & Dates"
class Onboarding2Screen extends StatelessWidget {
  final VoidCallback? onNext;
  final VoidCallback? onSkip;

  const Onboarding2Screen({
    super.key,
    this.onNext,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl + 2, // 14px
            vertical: AppSpacing.xxl + 2, // 14px
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Illustration Box
              Container(
                height: 190,
                decoration: BoxDecoration(
                  color: AppColors.onboard2Bg,
                  borderRadius: BorderRadius.circular(AppRadius.onboardPhoto),
                ),
                child: Center(
                  child: CustomPaint(
                    size: const Size(200, 140),
                    painter: _Onboarding2IllustrationPainter(),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.x4l),

              // Title
              Text(
                'Transparent Pricing & Dates',
                style: AppTextStyles.onboardTitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Subtitle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Text(
                  'Review clear upfront cost estimates and easily schedule your booking on your own timeline.',
                  style: AppTextStyles.onboardSub,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.x4l),

              // Pagination Dots
              const PaginationDots(total: 3, current: 1),

              const Spacer(),

              // Bottom Navigation Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: onSkip ?? () {
                      // TODO: Firebase / Navigation to Login
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(40, 36),
                    ),
                    child: Text(
                      'Skip',
                      style: AppTextStyles.link,
                    ),
                  ),
                  PrimaryButton(
                    label: 'Next',
                    isSmall: true,
                    icon: Icons.arrow_forward,
                    onPressed: onNext ?? () {
                      // TODO: Navigate to Onboarding 3/3
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter for Onboarding 2 calendar + price badge illustration
class _Onboarding2IllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final whitePaint = Paint()..color = Colors.white;
    final primaryPaint = Paint()..color = AppColors.primary;
    final primaryDarkPaint = Paint()..color = AppColors.primaryDark;
    final cellPaint = Paint()..color = AppColors.border;
    final tagBgPaint = Paint()..color = AppColors.accent;
    final tagBorderPaint = Paint()
      ..color = const Color(0xFFC9860F)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Calendar Card Body
    final calRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.15, size.height * 0.12, 110, 100),
      const Radius.circular(12),
    );
    canvas.drawRRect(calRect, whitePaint);
    canvas.drawRRect(calRect, borderPaint);

    // Calendar Header (Teal bar)
    final headerRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(size.width * 0.15, size.height * 0.12, 110, 24),
      topLeft: const Radius.circular(12),
      topRight: const Radius.circular(12),
    );
    canvas.drawRRect(headerRect, primaryPaint);

    // Binder rings
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.15 + 18, size.height * 0.06, 6, 16),
        const Radius.circular(3),
      ),
      primaryDarkPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.15 + 86, size.height * 0.06, 6, 16),
        const Radius.circular(3),
      ),
      primaryDarkPaint,
    );

    // Grid cells inside calendar
    final startX = size.width * 0.15 + 12;
    final startY = size.height * 0.12 + 34;
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 4; col++) {
        final cellRRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(startX + col * 22, startY + row * 18, 16, 12),
          const Radius.circular(2),
        );
        // Highlight one active day in row 1, col 1
        if (row == 1 && col == 1) {
          canvas.drawRRect(cellRRect, primaryPaint);
        } else {
          canvas.drawRRect(cellRRect, cellPaint);
        }
      }
    }

    // Price Tag / Badge overlapping bottom right
    final tagPath = Path()
      ..moveTo(size.width * 0.58, size.height * 0.58)
      ..lineTo(size.width * 0.58 + 26, size.height * 0.58)
      ..lineTo(size.width * 0.58 + 44, size.height * 0.74)
      ..lineTo(size.width * 0.58 + 44, size.height * 0.94)
      ..lineTo(size.width * 0.58 + 18, size.height * 0.94)
      ..lineTo(size.width * 0.58, size.height * 0.76)
      ..close();
    canvas.drawPath(tagPath, tagBgPaint);
    canvas.drawPath(tagPath, tagBorderPaint);

    // Price tag small hole
    canvas.drawCircle(
      Offset(size.width * 0.58 + 12, size.height * 0.68),
      3.5,
      whitePaint,
    );

    // "Rs" text on price badge
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Rs',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w700,
          fontSize: 13,
          color: Color(0xFF7A4A10),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(size.width * 0.58 + 18, size.height * 0.75),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
