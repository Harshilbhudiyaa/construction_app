import 'package:flutter/material.dart';
import 'package:construction_app/core/theme/design_system.dart';

enum StatusBadgeType { success, warning, danger, info, neutral }

class StatusBadge extends StatelessWidget {
  final String label;
  final StatusBadgeType type;
  final bool isLarge;

  const StatusBadge({
    super.key,
    required this.label,
    required this.type,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (type) {
      case StatusBadgeType.success: color = DesignSystem.success; break;
      case StatusBadgeType.warning: color = DesignSystem.accent; break;
      case StatusBadgeType.danger: color = DesignSystem.error; break;
      case StatusBadgeType.info: color = DesignSystem.info; break;
      case StatusBadgeType.neutral: color = DesignSystem.textSecondary; break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? 12 : 8, 
        vertical: isLarge ? 6 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: isLarge ? 11 : 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
