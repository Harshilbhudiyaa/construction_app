import 'dart:math' as math;
import 'package:flutter/material.dart';

// ─── BounceFadeIn ────────────────────────────────────────────────────────────
/// Elastic scale + fade entrance animation — great for cards, tiles, dialogs.
class BounceFadeIn extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final double beginScale;
  final Offset beginOffset;

  const BounceFadeIn({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    this.delay = Duration.zero,
    this.curve = Curves.elasticOut,
    this.beginScale = 0.85,
    this.beginOffset = const Offset(0, 0.06),
  });

  @override
  State<BounceFadeIn> createState() => _BounceFadeInState();
}

class _BounceFadeInState extends State<BounceFadeIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<double> _scale;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);

    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0, 0.6, curve: Curves.easeOut),
      ),
    );
    _scale = Tween<double>(begin: widget.beginScale, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: widget.curve),
    );
    _slide = Tween<Offset>(begin: widget.beginOffset, end: Offset.zero).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    if (widget.delay == Duration.zero) {
      _ctrl.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _ctrl.forward();
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) => Opacity(
        opacity: _fade.value.clamp(0, 1),
        child: Transform.scale(
          scale: _scale.value,
          child: SlideTransition(
            position: _slide,
            child: child,
          ),
        ),
      ),
      child: widget.child,
    );
  }
}

// ─── GlowOnHover ─────────────────────────────────────────────────────────────
/// Adds an animated glow shadow on mouse hover / long press.
class GlowOnHover extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final double glowRadius;
  final Duration duration;
  final BorderRadius borderRadius;

  const GlowOnHover({
    super.key,
    required this.child,
    this.glowColor = const Color(0xFFF5A623),
    this.glowRadius = 16,
    this.duration = const Duration(milliseconds: 300),
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  });

  @override
  State<GlowOnHover> createState() => _GlowOnHoverState();
}

class _GlowOnHoverState extends State<GlowOnHover> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: widget.duration,
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius,
          boxShadow: [
            BoxShadow(
              color: _hovered
                  ? widget.glowColor.withValues(alpha: 0.25)
                  : widget.glowColor.withValues(alpha: 0),
              blurRadius: _hovered ? widget.glowRadius : 0,
              spreadRadius: _hovered ? 2 : 0,
            ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}

// ─── FloatingWidget ──────────────────────────────────────────────────────────
/// Gentle continuous up-down float animation — ideal for empty states, icons.
class FloatingWidget extends StatefulWidget {
  final Widget child;
  final double distance;
  final Duration duration;

  const FloatingWidget({
    super.key,
    required this.child,
    this.distance = 8.0,
    this.duration = const Duration(milliseconds: 2400),
  });

  @override
  State<FloatingWidget> createState() => _FloatingWidgetState();
}

class _FloatingWidgetState extends State<FloatingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final dy = math.sin(_ctrl.value * math.pi) * widget.distance;
        return Transform.translate(
          offset: Offset(0, -dy),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

// ─── AnimatedGradientBorder ──────────────────────────────────────────────────
/// An animated rotating gradient border — premium CTA or highlight effect.
class AnimatedGradientBorder extends StatefulWidget {
  final Widget child;
  final double borderWidth;
  final double borderRadius;
  final List<Color> colors;
  final Duration duration;

  const AnimatedGradientBorder({
    super.key,
    required this.child,
    this.borderWidth = 2.0,
    this.borderRadius = 16.0,
    this.colors = const [
      Color(0xFFF5A623),
      Color(0xFF3B82F6),
      Color(0xFF10B981),
      Color(0xFFF5A623),
    ],
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<AnimatedGradientBorder> createState() => _AnimatedGradientBorderState();
}

class _AnimatedGradientBorderState extends State<AnimatedGradientBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return CustomPaint(
          painter: _GradientBorderPainter(
            progress: _ctrl.value,
            borderWidth: widget.borderWidth,
            borderRadius: widget.borderRadius,
            colors: widget.colors,
          ),
          child: Padding(
            padding: EdgeInsets.all(widget.borderWidth),
            child: child,
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius - widget.borderWidth),
        child: widget.child,
      ),
    );
  }
}

class _GradientBorderPainter extends CustomPainter {
  final double progress;
  final double borderWidth;
  final double borderRadius;
  final List<Color> colors;

  _GradientBorderPainter({
    required this.progress,
    required this.borderWidth,
    required this.borderRadius,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      borderWidth / 2,
      borderWidth / 2,
      size.width - borderWidth,
      size.height - borderWidth,
    );
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..shader = SweepGradient(
        startAngle: progress * 2 * math.pi,
        endAngle: progress * 2 * math.pi + 2 * math.pi,
        colors: colors,
        tileMode: TileMode.clamp,
        transform: GradientRotation(progress * 2 * math.pi),
      ).createShader(rect);

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(_GradientBorderPainter old) => old.progress != progress;
}

// ─── TapScaleEffect ──────────────────────────────────────────────────────────
/// Wraps a child with a subtle scale-down on tap + glow shadow.
class TapScaleEffect extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;
  final Color glowColor;

  const TapScaleEffect({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.96,
    this.glowColor = const Color(0xFFF5A623),
  });

  @override
  State<TapScaleEffect> createState() => _TapScaleEffectState();
}

class _TapScaleEffectState extends State<TapScaleEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(begin: 1.0, end: widget.pressedScale).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}
