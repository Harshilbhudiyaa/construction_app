import 'package:flutter/material.dart';
import '../../app/theme/app_spacing.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isSecondary;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    if (isSecondary) {
      return OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.all(AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
        icon: isLoading 
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : (icon != null ? Icon(icon) : const SizedBox.shrink()),
        label: Text(
          isLoading ? 'Please wait...' : label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    }

    return FilledButton.icon(
      onPressed: isLoading ? null : onPressed,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.all(AppSpacing.md),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),
      icon: isLoading 
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        : (icon != null ? Icon(icon) : const SizedBox.shrink()),
      label: Text(
        isLoading ? 'Please wait...' : label,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
