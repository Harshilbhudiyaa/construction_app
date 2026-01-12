import 'package:flutter/material.dart';

enum UiStatus {
  ok,
  low,
  pending,
  approved,
  rejected,
  inTransit,
  arrived,
  hold,
  stop,
  alert,
}

class StatusChip extends StatelessWidget {
  final UiStatus status;
  final String? labelOverride;

  const StatusChip({super.key, required this.status, this.labelOverride});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    String label() {
      if (labelOverride != null) return labelOverride!;
      switch (status) {
        case UiStatus.ok: return 'OK';
        case UiStatus.low: return 'LOW';
        case UiStatus.pending: return 'PENDING';
        case UiStatus.approved: return 'APPROVED';
        case UiStatus.rejected: return 'REJECTED';
        case UiStatus.inTransit: return 'IN TRANSIT';
        case UiStatus.arrived: return 'ARRIVED';
        case UiStatus.hold: return 'HOLD';
        case UiStatus.stop: return 'STOP';
        case UiStatus.alert: return 'ALERT';
      }
    }

    Color color() {
      switch (status) {
        case UiStatus.ok: return Colors.greenAccent;
        case UiStatus.low: return Colors.redAccent;
        case UiStatus.pending: return Colors.orangeAccent;
        case UiStatus.approved: return Colors.greenAccent;
        case UiStatus.rejected: return Colors.redAccent;
        case UiStatus.inTransit: return Colors.blueAccent;
        case UiStatus.arrived: return Colors.greenAccent;
        case UiStatus.hold: return Colors.orangeAccent;
        case UiStatus.stop: return Colors.redAccent;
        case UiStatus.alert: return Colors.orangeAccent;
      }
    }

    final c = color();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.withOpacity(0.25), width: 1),
      ),
      child: Text(
        label().toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color: c,
          fontSize: 10,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

}
