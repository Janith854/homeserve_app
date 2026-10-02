// Screen 15 — Admin Provider Verification
// Implements: Service Provider Verification & Compliance (Member 3)

import 'package:flutter/material.dart';
import 'package:homeserve_app/theme/app_theme.dart';
import 'package:homeserve_app/widgets/widgets.dart';

/// Screen 15: Admin — Provider Verification
class AdminVerificationScreen extends StatefulWidget {
  final ValueChanged<int>? onAdminNavTap;
  final VoidCallback? onMenuTap;

  const AdminVerificationScreen({
    super.key,
    this.onAdminNavTap,
    this.onMenuTap,
  });

  @override
  State<AdminVerificationScreen> createState() => _AdminVerificationScreenState();
}

class _AdminVerificationScreenState extends State<AdminVerificationScreen> {
  int _adminNavIndex = 0; // 0: Verification, 1: Reviews, 2: Settings

  // Placeholder pending verification records
  final List<Map<String, dynamic>> _pendingProviders = [
    {
      'id': 'pv1',
      'name': 'Chamara Bandara',
      'details': 'Electrical · NIC + Certificate uploaded',
      'status': 'Pending',
    },
    {
      'id': 'pv2',
      'name': 'Priyanka Jayasuriya',
      'details': 'Cleaning · Documents pending',
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
                      title: 'Provider Verification',
                      leadingIcon: Icons.menu_rounded,
                      onLeadingPressed: widget.onMenuTap ?? () {
                        // Open admin drawer
                      },
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Metrics Stat Grid
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatBox(
                            value: '340',
                            label: 'Total Providers',
                          ),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: _buildStatBox(
                            value: '18',
                            label: 'Pending Review',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // Section Title
                    Text(
                      'Pending Verification',
                      style: AppTextStyles.meta.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Pending Verification Provider Cards
                    ..._pendingProviders.asMap().entries.map((entry) {
                      final index = entry.key;
                      final provider = entry.value;
                      final isLast = index == _pendingProviders.length - 1;

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
                                      width: 40,
                                      height: 40,
                                      icon: Icons.person_outline_rounded,
                                      isCircular: true,
                                    ),
                                    const SizedBox(width: AppSpacing.xl),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            provider['name'] as String,
                                            style: AppTextStyles.name,
                                          ),
                                          const SizedBox(height: AppSpacing.xs),
                                          Text(
                                            provider['details'] as String,
                                            style: AppTextStyles.meta,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.lg),

                                // Verify & Reject Action Buttons
                                Row(
                                  children: [
                                    Expanded(
                                      child: PrimaryButton(
                                        label: 'Verify',
                                        icon: Icons.check,
                                        isSmall: true,
                                        onPressed: () {
                                          // TODO: Firebase Firestore update provider isVerified = true
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.lg),
                                    Expanded(
                                      child: DangerButton(
                                        label: 'Reject',
                                        icon: Icons.close,
                                        isSmall: true,
                                        isOutline: true,
                                        onPressed: () {
                                          // TODO: Firebase Firestore update provider isVerified = false / reject notes
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

            // Admin Bottom Navigation Bar
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
                  _buildAdminNavItem(
                    index: 0,
                    icon: Icons.verified_user_rounded,
                    label: 'Verification',
                  ),
                  _buildAdminNavItem(
                    index: 1,
                    icon: Icons.flag_rounded,
                    label: 'Reviews',
                  ),
                  _buildAdminNavItem(
                    index: 2,
                    icon: Icons.settings_rounded,
                    label: 'Settings',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox({required String value, required String label}) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.btn),
      ),
      child: Column(
        children: [
          Text(value, style: AppTextStyles.statNumber),
          const SizedBox(height: AppSpacing.xs),
          Text(label, style: AppTextStyles.statLabel),
        ],
      ),
    );
  }

  Widget _buildAdminNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isActive = _adminNavIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _adminNavIndex = index;
        });
        widget.onAdminNavTap?.call(index);
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
