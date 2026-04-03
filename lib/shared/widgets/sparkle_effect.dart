import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A smooth sparkle/particle overlay that renders twinkling stars.
/// Wrap any widget with this to add a premium sparkle effect.
class SparkleOverlay extends StatefulWidget {
  final Widget child;
  final int particleCount;
  final Color sparkleColor;
  final double maxParticleSize;
  final bool enabled;

  const SparkleOverlay({
    super.key,
    required this.child,
    this.particleCount = 20,
    this.sparkleColor = const Color(0xFFF5A623),
    this.maxParticleSize = 3.0,
    this.enabled = true,
  });

  @override
  State<SparkleOverlay> createState() => _SparkleOverlayState();
}

class _SparkleOverlayState extends State<SparkleOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_SparkleParticle> _particles;
  final _random = math.Random();

  @override
  void initState() {
    super.initState();
    _particles = List.generate(
      widget.particleCount,
      (_) => _SparkleParticle.random(_random),
    );
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => CustomPaint(
                painter: _SparklePainter(
                  particles: _particles,
                  progress: _controller.value,
                  color: widget.sparkleColor,
                  maxSize: widget.maxParticleSize,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SparkleParticle {
  final double x; // 0..1
  final double y; // 0..1
  final double phase; // 0..1 — offset so they don't all blink together
  final double speed; // multiplier
  final double size; // 0..1

  const _SparkleParticle({
    required this.x,
    required this.y,
    required this.phase,
    required this.speed,
    required this.size,
  });

  factory _SparkleParticle.random(math.Random rng) {
    return _SparkleParticle(
      x: rng.nextDouble(),
      y: rng.nextDouble(),
      phase: rng.nextDouble(),
      speed: 0.5 + rng.nextDouble() * 1.5,
      size: 0.3 + rng.nextDouble() * 0.7,
    );
  }
}

class _SparklePainter extends CustomPainter {
  final List<_SparkleParticle> particles;
  final double progress;
  final Color color;
  final double maxSize;

  _SparklePainter({
    required this.particles,
    required this.progress,
    required this.color,
    required this.maxSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      // Each particle twinkles at its own rate
      final t = ((progress * p.speed + p.phase) % 1.0);
      // Smooth twinkle: fade in then out
      final alpha = (math.sin(t * math.pi * 2) * 0.5 + 0.5).clamp(0.0, 1.0);

      if (alpha < 0.05) continue; // Skip invisible particles

      final dx = p.x * size.width;
      // Drift upward slowly
      final dy = (p.y - progress * 0.08 * p.speed) % 1.0 * size.height;
      final radius = p.size * maxSize;

      // Glow
      final glowPaint = Paint()
        ..color = color.withValues(alpha: alpha * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(Offset(dx, dy), radius * 2.5, glowPaint);

      // Core sparkle
      final corePaint = Paint()
        ..color = color.withValues(alpha: alpha * 0.9);
      canvas.drawCircle(Offset(dx, dy), radius, corePaint);

      // Cross-hair lines for star shape
      if (radius > 1.5) {
        final linePaint = Paint()
          ..color = color.withValues(alpha: alpha * 0.5)
          ..strokeWidth = 0.5
          ..strokeCap = StrokeCap.round;
        final len = radius * 2.2;
        canvas.drawLine(
          Offset(dx - len, dy),
          Offset(dx + len, dy),
          linePaint,
        );
        canvas.drawLine(
          Offset(dx, dy - len),
          Offset(dx, dy + len),
          linePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_SparklePainter old) => old.progress != progress;
}
