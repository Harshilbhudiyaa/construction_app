import 'package:flutter/material.dart';
import 'package:construction_app/core/theme/design_system.dart';
import 'package:construction_app/shared/widgets/enhanced_animations.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Widget? action;
  final bool useGlass;

  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inventory_2_outlined,
    this.action,
    this.useGlass = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Floating icon for a lively empty-state feel
            FloatingWidget(
              distance: 6,
              duration: const Duration(milliseconds: 2800),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(icon, size: 48, color: DesignSystem.textSecondary.withValues(alpha: 0.5)),
              ),
            ),
            const SizedBox(height: 24),
            BounceFadeIn(
              delay: const Duration(milliseconds: 200),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: DesignSystem.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            BounceFadeIn(
              delay: const Duration(milliseconds: 400),
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  color: DesignSystem.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (action != null) ...[
              const SizedBox(height: 24),
              BounceFadeIn(
                delay: const Duration(milliseconds: 600),
                child: action!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
