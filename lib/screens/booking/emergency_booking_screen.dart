// Screen 10 — Emergency Booking
// Implements: FR10 — Emergency Service Booking & Priority Dispatch (Member 3)

import 'package:flutter/material.dart';
import 'package:homeserve_app/theme/app_theme.dart';
import 'package:homeserve_app/widgets/widgets.dart';
import 'package:homeserve_app/services/booking_service.dart';

/// Screen 10: Emergency Booking — FR10
class EmergencyBookingScreen extends StatefulWidget {
  final ValueChanged<String>? onRequestUrgentHelp;
  final VoidCallback? onBack;

  const EmergencyBookingScreen({
    super.key,
    this.onRequestUrgentHelp,
    this.onBack,
  });
//emagency booking
  @override
  State<EmergencyBookingScreen> createState() => _EmergencyBookingScreenState();
}

class _EmergencyBookingScreenState extends State<EmergencyBookingScreen> {
  int _selectedCategoryIndex = 0;
  final _issueController = TextEditingController();
  final _addressController = TextEditingController();
  bool _submitting = false;

  final List<String> _categories = ['Plumbing', 'Electrical', 'Cleaning'];

  @override
  void dispose() {
    _issueController.dispose();
    _addressController.dispose();
    super.dispose();
  }

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
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom -
                  28,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Bar
                  AppBarWithIcon(
                    title: 'Emergency',
                    onLeadingPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Warning Notice Banner
                  const WarningBanner(
                    message: 'For urgent issues only — priority dispatch',
                    icon: Icons.warning_amber_rounded,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Emergency Category Chips Row
                  Row(
                    children: List.generate(_categories.length, (index) {
                      final isSelected = _selectedCategoryIndex == index;
                      return Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.md),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategoryIndex = index;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xxl,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : AppColors.surface,
                              border: Border.all(
                                color: isSelected ? AppColors.danger : AppColors.border,
                                width: isSelected ? 1.5 : 1,
                              ),
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                            ),
                            child: Text(
                              _categories[index],
                              style: AppTextStyles.chip.copyWith(
                                color: isSelected ? AppColors.danger : AppColors.text,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Issue Description Field
                  TextFormField(
                    controller: _issueController,
                    maxLines: 3,
                    style: AppTextStyles.fieldFilled,
                    decoration: InputDecoration(
                      hintText: 'Describe the issue (e.g. Burst pipe, power failure)',
                      hintStyle: AppTextStyles.field,
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
                        borderSide: const BorderSide(color: AppColors.danger),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Location Address Field
                  TextFormField(
                    controller: _addressController,
                    style: AppTextStyles.fieldFilled,
                    decoration: InputDecoration(
                      hintText: 'Emergency Address',
                      hintStyle: AppTextStyles.field,
                      filled: true,
                      fillColor: AppColors.surface,
                      prefixIcon: const Icon(Icons.location_on_outlined, size: 18, color: AppColors.danger),
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
                        borderSide: const BorderSide(color: AppColors.danger),
                      ),
                    ),
                  ),

                  const Spacer(),
                  const SizedBox(height: AppSpacing.xxl),

                  // Request Urgent Help Solid Danger Button
                  DangerButton(
                    label: 'Request Urgent Help',
                    icon: Icons.warning_amber_rounded,
                    isOutline: false,
                    onPressed: _submitting ? null : _submitEmergencyRequest,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitEmergencyRequest() async {
    if (_issueController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Describe the issue and provide an address.')),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      final bookingId = await BookingService.instance.createEmergencyBooking(
        serviceName: _categories[_selectedCategoryIndex],
        issueDescription: _issueController.text,
        address: _addressController.text,
      );
      if (!mounted) return;
      widget.onRequestUrgentHelp?.call(bookingId);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not submit emergency request: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}
