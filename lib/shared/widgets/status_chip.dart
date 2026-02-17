import 'package:flutter/material.dart';
import 'package:construction_app/shared/theme/app_theme.dart';

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
        case UiStatus.ok: return ConstructionColors.successGreen;
        case UiStatus.low: return ConstructionColors.errorRed;
        case UiStatus.pending: return const Color(0xFFFFB74D); // Amber
        case UiStatus.approved: return ConstructionColors.successGreen;
        case UiStatus.rejected: return ConstructionColors.errorRed;
        case UiStatus.inTransit: return const Color(0xFF5C6BC0); // Blue
        case UiStatus.arrived: return ConstructionColors.successGreen;
        case UiStatus.hold: return ConstructionColors.warningAmber;
        case UiStatus.stop: return ConstructionColors.errorRed;
        case UiStatus.alert: return const Color(0xFFFF6F00); // Deep Orange
      }
    }

    final c = color();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withOpacity(0.4), width: 1.5),
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
