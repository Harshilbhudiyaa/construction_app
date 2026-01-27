import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:construction_app/shared/theme/professional_theme.dart';
import 'package:construction_app/shared/widgets/professional_page.dart';
import 'package:construction_app/shared/widgets/status_chip.dart';
import 'machine_model.dart';
import 'machine_form_screen.dart';
import 'package:provider/provider.dart';
import 'package:construction_app/services/mock_machine_service.dart';
import 'package:construction_app/shared/widgets/confirm_dialog.dart';
import 'package:construction_app/utils/feedback_helper.dart';

class MachineDetailScreen extends StatelessWidget {
  final String machineId;

  const MachineDetailScreen({super.key, required this.machineId});

  @override
  Widget build(BuildContext context) {
    return Consumer<MockMachineService>(
      builder: (context, service, child) {
        final machine = service.machines.firstWhere(
          (m) => m.id == machineId,
          orElse: () => throw Exception('Machine not found'),
        );

        return ProfessionalPage(
          title: 'Machine Logistics',
          actions: [
            IconButton(
              onPressed: () => _editMachine(context, service, machine),
              icon: Icon(Icons.edit_note_rounded, color: Theme.of(context).colorScheme.primary),
            ),
          ],
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Profile Card
                  ProfessionalCard(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.1)),
                          ),
                          child: Center(
                            child: Text(
                              machine.type.icon,
                              style: const TextStyle(fontSize: 40),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                machine.name,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                machine.type.displayName.toUpperCase(),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 12),
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
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const ProfessionalSectionHeader(
                    title: 'Tactical Deployment',
                    subtitle: 'Site assignment and operational role',
                  ),
                  
                  ProfessionalCard(
                    useGlass: true,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildInfoRow(context, Icons.location_on_rounded, 'CURRENT SITE', machine.assignedSiteName ?? 'POOL ASSET'),
                        _buildDivider(context),
                        _buildInfoRow(context, Icons.person_rounded, 'OPERATOR', machine.operatorName ?? 'NOT ASSIGNED'),
                        _buildDivider(context),
                        _buildInfoRow(context, Icons.work_rounded, 'NATURE OF WORK', machine.natureOfWork?.displayName.toUpperCase() ?? 'NOT SPECIFIED'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const ProfessionalSectionHeader(
                    title: 'Technical Lifecycle',
                    subtitle: 'Maintenance schedule and health logs',
                  ),
                  
                  ProfessionalCard(
                    useGlass: true,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          context,
                          Icons.history_rounded,
                          'LAST SERVICED',
                          DateFormat('MMM dd, yyyy').format(machine.lastMaintenanceDate).toUpperCase(),
                        ),
                        _buildDivider(context),
                        _buildInfoRow(
                          context,
                          Icons.event_note_rounded,
                          'NEXT DUE DATE',
                          machine.nextMaintenanceDate != null
                              ? DateFormat('MMM dd, yyyy').format(machine.nextMaintenanceDate!).toUpperCase()
                              : 'NOT SCHEDULED',
                          color: machine.nextMaintenanceDate != null &&
                                  machine.nextMaintenanceDate!.isBefore(DateTime.now())
                              ? Colors.redAccent
                              : null,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  
                  // Action Menu
                  Row(
                    children: [
                      Expanded(
                        child: _ActionMenuButton(
                          label: 'EDIT ASSET DATA',
                          icon: Icons.edit_rounded,
                          onTap: () => _editMachine(context, service, machine),
                          color: Theme.of(context).colorScheme.primary,
                          textColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionMenuButton(
                          label: 'DECOMMISSION',
                          icon: Icons.delete_forever_rounded,
                          onTap: () => _deleteMachine(context, service, machine),
                          color: Colors.redAccent.withOpacity(0.15),
                          textColor: Colors.redAccent,
                          hasBorder: true,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(
      height: 1,
      color: Theme.of(context).dividerColor.withOpacity(0.1),
      margin: const EdgeInsets.symmetric(vertical: 16),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value, {Color? color}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.08)),
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary.withOpacity(0.5), size: 18),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  color: color ?? Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _editMachine(BuildContext context, MockMachineService service, MachineModel machine) async {
    final result = await Navigator.push<MachineModel>(
      context,
      MaterialPageRoute(
        builder: (context) => MachineFormScreen(machine: machine),
      ),
    );
    if (result != null) {
      service.updateMachine(result);
      FeedbackHelper.showSuccess(context, 'Machine configuration updated');
    }
  }

  Future<void> _deleteMachine(BuildContext context, MockMachineService service, MachineModel machine) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Decommission Asset?',
      message: 'Are you sure you want to permanently remove ${machine.name} from the active fleet?',
      confirmText: 'DECOMMISSION',
      cancelText: 'RETAIN ASSET',
      isDangerous: true,
    );

    if (confirmed == true && context.mounted) {
      service.deleteMachine(machine.id);
      FeedbackHelper.showSuccess(context, '${machine.name} decommissioned');
      Navigator.pop(context);
    }
  }
}

class _ActionMenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final Color textColor;
  final bool hasBorder;

  const _ActionMenuButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.color,
    required this.textColor,
    this.hasBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: hasBorder ? Border.all(color: textColor.withOpacity(0.3)) : null,
          boxShadow: !hasBorder ? [
            BoxShadow(color: Colors.black26, blurRadius: 10, offset: const Offset(0, 4))
          ] : null,
        ),
        child: Column(
          children: [
            Icon(icon, color: textColor, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w900,
                fontSize: 10,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
