import 'package:flutter/material.dart';
import 'package:construction_app/core/theme/design_system.dart';
import 'package:construction_app/shared/widgets/app_button.dart';

class AppDialogs {
  static Future<bool?> showConfirm({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        content: Text(message, style: const TextStyle(color: DesignSystem.textSecondary, fontSize: 14)),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelLabel, style: const TextStyle(color: DesignSystem.textSecondary, fontWeight: FontWeight.w600)),
          ),
          AppButton(
            label: confirmLabel,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            variant: isDestructive ? AppButtonVariant.danger : AppButtonVariant.primary,
            onTap: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
  }

  static Future<void> showAlert({
    required BuildContext context,
    required String title,
    required String message,
    String buttonLabel = 'OK',
    bool isError = false,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              isError ? Icons.error_rounded : Icons.info_rounded,
              color: isError ? DesignSystem.error : DesignSystem.info,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18))),
          ],
        ),
        content: Text(message, style: const TextStyle(color: DesignSystem.textSecondary, fontSize: 14)),
        actions: [
          AppButton(
            label: buttonLabel,
            width: double.infinity,
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
