import 'package:flutter/material.dart';

enum PaymentStatus {
  paid,
  pending,
  partial,
  overdue,
  failed,
}

class PaymentStatusBadge extends StatefulWidget {
  final PaymentStatus status;
  final bool showAnimation;
  final double fontSize;

  const PaymentStatusBadge({
    super.key,
    required this.status,
    this.showAnimation = true,
    this.fontSize = 11,
  });

  @override
  State<PaymentStatusBadge> createState() => _PaymentStatusBadgeState();
}

class _PaymentStatusBadgeState extends State<PaymentStatusBadge> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    if (widget.showAnimation && widget.status == PaymentStatus.pending) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getStatusLabel() {
    switch (widget.status) {
      case PaymentStatus.paid:
        return 'PAID';
      case PaymentStatus.pending:
        return 'PENDING';
      case PaymentStatus.partial:
        return 'PARTIAL';
      case PaymentStatus.overdue:
        return 'OVERDUE';
      case PaymentStatus.failed:
        return 'FAILED';
    }
  }

  IconData _getStatusIcon() {
    switch (widget.status) {
      case PaymentStatus.paid:
        return Icons.check_circle_rounded;
      case PaymentStatus.pending:
        return Icons.schedule_rounded;
      case PaymentStatus.partial:
        return Icons.hourglass_bottom_rounded;
      case PaymentStatus.overdue:
        return Icons.warning_rounded;
      case PaymentStatus.failed:
        return Icons.error_rounded;
    }
  }

  Color _getStatusColor() {
    switch (widget.status) {
      case PaymentStatus.paid:
        return Colors.greenAccent;
      case PaymentStatus.pending:
        return Colors.orangeAccent;
      case PaymentStatus.partial:
        return Colors.yellowAccent;
      case PaymentStatus.overdue:
        return Colors.redAccent;
      case PaymentStatus.failed:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();

    Widget badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(),
            color: color,
            size: widget.fontSize + 2,
          ),
          const SizedBox(width: 4),
          Text(
            _getStatusLabel(),
            style: TextStyle(
              color: color,
              fontSize: widget.fontSize,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );

    if (widget.showAnimation && widget.status == PaymentStatus.pending) {
      return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: 0.5 + (_controller.value * 0.5),
            child: child,
          );
        },
        child: badge,
      );
    }

    return badge;
  }
}
