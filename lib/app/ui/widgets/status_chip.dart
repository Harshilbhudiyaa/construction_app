import 'package:flutter/material.dart';

enum UiStatus { ok, low, pending, approved, rejected, inTransit, arrived, hold, stop }

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
        case UiStatus.ok:
          return 'OK';
        case UiStatus.low:
          return 'Low';
        case UiStatus.pending:
          return 'Pending';
        case UiStatus.approved:
          return 'Approved';
        case UiStatus.rejected:
          return 'Rejected';
        case UiStatus.inTransit:
          return 'In Transit';
        case UiStatus.arrived:
          return 'Arrived';
        case UiStatus.hold:
          return 'Hold';
        case UiStatus.stop:
          return 'Stop';
      }
    }

    Color color() {
      switch (status) {
        case UiStatus.ok:
          return cs.primary;
        case UiStatus.low:
          return cs.error;
        case UiStatus.pending:
          return cs.tertiary;
        case UiStatus.approved:
          return Colors.green;
        case UiStatus.rejected:
          return cs.error;
        case UiStatus.inTransit:
          return cs.tertiary;
        case UiStatus.arrived:
          return Colors.green;
        case UiStatus.hold:
          return Colors.orange;
        case UiStatus.stop:
          return cs.error;
      }
    }

    final c = color();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label(),
        style: TextStyle(fontWeight: FontWeight.w800, color: c, fontSize: 12),
      ),
    );
  }
}
