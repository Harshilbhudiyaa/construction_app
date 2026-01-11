import 'package:flutter/material.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/professional_theme.dart';
import '../../app/ui/widgets/professional_page.dart';
import '../../app/ui/widgets/staggered_animation.dart';
import '../../app/ui/widgets/app_search_field.dart';
import '../../app/ui/widgets/empty_state.dart';
import '../../app/utils/feedback_helper.dart';
import 'models/engineer_model.dart';
import 'engineer_form_screen.dart';
import 'engineer_detail_screen.dart';

class EngineerManagementScreen extends StatefulWidget {
  const EngineerManagementScreen({super.key});

  @override
  State<EngineerManagementScreen> createState() => _EngineerManagementScreenState();
}

class _EngineerManagementScreenState extends State<EngineerManagementScreen> {
  String _searchQuery = '';

  // Sample data
  final List<EngineerModel> _engineers = [
    EngineerModel(
      id: '1',
      name: 'Rajesh Kumar',
      role: EngineerRole.siteEngineer,
      permissions: const PermissionSet(
        siteManagement: true,
        workerManagement: true,
        inventoryManagement: true,
        reportViewing: true,
        createSite: true,
        editSite: true,
      ),
      email: 'rajesh@construction.com',
      phone: '+91 98765 43210',
      createdAt: DateTime(2024, 1, 15),
      lastLogin: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    EngineerModel(
      id: '2',
      name: 'Priya Sharma',
      role: EngineerRole.supervisor,
      permissions: const PermissionSet(
        workerManagement: true,
        toolMachineManagement: true,
        reportViewing: true,
      ),
      email: 'priya@construction.com',
      phone: '+91 98765 43211',
      createdAt: DateTime(2024, 2, 10),
      lastLogin: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    EngineerModel(
      id: '3',
      name: 'Amit Patel',
      role: EngineerRole.storeKeeper,
      permissions: const PermissionSet(
        inventoryManagement: true,
        toolMachineManagement: true,
      ),
      email: 'amit@construction.com',
      phone: '+91 98765 43212',
      createdAt: DateTime(2024, 3, 5),
      lastLogin: DateTime.now().subtract(const Duration(days: 1)),
    ),
    EngineerModel(
      id: '4',
      name: 'Vikram Singh',
      role: EngineerRole.machineOperator,
      permissions: const PermissionSet(
        toolMachineManagement: true,
      ),
      email: 'vikram@construction.com',
      phone: '+91 98765 43213',
      createdAt: DateTime(2024, 4, 20),
    ),
  ];

  List<EngineerModel> get _filteredEngineers {
    if (_searchQuery.isEmpty) return _engineers;
    
    return _engineers.where((engineer) {
      final query = _searchQuery.toLowerCase();
      return engineer.name.toLowerCase().contains(query) ||
          engineer.role.displayName.toLowerCase().contains(query) ||
          (engineer.email?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ProfessionalPage(
      title: 'Engineer & Workforce',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEngineerDialog(context),
        backgroundColor: AppColors.deepBlue1,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: const Text('Add Personnel', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      children: [
        AppSearchField(
          hint: 'Search by name, role, or email...',
          onChanged: (value) => setState(() => _searchQuery = value),
        ),
        
        const ProfessionalSectionHeader(
          title: 'Management Team',
          subtitle: 'Site engineers and workforce with role-based access',
        ),

        if (_filteredEngineers.isEmpty)
          const Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: EmptyState(
              icon: Icons.engineering_rounded,
              title: 'No Personnel Found',
              message: 'Try adjusting your search or add new personnel.',
            ),
          )
        else
          ..._filteredEngineers.asMap().entries.map((entry) {
            final index = entry.key;
            final engineer = entry.value;
            return StaggeredAnimation(
              index: index,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ProfessionalCard(
                  child: InkWell(
                    onTap: () => _viewEngineerDetails(context, engineer),
                    borderRadius: BorderRadius.circular(12),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: AppColors.gradientColors),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            engineer.name.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        engineer.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: AppColors.deepBlue1,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.deepBlue1.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  engineer.role.displayName,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.deepBlue1,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: engineer.isActive ? Colors.green : Colors.grey,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                engineer.isActive ? 'Active' : 'Inactive',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          if (engineer.email != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              engineer.email!,
                              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                            ),
                          ],
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit_rounded, color: AppColors.deepBlue1),
                        onPressed: () => _showEditEngineerDialog(context, engineer),
                      ),
                      children: [
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Permissions',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                  color: AppColors.deepBlue1,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildPermissionGrid(engineer.permissions),
                              const SizedBox(height: 16),
                              _buildInfoRow('Phone', engineer.phone ?? 'Not set'),
                              const SizedBox(height: 8),
                              _buildInfoRow(
                                'Last Login',
                                engineer.lastLogin != null
                                    ? _formatDateTime(engineer.lastLogin!)
                                    : 'Never',
                              ),
                              const SizedBox(height: 8),
                              _buildInfoRow('Member Since', _formatDate(engineer.createdAt)),
                              const SizedBox(height: 12),
                              // View Full Details Button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () => _viewEngineerDetails(context, engineer),
                                  icon: const Icon(Icons.visibility_rounded, size: 18),
                                  label: const Text('View Full Details'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.deepBlue1,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
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
    );
  }

  Widget _buildPermissionGrid(PermissionSet permissions) {
    final permissionItems = [
      ('Site Management', permissions.siteManagement, Icons.location_city_rounded),
      ('Worker Management', permissions.workerManagement, Icons.groups_rounded),
      ('Inventory Management', permissions.inventoryManagement, Icons.inventory_2_rounded),
      ('Tool & Machine', permissions.toolMachineManagement, Icons.precision_manufacturing_rounded),
      ('Report Viewing', permissions.reportViewing, Icons.analytics_rounded),
      ('Approval & Verification', permissions.approvalVerification, Icons.verified_rounded),
      ('Create Site', permissions.createSite, Icons.add_location_rounded),
      ('Edit Site', permissions.editSite, Icons.edit_location_rounded),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: permissionItems.map((item) {
        final (label, enabled, icon) = item;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: enabled ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: enabled ? Colors.green.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                enabled ? Icons.check_circle_rounded : Icons.cancel_rounded,
                size: 16,
                color: enabled ? Colors.green[700] : Colors.grey[500],
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: enabled ? Colors.green[700] : Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.deepBlue1,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return _formatDate(date);
    }
  }

  void _showAddEngineerDialog(BuildContext context) async {
    final result = await Navigator.push<EngineerModel>(
      context,
      MaterialPageRoute(
        builder: (context) => const EngineerFormScreen(),
      ),
    );

    if (result != null) {
      setState(() {
        _engineers.add(result);
      });
    }
  }

  void _showEditEngineerDialog(BuildContext context, EngineerModel engineer) async {
    final result = await Navigator.push<EngineerModel>(
      context,
      MaterialPageRoute(
        builder: (context) => EngineerFormScreen(engineer: engineer),
      ),
    );

    if (result != null) {
      setState(() {
        final index = _engineers.indexWhere((e) => e.id == engineer.id);
        if (index != -1) {
          _engineers[index] = result;
        }
      });
    }
  }

  void _viewEngineerDetails(BuildContext context, EngineerModel engineer) async {
    final result = await Navigator.push<EngineerModel>(
      context,
      MaterialPageRoute(
        builder: (context) => EngineerDetailScreen(engineer: engineer),
      ),
    );

    if (result != null) {
      setState(() {
        final index = _engineers.indexWhere((e) => e.id == engineer.id);
        if (index != -1) {
          _engineers[index] = result;
        }
      });
    }
  }
}
