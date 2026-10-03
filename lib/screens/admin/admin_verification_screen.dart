// Screen 15 — Admin Provider Verification
// Implements: Service Provider Verification & Compliance (Member 3)

import 'package:flutter/material.dart';
import 'package:homeserve_app/models/provider_application_model.dart';
import 'package:homeserve_app/services/provider_verification_service.dart';
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
  late final ProviderVerificationService _verificationService;

  @override
  void initState() {
    super.initState();
    _verificationService = ProviderVerificationService.instance;
  }

  Future<void> _approveApplication(ProviderApplicationModel application) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Approve Provider?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${application.name}'),
            Text('Service: ${application.serviceType}'),
            const SizedBox(height: 8),
            const Text('This will approve the provider application and activate their account.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _verificationService.approveApplication(application);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Provider approved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error approving provider: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _rejectApplication(ProviderApplicationModel application) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Provider?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${application.name}'),
            Text('Service: ${application.serviceType}'),
            const SizedBox(height: 8),
            const Text('This will reject the provider application.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reject', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _verificationService.rejectApplication(application);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Provider rejected')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error rejecting provider: ${e.toString()}')),
        );
      }
    }
  }

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

                    // Section Title
                    Text(
                      'Pending Applications',
                      style: AppTextStyles.meta.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Pending Applications Stream
                    StreamBuilder<List<ProviderApplicationModel>>(
                      stream: _verificationService.watchPendingApplications(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(AppSpacing.xl),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.xl),
                              child: Text(
                                'Error: ${snapshot.error}',
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          );
                        }

                        final applications = snapshot.data ?? [];

                        if (applications.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.xl),
                              child: Text(
                                'No pending applications',
                                style: AppTextStyles.meta.copyWith(
                                  color: AppColors.textLight,
                                ),
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: applications.asMap().entries.map((entry) {
                            final index = entry.key;
                            final application = entry.value;
                            final isLast = index == applications.length - 1;

                            return Column(
                              children: [
                                _buildApplicationCard(application),
                                if (!isLast)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                                    child: Divider(color: AppColors.border, thickness: 1),
                                  ),
                              ],
                            );
                          }).toList(),
                        );
                      },
                    ),
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

  Widget _buildApplicationCard(ProviderApplicationModel application) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with name and photo
          Row(
            children: [
              const PhotoPlaceholder(
                width: 50,
                height: 50,
                icon: Icons.person_outline_rounded,
                isCircular: true,
              ),
              const SizedBox(width: AppSpacing.xl),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application.name,
                      style: AppTextStyles.name,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      application.serviceType,
                      style: AppTextStyles.meta.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Contact Information
          _buildInfoRow('Email:', application.email),
          _buildInfoRow('Phone:', application.phone),
          const SizedBox(height: AppSpacing.md),

          // Experience and Description
          _buildInfoRow('Experience:', application.experience),
          const SizedBox(height: AppSpacing.md),

          Text(
            'Description',
            style: AppTextStyles.meta.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            application.description,
            style: AppTextStyles.body,
          ),
          const SizedBox(height: AppSpacing.md),

          // Available Areas
          Text(
            'Available Areas',
            style: AppTextStyles.meta.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: application.availableAreas.map((area) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.btn),
                ),
                child: Text(
                  area,
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.md),

          // Submitted Date
          _buildInfoRow(
            'Submitted:',
            _formatDate(application.submittedAt),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: 'Approve',
                  icon: Icons.check,
                  isSmall: true,
                  onPressed: () => _approveApplication(application),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: DangerButton(
                  label: 'Reject',
                  icon: Icons.close,
                  isSmall: true,
                  isOutline: true,
                  onPressed: () => _rejectApplication(application),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.meta.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.body,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
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
