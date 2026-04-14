import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';
import 'package:construction_app/shared/events/shell_events.dart';
import 'package:construction_app/shared/widgets/responsive_layout.dart';

/// SmartConstruction Premium Aesthetic Tokens 🏗️
/// Shared across the app for a unified, high-end construction feel.

// ─── Colors (Enterprise Construction Palette) ──────────────────────────────────

const Color bcNavy = Color(0xFF0F172A);    // Slate 900 - Deep & Industrial
const Color bcNavyMid = Color(0xFF1E293B); // Slate 800
const Color bcAmber = Color(0xFFF5A623);   // Hard Hat Yellow - High Visibility Accent
const Color bcSuccess = Color(0xFF10B981); // Emerald 500
const Color bcDanger = Color(0xFFEF4444);  // Rose 500
const Color bcInfo = Color(0xFF3B82F6);    // Blue 500
const Color bcSurface = Color(0xFFF8FAFC); // Slate 50 - Background
const Color bcCard = Colors.white;         // Clean White Cards
const Color bcBorder = Color(0xFFE2E8F0);  // Slate 200 - subtle borders
const Color bcPrimary = bcAmber;           // Primary Accent (Hard Hat Yellow)
const Color bcTextPrimary = Color(0xFF0F172A);
const Color bcTextSecondary = Color(0xFF64748B);
const Color bcTactileBg      = Color(0xFF0E1116);
const Color bcTactileAmber   = Color(0xFFE8A838);
const Color bcTactileSurface = Color(0xFF161B22);
const Color bcTactileBorder  = Color(0xFF21262D);

// Blueprint Blue Theme
const Color bcBlueprintBg     = Color(0xFF1E3A8A); // Royal/Deep Blue
const Color bcBlueprintAccent = Color(0xFF38BDF8); // Sky Blue Accent
const Color bcBlueprintGrid   = Colors.white;

// ─── Shared Painters ─────────────────────────────────────────────────────────

/// Renders a blueprint-style background grid.
class BlueprintGridPainter extends CustomPainter {
  final double opacity;
  final Color? gridColor;
  final double gridSize;
  
  BlueprintGridPainter({
    this.opacity = 0.18, 
    this.gridColor,
    this.gridSize = 28.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (gridColor ?? const Color(0xFF1A3A6B)).withValues(alpha: opacity)
      ..strokeWidth = 0.5;

    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant BlueprintGridPainter old) =>
      old.opacity != opacity || old.gridColor != gridColor || old.gridSize != gridSize;
}


/// Renders a minimalistic construction crane icon.
class ConstructionCranePainter extends CustomPainter {
  final Color color;
  ConstructionCranePainter({this.color = bcAmber});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Mast
    canvas.drawLine(
        Offset(size.width * 0.6, size.height),
        Offset(size.width * 0.6, size.height * 0.05),
        p);
    // Jib
    canvas.drawLine(
        Offset(size.width * 0.6, size.height * 0.08),
        Offset(0, size.height * 0.08),
        p);
    // Back jib
    canvas.drawLine(
        Offset(size.width * 0.6, size.height * 0.08),
        Offset(size.width, size.height * 0.16),
        p..strokeWidth = 1.5);
    // Cable
    canvas.drawLine(
        Offset(size.width * 0.2, size.height * 0.08),
        Offset(size.width * 0.2, size.height * 0.4),
        p..strokeWidth = 1);
    // Hook arc
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(size.width * 0.2, size.height * 0.43),
          width: 10,
          height: 10),
      0,
      math.pi,
      false,
      p,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─── Shared Widgets ──────────────────────────────────────────────────────────

/// A stylized divider inspired by steel I-beams.
class SteelBeamDivider extends StatelessWidget {
  final Color color;
  final double height;
  final double width;
  
  const SteelBeamDivider({
    super.key, 
    this.color = bcAmber, 
    this.height = 3.0,
    this.width = 60.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );
  }
}

/// A premium, construction-themed SliverAppBar.
class SmartConstructionSliverAppBar extends StatelessWidget {
  final String title;
  final Widget? titleWidget;
  final String subtitle;
  final String category;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final List<Widget>? headerStats;
  final bool isFull;

  const SmartConstructionSliverAppBar({
    super.key,
    required this.title,
    this.titleWidget,
    required this.subtitle,
    this.category = 'SmartConstruction SYSTEM',
    this.actions,
    this.bottom,
    this.headerStats,
    this.isFull = false,
  });


