import 'package:flutter/material.dart';
import 'package:construction_app/core/theme/aesthetic_tokens.dart';


/// Professional theme colors - Mapped to Construction Design System
class AppColors {
  static const deepBlue1 = bcNavy;
  static const deepBlue2 = Color(0xFF1E293B);
  static const deepBlue3 = bcAmber;
  static const deepBlue4 = Color(0xFF94A3B8);
  
  static const accentGold = bcAmber;
  static const accentOrange = bcAmber;
  
  static const glassWhite = Colors.white; 
  static const glassWhiteThick = Colors.white;
  static const glassBorder = Color(0xFFE2E8F0);

  static const deepBlue = bcNavy;
  static const steelBlue = Color(0xFF334155);

  static final gradientColors = [
    bcNavy,
    const Color(0xFF1E293B),
  ];
  
  static const loginGradientStart = bcSurface; 
  static const loginGradientEnd = Color(0xFFF1F5F9);   
}


class ProfessionalBackground extends StatelessWidget {
  final Widget child;
  final bool isTactile;
  final bool isBlueprint;
  
  const ProfessionalBackground({
    super.key,
    required this.child,
    this.isTactile = false,
    this.isBlueprint = false,
  });

  @override
  Widget build(BuildContext context) {
    // Dashboard Split: Header is handled by SliverAppBar, body is white
    final bgColor = isBlueprint ? bcSurface : (isTactile ? bcTactileBg : bcSurface);
    final gridOpacity = isBlueprint ? 0.04 : (isTactile ? 0.08 : 0.05);
    final gridColor = isBlueprint ? bcNavy : (isTactile ? bcTactileAmber.withValues(alpha: 0.15) : bcNavy.withValues(alpha: 0.1));

    return Container(
      color: bgColor,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: BlueprintGridPainter(
                opacity: gridOpacity,
                gridColor: gridColor,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}


/// Grid pattern painter for background (Optional: can keep for texture)
class GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.05)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const spacing = 40.0;

    // Vertical lines
    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    // Horizontal lines
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Professional Card - White, Shadowed, Rounded with animated hover elevation
class ProfessionalCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Gradient? gradient;
  final bool useGlass; 
  final double borderRadius;
  final Color? color;
  final List<BoxShadow>? boxShadow;
  final Border? border;
  final VoidCallback? onTap;

  const ProfessionalCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.gradient,
    this.useGlass = false, 
    this.borderRadius = 16,
    this.color,
    this.boxShadow,
    this.border,
    this.onTap,
  });

  @override
  State<ProfessionalCard> createState() => _ProfessionalCardState();
}

class _ProfessionalCardState extends State<ProfessionalCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final defaultShadow = widget.boxShadow ?? [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.04),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ];

    final hoverShadow = [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.08),
        blurRadius: 20,
        offset: const Offset(0, 8),
        spreadRadius: 2,
      ),
      BoxShadow(
        color: bcAmber.withValues(alpha: 0.06),
        blurRadius: 16,
        spreadRadius: -2,
      ),
    ];

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        width: widget.width,
        height: widget.height,
        margin: widget.margin,
        transform: _hovered
            ? Matrix4.translationValues(0.0, -2.0, 0.0)
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: widget.color ?? bcCard,
          gradient: widget.gradient,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: widget.border ?? Border.all(
            color: _hovered ? bcAmber.withValues(alpha: 0.3) : const Color(0xFFE2E8F0),
          ),
          boxShadow: _hovered ? hoverShadow : defaultShadow,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            splashColor: bcAmber.withValues(alpha: 0.08),
            highlightColor: bcAmber.withValues(alpha: 0.04),
            child: Container(
              padding: widget.padding ?? const EdgeInsets.all(24),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}


/// Professional section header
class ProfessionalSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;

  const ProfessionalSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    color: bcNavy,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          ...[action].nonNulls,
        ],
      ),
    );
  }
}
