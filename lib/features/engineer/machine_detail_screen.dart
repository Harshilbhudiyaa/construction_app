import 'package:flutter/material.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/professional_theme.dart';
import '../../app/ui/widgets/professional_page.dart';
import '../../app/ui/widgets/status_chip.dart';
import 'models/machine_model.dart';
import 'package:intl/intl.dart';
import 'machine_form_screen.dart';

class MachineDetailScreen extends StatelessWidget {
  final MachineModel machine;

  const MachineDetailScreen({super.key, required this.machine});

  @override
  Widget build(BuildContext context) {
    return ProfessionalPage(
      title: 'Machine Logistics',
      actions: [
        IconButton(
          onPressed: () => _editMachine(context),
          icon: const Icon(Icons.edit_note_rounded, color: Colors.white),
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
                useGlass: true,
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.12)),
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
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            machine.type.displayName.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
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
                    _buildInfoRow(Icons.location_on_rounded, 'CURRENT SITE', machine.assignedSiteName ?? 'UNASSIGNED'),
                    _buildDivider(),
                    _buildInfoRow(Icons.person_rounded, 'OPERATOR', machine.operatorName ?? 'NOT ASSIGNED'),
                    _buildDivider(),
                    _buildInfoRow(Icons.work_rounded, 'NATURE OF WORK', machine.natureOfWork?.displayName.toUpperCase() ?? 'NOT SPECIFIED'),
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
                      Icons.history_rounded,
                      'LAST SERVICED',
                      DateFormat('MMM dd, yyyy').format(machine.lastMaintenanceDate).toUpperCase(),
                    ),
                    _buildDivider(),
                    _buildInfoRow(
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
              SizedBox(
                width: double.infinity,
                child: InkWell(
                  onTap: () => _editMachine(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'EDIT CONFIGURATION',
                        style: TextStyle(
                          color: AppColors.deepBlue1,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: Colors.white.withOpacity(0.08),
      margin: const EdgeInsets.symmetric(vertical: 16),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? color}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Icon(icon, color: Colors.white.withOpacity(0.5), size: 18),
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
                  color: Colors.white.withOpacity(0.3),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  color: color ?? Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _editMachine(BuildContext context) async {
    final result = await Navigator.push<MachineModel>(
      context,
      MaterialPageRoute(
        builder: (context) => MachineFormScreen(machine: machine),
      ),
    );
    if (result != null && context.mounted) {
      Navigator.pop(context, result);
    }
  }
}
