// Screen 16 — Admin Reviews & Complaints
// Implements: US6 — Dispute Resolution & Community Moderation (Member 4)

import 'package:flutter/material.dart';
import 'package:homeserve_app/theme/app_theme.dart';
import 'package:homeserve_app/widgets/widgets.dart';

/// Screen 16: Admin — Reviews & Complaints — US6
class AdminReviewsScreen extends StatefulWidget {
  final ValueChanged<int>? onAdminNavTap;
  final VoidCallback? onBack;

  const AdminReviewsScreen({
    super.key,
    this.onAdminNavTap,
    this.onBack,
  });

  @override
  State<AdminReviewsScreen> createState() => _AdminReviewsScreenState();
}

class _AdminReviewsScreenState extends State<AdminReviewsScreen> {
  int _selectedTabIndex = 0; // 0: Flagged, 1: All Reviews
  int _adminNavIndex = 1; // 1: Reviews

  // Placeholder complaint records
  final List<Map<String, dynamic>> _complaints = [
    {
      'id': 'c1',
      'provider': 'Rohan De Silva',
      'severity': 'High',
      'comment': '"Arrived 2 hours late, no notice given."',
    },
    {
      'id': 'c2',
      'provider': 'Kasun Perera',
      'severity': 'Medium',
      'comment': '"Charged more than the estimated price."',
    },
    {
      'id': 'c3',
      'provider': 'Amara Silva',
      'severity': 'Low',
      'comment': '"Minor delay in response time."',
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
                      title: 'Reviews & Complaints',
                      onLeadingPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Tabs: Flagged / All Reviews
                    TabSelector(
                      tabs: const ['Flagged', 'All Reviews'],
                      selectedIndex: _selectedTabIndex,
                      onTap: (index) {
                        setState(() {
                          _selectedTabIndex = index;
                        });
                        // TODO: Filter complaints by tab in Firestore
                      },
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // Flagged Complaints List
                    ..._complaints.map((comp) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(AppRadius.card),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    comp['provider'] as String,
                                    style: AppTextStyles.name.copyWith(fontSize: 12),
                                  ),
                                  _buildSeverityTag(comp['severity'] as String),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                comp['comment'] as String,
                                style: AppTextStyles.meta.copyWith(color: AppColors.text),
                              ),
                              const SizedBox(height: AppSpacing.lg),

                              // View Details & Resolve Actions
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlineAppButton(
                                      label: 'View Details',
                                      isSmall: true,
                                      onPressed: () {
                                        // TODO: Open full complaint dispute investigation view
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.lg),
                                  Expanded(
                                    child: PrimaryButton(
                                      label: 'Resolve',
                                      isSmall: true,
                                      onPressed: () {
                                        // TODO: Firebase Firestore mark complaint as resolved
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
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

  Widget _buildSeverityTag(String severity) {
    Color bg;
    Color textColor;

    switch (severity.toLowerCase()) {
      case 'high':
        bg = const Color(0xFFFBEAEA);
        textColor = const Color(0xFF8A2F2F);
        break;
      case 'medium':
        bg = const Color(0xFFFBF3E4);
        textColor = const Color(0xFF8A5A10);
        break;
      default:
        bg = AppColors.primaryLight;
        textColor = AppColors.primaryDark;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.severityTag),
      ),
      child: Text(
        severity,
        style: AppTextStyles.severityTag.copyWith(color: textColor),
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
