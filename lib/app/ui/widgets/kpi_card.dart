import 'package:flutter/material.dart';
import '../../theme/app_spacing.dart';

class KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;

  const KpiCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final child = Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: cs.primary),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 2),
          Text(title, style: TextStyle(color: cs.onSurfaceVariant)),
        ],
      ),
    );

    return Card(
      child: onTap == null
          ? child
          : InkWell(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              onTap: onTap,
              child: child,
            ),
    );
  }
}
