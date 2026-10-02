// Screen 12 — Post-Job Rating & Review
// Implements: FR12 — Post-Job Rating & Review System (Member 4)

import 'package:flutter/material.dart';
import 'package:homeserve_app/theme/app_theme.dart';
import 'package:homeserve_app/widgets/widgets.dart';

/// Screen 12: Post-Job Rating & Review — FR12
class RatingReviewScreen extends StatefulWidget {
  final String providerId;
  final String providerName;
  final VoidCallback? onSubmitReview;
  final VoidCallback? onSkip;

  const RatingReviewScreen({
    super.key,
    this.providerId = 'p1',
    this.providerName = 'Rohan De Silva',
    this.onSubmitReview,
    this.onSkip,
  });

  @override
  State<RatingReviewScreen> createState() => _RatingReviewScreenState();
}

class _RatingReviewScreenState extends State<RatingReviewScreen> {
  double _rating = 4.0;
  final _reviewController = TextEditingController();
  final Set<String> _selectedChips = {'Punctual'};

  final List<String> _feedbackChips = ['Punctual', 'Professional', 'Good Value'];

  @override
  void dispose() {
    _reviewController.dispose();
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
                    title: 'Rate Your Experience',
                    onLeadingPressed: widget.onSkip ?? () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Provider Details Avatar & Name
                  Center(
                    child: Column(
                      children: [
                        const PhotoPlaceholder(
                          width: 64,
                          height: 64,
                          icon: Icons.build_rounded,
                          isCircular: true,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(widget.providerName, style: AppTextStyles.name.copyWith(fontSize: 14)),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Interactive Large Star Rating Row
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starValue = index + 1.0;
                        final isFilled = starValue <= _rating;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _rating = starValue;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: Icon(
                              Icons.star,
                              size: AppIconSize.starLarge,
                              color: isFilled ? AppColors.accent : AppColors.border,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Written Review Text Box
                  TextFormField(
                    controller: _reviewController,
                    maxLines: 3,
                    style: AppTextStyles.fieldFilled,
                    decoration: InputDecoration(
                      hintText: 'Write a review...',
                      hintStyle: AppTextStyles.field,
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xxl,
                        vertical: 12,
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

                  // Positive Feedback Chips Row
                  Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.md,
                    children: _feedbackChips.map((chipLabel) {
                      final isSelected = _selectedChips.contains(chipLabel);
                      return ChipFilter(
                        label: chipLabel,
                        isActive: isSelected,
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedChips.remove(chipLabel);
                            } else {
                              _selectedChips.add(chipLabel);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const Spacer(),
                  const SizedBox(height: AppSpacing.xxl),

                  // Submit Review Primary Button
                  PrimaryButton(
                    label: 'Submit Review',
                    onPressed: () {
                      // TODO: Save review to Firestore 'reviews' collection and recalculate provider average rating
                      widget.onSubmitReview?.call();
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Skip Link
                  Center(
                    child: GestureDetector(
                      onTap: widget.onSkip ?? () => Navigator.of(context).maybePop(),
                      child: Text(
                        'Skip',
                        style: AppTextStyles.link,
                      ),
                    ),
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
