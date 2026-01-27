import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:construction_app/shared/theme/professional_theme.dart';
import 'package:construction_app/shared/widgets/professional_page.dart';
import 'package:construction_app/utils/feedback_helper.dart';
import 'package:construction_app/services/site_service.dart';
import 'package:construction_app/services/auth_service.dart';
import 'package:construction_app/governance/sites/site_model.dart';
import 'package:construction_app/profiles/engineer_model.dart';

class SiteFormScreen extends StatefulWidget {
  final SiteModel? site;
  const SiteFormScreen({super.key, this.site});

  @override
  State<SiteFormScreen> createState() => _SiteFormScreenState();
}

class _SiteFormScreenState extends State<SiteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _refController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.site?.name ?? '');
    _locationController = TextEditingController(text: widget.site?.location ?? '');
    _refController = TextEditingController(text: widget.site?.id ?? 'SITE-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _refController.dispose();
    super.dispose();
  }

  Future<void> _saveSite() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    
    // Simulate network delay for premium feel (syncing to cloud)
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      final siteService = context.read<SiteService>();
      final newSite = SiteModel(
        id: _refController.text.trim(),
        name: _nameController.text.trim(),
        location: _locationController.text.trim(),
        rolePermissions: widget.site?.rolePermissions ?? {
          EngineerRole.siteEngineer: const PermissionSet(),
          EngineerRole.projectManager: const PermissionSet(),
          EngineerRole.supervisor: const PermissionSet(),
        },
        assignedEngineerIds: widget.site?.assignedEngineerIds ?? [],
      );

      if (widget.site == null) {
        siteService.addSite(newSite);
        FeedbackHelper.showSuccess(context, 'Site "${newSite.name}" registered successfully!');
      } else {
        siteService.updateSite(newSite);
        FeedbackHelper.showSuccess(context, 'Site details updated.');
      }
      
      if (mounted) Navigator.pop(context);
    } catch (e) {
      FeedbackHelper.showError(context, 'Failed to save site: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.site != null;

    return ProfessionalPage(
      title: isEdit ? 'Edit Site' : 'New Strategic Site',
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text(
                isEdit ? 'Update site parameters' : 'Register a new project location',
                style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('CORE IDENTIFICATION'),
                const SizedBox(height: 16),
                ProfessionalCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _nameController,
                        label: 'Project Name',
                        hint: 'e.g. Metropolis Heights Tower A',
                        icon: Icons.business_rounded,
                        validator: (v) => v!.isEmpty ? 'Name is required' : null,
                      ),
                      const SizedBox(height: 24),
                      _buildTextField(
                        controller: _locationController,
                        label: 'Operational Location',
                        hint: 'e.g. Sector 45, Gurugram',
                        icon: Icons.location_on_rounded,
                        validator: (v) => v!.isEmpty ? 'Location is required' : null,
                      ),
                      const SizedBox(height: 24),
                      _buildTextField(
                        controller: _refController,
                        label: 'Reference ID / Site Code',
                        hint: 'e.g. SITE-001',
                        icon: Icons.qr_code_rounded,
                        enabled: !isEdit,
                        validator: (v) => v!.isEmpty ? 'Reference ID is required' : null,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                _buildSectionHeader('DEPLOYMENT'),
                const SizedBox(height: 16),
                Text(
                   'Note: Modular permissions and engineer assignments can be managed from the Governance Hub after registration.',
                   style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 12, fontStyle: FontStyle.italic),
                ),

                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveSite,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 8,
                      shadowColor: theme.colorScheme.primary.withOpacity(0.4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isSaving 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          isEdit ? 'UPDATE SITE PARAMETERS' : 'FINALIZE SITE REGISTRATION',
                          style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
                        ),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
        color: AppColors.deepBlue2,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: enabled,
          validator: validator,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.deepBlue1, size: 20),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}
