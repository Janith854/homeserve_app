// Screen 7 — Payment
// Implements: FR07 — Payment Processing & Transaction Management (Member 3)

import 'package:flutter/material.dart';
import 'package:homeserve_app/theme/app_theme.dart';
import 'package:homeserve_app/widgets/widgets.dart';
import 'package:homeserve_app/services/booking_service.dart';

/// Screen 7: Payment — FR07
class PaymentScreen extends StatefulWidget {
  final String bookingId;
  final String serviceName;
  final double amount;
  final VoidCallback? onPaymentSuccess;
  final VoidCallback? onBack;

  const PaymentScreen({
    super.key,
    required this.bookingId,
    required this.serviceName,
    required this.amount,
    this.onPaymentSuccess,
    this.onBack,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _selectedPaymentMethod = 0; // 0: Card, 1: Cash

  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
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
                    title: 'Payment',
                    onLeadingPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Service Summary Card
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
                        Text(widget.serviceName, style: AppTextStyles.rowSplit),
                        Text(
                          'Rs. ${widget.amount.toStringAsFixed(0)}',
                          style: AppTextStyles.rowSplit.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Payment Method Section Title
                  Text(
                    'Payment Method',
                    style: AppTextStyles.meta.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Payment Method Options
                  _buildPaymentMethodTile(
                    index: 0,
                    icon: Icons.credit_card,
                    label: 'Card',
                  ),
                  _buildPaymentMethodTile(
                    index: 1,
                    icon: Icons.money,
                    label: 'Cash',
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Card Inputs (shown when Card is selected)
                  if (_selectedPaymentMethod == 0) ...[
                    TextFormField(
                      controller: _cardNumberController,
                      style: AppTextStyles.fieldFilled,
                      decoration: InputDecoration(
                        hintText: 'Card Number',
                        hintStyle: AppTextStyles.field,
                        filled: true,
                        fillColor: AppColors.surface,
                        prefixIcon: const Icon(Icons.credit_card, size: 18, color: AppColors.primary),
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
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _expiryController,
                            style: AppTextStyles.fieldFilled,
                            decoration: InputDecoration(
                              hintText: 'MM/YY',
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
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: TextFormField(
                            controller: _cvvController,
                            obscureText: true,
                            style: AppTextStyles.fieldFilled,
                            decoration: InputDecoration(
                              hintText: 'CVV',
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
                        ),
                      ],
                    ),
                  ],

                  const Spacer(),
                  const SizedBox(height: AppSpacing.xxl),

                  // Pay Button
                  PrimaryButton(
                    label: 'Pay Rs. ${widget.amount.toStringAsFixed(0)}',
                    onPressed: _completePayment,
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

  Future<void> _completePayment() async {
    try {
      await BookingService.instance.markPaymentCompleted(widget.bookingId);
      if (mounted) widget.onPaymentSuccess?.call();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not complete payment: $error')),
        );
      }
    }
  }

  Widget _buildPaymentMethodTile({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedPaymentMethod == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = index;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: AppSpacing.lg),
            Icon(icon, size: AppIconSize.standard, color: AppColors.text),
            const SizedBox(width: AppSpacing.lg),
            Text(label, style: AppTextStyles.checklist),
          ],
        ),
      ),
    );
  }
}
