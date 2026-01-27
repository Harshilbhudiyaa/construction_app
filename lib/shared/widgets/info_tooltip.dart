import 'package:flutter/material.dart';
import 'package:construction_app/shared/theme/professional_theme.dart';

/// A helpful tooltip widget that provides contextual information to users
class InfoTooltip extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color? color;

  const InfoTooltip({
    super.key,
    required this.message,
    this.icon = Icons.info_outline_rounded,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      decoration: BoxDecoration(
        color: AppColors.deepBlue1,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      preferBelow: false,
      verticalOffset: 10,
      child: Icon(
        icon,
        size: 18,
        color: color ?? AppColors.deepBlue1.withOpacity(0.7),
      ),
    );
  }
}
