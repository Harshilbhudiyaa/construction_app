import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/professional_theme.dart';
import '../../../../app/ui/widgets/app_search_field.dart';
import '../../../../app/ui/widgets/empty_state.dart';
import '../../../../app/ui/widgets/status_chip.dart';
import '../../../../app/ui/widgets/professional_page.dart';
import 'create_truck_entry_screen.dart';
import 'truck_trip_detail_screen.dart';

enum TruckTripStatus { scheduled, inTransit, arrived, hold, stopped }

class TruckTripsListScreen extends StatefulWidget {
  const TruckTripsListScreen({super.key});

  @override
  State<TruckTripsListScreen> createState() => _TruckTripsListScreenState();
}

class _TruckTripsListScreenState extends State<TruckTripsListScreen> {
  String _query = '';
  TruckTripStatus? _filter;
  String _range = 'Today';

  final List<TruckTripItem> _items = [
    const TruckTripItem(
      id: 'TR-9005',
      supplier: 'ABC Sand Supplier',
      material: 'Sand',
      vehicleNo: 'GJ01AB1234',
      driverName: 'Rajesh',
      status: TruckTripStatus.inTransit,
      departAt: '10:20 AM',
      eta: '12:10 PM',
      lastGps: 'Near Highway Junction',
    ),
    const TruckTripItem(
      id: 'TR-9002',
      supplier: 'Cement Depot',
      material: 'Cement (Bags)',
      vehicleNo: 'GJ02CD5678',
      driverName: 'Mahesh',
      status: TruckTripStatus.hold,
      departAt: '09:10 AM',
      eta: '11:00 AM',
      lastGps: 'City Gate',
    ),
    const TruckTripItem(
      id: 'TR-8999',
      supplier: 'Steel Yard',
      material: 'Steel Rod',
      vehicleNo: 'GJ03EF4321',
      driverName: 'Sanjay',
      status: TruckTripStatus.arrived,
      departAt: '07:30 AM',
      eta: '09:00 AM',
      lastGps: 'Site A',
    ),
  ];

  List<TruckTripItem> get _filtered {
    final q = _query.trim().toLowerCase();
    return _items.where((x) {
      if (_filter != null && x.status != _filter) return false;
      if (q.isEmpty) return true;
      final hay =
          '${x.id} ${x.supplier} ${x.material} ${x.vehicleNo} ${x.driverName} ${x.lastGps}'
              .toLowerCase();
      return hay.contains(q);
    }).toList();
  }

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

  @override
  Widget build(BuildContext context) {
    return ProfessionalPage(
      title: 'Truck Trips',
      actions: [
        IconButton(
          tooltip: 'Create Truck Entry',
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CreateTruckEntryScreen(),
              ),
            );
          },
          icon: const Icon(Icons.add_circle_rounded, color: Colors.white),
        ),
      ],
      children: [
        AppSearchField(
          hint: 'Search supplier, vehicle, id...',
          onChanged: (v) => setState(() => _query = v),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Today', 'This Week', 'This Month'].map((r) {
              final selected = _range == r;
              return ChoiceChip(
                label: Text(r),
                selected: selected,
                onSelected: (_) => setState(() => _range = r),
              );
            }).toList(),
          ),
        ),

        const ProfessionalSectionHeader(
          title: 'Filters',
          subtitle: 'Status-based supply monitoring',
        ),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ProfessionalCard(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _filter == null,
                  onSelected: (_) => setState(() => _filter = null),
                ),
                FilterChip(
                  label: const Text('In Transit'),
                  selected: _filter == TruckTripStatus.inTransit,
                  onSelected: (_) =>
                      setState(() => _filter = TruckTripStatus.inTransit),
                ),
                FilterChip(
                  label: const Text('Arrived'),
                  selected: _filter == TruckTripStatus.arrived,
                  onSelected: (_) =>
                      setState(() => _filter = TruckTripStatus.arrived),
                ),
                FilterChip(
                  label: const Text('Hold'),
                  selected: _filter == TruckTripStatus.hold,
                  onSelected: (_) =>
                      setState(() => _filter = TruckTripStatus.hold),
                ),
                FilterChip(
                  label: const Text('Stop'),
                  selected: _filter == TruckTripStatus.stopped,
                  onSelected: (_) =>
                      setState(() => _filter = TruckTripStatus.stopped),
                ),
              ],
            ),
          ),
        ),

        const ProfessionalSectionHeader(
          title: 'Trips',
          subtitle: 'Active and recent logistics',
        ),

        if (_filtered.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: EmptyState(
              icon: Icons.local_shipping_rounded,
              title: 'No trips found',
              message: 'Try changing filters or search.',
            ),
          )
        else
          ..._filtered.map((x) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ProfessionalCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.deepBlue1.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.local_shipping_rounded,
                      color: AppColors.deepBlue1,
                    ),
                  ),
                  title: Text(
                    '${x.material} • ${x.vehicleNo}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppColors.deepBlue1,
                    ),
                  ),
                  subtitle: Text(
                    '${x.supplier}\nDriver: ${x.driverName} • ${x.departAt} → ETA ${x.eta}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  isThreeLine: true,
                  trailing: StatusChip(
                    status: _toUi(x.status),
                    labelOverride: _label(x.status),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TruckTripDetailScreen(item: x),
                      ),
                    );
                  },
                ),
              ),
            );
          }),

        const SizedBox(height: 16),
      ],
    );
  }
}


class TruckTripItem {
  final String id;
  final String supplier;
  final String material;
  final String vehicleNo;
  final String driverName;
  final TruckTripStatus status;
  final String departAt;
  final String eta;
  final String lastGps;

  const TruckTripItem({
    required this.id,
    required this.supplier,
    required this.material,
    required this.vehicleNo,
    required this.driverName,
    required this.status,
    required this.departAt,
    required this.eta,
    required this.lastGps,
  });

  TruckTripItem copyWith({TruckTripStatus? status}) {
    return TruckTripItem(
      id: id,
      supplier: supplier,
      material: material,
      vehicleNo: vehicleNo,
      driverName: driverName,
      status: status ?? this.status,
      departAt: departAt,
      eta: eta,
      lastGps: lastGps,
    );
  }
}
