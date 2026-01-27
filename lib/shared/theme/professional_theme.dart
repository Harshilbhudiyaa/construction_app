import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Professional theme colors - Light gradients like login page
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

  static const deepBlue = deepBlue1;
  static const steelBlue = deepBlue3;

  static final gradientColors = [
    deepBlue1,
    deepBlue2,
    deepBlue3,
    deepBlue4,
  ];
  
  // Login page style - Light gradient
  static const loginGradientStart = Color(0xFFE8EAF6); // Very light blue
  static const loginGradientEnd = Color(0xFFEDE7F6);   // Very light purple
}

/// Professional background - Light gradient like login page
class ProfessionalBackground extends StatelessWidget {
  final Widget child;
  
  const ProfessionalBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark 
            ? [const Color(0xFF020617), const Color(0xFF0F172A)]
            : [const Color(0xFFF8FAFC), const Color(0xFFF1F5F9)],
        ),
      ),
      child: child,
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

/// Professional white card - matching login page card style
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final glassColor = isDark 
        ? Colors.white.withOpacity(0.03) 
        : Colors.white.withOpacity(0.7);
    final glassBorder = isDark 
        ? Colors.white.withOpacity(0.08) 
        : Colors.black.withOpacity(0.05);

    return Container(
      width: width,
      height: height,
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color ?? (useGlass ? glassColor : theme.cardTheme.color),
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border ?? Border.all(color: useGlass ? glassBorder : Colors.transparent),
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: isDark ? 30 : 20,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            padding: padding ?? const EdgeInsets.all(24),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Professional section header for light backgrounds
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
    final theme = Theme.of(context);
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
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall,
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