  @override
  Widget build(BuildContext context) {
    final hasBottom = bottom != null;
    final hasStats = headerStats != null && headerStats!.isNotEmpty;
    final isWide = !ResponsiveLayout.isMobile(context);

    // Height tuned to prevent bottom overflows. Stats add ~70px; bottom TabBar adds ~90px.
    double expandedH;
    if (isFull) {
      expandedH = (hasBottom ? (isWide ? 410.0 : 400.0) : (isWide ? 310.0 : 280.0));
    } else {
      // Increased to 320/310 to accommodate TabBars with icons+text (Stock Operations)
      expandedH = (hasBottom ? (isWide ? 320.0 : 310.0) : (isWide ? 240.0 : 220.0));
    }
    // Extra height when we have both stats and a bottom bar
    if (hasStats && hasBottom) expandedH += (isWide ? 100.0 : 100.0);
    if (hasStats && !hasBottom) expandedH += (isWide ? 90.0 : 90.0);

    return SliverAppBar(
      expandedHeight: expandedH,
      pinned: true,
      stretch: true,
      backgroundColor: bcNavy,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      leading: Navigator.canPop(context)
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: bcAmber, size: 20),
              onPressed: () => Navigator.pop(context),
            )
          : (ResponsiveLayout.isMobile(context)
              ? IconButton(
                  icon: const Icon(Icons.menu_rounded, color: bcAmber),
                  onPressed: () => OpenShellDrawerNotification().dispatch(context),
                )
              : null),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: BlueprintGridPainter(opacity: 0.1, gridColor: bcAmber.withValues(alpha: 0.2)),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16, isWide ? 70 : 80, 16, hasBottom ? (isWide ? 80 : 70) : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                    Text(
                      category.toUpperCase(),
                      style: TextStyle(
                        color: bcAmber.withValues(alpha: 0.7),
                        fontSize: isWide ? 10 : 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.2,
                      ),
                    ),
                  const SizedBox(height: 6),
                  titleWidget ?? Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isWide ? 34 : 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.2,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                  if (headerStats != null) ...[
                    const SizedBox(height: 24),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(children: headerStats!),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      actions: actions,
      bottom: bottom,
    );
  }
}

// ─── Shared Components ──────────────────────────────────────────────────────

class HeroStatPill extends StatelessWidget {
  final String label, value;
  final IconData? icon;
  final Widget? iconWidget;
  final Color color;
  final bool showBorder;
  final VoidCallback? onTap;

  const HeroStatPill({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.iconWidget,
    required this.color,
    this.showBorder = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(24),
              splashColor: color.withValues(alpha: 0.1),
              highlightColor: color.withValues(alpha: 0.05),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: !ResponsiveLayout.isMobile(context) ? 22 : 12,
                  vertical: !ResponsiveLayout.isMobile(context) ? 14 : 8,
                ), 
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF1E293B).withValues(alpha: 0.7), // Slate 800
                      const Color(0xFF0F172A).withValues(alpha: 0.8), // Slate 900
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: showBorder ? Border.all(color: color.withValues(alpha: 0.4), width: 1.5) : null,
                  boxShadow: [
                    if (showBorder) BoxShadow(
                      color: color.withValues(alpha: 0.15),
                      blurRadius: 12,
                      spreadRadius: -4,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null || iconWidget != null) ...[
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(color: color.withValues(alpha: 0.15), width: 1),
                        ),
                        child: iconWidget ?? Icon(icon, color: color, size: !ResponsiveLayout.isMobile(context) ? 14 : 12),
                      ),
                      SizedBox(width: !ResponsiveLayout.isMobile(context) ? 16 : 10),
                    ] else ...[
                      const SizedBox(width: 4),
                    ],
                    Flexible(
                      fit: FlexFit.loose,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            value,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: !ResponsiveLayout.isMobile(context) ? 30 : 20, 
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1.5,
                              height: 1.0, 
                              shadows: [
                                Shadow(color: Colors.black.withValues(alpha: 0.2), offset: const Offset(0, 2), blurRadius: 4),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6), // Better spacing for legibility
                          Text(
                            label.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.65),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.4, // Wider tracking for clarity
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Premium Components ──────────────────────────────────────────────────────

/// A high-end glassmorphism card.
class GlassCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final Color? color;
  final BorderRadius? borderRadius;
  final Border? border;
  final EdgeInsetsGeometry? padding;

  const GlassCard({
    super.key,
    required this.child,
    this.blur = 15.0,
    this.opacity = 0.1,
    this.color,
    this.borderRadius,
    this.border,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: (color ?? Colors.white).withValues(alpha: opacity),
            borderRadius: borderRadius ?? BorderRadius.circular(20),
            border: border ?? Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// A professional action card with gradient and icon.
class PremiumActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isCompact;

  const PremiumActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: EdgeInsets.all(isCompact ? 12 : 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.15),
                  color.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: isCompact ? 20 : 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: bcNavy,
                          fontSize: isCompact ? 14 : 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: bcNavy.withValues(alpha: 0.6),
                          fontSize: isCompact ? 11 : 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: color.withValues(alpha: 0.4), size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A standardized status pill.
class StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final bool onDark;

  const StatusPill({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.onDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = onDark ? Colors.white : color;
    final bgColor = onDark ? Colors.white.withValues(alpha: 0.15) : color.withValues(alpha: 0.1);
    final borderColor = onDark ? Colors.white.withValues(alpha: 0.3) : color.withValues(alpha: 0.2);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: effectiveColor, size: 12),
            const SizedBox(width: 4),
          ],
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: effectiveColor,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

/// A premium toggle for app modes.
class ModeToggleWidget extends StatelessWidget {
  final bool isAdvanced;
  final Function(bool) onToggle;

  const ModeToggleWidget({
    super.key,
    required this.isAdvanced,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bcNavy.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildOption('SIMPLE', !isAdvanced),
          _buildOption('ADVANCED', isAdvanced),
        ],
      ),
    );
  }

  Widget _buildOption(String label, bool active) {
    return GestureDetector(
      onTap: active ? null : () => onToggle(label == 'ADVANCED'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? bcAmber : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          boxShadow: active ? [
            BoxShadow(
              color: bcAmber.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ] : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : bcNavy.withValues(alpha: 0.4),
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}

