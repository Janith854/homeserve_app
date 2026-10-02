// Screen 6 — Booking & Scheduling
// Implements: FR06 — Service Booking & Scheduling (Member 2)

import 'package:flutter/material.dart';
import 'package:homeserve_app/theme/app_theme.dart';
import 'package:homeserve_app/widgets/widgets.dart';

/// Screen 6: Booking & Scheduling — FR06
class BookingSchedulingScreen extends StatefulWidget {
  final VoidCallback? onConfirmBooking;
  final VoidCallback? onBack;

  const BookingSchedulingScreen({
    super.key,
    this.onConfirmBooking,
    this.onBack,
  });

  @override
  State<BookingSchedulingScreen> createState() => _BookingSchedulingScreenState();
}

class _BookingSchedulingScreenState extends State<BookingSchedulingScreen> {
  int _selectedDay = 3; // default selected day: 3rd
  int _selectedTimeSlotIndex = 0; // 0: 9:00 AM

  final _addressController = TextEditingController(text: '123 Galle Road, Colombo 03');
  final _notesController = TextEditingController();

  final List<String> _timeSlots = ['9:00 AM', '11:00 AM', '2:00 PM', '4:00 PM'];
  final List<String> _weekDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
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
                    title: 'Book Service',
                    onLeadingPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Select Date Section
                  Text(
                    'Select Date',
                    style: AppTextStyles.meta.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Calendar Weekday Header & Day Grid
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(AppRadius.btn),
                    ),
                    child: Column(
                      children: [
                        // Weekday headers
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: _weekDays.map((day) {
                            return SizedBox(
                              width: 32,
                              child: Text(
                                day,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.meta.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Days 1 through 7
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(7, (index) {
                            final dayNum = index + 1;
                            final isSelected = dayNum == _selectedDay;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedDay = dayNum;
                                });
                              },
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primary : Colors.transparent,
                                  borderRadius: BorderRadius.circular(AppRadius.severityTag),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '$dayNum',
                                  style: isSelected
                                      ? AppTextStyles.meta.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        )
                                      : AppTextStyles.meta.copyWith(
                                          color: AppColors.text,
                                        ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Select Time Section
                  Text(
                    'Select Time',
                    style: AppTextStyles.meta.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Time Slots Wrap
                  Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.md,
                    children: List.generate(_timeSlots.length, (index) {
                      final isSelected = _selectedTimeSlotIndex == index;
                      return ChipFilter(
                        label: _timeSlots[index],
                        isActive: isSelected,
                        onTap: () {
                          setState(() {
                            _selectedTimeSlotIndex = index;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Address Input Field
                  TextFormField(
                    controller: _addressController,
                    style: AppTextStyles.fieldFilled,
                    decoration: InputDecoration(
                      hintText: 'Service Address',
                      hintStyle: AppTextStyles.field,
                      filled: true,
                      fillColor: AppColors.surface,
                      prefixIcon: const Icon(Icons.location_on_outlined, size: 18, color: AppColors.primary),
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
                  const SizedBox(height: AppSpacing.xl),

                  // Notes for Provider Field
                  TextFormField(
                    controller: _notesController,
                    maxLines: 2,
                    style: AppTextStyles.fieldFilled,
                    decoration: InputDecoration(
                      hintText: 'Notes for provider (optional)',
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
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),

                  const Spacer(),
                  const SizedBox(height: AppSpacing.xxl),

                  // Confirm Booking Primary Button
                  PrimaryButton(
                    label: 'Confirm Booking',
                    onPressed: () {
                      // TODO: Save booking draft to Firestore and navigate to Payment (Screen 7)
                      widget.onConfirmBooking?.call();
                    },
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
}
