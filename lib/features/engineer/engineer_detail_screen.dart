import 'package:flutter/material.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/professional_theme.dart';
import '../../app/ui/widgets/professional_page.dart';
import 'models/engineer_model.dart';
import 'engineer_form_screen.dart';

class EngineerDetailScreen extends StatelessWidget {
  final EngineerModel engineer;

  const EngineerDetailScreen({super.key, required this.engineer});

  @override
  Widget build(BuildContext context) {
    return ProfessionalPage(
      title: 'Personnel Details',
      actions: [
        IconButton(
          onPressed: () => _editEngineer(context),
          icon: const Icon(Icons.edit_rounded, color: Colors.white),
          tooltip: 'Edit Personnel',
        ),
      ],
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Card
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: AppColors.gradientColors),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          engineer.name.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.deepBlue1,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      engineer.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        engineer.role.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: engineer.isActive ? Colors.greenAccent : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          engineer.isActive ? 'Active' : 'Inactive',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Contact Information
              _buildSectionHeader('Contact Information'),
              const SizedBox(height: AppSpacing.sm),
              ProfessionalCard(
                child: Column(
                  children: [
                    if (engineer.email != null)
                      _buildInfoRow(
                        Icons.email_rounded,
                        'Email',
                        engineer.email!,
                      ),
                    if (engineer.email != null && engineer.phone != null)
                      const Divider(height: 24),
                    if (engineer.phone != null)
                      _buildInfoRow(
                        Icons.phone_rounded,
                        'Phone',
                        engineer.phone!,
                      ),
                    if (engineer.email == null && engineer.phone == null)
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Text(
                          'No contact information available',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Permissions
              _buildSectionHeader('Access Permissions'),
              const SizedBox(height: AppSpacing.sm),
              ProfessionalCard(
                child: Column(
                  children: [
                    _buildPermissionItem(
                      'Site Management',
                      Icons.location_city_rounded,
                      engineer.permissions.siteManagement,
                    ),
                    _buildPermissionItem(
                      'Worker Management',
                      Icons.groups_rounded,
                      engineer.permissions.workerManagement,
                    ),
                    _buildPermissionItem(
                      'Inventory Management',
                      Icons.inventory_2_rounded,
                      engineer.permissions.inventoryManagement,
                    ),
                    _buildPermissionItem(
                      'Tool & Machine Management',
                      Icons.precision_manufacturing_rounded,
                      engineer.permissions.toolMachineManagement,
                    ),
                    _buildPermissionItem(
                      'Report Viewing',
                      Icons.analytics_rounded,
                      engineer.permissions.reportViewing,
                    ),
                    _buildPermissionItem(
                      'Approval & Verification',
                      Icons.verified_rounded,
                      engineer.permissions.approvalVerification,
                    ),
                    _buildPermissionItem(
                      'Create Site',
                      Icons.add_location_rounded,
                      engineer.permissions.createSite,
                    ),
                    _buildPermissionItem(
                      'Edit Site',
                      Icons.edit_location_rounded,
                      engineer.permissions.editSite,
                      showDivider: false,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Account Information
              _buildSectionHeader('Account Information'),
              const SizedBox(height: AppSpacing.sm),
              ProfessionalCard(
                child: Column(
                  children: [
                    _buildInfoRow(
                      Icons.calendar_today_rounded,
                      'Member Since',
                      _formatDate(engineer.createdAt),
                    ),
                    if (engineer.lastLogin != null) ...[
                      const Divider(height: 24),
                      _buildInfoRow(
                        Icons.login_rounded,
                        'Last Login',
                        _formatDateTime(engineer.lastLogin!),
                      ),
                    ],
                  ],
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
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w900,
        color: AppColors.deepBlue1,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.deepBlue1.withOpacity(0.1),
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
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.deepBlue1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionItem(
    String label,
    IconData icon,
    bool enabled, {
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: enabled ? Colors.green : Colors.grey[400],
                size: 20,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: enabled ? AppColors.deepBlue1 : Colors.grey[500],
                  ),
                ),
              ),
              Icon(
                enabled ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: enabled ? Colors.green : Colors.grey[400],
                size: 20,
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1),
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
}
