// Screen 6 — Booking & Scheduling
// Implements: FR06 — Service Booking & Scheduling (Member 2)

import 'package:flutter/material.dart';
import 'package:homeserve_app/theme/app_theme.dart';
import 'package:homeserve_app/widgets/widgets.dart';
import 'package:homeserve_app/services/booking_service.dart';

/// Screen 6: Booking & Scheduling — FR06
class BookingSchedulingScreen extends StatefulWidget {
  final String providerId;
  final String serviceId;
  final String serviceName;
  final double price;
  final ValueChanged<String>? onBookingCreated;
  final VoidCallback? onConfirmBooking;
  final VoidCallback? onBack;

  const BookingSchedulingScreen({
    super.key,
    required this.providerId,
    required this.serviceId,
    required this.serviceName,
    required this.price,
    this.onBookingCreated,
    this.onConfirmBooking,
    this.onBack,
  });

  @override
  State<BookingSchedulingScreen> createState() => _BookingSchedulingScreenState();
}

class _BookingSchedulingScreenState extends State<BookingSchedulingScreen> {
  DateTime? _selectedDate;
  int _selectedTimeSlotIndex = 0; // 0: 9:00 AM

  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  final List<String> _timeSlots = ['9:00 AM', '10:00 AM', '11:00 AM', '12:00 PM', '2:00 PM', '3:00 PM', '4:00 PM', '5:00 PM'];
  bool _saving = false;
  String? _bookingId;
  bool _isEditing = true;

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isViewMode = _bookingId != null && !_isEditing;

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
                    title: isViewMode ? 'Booking Summary' : 'Book Service',
                    onLeadingPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  if (isViewMode) ...[
                    // Read-Only View Mode
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(AppRadius.card),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Service', style: AppTextStyles.meta.copyWith(color: AppColors.textLight)),
                          Text(widget.serviceName, style: AppTextStyles.h3),
                          const SizedBox(height: AppSpacing.lg),
                          Text('Date & Time', style: AppTextStyles.meta.copyWith(color: AppColors.textLight)),
                          Text('${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year} at ${_timeSlots[_selectedTimeSlotIndex]}', style: AppTextStyles.body),
                          const SizedBox(height: AppSpacing.lg),
                          Text('Address', style: AppTextStyles.meta.copyWith(color: AppColors.textLight)),
                          Text(_addressController.text, style: AppTextStyles.body),
                          if (_notesController.text.trim().isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.lg),
                            Text('Note', style: AppTextStyles.meta.copyWith(color: AppColors.textLight)),
                            Text(_notesController.text, style: AppTextStyles.body),
                          ],
                        ],
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(height: AppSpacing.xxl),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        OutlinedButton(
                          onPressed: _saving ? null : () {
                            setState(() => _isEditing = true);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.btn)),
                          ),
                          child: const Text('Edit Booking', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        PrimaryButton(
                          label: 'Continue to Payment',
                          onPressed: _saving ? null : () {
                            widget.onBookingCreated?.call(_bookingId!);
                          },
                        ),
                      ],
                    ),
                  ] else ...[
                    // Edit Mode
                    // Select Date Section
                    Text('Select Date', style: AppTextStyles.meta.copyWith(fontWeight: FontWeight.w700, color: AppColors.text)),
                    const SizedBox(height: AppSpacing.md),
                    InkWell(
                      onTap: () => _selectDate(context),
                      borderRadius: BorderRadius.circular(AppRadius.btn),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(AppRadius.btn),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month, color: AppColors.primary, size: 20),
                            const SizedBox(width: AppSpacing.md),
                            Text(
                              _selectedDate == null
                                  ? 'Choose a date'
                                  : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                              style: AppTextStyles.field,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // Select Time Section
                    Text('Select Time', style: AppTextStyles.meta.copyWith(fontWeight: FontWeight.w700, color: AppColors.text)),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.md,
                      children: List.generate(_timeSlots.length, (index) {
                        final isSelected = _selectedTimeSlotIndex == index;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedTimeSlotIndex = index;
                            });
                          },
                          borderRadius: BorderRadius.circular(AppRadius.card),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : AppColors.surface,
                              border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
                              borderRadius: BorderRadius.circular(AppRadius.card),
                              boxShadow: isSelected
                                  ? [BoxShadow(color: AppColors.primary.withAlpha(77), blurRadius: 4, offset: const Offset(0, 2))]
                                  : null,
                            ),
                            child: Text(
                              _timeSlots[index],
                              style: AppTextStyles.meta.copyWith(
                                color: isSelected ? Colors.white : AppColors.text,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ),
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
                        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: 11),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.btn), borderSide: const BorderSide(color: AppColors.border)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.btn), borderSide: const BorderSide(color: AppColors.primary)),
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
                        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: 11),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.btn), borderSide: const BorderSide(color: AppColors.border)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.btn), borderSide: const BorderSide(color: AppColors.primary)),
                      ),
                    ),

                    const Spacer(),
                    const SizedBox(height: AppSpacing.xxl),

                    // Buttons
                    PrimaryButton(
                      label: _bookingId == null ? 'Save Booking' : 'Update Booking',
                      onPressed: _saving ? null : _saveBooking,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveBooking() async {
    if (widget.serviceName.trim().isEmpty ||
        widget.providerId.trim().isEmpty ||
        widget.serviceId.trim().isEmpty ||
        _selectedDate == null ||
        _timeSlots[_selectedTimeSlotIndex].isEmpty ||
        _addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Service, provider, date, time, and address are required.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final dateStr = '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';
      final timeStr = _timeSlots[_selectedTimeSlotIndex];
      
      if (_bookingId == null) {
        final newBookingId = await BookingService.instance.createBooking(
          providerId: widget.providerId,
          serviceId: widget.serviceId,
          serviceName: widget.serviceName,
          date: dateStr,
          time: timeStr,
          address: _addressController.text,
          price: widget.price,
          specialRequest: _notesController.text,
        );
        if (!mounted) return;
        setState(() {
          _bookingId = newBookingId;
          _isEditing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking saved.')),
        );
      } else {
        await BookingService.instance.updateBookingDetails(
          bookingId: _bookingId!,
          date: dateStr,
          time: timeStr,
          address: _addressController.text,
          specialRequest: _notesController.text,
        );
        if (!mounted) return;
        setState(() {
          _isEditing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking updated.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save booking: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
