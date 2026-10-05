// Screen 0a — Onboarding 1/3
// Implements: User Onboarding Flow (Member 1)

import 'package:flutter/material.dart';
import 'package:homeserve_app/theme/app_theme.dart';
import 'package:homeserve_app/widgets/widgets.dart';

/// Screen 0a: Onboarding 1/3
/// "Find Trusted Local Experts"
class Onboarding1Screen extends StatelessWidget {
  final VoidCallback? onNext;
  final VoidCallback? onSkip;

  const Onboarding1Screen({
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
              // Top Bar with Skip
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onSkip ?? () {},
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.text,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(40, 36),
                  ),
                  child: Text(
                    'Skip',
                    style: AppTextStyles.meta.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Illustration Box
              Container(
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                ),
                child: Center(
                  child: CustomPaint(
                    size: const Size(200, 180),
                    painter: _Onboarding1IllustrationPainter(),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.x4l),

              // Title
              Text(
                'Quality Home\nServices',
                style: AppTextStyles.h1.copyWith(
                  color: AppColors.primaryDark,
                  fontSize: 28,
                  height: 1.2,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: AppSpacing.md),

              // Subtitle
              Text(
                'Find trusted professionals for\nall your home service needs.',
                style: AppTextStyles.meta.copyWith(
                  fontSize: 16,
                  height: 1.5,
                ),
                textAlign: TextAlign.left,
              ),
              
              const Spacer(),

              // Pagination Dots
              const Center(
                child: PaginationDots(total: 3, current: 0),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Bottom Navigation Actions
              PrimaryButton(
                label: 'Next',
                icon: Icons.arrow_forward,
                isSmall: false,
                onPressed: onNext ?? () {},
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter for Onboarding 1 house + technician illustration
class _Onboarding1IllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final groundPaint = Paint()..color = const Color(0xFFE4CFB6);
    final houseWallPaint = Paint()..color = const Color(0xFFC97B4A);
    final roofPaint = Paint()..color = const Color(0xFF8C4A2A);
    final doorPaint = Paint()..color = const Color(0xFF5A3520);
    final facePaint = Paint()..color = const Color(0xFFF2C9A0);
    final hairPaint = Paint()..color = AppColors.accent;
    final bodyPaint = Paint()..color = AppColors.primary;
    final toolPaint = Paint()..color = const Color(0xFF8C8C8C);

    // Ground line
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, size.height * 0.75, size.width, size.height * 0.25),
        const Radius.circular(8),
      ),
      groundPaint,
    );

    // House Wall
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.1, size.height * 0.42, 52, 48),
        const Radius.circular(4),
      ),
      houseWallPaint,
    );

    // House Roof
    final roofPath = Path()
      ..moveTo(size.width * 0.08, size.height * 0.42)
      ..lineTo(size.width * 0.1 + 26, size.height * 0.2)
      ..lineTo(size.width * 0.1 + 56, size.height * 0.42)
      ..close();
    canvas.drawPath(roofPath, roofPaint);

    // House Door
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.1 + 18, size.height * 0.56, 15, 28),
      doorPaint,
    );

    // Technician Head
    final headCenter = Offset(size.width * 0.65, size.height * 0.45);
    canvas.drawCircle(headCenter, 20, facePaint);

    // Technician Cap/Hair
    final capPath = Path()
      ..addArc(
        Rect.fromCircle(center: headCenter, radius: 20),
        3.14,
        3.14,
      );
    canvas.drawPath(capPath, hairPaint);

    // Technician Body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.65 - 14, size.height * 0.62, 28, 36),
        const Radius.circular(8),
      ),
      bodyPaint,
    );

    // Arms
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.65 - 24, size.height * 0.66, 12, 26),
        const Radius.circular(6),
      ),
      bodyPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.65 + 12, size.height * 0.66, 12, 24),
        const Radius.circular(6),
      ),
      bodyPaint,
    );

    // Tool (Wrench in hand)
    final toolRect = Rect.fromLTWH(size.width * 0.65 + 16, size.height * 0.72, 20, 6);
    canvas.save();
    canvas.translate(toolRect.center.dx, toolRect.center.dy);
    canvas.rotate(0.4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: 22, height: 6),
        const Radius.circular(3),
      ),
      toolPaint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
