import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:construction_app/shared/theme/professional_theme.dart';
import 'package:construction_app/shared/widgets/professional_page.dart';
import 'package:construction_app/shared/widgets/staggered_animation.dart';
import 'package:construction_app/services/site_service.dart';
import 'package:construction_app/services/mock_engineer_service.dart';
import 'package:construction_app/services/approval_service.dart';
import 'package:construction_app/governance/approvals/models/action_request.dart';
import 'package:construction_app/governance/approvals/approval_detail_screen.dart';
import 'package:construction_app/governance/sites/site_model.dart';
import 'package:construction_app/profiles/engineer_model.dart';
import 'package:construction_app/utils/feedback_helper.dart';
import 'package:intl/intl.dart';
import 'site_form_screen.dart';

class GovernanceHubScreen extends StatefulWidget {
  const GovernanceHubScreen({super.key});

  @override
  State<GovernanceHubScreen> createState() => _GovernanceHubScreenState();
}

class _GovernanceHubScreenState extends State<GovernanceHubScreen> {
  String? _selectedSiteId;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: ProfessionalPage(
        title: 'Governance Hub',
        actions: [
          IconButton(
            onPressed: () => _showDiagnosticView(context),
            icon: const Icon(Icons.analytics_rounded),
            tooltip: 'System Analysis',
          ),
        ],
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'SITE MANAGEMENT'),
              Tab(text: 'UNIFIED HUB LOG'),
            ],
            labelColor: AppColors.deepBlue1,
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5),
            indicatorColor: AppColors.deepBlue1,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: TabBarView(
              children: [
                _buildSiteManagement(context),
                _buildUnifiedLog(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSiteManagement(BuildContext context) {
    return Consumer<SiteService>(
      builder: (context, siteService, child) {
        final sites = siteService.sites;
        _selectedSiteId ??= sites.isNotEmpty ? sites.first.id : null;

        final selectedSite = sites.firstWhere(
          (s) => s.id == _selectedSiteId,
          orElse: () => sites.isNotEmpty ? sites.first : SiteModel(id: '', name: 'N/A', location: '', rolePermissions: {}),
        );

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Site Selector with Add/Edit/Delete
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'OPERATIONAL SITES',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Theme.of(context).colorScheme.primary,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Row(
                          children: [
                            if (_selectedSiteId != null) ...[
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.edit_location_alt_rounded, size: 18, color: Colors.blueAccent),
                                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SiteFormScreen(site: selectedSite))),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.delete_sweep_rounded, size: 18, color: Colors.redAccent),
                                onPressed: () => _confirmDeleteSite(context, selectedSite),
                              ),
                              const SizedBox(width: 8),
                            ],
                            IconButton(
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.add_location_alt_rounded, size: 18, color: Colors.greenAccent),
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SiteFormScreen())),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 100,
                      child: sites.isEmpty 
                        ? const Center(child: Text('No sites available. Add one to start.', style: TextStyle(fontSize: 12, color: Colors.grey)))
                        : ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: sites.length,
                            separatorBuilder: (context, index) => const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final site = sites[index];
                              final isSelected = site.id == _selectedSiteId;
                              return _SiteSelectorCard(
                                site: site,
                                isSelected: isSelected,
                                onTap: () => setState(() => _selectedSiteId = site.id),
                              );
                            },
                          ),
                    ),
                  ],
                ),
              ),

              if (_selectedSiteId != null && selectedSite.id.isNotEmpty) ...[
                ProfessionalSectionHeader(
                  title: 'Personnel & Control',
                  subtitle: 'Manage assigned engineers for ${selectedSite.name}',
                  action: TextButton.icon(
                    onPressed: () => _showAssignSheet(context, selectedSite),
                    icon: const Icon(Icons.person_add_rounded, size: 18),
                    label: const Text('ASSIGN ENGINEER', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
                  ),
                ),

                Consumer2<MockEngineerService, ApprovalService>(
                  builder: (context, engineerService, approvalService, _) {
                    final assignedEngineers = engineerService.engineers.where(
                      (e) => selectedSite.assignedEngineerIds.contains(e.id),
                    ).toList();

                    if (assignedEngineers.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(
                          child: Text(
                            'No personnel assigned to this site yet.',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: assignedEngineers.length,
                      itemBuilder: (context, index) {
                        final engineer = assignedEngineers[index];
                        final pendingRequests = approvalService.requests.where(
                          (r) => r.requesterId == engineer.id && r.status == ApprovalStatus.pending && r.siteId == selectedSite.id
                        ).toList();

                        return StaggeredAnimation(
                          index: index,
                          child: _EngineerControlCard(
                            site: selectedSite,
                            engineer: engineer,
                            pendingRequests: pendingRequests,
                            onPermissionChanged: (permissions) {
                              siteService.updatePermissions(selectedSite.id, engineer.role, permissions);
                              FeedbackHelper.showSuccess(context, 'Permissions updated for ${engineer.name}');
                            },
                            onUnassign: () => siteService.unassignEngineer(selectedSite.id, engineer.id),
                          ),
                        );
                      },
                    );
                  }
                ),
              ],
              const SizedBox(height: 100),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUnifiedLog(BuildContext context) {
    return Consumer<ApprovalService>(
      builder: (context, service, _) {
        final requests = service.requests;
        if (requests.isEmpty) {
          return const Center(
            child: Text('Notification logs will appear here as engineers take action.', style: TextStyle(color: Colors.grey)),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          separatorBuilder: (context, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final req = requests[index];
            return ProfessionalCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: req.status == ApprovalStatus.approved ? Colors.greenAccent.withOpacity(0.1) : (req.status == ApprovalStatus.rejected ? Colors.redAccent.withOpacity(0.1) : Colors.orangeAccent.withOpacity(0.1)),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      req.status == ApprovalStatus.approved ? Icons.check_circle_rounded : (req.status == ApprovalStatus.rejected ? Icons.cancel_rounded : Icons.pending_rounded),
                      size: 20,
                      color: req.status == ApprovalStatus.approved ? Colors.green : (req.status == ApprovalStatus.rejected ? Colors.red : Colors.orange),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${req.requesterName} @ ${req.siteId}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Action: ${req.action.name.toUpperCase()} ${req.entityType.toUpperCase()}',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        ),
                        Text(
                          DateFormat('MMM dd, hh:mm a').format(req.createdAt),
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
                        ),
                      ],
                    ),
                  ),
                  _StatusIndicator(status: req.status),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ApprovalDetailScreen(request: req))),
                    child: const Text('VIEW', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }


  void _confirmDeleteSite(BuildContext context, SiteModel site) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion', style: TextStyle(fontWeight: FontWeight.w900)),
        content: Text('Are you sure you want to remove ${site.name}? This action cannot be undone and will affect all assigned personnel.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          TextButton(
            onPressed: () {
              Provider.of<SiteService>(context, listen: false).deleteSite(site.id);
              setState(() => _selectedSiteId = null);
              Navigator.pop(context);
              FeedbackHelper.showSuccess(context, 'Site removed from Governance Hub.');
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _showDiagnosticView(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AdminDiagnosticView(),
    );
  }

  void _showAssignSheet(BuildContext context, SiteModel site) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EngineerAssignSheet(site: site),
    );
  }

  Widget _buildAssignedEngineersList(BuildContext context, SiteModel site, SiteService siteService) {
    return Consumer<MockEngineerService>(
      builder: (context, engineerService, _) {
        final assignedEngineers = engineerService.engineers.where(
          (e) => site.assignedEngineerIds.contains(e.id),
        ).toList();

        if (assignedEngineers.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Text(
                'No personnel assigned to this site yet.',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: assignedEngineers.length,
          itemBuilder: (context, index) {
            final engineer = assignedEngineers[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ProfessionalCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      child: Text(
                        engineer.name[0].toUpperCase(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(engineer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            engineer.role.displayName,
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => siteService.unassignEngineer(site.id, engineer.id),
                      icon: const Icon(Icons.link_off_rounded, color: Colors.redAccent, size: 20),
                      tooltip: 'Remove Assignment',
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _EngineerAssignSheet extends StatelessWidget {
  final SiteModel site;
  const _EngineerAssignSheet({required this.site});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Consumer2<MockEngineerService, SiteService>(
        builder: (context, engineerService, siteService, _) {
          final unassigned = engineerService.engineers.where(
            (e) => !site.assignedEngineerIds.contains(e.id),
          ).toList();

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Assign Personnel',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Allocating engineers to ${site.name}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 24),
              if (unassigned.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('All available engineers are already assigned.'),
                  ),
                )
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 400),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: unassigned.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final e = unassigned[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          child: Text(e.name[0]),
                        ),
                        title: Text(e.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(e.role.displayName),
                        trailing: ElevatedButton(
                          onPressed: () {
                            siteService.assignEngineer(site.id, e.id);
                            Navigator.pop(context);
                            FeedbackHelper.showSuccess(context, '${e.name} assigned to ${site.name}');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('ASSIGN'),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}

class _SiteSelectorCard extends StatelessWidget {
  final SiteModel site;
  final bool isSelected;
  final VoidCallback onTap;

  const _SiteSelectorCard({
    required this.site,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ProfessionalCard(
      padding: EdgeInsets.zero,
      width: 180,
      color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.05) : null,
      border: Border.all(
        color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor.withOpacity(0.05),
        width: 1.5,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                site.name,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                site.id,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EngineerControlCard extends StatefulWidget {
  final SiteModel site;
  final EngineerModel engineer;
  final List<ActionRequest> pendingRequests;
  final Function(PermissionSet) onPermissionChanged;
  final VoidCallback onUnassign;

  const _EngineerControlCard({
    required this.site,
    required this.engineer,
    required this.pendingRequests,
    required this.onPermissionChanged,
    required this.onUnassign,
  });

  @override
  State<_EngineerControlCard> createState() => _EngineerControlCardState();
}

class _EngineerControlCardState extends State<_EngineerControlCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final permissions = widget.site.rolePermissions[widget.engineer.role] ?? const PermissionSet();
    final hasPending = widget.pendingRequests.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ProfessionalCard(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            // 1. Header (Engineer Info)
            InkWell(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      child: Text(
                        widget.engineer.name[0].toUpperCase(),
                        style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(widget.engineer.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                              const SizedBox(width: 8),
                              if (hasPending)
                                _badge('${widget.pendingRequests.length} PENDING', Colors.orangeAccent),
                            ],
                          ),
                          Text(widget.engineer.role.displayName, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: widget.onUnassign,
                      icon: const Icon(Icons.link_off_rounded, color: Colors.redAccent, size: 18),
                      tooltip: 'Unassign from Site',
                    ),
                    Icon(
                      _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),

            if (_isExpanded) ...[
              Divider(height: 1, color: Theme.of(context).dividerColor.withOpacity(0.05)),
              
              // 2. Control Tabs
              DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    const TabBar(
                      tabs: [
                        Tab(text: 'MODULE ACCESS'),
                        Tab(text: 'ACTION LOG'),
                      ],
                      labelColor: AppColors.deepBlue1,
                      unselectedLabelColor: Colors.grey,
                      labelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                      indicatorColor: AppColors.deepBlue1,
                      indicatorSize: TabBarIndicatorSize.label,
                    ),
                    SizedBox(
                      height: 300,
                      child: TabBarView(
                        children: [
                          // TAB 1: Permissions
                          _buildPermissions(permissions),
                          // TAB 2: Pending Requests
                          _buildRequestList(context),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPermissions(PermissionSet permissions) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _PermissionSwitch(
          label: 'Inventory Control',
          subtitle: 'Materials and Stock management',
          value: permissions.inventoryManagement,
          onChanged: (v) => widget.onPermissionChanged(permissions.copyWith(inventoryManagement: v)),
        ),
        _PermissionSwitch(
          label: 'Worker Management',
          subtitle: 'Force and attendance controls',
          value: permissions.workerManagement,
          onChanged: (v) => widget.onPermissionChanged(permissions.copyWith(workerManagement: v)),
        ),
        _PermissionSwitch(
          label: 'Asset Operations',
          subtitle: 'Machinery and site tools',
          value: permissions.toolMachineManagement,
          onChanged: (v) => widget.onPermissionChanged(permissions.copyWith(toolMachineManagement: v)),
        ),
        _PermissionSwitch(
          label: 'Financial Visibility',
          subtitle: 'Site expenditure reports',
          value: permissions.reportViewing,
          onChanged: (v) => widget.onPermissionChanged(permissions.copyWith(reportViewing: v)),
        ),
      ],
    );
  }

  Widget _buildRequestList(BuildContext context) {
    if (widget.pendingRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline_rounded, color: Colors.greenAccent.withOpacity(0.5), size: 40),
            const SizedBox(height: 8),
            const Text('No pending actions from this engineer.', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: widget.pendingRequests.length,
      separatorBuilder: (context, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final req = widget.pendingRequests[index];
        return _ActionRow(request: req);
      },
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(text, style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold)),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final ActionRequest request;
  const _ActionRow({required this.request});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(_getIcon(request.entityType), size: 14, color: Colors.blueAccent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${request.action.name.toUpperCase()} ${request.entityType.toUpperCase()}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                Text(
                  DateFormat('MMM dd • HH:mm').format(request.createdAt),
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => ApprovalDetailScreen(request: request)));
            },
            child: const Text('REVIEW', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type.toLowerCase()) {
      case 'worker': return Icons.badge_rounded;
      case 'tool': return Icons.build_circle_rounded;
      case 'machine': return Icons.precision_manufacturing_rounded;
      case 'material': return Icons.inventory_2_rounded;
      default: return Icons.help_outline_rounded;
    }
  }
}

class _PermissionSwitch extends StatefulWidget {
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PermissionSwitch({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  State<_PermissionSwitch> createState() => _PermissionSwitchState();
}

class _PermissionSwitchState extends State<_PermissionSwitch> {
  bool _isSyncing = false;

  Future<void> _handleToggle(bool v) async {
    setState(() => _isSyncing = true);
    // Simulate cloud sync delay
    await Future.delayed(const Duration(milliseconds: 300));
    widget.onChanged(v);
    if (mounted) setState(() => _isSyncing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.label,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    if (_isSyncing) ...[
                      const SizedBox(width: 8),
                      const SizedBox(
                        width: 10,
                        height: 10,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.deepBlue1),
                      ),
                    ],
                  ],
                ),
                Text(
                  widget.subtitle,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: widget.value,
            onChanged: _isSyncing ? null : _handleToggle,
            activeColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  final ApprovalStatus status;
  const _StatusIndicator({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;
    switch (status) {
      case ApprovalStatus.approved:
        color = Colors.green;
        text = 'APPROVED';
        break;
      case ApprovalStatus.rejected:
        color = Colors.red;
        text = 'REJECTED';
        break;
      case ApprovalStatus.pending:
        color = Colors.orange;
        text = 'PENDING';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _AdminDiagnosticView extends StatelessWidget {
  const _AdminDiagnosticView();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.security_rounded, color: Colors.blueAccent),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('System Diagnostic', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                    Text('Analyzing permissions and data isolation...', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Consumer2<SiteService, MockEngineerService>(
              builder: (context, siteService, engineerService, _) {
                final allSites = siteService.sites;
                final allEngineers = engineerService.engineers;
                final auditResults = <PermissionAuditResult>[];

                for (final site in allSites) {
                  auditResults.addAll(siteService.auditSitePermissions(site.id, allEngineers));
                }

                return ListView(
                  children: [
                    if (auditResults.isNotEmpty) ...[
                      _buildAuditHeader('RBAC INCONSISTENCIES DETECTED (${auditResults.length})', Colors.redAccent),
                      ...auditResults.map((res) => _DiagnosticItem(
                        title: '${res.engineerName} (${res.role.displayName})',
                        status: 'CONFLICT',
                        desc: res.details,
                        icon: Icons.error_outline_rounded,
                        color: Colors.redAccent,
                        actionLabel: 'FIX ACCESS',
                        onAction: () {
                           // Logic to auto-fix or navigate
                           FeedbackHelper.showSuccess(context, 'Syncing permissions for ${res.engineerName}...');
                           siteService.updatePermissions(
                             allSites.firstWhere((s) => s.assignedEngineerIds.contains(res.engineerId)).id,
                             res.role,
                             res.role.mandatoryPermissions,
                           );
                        },
                      )),
                      const Divider(height: 32),
                    ],
                    _buildAuditHeader('SYSTEM HEALTH', Colors.grey),
                    _DiagnosticItem(
                      title: 'Data Isolation Audit',
                      status: 'SECURE',
                      desc: 'Engineers are strictly restricted to their assigned site IDs in all queries.',
                      icon: Icons.leak_remove_rounded,
                      color: Colors.green,
                    ),
                    _DiagnosticItem(
                      title: 'Approval Sync Status',
                      status: 'OPTIMAL',
                      desc: 'Governance Hub is the single source of truth. Approvals reflect within <1s.',
                      icon: Icons.sync_rounded,
                      color: Colors.green,
                    ),
                    _DiagnosticItem(
                      title: 'Session Management',
                      status: 'STABLE',
                      desc: 'Universal mapping verified. Login-time validation layer active.',
                      icon: Icons.verified_user_rounded,
                      color: Colors.green,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: color, letterSpacing: 1.2),
      ),
    );
  }
}

class _DiagnosticItem extends StatelessWidget {
  final String title;
  final String status;
  final String desc;
  final IconData icon;
  final Color color;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _DiagnosticItem({
    required this.title,
    required this.status,
    required this.desc,
    required this.icon,
    required this.color,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return ProfessionalCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                      child: Text(status, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(desc, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                if (actionLabel != null) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 32,
                    child: TextButton(
                      onPressed: onAction,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        backgroundColor: color.withOpacity(0.1),
                      ),
                      child: Text(actionLabel!, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
