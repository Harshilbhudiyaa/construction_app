import 'package:flutter/material.dart';

/// Professional theme colors used throughout the app
class AppColors {
  static const deepBlue1 = Color(0xFF1A237E);
  static const deepBlue2 = Color(0xFF283593);
  static const deepBlue3 = Color(0xFF3949AB);
  static const deepBlue4 = Color(0xFF5C6BC0);
  
  static const accentGold = Color(0xFFFFD54F);
  static const accentOrange = Color(0xFFFF8A65);
  
  static const glassWhite = Color(0x33FFFFFF);
  static const glassWhiteThick = Color(0x66FFFFFF);
  static const glassBorder = Color(0x4DFFFFFF);

  static const gradientColors = [
    deepBlue1,
    deepBlue2,
    deepBlue3,
    deepBlue4,
  ];
}

/// Professional background with gradient and grid pattern
class ProfessionalBackground extends StatelessWidget {
  final Widget child;
  
  const ProfessionalBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradient Background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppColors.gradientColors,
            ),
          ),
        ),
        
        // Grid Pattern Overlay
        Positioned.fill(
          child: CustomPaint(
            painter: GridPatternPainter(),
          ),
        ),
        
        // Content
        child,
      ],
    );
  }
}

/// Grid pattern painter for background
class GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const spacing = 50.0;

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

/// Professional white card with shadow or glassmorphism
class ProfessionalCard extends StatelessWidget {
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
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color ?? (useGlass ? AppColors.glassWhite : (gradient == null ? Colors.white : null)),
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border ?? (useGlass 
          ? Border.all(color: AppColors.glassBorder, width: 1.5)
          : null),
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}


/// Professional section header for dark backgrounds
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}
