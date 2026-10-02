// Screen 9 — Notifications
// Implements: FR09 — Push & In-App Notifications (Member 3)

import 'package:flutter/material.dart';
import 'package:homeserve_app/theme/app_theme.dart';
import 'package:homeserve_app/widgets/widgets.dart';

/// Screen 9: Notifications — FR09
class NotificationsScreen extends StatelessWidget {
  final ValueChanged<String>? onNotificationTap;
  final VoidCallback? onBack;

  const NotificationsScreen({
    super.key,
    this.onNotificationTap,
    this.onBack,
  });

  // Placeholder notification items from prototype
  final List<Map<String, dynamic>> _notifications = const [
    {
      'id': 'n1',
      'title': 'Booking Confirmed',
      'subtitle': 'Rohan De Silva accepted your request',
      'time': '2m',
      'icon': Icons.check,
    },
    {
      'id': 'n2',
      'title': 'Provider On the Way',
      'subtitle': 'Arriving in approx. 12 minutes',
      'time': '10m',
      'icon': Icons.local_shipping_outlined,
    },
    {
      'id': 'n3',
      'title': 'Payment Successful',
      'subtitle': 'Rs. 1,500 paid via Card',
      'time': '1h',
      'icon': Icons.payments_outlined,
    },
    {
      'id': 'n4',
      'title': 'Rate Your Service',
      'subtitle': 'Let others know how it went',
      'time': '1d',
      'icon': Icons.star_border_rounded,
    },
  ];

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // App Bar
              AppBarWithIcon(
                title: 'Notifications',
                onLeadingPressed: onBack ?? () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Notification List
              ..._notifications.asMap().entries.map((entry) {
                final index = entry.key;
                final notif = entry.value;
                final isLast = index == _notifications.length - 1;

                return Column(
                  children: [
                    InkWell(
                      onTap: () {
                        onNotificationTap?.call(notif['id'] as String);
                        // TODO: Handle notification tap action / deep link
                      },
                      borderRadius: BorderRadius.circular(AppRadius.btn),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.lg,
                          horizontal: AppSpacing.xs,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Notification Icon Dot
                            Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primaryLight,
                              ),
                              child: Icon(
                                notif['icon'] as IconData,
                                size: 16,
                                color: AppColors.primaryDark,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xl),

                            // Text details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    notif['title'] as String,
                                    style: AppTextStyles.notifTitle,
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    notif['subtitle'] as String,
                                    style: AppTextStyles.notifSub,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.lg),

                            // Time badge
                            Text(
                              notif['time'] as String,
                              style: AppTextStyles.notifTime,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (!isLast) const Divider(color: AppColors.border, thickness: 1),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
