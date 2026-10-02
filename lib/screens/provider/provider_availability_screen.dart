// Screen 14 — Provider Availability & Profile
// Implements: Service Provider Availability & Service Catalog Management (Member 4)

import 'package:flutter/material.dart';
import 'package:homeserve_app/theme/app_theme.dart';
import 'package:homeserve_app/widgets/widgets.dart';

/// Screen 14: Provider — Availability & Profile
class ProviderAvailabilityScreen extends StatefulWidget {
  final VoidCallback? onSaveChanges;
  final ValueChanged<int>? onProviderNavTap;
  final VoidCallback? onBack;

  const ProviderAvailabilityScreen({
    super.key,
    this.onSaveChanges,
    this.onProviderNavTap,
    this.onBack,
  });

  @override
  State<ProviderAvailabilityScreen> createState() => _ProviderAvailabilityScreenState();
}

class _ProviderAvailabilityScreenState extends State<ProviderAvailabilityScreen> {
  bool _isAvailable = true;
  int _navIndex = 1; // 1: Availability

  final Set<String> _workingDays = {'Mon', 'Tue', 'Wed', 'Thu', 'Fri'};
  final List<String> _allDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  final _startTimeController = TextEditingController(text: '8:00 AM');
  final _endTimeController = TextEditingController(text: '6:00 PM');
  final _callOutFeeController = TextEditingController(text: 'Rs. 300');

  final List<String> _services = ['Plumbing', 'Pipe Repair'];

  @override
  void dispose() {
    _startTimeController.dispose();
    _endTimeController.dispose();
    _callOutFeeController.dispose();
    super.dispose();
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
                      title: 'Availability & Profile',
                      onLeadingPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Availability Toggle Card
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(AppRadius.card),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Available for Bookings', style: AppTextStyles.name),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  'Toggle off to pause new requests',
                                  style: AppTextStyles.meta,
                                ),
                              ],
                            ),
                          ),
                          AppToggle(
                            value: _isAvailable,
                            onChanged: (val) {
                              setState(() {
                                _isAvailable = val;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // Working Days Section
                    Text(
                      'Working Days',
                      style: AppTextStyles.meta.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _allDays.map((day) {
                          final isSelected = _workingDays.contains(day);
                          return Padding(
                            padding: const EdgeInsets.only(right: AppSpacing.sm),
                            child: ChipFilter(
                              label: day,
                              isActive: isSelected,
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _workingDays.remove(day);
                                  } else {
                                    _workingDays.add(day);
                                  }
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // Working Hours Section
                    Text(
                      'Working Hours',
                      style: AppTextStyles.meta.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _startTimeController,
                            style: AppTextStyles.fieldFilled,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.surface,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xxl,
                                vertical: 11,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppRadius.btn),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppRadius.btn),
                                borderSide: const BorderSide(color: AppColors.primary),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: TextFormField(
                            controller: _endTimeController,
                            style: AppTextStyles.fieldFilled,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.surface,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xxl,
                                vertical: 11,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppRadius.btn),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppRadius.btn),
                                borderSide: const BorderSide(color: AppColors.primary),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // Services Offered Section
                    Text(
                      'Services Offered',
                      style: AppTextStyles.meta.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.md,
                      children: [
                        ..._services.map((srv) => ChipFilter(label: srv, isActive: true)),
                        GestureDetector(
                          onTap: () {
                            // TODO: Add new service dialog
                          },
                          child: const ChipFilter(label: '+ Add', isActive: false),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // Base Call-out Fee Section
                    Text(
                      'Base Call-out Fee',
                      style: AppTextStyles.meta.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _callOutFeeController,
                      style: AppTextStyles.fieldFilled,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.surface,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xxl,
                          vertical: 11,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.btn),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.btn),
                          borderSide: const BorderSide(color: AppColors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // Save Changes Primary Button
                    PrimaryButton(
                      label: 'Save Changes',
                      onPressed: () {
                        // TODO: Firebase Firestore update provider schedule & rate settings
                        widget.onSaveChanges?.call();
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
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
