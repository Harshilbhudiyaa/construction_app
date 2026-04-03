import 'package:flutter/material.dart';

/// Construction-themed progress bar with yellow/black stripe pattern
class ConstructionProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double height;
  final Color backgroundColor;
  final Color progressColor;
  final bool showStripes;
  final BorderRadius? borderRadius;

  const ConstructionProgressBar({
    super.key,
    required this.progress,
    this.height = 8,
    this.backgroundColor = const Color(0xFFE0E0E0),
    this.progressColor = const Color(0xFFFFD700), // Construction Yellow
    this.showStripes = false,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          tween: Tween<double>(begin: 0, end: progress),
          builder: (context, value, child) {
            return FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: progressColor,
                  borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Circular progress indicator with construction theme
class ConstructionCircularProgress extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double size;
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;
  final Widget? center;
  final VoidCallback? onTap;

  const ConstructionCircularProgress({
    super.key,
    required this.progress,
    this.size = 60,
    this.strokeWidth = 6,
    this.backgroundColor = const Color(0xFFE0E0E0),
    this.progressColor = const Color(0xFFFFD700),
    this.center,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background circle
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                value: 1.0,
                strokeWidth: strokeWidth,
                backgroundColor: backgroundColor,
                valueColor: AlwaysStoppedAnimation<Color>(backgroundColor),
              ),
            ),
            // Animated progress
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              tween: Tween<double>(begin: 0, end: progress),
              builder: (context, value, child) {
                return SizedBox(
                  width: size,
                  height: size,
                  child: CircularProgressIndicator(
                    value: value.clamp(0.0, 1.0),
                    strokeWidth: strokeWidth,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                    strokeCap: StrokeCap.round,
                  ),
                );
              },
            ),
            // Center content
            ?center,




          ],
        ),
      ),
    );
  }
}
