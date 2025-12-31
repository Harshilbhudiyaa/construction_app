import 'package:flutter/material.dart';
import '../../theme/app_spacing.dart';
import '../../theme/professional_theme.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {

    return Card(
      elevation: 0,
      color: AppColors.deepBlue1.withOpacity(0.02),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.deepBlue1.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg * 2),
        child: Column(
          children: [
            // Animated icon with background
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 600),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.deepBlue1.withOpacity(0.1),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.deepBlue1.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      size: 40,
                      color: AppColors.deepBlue1,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            
            // Title
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: AppColors.deepBlue1,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            
            // Message
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                height: 1.5,
              ),
            ),
            
            // Action button
            if (onAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.deepBlue1,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: Text(
                    actionText ?? 'Get Started',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
