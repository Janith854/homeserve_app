import 'package:flutter/material.dart';
import 'package:homeserve_app/theme/app_theme.dart';

/// Matches CSS `.toggle` / `.toggle.on` — custom toggle switch.
class AppToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const AppToggle({
    super.key,
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged?.call(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 22,
        decoration: BoxDecoration(
          color: value ? AppColors.primary : AppColors.border,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.all(2),
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: AppShadows.toggleKnob,
            ),
          ),
        ),
      ),
    );
  }
}
