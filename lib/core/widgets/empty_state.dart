import 'package:flutter/material.dart';
import '../../app/theme/app_spacing.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onRetry;
  final String? retryLabel;

  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_rounded,
    this.onRetry,
    this.retryLabel,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: cs.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: cs.onSurfaceVariant.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.xl),
              FilledButton(
                onPressed: onRetry,
                child: Text(retryLabel ?? 'Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
