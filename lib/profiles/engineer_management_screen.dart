import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:construction_app/shared/theme/app_spacing.dart';
import 'package:construction_app/shared/theme/professional_theme.dart';
import 'package:construction_app/shared/widgets/professional_page.dart';
import 'package:construction_app/shared/widgets/staggered_animation.dart';
import 'package:construction_app/shared/widgets/status_chip.dart';
import 'package:construction_app/shared/widgets/app_search_field.dart';
import 'package:construction_app/shared/widgets/empty_state.dart';
import 'package:construction_app/services/mock_engineer_service.dart';
import 'package:construction_app/profiles/engineer_model.dart';
import 'engineer_detail_screen.dart';
import 'package:construction_app/profiles/engineer_form_screen.dart';

class EngineerManagementScreen extends StatefulWidget {
  const EngineerManagementScreen({super.key});

  @override
  State<EngineerManagementScreen> createState() => _EngineerManagementScreenState();
}

class _EngineerManagementScreenState extends State<EngineerManagementScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Consumer<MockEngineerService>(
      builder: (context, service, child) {
        final engineers = service.engineers;
        final filteredEngineers = engineers.where((engineer) {
          final query = _searchQuery.toLowerCase();
          return engineer.name.toLowerCase().contains(query) ||
              engineer.role.displayName.toLowerCase().contains(query) ||
              (engineer.email?.toLowerCase().contains(query) ?? false);
        }).toList();

        return Scaffold(
          body: ProfessionalPage(
            title: 'Engineers',
            actions: [
              IconButton(
                onPressed: () => _addEngineer(context),
                icon: const Icon(Icons.person_add_rounded),
                tooltip: 'Add New Engineer',
              ),
            ],
            children: [
              AppSearchField(
                hint: 'Search by name or role...',
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
              
              const ProfessionalSectionHeader(
                title: 'Operational Directory',
                subtitle: 'Global management of site engineers and technical staff',
              ),
  
              if (filteredEngineers.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: EmptyState(
                    icon: Icons.engineering_rounded,
                    title: 'No Engineers Found',
                    message: 'Register your technical staff to manage their site access.',
                  ),
                )
              else
                ...filteredEngineers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final engineer = entry.value;
                  return StaggeredAnimation(
                    index: index,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ProfessionalCard(
                        padding: EdgeInsets.zero,
                        child: Theme(
                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            shape: const Border(),
                            collapsedShape: const Border(),
                            tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            iconColor: Theme.of(context).colorScheme.primary,
                            collapsedIconColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                                shape: BoxShape.circle,
                                border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.1)),
                              ),
                              child: Center(
                                child: Text(
                                  engineer.name[0],
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              engineer.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 17,
                              ),
                            ),
                            subtitle: Row(
                              children: [
                                Text(
                                  (engineer.role == EngineerRole.other && engineer.customRoleName != null)
                                      ? engineer.customRoleName!.toUpperCase()
                                      : engineer.role.displayName.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Theme.of(context).textTheme.bodySmall?.color,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                StatusChip(
                                  status: engineer.isActive ? UiStatus.ok : UiStatus.pending,
                                  labelOverride: engineer.isActive ? 'ACTIVE' : 'INACTIVE',
                                ),
                              ],
                            ),
                            children: [
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.all(12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.03),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'ACCESS PERMISSIONS',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                        color: Theme.of(context).textTheme.bodySmall?.color,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    _buildPermissionGrid(context, engineer.permissions),
                                    const SizedBox(height: 20),
                                    _buildInfoRow(context, 'Contact', engineer.phone ?? 'N/A', Icons.phone_android_rounded),
                                    const SizedBox(height: 12),
                                    _buildInfoRow(context, 'Joined', _formatDate(engineer.createdAt), Icons.calendar_today_rounded),
                                    const SizedBox(height: 20),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () => _editEngineer(context, engineer),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                              foregroundColor: Theme.of(context).colorScheme.primary,
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                            child: const Text('EDIT PROFILE', style: TextStyle(fontWeight: FontWeight.bold)),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () => _viewEngineerDetails(context, engineer),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                                              foregroundColor: Theme.of(context).colorScheme.secondary,
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                            child: const Text('ANALYTICS', style: TextStyle(fontWeight: FontWeight.bold)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 100),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _addEngineer(context),
            label: const Text('NEW ENGINEER', style: TextStyle(fontWeight: FontWeight.bold)),
            icon: const Icon(Icons.person_add_rounded),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      },
    );
  }

  Widget _buildPermissionGrid(BuildContext context, PermissionSet permissions) {
    final permissionItems = [
      ('Site Management', permissions.siteManagement),
      ('Workforce', permissions.workerManagement),
      ('Inventory', permissions.inventoryManagement),
      ('Reports', permissions.reportViewing),
      ('Verifications', permissions.approvalVerification),
    ];

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: permissionItems.where((i) => i.$2).map((item) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.08),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.green.withOpacity(0.2)),
          ),
          child: Text(
            item.$1,
            style: const TextStyle(fontSize: 9, color: Colors.green, fontWeight: FontWeight.bold),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
        const Spacer(),
        Text(value, style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _viewEngineerDetails(BuildContext context, EngineerModel engineer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EngineerDetailScreen(engineer: engineer),
      ),
    );
  }

  void _addEngineer(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EngineerFormScreen(),
      ),
    );
  }

  void _editEngineer(BuildContext context, EngineerModel engineer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EngineerFormScreen(engineer: engineer),
      ),
    );
  }
}
