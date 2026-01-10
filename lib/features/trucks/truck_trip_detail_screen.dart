import 'package:flutter/material.dart';
import '../../../../app/theme/professional_theme.dart';
import '../../../../app/ui/widgets/professional_page.dart';
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
      case TruckTripStatus.scheduled: return UiStatus.pending;
      case TruckTripStatus.inTransit: return UiStatus.ok;
      case TruckTripStatus.arrived: return UiStatus.approved;
      case TruckTripStatus.hold: return UiStatus.low;
      case TruckTripStatus.stopped: return UiStatus.rejected;
    }
  }

  String _label(TruckTripStatus s) {
    switch (s) {
      case TruckTripStatus.scheduled: return 'Scheduled';
      case TruckTripStatus.inTransit: return 'In Transit';
      case TruckTripStatus.arrived: return 'Arrived';
      case TruckTripStatus.hold: return 'Held';
      case TruckTripStatus.stopped: return 'Stopped';
    }
  }

  void _setStatus(TruckTripStatus s) {
    setState(() => _item = _item.copyWith(status: s));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Logistics Decision Applied: ${_label(s)}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ProfessionalPage(
      title: 'Dispatch Intelligence',
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ProfessionalCard(
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: AppColors.gradientColors),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.deepBlue1.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.local_shipping_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_item.material} • ${_item.vehicleNo}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.deepBlue1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _item.supplier,
                        style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                StatusChip(
                  status: _toUi(_item.status),
                  labelOverride: _label(_item.status).toUpperCase(),
                ),
              ],
            ),
          ),
        ),

        const ProfessionalSectionHeader(
          title: 'Transit Logistics',
          subtitle: 'Live telemetry and timing data',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ProfessionalCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _kv('Direct Driver', _item.driverName, icon: Icons.person_pin_circle_rounded),
                const Divider(height: 32),
                _kv('Departure Time', _item.departAt, icon: Icons.outbox_rounded),
                const Divider(height: 32),
                _kv('Estimated Arrival', _item.eta, icon: Icons.timer_rounded, isHighlighted: true),
                const Divider(height: 32),
                _kv('Geospatial Tag', _item.lastGps, icon: Icons.map_rounded),
                const Divider(height: 32),
                _kv('Trip Reference', _item.id, icon: Icons.tag_rounded),
              ],
            ),
          ),
        ),

        const ProfessionalSectionHeader(
          title: 'Verification Proofs',
          subtitle: 'Visual evidence captured during transit',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ProfessionalCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.add_a_photo_rounded, color: Colors.blue, size: 20),
                  ),
                  title: const Text('Departure Manifesto', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.deepBlue1)),
                  subtitle: const Text('Verified by supplier kiosk at gate'),
                  trailing: const Icon(Icons.chevron_right_rounded, size: 18),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.photo_library_rounded, color: Colors.orange, size: 20),
                  ),
                  title: const Text('Load Inspection Photo', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.deepBlue1)),
                  subtitle: const Text('Pending arrival confirmation'),
                  trailing: const Icon(Icons.chevron_right_rounded, size: 18),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),

        const ProfessionalSectionHeader(
          title: 'Dispatch Control',
          subtitle: 'Real-time intervention options',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ProfessionalCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Automated checks: worker capacity, site space, and safety metrics are green.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _setStatus(TruckTripStatus.hold),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.orange[400]!),
                          foregroundColor: Colors.orange[800],
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.pause_circle_filled_rounded, size: 18),
                        label: const Text('Initiate Hold', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _setStatus(TruckTripStatus.stopped),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.red[400]!),
                          foregroundColor: Colors.red[800],
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.cancel_rounded, size: 18),
                        label: const Text('Terminate Trip', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () => _setStatus(TruckTripStatus.inTransit),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.deepBlue1,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.verified_user_rounded, size: 20),
                    label: const Text('Authorize / Continue', style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            ),
          ),
        ),

        const ProfessionalSectionHeader(
          title: 'Unloading Protocol',
          subtitle: 'Formal site entry sequence',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ProfessionalCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.fact_check_rounded, color: Colors.green),
              ),
              title: const Text('Execute Arrival Seq', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.deepBlue1, fontSize: 16)),
              subtitle: const Text('Capture arrival biometrics + visual proof'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => TruckArrivalConfirmScreen(tripId: _item.id)),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _kv(String k, String v, {IconData? icon, bool isHighlighted = false}) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: Colors.grey[400]),
          const SizedBox(width: 12),
        ],
        Text(k, style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w700)),
        const Spacer(),
        Text(
          v,
          style: TextStyle(
            color: isHighlighted ? Colors.orange[800] : AppColors.deepBlue1,
            fontWeight: FontWeight.w900,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
