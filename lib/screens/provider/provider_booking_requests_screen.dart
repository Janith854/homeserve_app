// Screen 13 — Provider Booking Requests
// Implements: US4 — Service Provider Job Management & Request Acceptance (Member 4)

import 'package:flutter/material.dart';
import 'package:homeserve_app/theme/app_theme.dart';
import 'package:homeserve_app/widgets/widgets.dart';

/// Screen 13: Provider — Booking Requests — US4
class ProviderBookingRequestsScreen extends StatefulWidget {
  final ValueChanged<int>? onProviderNavTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onMenuTap;

  const ProviderBookingRequestsScreen({
    super.key,
    this.onProviderNavTap,
    this.onNotificationTap,
    this.onMenuTap,
  });

  @override
  State<ProviderBookingRequestsScreen> createState() => _ProviderBookingRequestsScreenState();
}

class _ProviderBookingRequestsScreenState extends State<ProviderBookingRequestsScreen> {
  int _navIndex = 0; // 0: Requests, 1: Availability, 2: Profile

  // Placeholder booking requests
  final List<Map<String, dynamic>> _requests = [
    {
      'id': 'r1',
      'customer': 'Nimasha Perera',
      'service': 'Plumbing · Today, 2:00 PM',
      'status': 'Pending',
    },
    {
      'id': 'r2',
      'customer': 'Suresh Kumara',
      'service': 'Pipe Repair · Tomorrow, 10:00 AM',
      'status': 'Pending',
    },
    {
      'id': 'r3',
      'customer': 'Ayesha Fernando',
      'service': 'Emergency · Aug 5, 6:30 PM',
      'status': 'Pending',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
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
                      title: 'Booking Requests',
                      leadingIcon: Icons.menu_rounded,
                      trailingIcon: Icons.notifications_none_rounded,
                      showBadge: true,
                      onLeadingPressed: widget.onMenuTap ?? () {
                        // Open provider drawer
                      },
                      onTrailingPressed: widget.onNotificationTap ?? () {
                        // TODO: Navigate to Notifications (Screen 9)
                      },
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Booking Requests List
                    ..._requests.asMap().entries.map((entry) {
                      final index = entry.key;
                      final req = entry.value;
                      final isLast = index == _requests.length - 1;

                      return Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.xl),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(AppRadius.card),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    const PhotoPlaceholder(
                                      width: 44,
                                      height: 44,
                                      icon: Icons.person_outline_rounded,
                                      isCircular: true,
                                    ),
                                    const SizedBox(width: AppSpacing.xl),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            req['customer'] as String,
                                            style: AppTextStyles.name,
                                          ),
                                          const SizedBox(height: AppSpacing.xs),
                                          Text(
                                            req['service'] as String,
                                            style: AppTextStyles.meta,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.lg),

                                // Accept & Decline Action Buttons
                                Row(
                                  children: [
                                    Expanded(
                                      child: PrimaryButton(
                                        label: 'Accept',
                                        isSmall: true,
                                        onPressed: () {
                                          // TODO: Firebase Firestore update booking status to 'confirmed' / 'accepted'
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.lg),
                                    Expanded(
                                      child: DangerButton(
                                        label: 'Decline',
                                        isSmall: true,
                                        isOutline: true,
                                        onPressed: () {
                                          // TODO: Firebase Firestore update booking status to 'declined'
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (!isLast) const Padding(
                            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                            child: Divider(color: AppColors.border, thickness: 1),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Provider Bottom Navigation Bar
            Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  top: BorderSide(color: AppColors.border, width: 1),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildProviderNavItem(
                    index: 0,
                    icon: Icons.format_list_bulleted_rounded,
                    label: 'Requests',
                  ),
                  _buildProviderNavItem(
                    index: 1,
                    icon: Icons.calendar_today_rounded,
                    label: 'Availability',
                  ),
                  _buildProviderNavItem(
                    index: 2,
                    icon: Icons.person_outline_rounded,
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isActive = _navIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _navIndex = index;
        });
        widget.onProviderNavTap?.call(index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: AppIconSize.nav,
            color: isActive ? AppColors.primary : AppColors.muted,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: isActive ? AppTextStyles.navItemActive : AppTextStyles.navItem,
          ),
        ],
      ),
    );
  }
}
