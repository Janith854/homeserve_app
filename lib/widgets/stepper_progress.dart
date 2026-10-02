import 'package:flutter/material.dart';
import 'package:homeserve_app/theme/app_theme.dart';

/// Matches CSS `.stepper`, `.step`, `.stepline` — progress stepper.
class StepperProgress extends StatelessWidget {
  final int totalSteps;
  final int currentStep; // 0-indexed; steps before this are "done"
  final List<String>? labels;
  final List<String>? steps;

  const StepperProgress({
    super.key,
    this.totalSteps = 4,
    required this.currentStep,
    this.labels,
    this.steps,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTotalSteps = steps?.length ?? totalSteps;
    final effectiveLabels = steps ?? labels;

    return Column(
      children: [
        Row(
          children: List.generate(effectiveTotalSteps * 2 - 1, (index) {
            if (index.isEven) {
              // Step circle
              final stepIndex = index ~/ 2;
              final isDone = stepIndex < currentStep;
              final isNow = stepIndex == currentStep;

              Color bgColor;
              Color borderColor;
              Color textColor;

              if (isDone) {
                bgColor = AppColors.primary;
                borderColor = AppColors.primary;
                textColor = Colors.white;
              } else if (isNow) {
                bgColor = AppColors.accent;
                borderColor = AppColors.accent;
                textColor = const Color(0xFF1A1A1A);
              } else {
                bgColor = AppColors.surface;
                borderColor = AppColors.border;
                textColor = AppColors.muted;
              }

              return Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor, width: 2),
                ),
                child: Center(
                  child: isDone
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : Text(
                          '${stepIndex + 1}',
                          style: AppTextStyles.stepNumber.copyWith(
                            color: textColor,
                          ),
                        ),
                ),
              );
            } else {
              // Step line
              final lineIndex = index ~/ 2;
              final isDone = lineIndex < currentStep;

              return Expanded(
                child: Container(
                  height: 3,
                  color: isDone ? AppColors.primary : AppColors.border,
                ),
              );
            }
          }),
        ),
        if (effectiveLabels != null && effectiveLabels.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: effectiveLabels
                .map((label) => Text(label, style: AppTextStyles.stepLabel))
                .toList(),
          ),
        ],
      ],
    );
  }
}
