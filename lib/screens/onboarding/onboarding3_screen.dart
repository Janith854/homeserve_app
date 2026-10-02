// Screen 0c — Onboarding 3/3
// Implements: User Onboarding Flow (Member 1)

import 'package:flutter/material.dart';
import 'package:homeserve_app/theme/app_theme.dart';
import 'package:homeserve_app/widgets/widgets.dart';

/// Screen 0c: Onboarding 3/3
/// "Track Bookings Real-Time"
class Onboarding3Screen extends StatelessWidget {
  final VoidCallback? onGetStarted;
  final VoidCallback? onSkip;

  const Onboarding3Screen({
    super.key,
    this.onGetStarted,
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
                  color: AppColors.onboard3Bg,
                  borderRadius: BorderRadius.circular(AppRadius.onboardPhoto),
                ),
                child: Center(
                  child: CustomPaint(
                    size: const Size(200, 140),
                    painter: _Onboarding3IllustrationPainter(),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.x4l),

              // Title
              Text(
                'Track Bookings Real-Time',
                style: AppTextStyles.onboardTitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Subtitle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Text(
                  'Monitor status progression live, with clear updates from booking to dispatch to your front door.',
                  style: AppTextStyles.onboardSub,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.x4l),

              // Pagination Dots
              const PaginationDots(total: 3, current: 2),

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
                    label: 'Get Started',
                    isSmall: true,
                    onPressed: onGetStarted ?? () {
                      // TODO: Navigate to Login / Sign Up
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

/// Custom painter for Onboarding 3 map road + service truck + pin illustration
class _Onboarding3IllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = const Color(0xFFC9D6DC)
      ..strokeWidth = 24
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dashPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final truckBodyPaint = Paint()..color = AppColors.primary;
    final truckCabPaint = Paint()..color = AppColors.primaryDark;
    final truckWindowPaint = Paint()..color = const Color(0xFFCFEAE3);
    final wheelPaint = Paint()..color = const Color(0xFF2B2B2B);
    final hubcapPaint = Paint()..color = const Color(0xFFCCCCCC);
    final pinPaint = Paint()..color = AppColors.danger;
    final pinHolePaint = Paint()..color = Colors.white;

    // Road Curve
    final roadPath = Path()
      ..moveTo(0, size.height * 0.8)
      ..quadraticBezierTo(
        size.width * 0.4,
        size.height * 0.45,
        size.width,
        size.height * 0.8,
      );
    canvas.drawPath(roadPath, roadPaint);
    canvas.drawPath(roadPath, dashPaint);

    // Truck
    final truckX = size.width * 0.25;
    final truckY = size.height * 0.48;

    // Cargo Body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(truckX, truckY, 56, 28),
        const Radius.circular(5),
      ),
      truckBodyPaint,
    );

    // Cab
    final cabPath = Path()
      ..moveTo(truckX + 56, truckY + 6)
      ..lineTo(truckX + 70, truckY + 6)
      ..lineTo(truckX + 80, truckY + 18)
      ..lineTo(truckX + 80, truckY + 28)
      ..lineTo(truckX + 56, truckY + 28)
      ..close();
    canvas.drawPath(cabPath, truckCabPaint);

    // Windows
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(truckX + 60, truckY + 10, 14, 8),
        const Radius.circular(2),
      ),
      truckWindowPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(truckX + 8, truckY + 6, 16, 10),
        const Radius.circular(2),
      ),
      truckWindowPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(truckX + 28, truckY + 6, 16, 10),
        const Radius.circular(2),
      ),
      truckWindowPaint,
    );

    // Wheels
    canvas.drawCircle(Offset(truckX + 12, truckY + 30), 7, wheelPaint);
    canvas.drawCircle(Offset(truckX + 12, truckY + 30), 2.5, hubcapPaint);
    canvas.drawCircle(Offset(truckX + 68, truckY + 30), 7, wheelPaint);
    canvas.drawCircle(Offset(truckX + 68, truckY + 30), 2.5, hubcapPaint);

    // Location Pin at upper right destination
    final pinX = size.width * 0.78;
    final pinY = size.height * 0.18;
    final pinPath = Path()
      ..moveTo(pinX, pinY + 24)
      ..cubicTo(
        pinX - 12,
        pinY + 12,
        pinX - 12,
        pinY,
        pinX,
        pinY,
      )
      ..cubicTo(
        pinX + 12,
        pinY,
        pinX + 12,
        pinY + 12,
        pinX,
        pinY + 24,
      )
      ..close();
    canvas.drawPath(pinPath, pinPaint);
    canvas.drawCircle(Offset(pinX, pinY + 8), 4, pinHolePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
