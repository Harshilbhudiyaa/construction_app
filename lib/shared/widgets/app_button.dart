import 'package:flutter/material.dart';
import 'package:construction_app/core/theme/design_system.dart';

enum AppButtonVariant { primary, secondary, ghost, danger, ghostBorder }

class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final EdgeInsetsGeometry? padding;

  const AppButton({
    super.key,
    required this.label,
    this.onTap,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.width,
    this.padding,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _scaleAnim;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color foregroundColor;
    BorderSide? border;

    switch (widget.variant) {
      case AppButtonVariant.primary:
        backgroundColor = DesignSystem.primary;
        foregroundColor = Colors.white;
        break;
      case AppButtonVariant.secondary:
        backgroundColor = DesignSystem.accent;
        foregroundColor = Colors.black;
        break;
      case AppButtonVariant.ghost:
        backgroundColor = Colors.transparent;
        foregroundColor = DesignSystem.primary;
        break;
      case AppButtonVariant.ghostBorder:
        backgroundColor = Colors.transparent;
        foregroundColor = DesignSystem.primary;
        border = const BorderSide(color: DesignSystem.border, width: 1.5);
        break;
      case AppButtonVariant.danger:
        backgroundColor = DesignSystem.error.withValues(alpha: 0.1);
        foregroundColor = DesignSystem.error;
        break;
    }

    final isPrimary = widget.variant == AppButtonVariant.primary;

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: 0,
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: border ?? BorderSide.none,
      ),
      textStyle: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 14,
        letterSpacing: 0.2,
      ),
    );

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          )
        else if (widget.icon != null) ...[
          Icon(widget.icon, size: 18),
          const SizedBox(width: 8),
        ],
        if (!widget.isLoading) Text(widget.label),
      ],
    );

    Widget button;
    if (widget.width != null) {
      button = SizedBox(
        width: widget.width,
        child: ElevatedButton(
          onPressed: widget.isLoading ? null : widget.onTap,
          style: buttonStyle,
          child: content,
        ),
      );
    } else {
      button = ElevatedButton(
        onPressed: widget.isLoading ? null : widget.onTap,
        style: buttonStyle,
        child: content,
      );
    }

    // Wrap primary buttons with press scale + glow effect
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => _pressCtrl.forward(),
        onTapUp: (_) => _pressCtrl.reverse(),
        onTapCancel: () => _pressCtrl.reverse(),
        child: AnimatedBuilder(
          animation: _scaleAnim,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnim.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: isPrimary && _hovered
                    ? [
                        BoxShadow(
                          color: DesignSystem.primary.withValues(alpha: 0.3),
                          blurRadius: 16,
                          spreadRadius: -2,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: child,
            ),
          ),
          child: button,
        ),
      ),
    );
  }
}
