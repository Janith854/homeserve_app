import 'package:flutter/material.dart';
import 'package:homeserve_app/theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    IconData icon;
    String label = status.toUpperCase();

    final s = status.toLowerCase().trim();

    if (s == 'pending') {
      bgColor = AppColors.warningBannerBg;
      textColor = const Color(0xFFC9860F); // Amber text
      icon = Icons.access_time_rounded;
      label = 'Pending';
    } else if (s == 'confirmed' || s == 'approved') {
      bgColor = const Color(0xFFE3F2FD); // Light Blue
      textColor = const Color(0xFF1976D2); // Blue
      icon = Icons.check_circle_outline_rounded;
      label = s == 'confirmed' ? 'Confirmed' : 'Approved';
    } else if (s == 'in_progress' || s == 'in progress') {
      bgColor = const Color(0xFFF3E5F5); // Light Purple
      textColor = const Color(0xFF7B1FA2); // Purple
      icon = Icons.sync_rounded;
      label = 'In Progress';
    } else if (s == 'completed' || s == 'success') {
      bgColor = const Color(0xFFE8F5E9); // Light Green
      textColor = const Color(0xFF388E3C); // Green
      icon = Icons.check_circle_rounded;
      label = s == 'completed' ? 'Completed' : 'Success';
    } else if (s == 'rejected' || s == 'cancelled' || s == 'canceled') {
      bgColor = AppColors.warningBannerBg; // Light red/pinkish
      textColor = AppColors.danger; // Red
      icon = Icons.cancel_rounded;
      label = s == 'rejected' ? 'Rejected' : 'Cancelled';
    } else if (s == 'failed' || s == 'error') {
      bgColor = const Color(0xFFFFEBEE);
      textColor = const Color(0xFFD32F2F); // Dark Red
      icon = Icons.error_rounded;
      label = s == 'failed' ? 'Failed' : 'Error';
    } else if (s == 'verified') {
      bgColor = AppColors.primaryLight;
      textColor = AppColors.primaryDark;
      icon = Icons.verified_user_rounded;
      label = 'Verified Provider';
    } else {
      // Information / Default
      bgColor = const Color(0xFFE1F5FE);
      textColor = const Color(0xFF0288D1);
      icon = Icons.info_outline_rounded;
      label = status.isNotEmpty ? status : 'Unknown';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: textColor.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
