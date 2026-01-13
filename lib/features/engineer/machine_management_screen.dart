import 'package:flutter/material.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/professional_theme.dart';
import '../../app/ui/widgets/professional_page.dart';
import '../../app/ui/widgets/staggered_animation.dart';
import '../../app/ui/widgets/app_search_field.dart';
import '../../app/ui/widgets/empty_state.dart';
import '../../app/ui/widgets/status_chip.dart';
import '../../app/utils/feedback_helper.dart';
import 'models/machine_model.dart';
import 'machine_form_screen.dart';
import 'machine_detail_screen.dart';

class MachineManagementScreen extends StatefulWidget {
  const MachineManagementScreen({super.key});

  @override
  State<MachineManagementScreen> createState() => _MachineManagementScreenState();
}

class _MachineManagementScreenState extends State<MachineManagementScreen> {
  String _searchQuery = '';
  MachineStatus? _filterStatus;

  // Sample data
  final List<MachineModel> _machines = [
    MachineModel(
      id: '1',
      name: 'Excavator JCB-450',
      type: MachineType.excavator,
      assignedSiteId: 'site1',
      assignedSiteName: 'Metropolis Heights',
      natureOfWork: NatureOfWork.excavation,
      status: MachineStatus.inUse,
      lastMaintenanceDate: DateTime(2024, 12, 15),
      nextMaintenanceDate: DateTime(2025, 3, 15),
      operatorId: 'op1',
      operatorName: 'Ramesh Yadav',
    ),
    MachineModel(
      id: '2',
      name: 'Crane TC-7032',
      type: MachineType.crane,
      assignedSiteId: 'site2',
      assignedSiteName: 'Skyline Plaza',
      natureOfWork: NatureOfWork.lifting,
      status: MachineStatus.inUse,
      lastMaintenanceDate: DateTime(2024, 11, 20),
      nextMaintenanceDate: DateTime(2025, 2, 20),
      operatorId: 'op2',
      operatorName: 'Suresh Kumar',
    ),
    MachineModel(
      id: '3',
      name: 'Concrete Mixer CM-350',
      type: MachineType.mixer,
      assignedSiteId: 'site1',
      assignedSiteName: 'Metropolis Heights',
      natureOfWork: NatureOfWork.mixing,
      status: MachineStatus.available,
      lastMaintenanceDate: DateTime(2025, 1, 5),
      nextMaintenanceDate: DateTime(2025, 4, 5),
    ),
    MachineModel(
      id: '4',
      name: 'Road Roller RR-22',
      type: MachineType.roller,
      status: MachineStatus.maintenance,
      lastMaintenanceDate: DateTime(2025, 1, 10),
      nextMaintenanceDate: DateTime(2025, 1, 17),
    ),
    MachineModel(
      id: '5',
      name: 'Hydro-Static Block Machine B-200',
      type: MachineType.blockMachine,
      status: MachineStatus.inUse,
      assignedSiteName: 'Metropolis Heights',
      natureOfWork: NatureOfWork.blockProduction,
      lastMaintenanceDate: DateTime(2025, 1, 1),
      nextMaintenanceDate: DateTime(2025, 4, 1),
    ),
  ];


  List<MachineModel> get _filteredMachines {
    var filtered = _machines;
    
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((machine) {
        final query = _searchQuery.toLowerCase();
        return machine.name.toLowerCase().contains(query) ||
            machine.type.displayName.toLowerCase().contains(query) ||
            (machine.assignedSiteName?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    if (_filterStatus != null) {
      filtered = filtered.where((m) => m.status == _filterStatus).toList();
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return ProfessionalPage(
      title: 'Machine Management',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMachineDialog(context),
        backgroundColor: AppColors.deepBlue1,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Machine', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      children: [
        AppSearchField(
          hint: 'Search by machine name, type, or site...',
          onChanged: (value) => setState(() => _searchQuery = value),
        ),

        // Status Filter Chips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', _filterStatus == null, () {
                  setState(() => _filterStatus = null);
                }),
                const SizedBox(width: 8),
                ...MachineStatus.values.map((status) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildFilterChip(
                      '${status.icon} ${status.displayName}',
                      _filterStatus == status,
                      () => setState(() => _filterStatus = status),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),

        // Stats Cards
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'TOTAL',
                  '${_machines.length}',
                  Icons.precision_manufacturing_rounded,
                  Colors.blueAccent,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'IN USE',
                  '${_machines.where((m) => m.status == MachineStatus.inUse).length}',
                  Icons.construction_rounded,
                  Colors.greenAccent,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'SERVICE',
                  '${_machines.where((m) => m.status == MachineStatus.maintenance).length}',
                  Icons.build_rounded,
                  Colors.orangeAccent,
                ),
              ),
            ],
          ),
        ),
        
