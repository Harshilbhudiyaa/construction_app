import 'package:flutter/material.dart';

/// A reusable circular badge widget for the application logo.
class AppLogoBadge extends StatelessWidget {
  final double size;
  final double padding;
  final double? zoom;
  final List<BoxShadow>? boxShadow;
  final Color backgroundColor;

  const AppLogoBadge({
    super.key,
    this.size = 140,
    this.padding = 0,
    this.zoom = 1.15,
    this.boxShadow,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: EdgeInsets.all(padding),
      child: Transform.scale(
        scale: zoom ?? 1.0,
        child: Image.asset(
          'assets/images/logo.png',
          fit: BoxFit.cover,
          // Handle the large 8MB asset efficiently
          cacheWidth: (size * MediaQuery.of(context).devicePixelRatio).toInt(),
        ),
      ),
    );
  }
}
