// Screen 3 — Filter Providers
// Implements: FR03 — Advanced Filter & Sorting (Member 2)

import 'package:flutter/material.dart';
import 'package:homeserve_app/theme/app_theme.dart';
import 'package:homeserve_app/widgets/widgets.dart';

/// Screen 3: Filter Providers — FR03
class FilterProvidersScreen extends StatefulWidget {
  final VoidCallback? onApplyFilters;
  final VoidCallback? onBack;

  const FilterProvidersScreen({
    super.key,
    this.onApplyFilters,
    this.onBack,
  });

  @override
  State<FilterProvidersScreen> createState() => _FilterProvidersScreenState();
}

class _FilterProvidersScreenState extends State<FilterProvidersScreen> {
  final Map<String, bool> _categorySelections = {
    'Plumbing': true,
    'Electrical': false,
    'Cleaning': false,
  };

  RangeValues _priceRange = const RangeValues(500, 5000);
  double _minRating = 4.0;
  double _distanceKm = 5.0;

  void _clearAll() {
    setState(() {
      _categorySelections.updateAll((key, value) => false);
      _categorySelections['Plumbing'] = true;
      _priceRange = const RangeValues(500, 5000);
      _minRating = 4.0;
      _distanceKm = 5.0;
    });
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
                    title: 'Filters',
                    onLeadingPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Category Section
                  Text(
                    'Category',
                    style: AppTextStyles.meta.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Category Checklist
                  Column(
                    children: _categorySelections.keys.map((category) {
                      final isSelected = _categorySelections[category] ?? false;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _categorySelections[category] = !isSelected;
                            });
                          },
                          child: Row(
                            children: [
                              Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primary : AppColors.surface,
                                  border: Border.all(
                                    color: isSelected ? AppColors.primary : AppColors.border,
                                  ),
                                  borderRadius: BorderRadius.circular(AppRadius.checkbox),
                                ),
                                child: isSelected
                                    ? const Icon(Icons.check, size: 12, color: Colors.white)
                                    : null,
                              ),
                              const SizedBox(width: AppSpacing.xl),
                              Text(category, style: AppTextStyles.checklist),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Price Range Section
                  Text(
                    'Price Range',
                    style: AppTextStyles.meta.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppField(
                    text: 'Rs. ${_priceRange.start.toInt()} — Rs. ${_priceRange.end.toInt()}',
                    isFilled: true,
                  ),
                  RangeSlider(
                    values: _priceRange,
                    min: 0,
                    max: 10000,
                    divisions: 20,
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.border,
                    onChanged: (values) {
                      setState(() {
                        _priceRange = values;
                      });
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Minimum Rating Section
                  Text(
                    'Minimum Rating',
                    style: AppTextStyles.meta.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      RatingStars(
                        rating: _minRating,
                        size: 22,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Text(
                        '${_minRating.toStringAsFixed(1)} & up',
                        style: AppTextStyles.meta.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Distance Section
                  Text(
                    'Distance',
                    style: AppTextStyles.meta.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppField(
                    text: 'Within ${_distanceKm.toInt()} km',
                    isFilled: true,
                  ),
                  Slider(
                    value: _distanceKm,
                    min: 1,
                    max: 50,
                    divisions: 49,
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.border,
                    onChanged: (val) {
                      setState(() {
                        _distanceKm = val;
                      });
                    },
                  ),

                  const Spacer(),
                  const SizedBox(height: AppSpacing.xxl),

                  // Apply Filters Primary Button
                  PrimaryButton(
                    label: 'Apply Filters',
                    onPressed: () {
                      // TODO: Apply filter parameters to Firestore query
                      widget.onApplyFilters?.call();
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Clear All Link
                  Center(
                    child: GestureDetector(
                      onTap: _clearAll,
                      child: Text(
                        'Clear All',
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
