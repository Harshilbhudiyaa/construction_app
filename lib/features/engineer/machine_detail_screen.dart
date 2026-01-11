import 'package:flutter/material.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/professional_theme.dart';
import '../../app/ui/widgets/professional_page.dart';
import 'models/machine_model.dart';
import 'package:intl/intl.dart';
import 'machine_form_screen.dart';

class MachineDetailScreen extends StatelessWidget {
  final MachineModel machine;

  const MachineDetailScreen({super.key, required this.machine});

  @override
  Widget build(BuildContext context) {
    return ProfessionalPage(
      title: 'Machine Details',
      actions: [
        IconButton(
          onPressed: () => _editMachine(context),
          icon: const Icon(Icons.edit_rounded, color: Colors.white),
        ),
      ],
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              ProfessionalCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                gradient: const LinearGradient(
                  colors: [AppColors.deepBlue1, AppColors.deepBlue2],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Text(
                          machine.type.icon,
                          style: const TextStyle(fontSize: 35),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            machine.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            machine.type.displayName,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildStatusBadge(machine.status),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),
              _buildSectionHeader('Operational Overview'),
              ProfessionalCard(
                child: Column(
                  children: [
                    _buildInfoRow(Icons.location_on_rounded, 'Current Site', machine.assignedSiteName ?? 'Not Assigned'),
                    const Divider(height: 20),
                    _buildInfoRow(Icons.person_rounded, 'Operator', machine.operatorName ?? 'Not Assigned'),
                    const Divider(height: 20),
                    _buildInfoRow(Icons.work_rounded, 'Work Nature', machine.natureOfWork?.displayName ?? 'Not Specified'),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),
              _buildSectionHeader('Maintenance Log'),
              ProfessionalCard(
                child: Column(
                  children: [
                    _buildInfoRow(
                      Icons.history_rounded,
                      'Last Serviced',
                      DateFormat('MMM dd, yyyy').format(machine.lastMaintenanceDate),
                    ),
                    const Divider(height: 20),
                    _buildInfoRow(
                      Icons.event_note_rounded,
                      'Next Due',
                      machine.nextMaintenanceDate != null
                          ? DateFormat('MMM dd, yyyy').format(machine.nextMaintenanceDate!)
                          : 'Not Scheduled',
                      color: machine.nextMaintenanceDate != null &&
                              machine.nextMaintenanceDate!.isBefore(DateTime.now())
                          ? Colors.red
                          : null,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _editMachine(context),
                  icon: const Icon(Icons.edit_rounded),
                  label: const Text('Edit Configuration'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.deepBlue1,
                    padding: const EdgeInsets.symmetric(vertical: 16),
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(MachineStatus status) {
    Color color;
    switch (status) {
      case MachineStatus.available: color = Colors.greenAccent; break;
      case MachineStatus.inUse: color = Colors.blueAccent; break;
      case MachineStatus.maintenance: color = Colors.orangeAccent; break;
      case MachineStatus.breakdown: color = Colors.redAccent; break;
      case MachineStatus.reserved: color = Colors.purpleAccent; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            status.displayName,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? color}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.deepBlue1.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.deepBlue1, size: 20),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w600),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  color: color ?? AppColors.deepBlue1,
                  fontWeight: FontWeight.bold,
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
