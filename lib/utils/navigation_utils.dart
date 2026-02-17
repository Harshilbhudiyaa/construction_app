import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:construction_app/routes.dart';
import 'package:construction_app/services/auth_service.dart';

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
              color: Color(0xFF1A237E),
              size: 28,
            ),
            SizedBox(width: 12),
            Text(
              'Confirm Logout',
              style: TextStyle(
                color: Color(0xFF1A237E),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to log out? You will need to sign in again.',
          style: TextStyle(
            color: Color(0xFF37474F),
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Color(0xFF78909C),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1A237E),
              foregroundColor: Colors.white,
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
        final authService = context.read<AuthService>();
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
