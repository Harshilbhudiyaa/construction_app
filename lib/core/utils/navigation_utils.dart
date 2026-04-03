import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:construction_app/core/routing/app_router.dart';
import 'package:construction_app/data/repositories/auth_repository.dart';
import 'package:construction_app/core/theme/design_system.dart';

class NavigationUtils {
  static Future<bool> showLogoutDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: const [
            Icon(
              Icons.logout_rounded,
              color: DesignSystem.charcoalBlack,
              size: 28,
            ),
            SizedBox(width: 12),
            Text(
              'Confirm Logout',
              style: TextStyle(
                color: DesignSystem.charcoalBlack,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to log out? You will need to sign in again.',
          style: TextStyle(
            color: DesignSystem.textPrimary,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: DesignSystem.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: DesignSystem.constructionYellow,
              foregroundColor: DesignSystem.charcoalBlack,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (result == true) {
      if (context.mounted) {
        // Clear the session
        final authService = context.read<AuthRepository>();
        await authService.clearSession();
        
        if (!context.mounted) return false;

        // Navigate to login
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.login,
          (route) => false,
        );
      }
    }
    return result ?? false;
  }
}