        const ProfessionalSectionHeader(
          title: 'Heavy Machinery',
          subtitle: 'Track utilization and maintenance schedules',
        ),

        if (_filteredMachines.isEmpty)
          const Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: EmptyState(
              icon: Icons.precision_manufacturing_rounded,
              title: 'No Machines Found',
              message: 'Try adjusting your filters or add new machines.',
            ),
          )
        else
          ..._filteredMachines.asMap().entries.map((entry) {
            final index = entry.key;
            final machine = entry.value;
            return StaggeredAnimation(
              index: index,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ProfessionalCard(
                  useGlass: true,
                  padding: EdgeInsets.zero,
                  child: InkWell(
                    onTap: () => _showMachineDetails(context, machine),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Machine Icon
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: _getStatusColor(machine.status).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: _getStatusColor(machine.status).withOpacity(0.2)),
                                ),
                                child: Center(
                                  child: Text(
                                    machine.type.icon,
                                    style: const TextStyle(fontSize: 28),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Machine Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      machine.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 17,
                                        color: Colors.white,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      machine.type.displayName.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.white.withOpacity(0.4),
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Status Badge
                              StatusChip(
                                status: machine.status == MachineStatus.available 
                                  ? UiStatus.ok 
                                  : machine.status == MachineStatus.maintenance 
                                    ? UiStatus.alert 
                                    : machine.status == MachineStatus.breakdown 
                                      ? UiStatus.stop 
                                      : UiStatus.pending,
                                labelOverride: machine.status.displayName.toUpperCase(),
                              ),
                            ],
                          ),
                          
                          if (machine.assignedSiteName != null || machine.natureOfWork != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.04),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white.withOpacity(0.08)),
                              ),
                              child: Row(
                                children: [
                                  if (machine.assignedSiteName != null) ...[
                                    Expanded(
                                      child: _buildDetailItem(
                                        Icons.location_on_rounded,
                                        'SITE',
                                        machine.assignedSiteName!,
                                      ),
                                    ),
                                  ],
                                  if (machine.natureOfWork != null) ...[
                                    if (machine.assignedSiteName != null) 
                                      Container(height: 24, width: 1, color: Colors.white.withOpacity(0.1), margin: const EdgeInsets.symmetric(horizontal: 12)),
                                    Expanded(
                                      child: _buildDetailItem(
                                        Icons.work_rounded,
                                        'WORK',
                                        machine.natureOfWork!.displayName,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                          
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildDetailItem(
                                  Icons.build_circle_rounded,
                                  'PREV SERVICE',
                                  _formatDate(machine.lastMaintenanceDate),
                                ),
                              ),
                              if (machine.nextMaintenanceDate != null) ...[
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildDetailItem(
                                    Icons.schedule_rounded,
                                    'NEXT DUE',
                                    _formatDate(machine.nextMaintenanceDate!),
                                    color: machine.nextMaintenanceDate!.isBefore(DateTime.now()) ? Colors.redAccent : null,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),

        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return ProfessionalCard(
      useGlass: true,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: Colors.white.withOpacity(0.4),
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? Colors.white : Colors.white.withOpacity(0.1)),
        ),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            color: isSelected ? AppColors.deepBlue1 : Colors.white70,
            fontWeight: FontWeight.w900,
            fontSize: 10,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white.withOpacity(0.3)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.white.withOpacity(0.3),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  color: color ?? Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(MachineStatus status) {
    switch (status) {
      case MachineStatus.available:
        return Colors.green;
      case MachineStatus.inUse:
        return Colors.blue;
      case MachineStatus.maintenance:
        return Colors.orange;
      case MachineStatus.breakdown:
        return Colors.red;
      case MachineStatus.reserved:
        return Colors.purple;
    }
  }

  List<Color> _getStatusGradient(MachineStatus status) {
    final color = _getStatusColor(status);
    return [color.withOpacity(0.7), color];
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAddMachineDialog(BuildContext context) async {
    final result = await Navigator.push<MachineModel>(
      context,
      MaterialPageRoute(
        builder: (context) => const MachineFormScreen(),
      ),
    );

    if (result != null) {
      setState(() {
        _machines.add(result);
      });
    }
  }

  void _showMachineDetails(BuildContext context, MachineModel machine) async {
    final result = await Navigator.push<MachineModel>(
      context,
      MaterialPageRoute(
        builder: (context) => MachineDetailScreen(machine: machine),
      ),
    );

    if (result != null) {
      setState(() {
        final index = _machines.indexWhere((m) => m.id == machine.id);
        if (index != -1) {
          _machines[index] = result;
        }
      });
    }
  }
}
