import 'package:flutter/material.dart';
import 'package:construction_app/shared/theme/professional_theme.dart';
import 'package:construction_app/shared/widgets/professional_page.dart';
import 'package:construction_app/shared/widgets/staggered_animation.dart';
import 'package:construction_app/shared/widgets/app_search_field.dart';
import 'package:construction_app/shared/widgets/empty_state.dart';
import 'machine_model.dart';
import 'machine_form_screen.dart';
import 'machine_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:construction_app/services/mock_machine_service.dart';

class MachineManagementScreen extends StatefulWidget {
  final String? activeSiteId;
  const MachineManagementScreen({super.key, this.activeSiteId});

  @override
  State<MachineManagementScreen> createState() => _MachineManagementScreenState();
}

class _MachineManagementScreenState extends State<MachineManagementScreen> {
  String _searchQuery = '';
  MachineStatus? _filterStatus;

  @override
  Widget build(BuildContext context) {
    return Consumer<MockMachineService>(
      builder: (context, service, child) {
        final machines = service.machines;
        
        final filtered = machines.where((m) {
          if (widget.activeSiteId != null && m.assignedSiteId != widget.activeSiteId) {
            return false;
          }
          final matchesSearch = m.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              m.type.displayName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              (m.assignedSiteName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
          final matchesStatus = _filterStatus == null || m.status == _filterStatus;
          return matchesSearch && matchesStatus;
        }).toList();

        final activeMachines = machines.where((m) => m.status == MachineStatus.inUse).length;
        final maintenanceMachines = machines.where((m) => m.status == MachineStatus.maintenance).length;

        return ProfessionalPage(
          title: 'Heavy Assets',
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _addMachine(context, service),
            backgroundColor: Theme.of(context).colorScheme.primary,
            icon: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
            label: const Text('DEPLOY ASSET', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          children: [
            // 1. Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: AppSearchField(
                hint: 'Search machines, types, or sites...',
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
            ),

            // 2. Premium Filters
            Container(
              height: 50,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _FilterChip(
                    label: 'Fleet',
                    isSelected: _filterStatus == null,
                    onTap: () => setState(() => _filterStatus = null),
                    icon: Icons.inventory_2_rounded,
                  ),
                  ...MachineStatus.values.map((status) => Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: _FilterChip(
                      label: status.displayName,
                      isSelected: _filterStatus == status,
                      onTap: () => setState(() => _filterStatus = status),
                      icon: _getStatusIcon(status),
                    ),
                  )),
                ],
              ),
            ),

            // 3. Stat Cards
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(child: _StatCard(label: 'TOTAL', value: '${machines.length}', icon: Icons.precision_manufacturing_rounded, color: Colors.blueAccent)),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(label: 'ACTIVE', value: '$activeMachines', icon: Icons.engineering_rounded, color: Colors.greenAccent)),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(label: 'SERVICE', value: '$maintenanceMachines', icon: Icons.auto_fix_high_rounded, color: Colors.orangeAccent)),
                ],
              ),
            ),

            // 4. Machine List
            if (filtered.isEmpty)
              const EmptyState(
                icon: Icons.search_off_rounded,
                title: 'No Assets Identified',
                message: 'Adjust your search parameters or filter criteria.',
              )
            else
              ...filtered.asMap().entries.map((entry) {
                return StaggeredAnimation(
                  index: entry.key,
                  child: _MachineCard(
                    machine: entry.value,
                    onTap: () => _viewMachineDetail(context, service, entry.value),
                  ),
                );
              }),

            const SizedBox(height: 120),
          ],
        );
      },
    );
  }

  IconData _getStatusIcon(MachineStatus status) {
    switch (status) {
      case MachineStatus.available: return Icons.check_circle_rounded;
      case MachineStatus.inUse: return Icons.construction_rounded;
      case MachineStatus.maintenance: return Icons.build_rounded;
      case MachineStatus.breakdown: return Icons.warning_rounded;
      case MachineStatus.reserved: return Icons.event_available_rounded;
    }
  }

  void _addMachine(BuildContext context, MockMachineService service) async {
    final result = await Navigator.push<MachineModel>(
      context,
      MaterialPageRoute(builder: (_) => MachineFormScreen(currentSiteId: widget.activeSiteId)),
    );
    if (result != null) service.addMachine(result);
  }

  void _viewMachineDetail(BuildContext context, MockMachineService service, MachineModel machine) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MachineDetailScreen(machineId: machine.id)),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData icon;

  const _FilterChip({required this.label, required this.isSelected, required this.onTap, required this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
            const SizedBox(width: 8),
            Text(
              label.toUpperCase(),
              style: TextStyle(color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface.withOpacity(0.7), fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return ProfessionalCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface, letterSpacing: -1)),
          Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: color, letterSpacing: 1)),
        ],
      ),
    );
  }
}

class _MachineCard extends StatelessWidget {
  final MachineModel machine;
  final VoidCallback onTap;

  const _MachineCard({required this.machine, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ProfessionalCard(
        padding: EdgeInsets.zero,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.1)),
                      ),
                      child: Center(child: Text(machine.type.icon, style: const TextStyle(fontSize: 32))),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(machine.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface, letterSpacing: -0.5)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(machine.type.displayName.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.blueAccent)),
                              const SizedBox(width: 8),
                              _buildStatusDot(machine.status),
                              const SizedBox(width: 4),
                              Text(machine.status.displayName.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildMetric(context, Icons.location_on_rounded, machine.assignedSiteName ?? 'Warehouse Hub'),
                    _buildMetric(context, Icons.engineering_rounded, machine.operatorName ?? 'Pool Asset'),
                  ],
                ),
                Divider(height: 24, color: Theme.of(context).dividerColor.withOpacity(0.1)),
                Row(
                  children: [
                    _buildSubMetric(context, 'LAST SERVICE', _formatDate(machine.lastMaintenanceDate)),
                    const Spacer(),
                    if (machine.nextMaintenanceDate != null)
                      _buildSubMetric(context, 'NEXT DUE', _formatDate(machine.nextMaintenanceDate!), 
                          isAlert: machine.nextMaintenanceDate!.isBefore(DateTime.now())),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusDot(MachineStatus status) {
    Color color;
    switch (status) {
      case MachineStatus.available: color = Colors.greenAccent; break;
      case MachineStatus.inUse: color = Colors.blueAccent; break;
      case MachineStatus.maintenance: color = Colors.orangeAccent; break;
      case MachineStatus.breakdown: color = Colors.redAccent; break;
      case MachineStatus.reserved: color = Colors.purpleAccent; break;
    }
    return Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }

  Widget _buildMetric(BuildContext context, IconData icon, String value) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)), maxLines: 1, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _buildSubMetric(BuildContext context, String label, String value, {bool isAlert = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3), letterSpacing: 0.5)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: isAlert ? Colors.redAccent : Theme.of(context).colorScheme.onSurface)),
      ],
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}
