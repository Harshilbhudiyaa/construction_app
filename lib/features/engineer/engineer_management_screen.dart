import 'package:flutter/material.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/professional_theme.dart';
import '../../app/ui/widgets/professional_page.dart';
import '../../app/ui/widgets/staggered_animation.dart';
import '../../app/ui/widgets/status_chip.dart';
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
      title: 'Personnel Center',
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.blueAccent, AppColors.deepBlue1],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _showAddEngineerDialog(context),
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.person_add_rounded, color: Colors.white),
          label: const Text('Add Personnel', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
      children: [
        AppSearchField(
          hint: 'Search by name, role, or email...',
          onChanged: (value) => setState(() => _searchQuery = value),
        ),
        
        const ProfessionalSectionHeader(
          title: 'Management Tier',
          subtitle: 'Operational workforce and site engineers',
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
                  useGlass: true,
                  padding: EdgeInsets.zero,
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent,
                      unselectedWidgetColor: Colors.white70,
                      colorScheme: const ColorScheme.dark().copyWith(
                        primary: Colors.white,
                      ),
                    ),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      leading: Hero(
                        tag: 'personnel_icon_${engineer.id}',
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.18),
                                Colors.white.withOpacity(0.05),
                              ],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.25), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              engineer.name.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        engineer.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          fontSize: 18,
                          letterSpacing: -0.5,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.white.withOpacity(0.15)),
                                ),
                                child: Text(
                                  engineer.role.displayName.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white70,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              StatusChip(
                                status: engineer.isActive ? UiStatus.ok : UiStatus.pending,
                                labelOverride: engineer.isActive ? 'ACTIVE' : 'INACTIVE',
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 28),
                        onPressed: () => _showEditEngineerDialog(context, engineer),
                      ),
                      children: [
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.all(12),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.08)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.security_rounded, size: 14, color: Colors.white38),
                                  const SizedBox(width: 8),
                                  Text(
                                    'ACCESS PERMISSIONS',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 10,
                                      color: Colors.white.withOpacity(0.4),
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildPermissionGrid(engineer.permissions),
                              const SizedBox(height: 24),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.04),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    _buildInfoRow('Primary Contact', engineer.phone ?? 'Not provided', Icons.phone_android_rounded),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 12),
                                      child: Divider(color: Colors.white10),
                                    ),
                                    _buildInfoRow('Last Active', engineer.lastLogin != null ? _formatDateTime(engineer.lastLogin!) : 'Never', Icons.history_rounded),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 12),
                                      child: Divider(color: Colors.white10),
                                    ),
                                    _buildInfoRow('Member Since', _formatDate(engineer.createdAt), Icons.calendar_today_rounded),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Colors.blueAccent, AppColors.deepBlue3],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blueAccent.withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: () => _viewEngineerDetails(context, engineer),
                                  icon: const Icon(Icons.analytics_outlined, size: 20),
                                  label: const Text(
                                    'VIEW PERFORMANCE ANALYTICS',
                                    style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: Colors.white,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(vertical: 18),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    elevation: 0,
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
      ('Machine Management', permissions.toolMachineManagement, Icons.precision_manufacturing_rounded),
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
            color: enabled ? Colors.greenAccent.withOpacity(0.1) : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: enabled ? Colors.greenAccent.withOpacity(0.3) : Colors.white.withOpacity(0.1),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                enabled ? Icons.check_circle_rounded : Icons.cancel_rounded,
                size: 14,
                color: enabled ? Colors.greenAccent : Colors.white24,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: enabled ? Colors.white : Colors.white38,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 14, color: Colors.white38),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.4),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.w900,
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
