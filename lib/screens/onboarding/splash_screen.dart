import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:homeserve_app/routes/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    if (hasSeenOnboarding) {
      context.go(AppRouteNames.login);
    } else {
      context.go(AppRouteNames.onboarding1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/homeserve_logo.jpg',
                  width: 250,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Trusted help, right at home',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          // Bottom Wavy Shapes
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 250,
              child: CustomPaint(
                painter: _SplashWavesPainter(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashWavesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final tealPaint = Paint()..color = const Color(0xFF0F6B5C);
    final amberPaint = Paint()..color = const Color(0xFFF2A93B);

    // Amber wave (back)
    final amberPath = Path()
      ..moveTo(0, size.height * 0.4)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.7, size.width * 0.5, size.height * 0.5)
      ..quadraticBezierTo(size.width * 0.8, size.height * 0.2, size.width, size.height * 0.4)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(amberPath, amberPaint);

    // Teal wave (front)
    final tealPath = Path()
      ..moveTo(0, size.height * 0.1)
      ..quadraticBezierTo(size.width * 0.3, size.height * 0.2, size.width * 0.6, size.height * 0.6)
      ..quadraticBezierTo(size.width * 0.8, size.height * 0.85, size.width, size.height * 0.8)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(tealPath, tealPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
