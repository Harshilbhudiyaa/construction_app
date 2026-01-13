import 'package:flutter/material.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/professional_theme.dart';
import '../../app/ui/widgets/professional_page.dart';
import '../../app/ui/widgets/status_chip.dart';
import 'models/engineer_model.dart';
import 'engineer_form_screen.dart';
import 'engineer_shell.dart';

class EngineerDetailScreen extends StatelessWidget {
  final EngineerModel engineer;

  const EngineerDetailScreen({super.key, required this.engineer});

  @override
  Widget build(BuildContext context) {
    return ProfessionalPage(
      title: 'Personnel Profile',
      actions: [
        IconButton(
          onPressed: () => _editEngineer(context),
          icon: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 28),
          tooltip: 'Edit Personnel',
        ),
        IconButton(
          onPressed: () => _simulateLogin(context),
          icon: const Icon(Icons.login_rounded, color: Colors.white, size: 28),
          tooltip: 'Login as ${engineer.name}',
        ),
      ],
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Profile Card
              ProfessionalCard(
                useGlass: true,
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Hero(
                      tag: 'personnel_icon_${engineer.id}',
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.2),
                              Colors.white.withOpacity(0.05),
                            ],
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            engineer.name.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            engineer.name,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              engineer.role.displayName.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w900,
                                fontSize: 10,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    StatusChip(
                      status: engineer.isActive ? UiStatus.ok : UiStatus.pending,
                      labelOverride: engineer.isActive ? 'ACTIVE' : 'INACTIVE',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // KPI Section for Personnel
              _buildProfessionalGrid([
                _MetricTile(
                  label: 'LAST LOGIN',
                  value: engineer.lastLogin != null ? _formatDateTime(engineer.lastLogin!) : 'NEVER',
                  icon: Icons.login_rounded,
                  color: Colors.blueAccent,
                ),
                _MetricTile(
                  label: 'JOINED',
                  value: _formatDate(engineer.createdAt),
                  icon: Icons.calendar_today_rounded,
                  color: Colors.orangeAccent,
                ),
              ]),

              const SizedBox(height: 12),

              // Contact Information
              ProfessionalCard(
                useGlass: true,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('CONTACT INFORMATION'),
                    const SizedBox(height: 24),
                    _kv('Work Email', engineer.email ?? 'Not provided', icon: Icons.email_rounded),
                    _kv('Primary Phone', engineer.phone ?? 'Not provided', icon: Icons.phone_android_rounded),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Permissions
              ProfessionalCard(
                useGlass: true,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('ACCESS PERMISSIONS'),
                    const SizedBox(height: 24),
                    _buildPermissionGrid(engineer.permissions),
                  ],
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfessionalGrid(List<Widget> children) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.8,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: children,
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        color: Colors.white.withOpacity(0.4),
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _kv(String k, String v, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: Colors.white70),
            ),
            const SizedBox(width: 16),
          ],
          Text(
            k,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            v,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 16,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
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
      spacing: 10,
      runSpacing: 10,
      children: permissionItems.map((item) {
        final (label, enabled, icon) = item;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: enabled ? Colors.greenAccent.withOpacity(0.08) : Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: enabled ? Colors.greenAccent.withOpacity(0.2) : Colors.white.withOpacity(0.08),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                enabled ? Icons.check_circle_rounded : Icons.cancel_rounded,
                size: 16,
                color: enabled ? Colors.greenAccent : Colors.white24,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: enabled ? Colors.white : Colors.white.withOpacity(0.35),
                ),
              ),
            ],
          ),
        );
      }).toList(),
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

  void _editEngineer(BuildContext context) async {
    final result = await Navigator.push<EngineerModel>(
      context,
      MaterialPageRoute(
        builder: (context) => EngineerFormScreen(engineer: engineer),
      ),
    );

    if (result != null && context.mounted) {
      Navigator.pop(context, result);
    }
  }

  void _simulateLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EngineerShell(
          engineerId: engineer.id,
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ProfessionalCard(
      useGlass: true,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color.withOpacity(0.7)),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Colors.white.withOpacity(0.4),
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

