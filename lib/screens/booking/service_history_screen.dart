// Screen 11 — Service History
// Implements: FR11 — Service History & Booking Logs (Member 3)

import 'package:flutter/material.dart';
import 'package:homeserve_app/theme/app_theme.dart';
import 'package:homeserve_app/widgets/widgets.dart';

/// Screen 11: Service History — FR11
class ServiceHistoryScreen extends StatefulWidget {
  final ValueChanged<String>? onBookingSelected;
  final VoidCallback? onBack;

  const ServiceHistoryScreen({
    super.key,
    this.onBookingSelected,
    this.onBack,
  });

  @override
  State<ServiceHistoryScreen> createState() => _ServiceHistoryScreenState();
}

class _ServiceHistoryScreenState extends State<ServiceHistoryScreen> {
  int _selectedTabIndex = 0; // 0: Upcoming, 1: Completed, 2: Cancelled

  final List<String> _tabs = ['Upcoming', 'Completed', 'Cancelled'];

  // Placeholder history logs
  final List<Map<String, dynamic>> _historyItems = [
    {
      'id': 'b1',
      'title': 'Plumbing · Aug 3',
      'provider': 'Rohan De Silva',
      'status': 'Done',
      'icon': Icons.build_rounded,
    },
    {
      'id': 'b2',
      'title': 'Electrical · Jul 28',
      'provider': 'Kasun Perera',
      'status': 'Done',
      'icon': Icons.bolt_rounded,
    },
    {
      'id': 'b3',
      'title': 'Cleaning · Jul 20',
      'provider': 'Amara Silva',
      'status': 'Done',
      'icon': Icons.cleaning_services_rounded,
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
                title: 'Service History',
                leadingIcon: Icons.arrow_back_rounded,
                onLeadingPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Segmented Tabs
              TabSelector(
                tabs: _tabs,
                selectedIndex: _selectedTabIndex,
                onTap: (index) {
                  setState(() {
                    _selectedTabIndex = index;
                  });
                  // TODO: Firebase Firestore query filter by status
                },
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Service Cards List
              ..._historyItems.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                  child: InkWell(
                    onTap: () {
                      widget.onBookingSelected?.call(item['id'] as String);
                      // TODO: View booking details modal / page
                    },
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(AppRadius.card),
                      ),
                      child: Row(
                        children: [
                          PhotoPlaceholder(
                            width: 40,
                            height: 40,
                            icon: item['icon'] as IconData,
                          ),
                          const SizedBox(width: AppSpacing.xl),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['title'] as String,
                                  style: AppTextStyles.name,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  item['provider'] as String,
                                  style: AppTextStyles.meta,
                                ),
                              ],
                            ),
                          ),
                          // Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xl,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                            ),
                            child: Text(
                              item['status'] as String,
                              style: AppTextStyles.meta.copyWith(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: AppSpacing.xl),

              // View All Details Link
              Center(
                child: Text(
                  'View All Details',
                  style: AppTextStyles.link,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }
}
