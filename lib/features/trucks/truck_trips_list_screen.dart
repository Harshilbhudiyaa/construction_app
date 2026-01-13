import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/professional_theme.dart';
import '../../../../app/ui/widgets/app_search_field.dart';
import '../../../../app/ui/widgets/empty_state.dart';
import '../../../../app/ui/widgets/staggered_animation.dart';
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
      title: 'Truck Logistics',
      actions: [
        IconButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateTruckEntryScreen()),
            );
          },
          icon: const Icon(Icons.add_circle_rounded, color: Colors.white),
        ),
      ],
      children: [
        // 1. Search Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: AppSearchField(
            hint: 'Search supplier, vehicle, id...',
            useGlass: true,
            onChanged: (v) => setState(() => _query = v),
          ),
        ),

        // 3. Logistics Summary KPIs
        SizedBox(
          height: 110,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              _buildSummaryKpi(
                'IN TRANSIT',
                '4',
                Icons.local_shipping_rounded,
                Colors.blueAccent,
                'Active',
              ),
              _buildSummaryKpi(
                'ETA < 1HR',
                '2',
                Icons.timer_rounded,
                Colors.orangeAccent,
                'Nearing',
              ),
              _buildSummaryKpi(
                'ARRIVED',
                '12',
                Icons.check_circle_rounded,
                Colors.greenAccent,
                'Today',
              ),
              _buildSummaryKpi(
                'ALERTS',
                '1',
                Icons.warning_rounded,
                Colors.redAccent,
                'Priority',
              ),
            ],
          ),
        ),

        const ProfessionalSectionHeader(
          title: 'Fleet Filter',
          subtitle: 'Status-based supply monitoring',
        ),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _FilterBtn(
                  label: 'All Capacity',
                  isSelected: _filter == null,
                  onTap: () => setState(() => _filter = null),
                ),
                _FilterBtn(
                  label: 'In Transit',
                  isSelected: _filter == TruckTripStatus.inTransit,
                  onTap: () => setState(() => _filter = TruckTripStatus.inTransit),
                ),
                _FilterBtn(
                  label: 'Arrived',
                  isSelected: _filter == TruckTripStatus.arrived,
                  onTap: () => setState(() => _filter = TruckTripStatus.arrived),
                ),
                _FilterBtn(
                  label: 'Hold',
                  isSelected: _filter == TruckTripStatus.hold,
                  onTap: () => setState(() => _filter = TruckTripStatus.hold),
                ),
              ],
            ),
          ),
        ),

        const ProfessionalSectionHeader(
          title: 'Active Manifests',
          subtitle: 'Live inbound logistics tracking',
        ),

        if (_filtered.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 48),
            child: EmptyState(
              icon: Icons.local_shipping_rounded,
              title: 'No active trips',
              message: 'Logistics pipeline is currently empty.',
              useGlass: true,
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _filtered.length,
            itemBuilder: (context, index) {
              final x = _filtered[index];
              return StaggeredAnimation(
                index: index,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: _buildLogisticsCard(x),
                ),
              );
            },
          ),

        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildSummaryKpi(String label, String value, IconData icon, Color color, String trend) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 18),
              Text(
                trend,
                style: TextStyle(color: color.withOpacity(0.7), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
              ),
              Text(
                label,
                style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.5),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogisticsCard(TruckTripItem x) {
    final statusColor = x.status == TruckTripStatus.inTransit 
        ? Colors.blueAccent 
        : (x.status == TruckTripStatus.arrived ? Colors.greenAccent : Colors.redAccent);

    final bool isLive = x.status == TruckTripStatus.inTransit;

    return ProfessionalCard(
      useGlass: true,
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TruckTripDetailScreen(item: x)),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.local_shipping_rounded, color: statusColor, size: 22),
                      ),
                      if (isLive)
                        _buildLiveDot(),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          x.vehicleNo,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                        ),
                        Text(
                          '${x.material.toUpperCase()} • ${x.supplier}',
                          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                        ),
                      ],
                    ),
                  ),
                  StatusChip(status: _toUi(x.status), labelOverride: _label(x.status)),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _buildLogDetail(Icons.person_pin_circle_rounded, x.driverName),
                    const SizedBox(width: 16),
                    _buildLogDetail(Icons.access_time_filled_rounded, 'ETA ${x.eta}'),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(x.id, style: const TextStyle(color: Colors.blueAccent, fontSize: 9, fontWeight: FontWeight.w900)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiveDot() {
    return Container(
      width: 8,
      height: 8,
      margin: const EdgeInsets.all(2),
      decoration: const BoxDecoration(
        color: Colors.redAccent,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.redAccent, blurRadius: 4, spreadRadius: 1),
        ],
      ),
    );
  }

  Widget _buildLogDetail(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 12, color: Colors.white.withOpacity(0.4)),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _FilterBtn extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterBtn({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blueAccent : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.blueAccent : Colors.white.withOpacity(0.1),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
            ),
          ),
        ),
      ),
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
