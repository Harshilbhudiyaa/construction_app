import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/ui/widgets/section_header.dart';
import '../../../../app/ui/widgets/status_chip.dart';
import 'truck_arrival_confirm_screen.dart';
import 'truck_trips_list_screen.dart';

class TruckTripDetailScreen extends StatefulWidget {
  final TruckTripItem item;

  const TruckTripDetailScreen({super.key, required this.item});

  @override
  State<TruckTripDetailScreen> createState() => _TruckTripDetailScreenState();
}

class _TruckTripDetailScreenState extends State<TruckTripDetailScreen> {
  late TruckTripItem _item = widget.item;

  UiStatus _toUi(TruckTripStatus s) {
    switch (s) {
      case TruckTripStatus.scheduled:
        return UiStatus.pending;
      case TruckTripStatus.inTransit:
        return UiStatus.ok;
      case TruckTripStatus.arrived:
        return UiStatus.approved;
      case TruckTripStatus.hold:
        return UiStatus.low;
      case TruckTripStatus.stopped:
        return UiStatus.rejected;
    }
  }

  String _label(TruckTripStatus s) {
    switch (s) {
      case TruckTripStatus.scheduled:
        return 'Scheduled';
      case TruckTripStatus.inTransit:
        return 'In Transit';
      case TruckTripStatus.arrived:
        return 'Arrived';
      case TruckTripStatus.hold:
        return 'Hold';
      case TruckTripStatus.stopped:
        return 'Stop';
    }
  }

  void _setStatus(TruckTripStatus s) {
    setState(() => _item = _item.copyWith(status: s));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Decision applied: ${_label(s)} (UI-only)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Trip Detail')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      child: Icon(Icons.local_shipping_rounded, color: cs.onPrimaryContainer),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${_item.material} • ${_item.vehicleNo}', style: const TextStyle(fontWeight: FontWeight.w900)),
                          const SizedBox(height: 2),
                          Text(_item.supplier, style: TextStyle(color: cs.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    StatusChip(status: _toUi(_item.status), labelOverride: _label(_item.status)),
                  ],
                ),
              ),
            ),
          ),

          const SectionHeader(title: 'Trip Info', subtitle: 'Driver, timing, location'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    _kv('Driver', _item.driverName),
                    _kv('Depart', _item.departAt),
                    _kv('ETA', _item.eta),
                    _kv('Last GPS', _item.lastGps),
                    _kv('Trip ID', _item.id),
                  ],
                ),
              ),
            ),
          ),

          const SectionHeader(title: 'Proof', subtitle: 'Photo placeholders (UI-only)'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.photo_camera_rounded, color: cs.primary),
                    title: const Text('Departure Photo', style: TextStyle(fontWeight: FontWeight.w900)),
                    subtitle: const Text('Tap to open (placeholder)'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Open departure photo (next step)')),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.photo_camera_rounded, color: cs.primary),
                    title: const Text('Arrival Photo', style: TextStyle(fontWeight: FontWeight.w900)),
                    subtitle: const Text('Tap after arrival (placeholder)'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Open arrival photo (next step)')),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SectionHeader(title: 'Decision Engine', subtitle: 'Allow / Hold / Stop (UI-only)'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Checks: worker availability, storage space, safety compliance, weather.',
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _setStatus(TruckTripStatus.hold),
                            icon: const Icon(Icons.pause_circle_rounded),
                            label: const Text('Hold'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _setStatus(TruckTripStatus.stopped),
                            icon: const Icon(Icons.stop_circle_rounded),
                            label: const Text('Stop'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => _setStatus(TruckTripStatus.inTransit),
                        icon: const Icon(Icons.check_circle_rounded),
                        label: const Text('Allow / Continue'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SectionHeader(title: 'Arrival', subtitle: 'Confirm arrival and unload'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Card(
              child: ListTile(
                leading: Icon(Icons.fact_check_rounded, color: cs.primary),
                title: const Text('Confirm Arrival', style: TextStyle(fontWeight: FontWeight.w900)),
                subtitle: const Text('Capture arrival photo + time (UI-only)'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => TruckArrivalConfirmScreen(tripId: _item.id)),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(child: Text(k, style: const TextStyle(fontWeight: FontWeight.w800))),
          Text(v),
        ],
      ),
    );
  }
}
