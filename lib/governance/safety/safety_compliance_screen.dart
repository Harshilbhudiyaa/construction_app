import 'package:flutter/material.dart';
import 'package:construction_app/shared/theme/app_spacing.dart';
import 'package:construction_app/shared/theme/professional_theme.dart';
import 'package:construction_app/shared/widgets/professional_page.dart';

/// Safety Compliance Screen
/// Displays safety checklist, compliance status, and incident reports
/// Organized with clear sections for better maintainability
class SafetyComplianceScreen extends StatefulWidget {
  const SafetyComplianceScreen({super.key});

  @override
  State<SafetyComplianceScreen> createState() => _SafetyComplianceScreenState();
}

class _SafetyComplianceScreenState extends State<SafetyComplianceScreen> 
    with SingleTickerProviderStateMixin {
  
  // ============================================================================
  // SECTION: State Variables & Controllers
  // ============================================================================
  
  /// Animation controller for screen entrance effects
  late AnimationController _animController;
  
  /// Fade animation for smooth entrance
  late Animation<double> _fadeAnimation;

  /// Safety checklist items with their compliance status
  /// Keys represent different safety requirements
  final Map<String, bool> _safetyChecks = {
    'helmet': true,
    'shoes': true,
    'firstAid': false,
    'supervisor': true,
    'fireExtinguisher': true,
    'emergencyExit': true,
  };

  // ============================================================================
  // SECTION: Lifecycle Methods
  // ============================================================================
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ============================================================================
  // SECTION: Computed Properties
  // ============================================================================
  
  /// Returns true if all safety checks are compliant
  bool get _allCompliant => !_safetyChecks.values.contains(false);
  
  /// Returns compliance percentage for progress tracking
  double get _compliancePercentage {
    final compliantCount = _safetyChecks.values.where((v) => v).length;
    return compliantCount / _safetyChecks.length;
  }

  // ============================================================================
  // SECTION: Public Build Method
  // ============================================================================
  
  @override
  Widget build(BuildContext context) {
    return ProfessionalPage(
      title: 'Safety Compliance',
      children: [
        // Status Overview Section
        _buildStatusOverview(),
        
        // Safety Checklist Section
        _buildSafetyChecklistSection(),
        
        // Recent Incidents Section
        _buildRecentIncidentsSection(),
        
        // Actions Section
        _buildActionsSection(),
        
        const SizedBox(height: 32),
      ],
    );
  }

  // ============================================================================
  // SECTION: Major UI Section Builders (Private)
  // ============================================================================
  
  /// Builds the status overview banner showing overall compliance
  Widget _buildStatusOverview() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ProfessionalCard(
          gradient: LinearGradient(
            colors: _allCompliant
                ? [Colors.green.shade700, Colors.green.shade500]
                : [Colors.orange.shade700, Colors.orange.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildStatusIcon(),
                    const SizedBox(width: 16),
                    Expanded(child: _buildStatusText()),
                  ],
                ),
                const SizedBox(height: 16),
                _buildComplianceProgress(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the safety checklist section with all safety items
  Widget _buildSafetyChecklistSection() {
    return Column(
      children: [
        const ProfessionalSectionHeader(
          title: 'Safety Checklist',
          subtitle: 'Daily mandatory compliance items',
        ),
        _buildSafetyItem(
          'Safety Helmets',
          'All workers wearing approved helmets',
          Icons.construction_rounded,
          'helmet',
          Colors.orange,
        ),
        _buildSafetyItem(
          'Safety Shoes',
          'Steel-toe boots for all personnel',
          Icons.fitness_center_rounded,
          'shoes',
          Colors.brown,
        ),
        _buildSafetyItem(
          'First Aid Kit',
          'Stocked and accessible',
          Icons.medical_services_rounded,
          'firstAid',
          Colors.red,
        ),
        _buildSafetyItem(
          'Safety Supervisor',
          'Certified supervisor on-site',
          Icons.admin_panel_settings_rounded,
          'supervisor',
          Colors.blue,
        ),
        _buildSafetyItem(
          'Fire Extinguisher',
          'Inspected and ready',
          Icons.fire_extinguisher_rounded,
          'fireExtinguisher',
          Colors.deepOrange,
        ),
        _buildSafetyItem(
          'Emergency Exits',
          'Clear and marked',
          Icons.exit_to_app_rounded,
          'emergencyExit',
          Colors.green,
        ),
      ],
    );
  }

  /// Builds the recent incidents section showing incident history
  Widget _buildRecentIncidentsSection() {
    return Column(
      children: [
        const ProfessionalSectionHeader(
          title: 'Recent Incidents',
          subtitle: 'Last 7 days',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ProfessionalCard(
            child: Column(
              children: [
                _buildIncidentTile(
                  'Minor Cut - First Aid Applied',
                  '28 Dec, 10:45 AM',
                  'Ramesh Kumar',
                  Icons.healing_rounded,
                  Colors.amber,
                ),
                const Divider(height: 1),
                _buildIncidentTile(
                  'Near Miss - Falling Object',
                  '26 Dec, 2:30 PM',
                  'Site A - Block 3',
                  Icons.report_problem_rounded,
                  Colors.orange,
                ),
                const Divider(height: 1),
                _buildIncidentTile(
                  'Safety Drill Completed',
                  '24 Dec, 9:00 AM',
                  'All Personnel',
                  Icons.check_circle_rounded,
                  Colors.green,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the actions section with primary action buttons
  Widget _buildActionsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          // Generate Report Button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _generateSafetyReport,
              icon: const Icon(Icons.description_rounded),
              label: const Text('Generate Safety Report'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.deepBlue1,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // Report Incident Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _reportIncident,
              icon: const Icon(Icons.report_problem_outlined),
              label: const Text('Report New Incident'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.deepBlue1,
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: AppColors.deepBlue1, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // SECTION: Component Builders (Private)
  // ============================================================================
  
  /// Builds the status icon based on compliance state
  Widget _buildStatusIcon() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        _allCompliant ? Icons.verified_rounded : Icons.warning_amber_rounded,
        color: Colors.white,
        size: 32,
      ),
    );
  }

  /// Builds the status text showing compliance message
  Widget _buildStatusText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _allCompliant ? 'All Clear' : 'Action Required',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _allCompliant
              ? 'Site meets all safety requirements'
              : 'Some safety checks are pending',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  /// Builds the compliance progress indicator
  Widget _buildComplianceProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Compliance Progress',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(_compliancePercentage * 100).toInt()}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: _compliancePercentage,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  /// Builds a single safety checklist item
  Widget _buildSafetyItem(
    String title,
    String subtitle,
    IconData icon,
    String key,
    Color color,
  ) {
    final isCompliant = _safetyChecks[key] ?? false;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ProfessionalCard(
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.deepBlue1,
              fontSize: 14,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          trailing: Switch(
            value: isCompliant,
            onChanged: (value) => _toggleSafetyCheck(key, value),
            activeColor: Colors.green,
            inactiveThumbColor: Colors.red,
          ),
        ),
      ),
    );
  }

  /// Builds a single incident tile in the recent incidents list
  Widget _buildIncidentTile(
    String title,
    String timestamp,
    String location,
    IconData icon,
    Color color,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.deepBlue1,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 12, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                location,
                style: TextStyle(fontSize: 11, color: Colors.grey[700]),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(Icons.access_time, size: 12, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                timestamp,
                style: TextStyle(fontSize: 10, color: Colors.grey[500]),
              ),
            ],
          ),
        ],
      ),
      isThreeLine: true,
    );
  }

  // ============================================================================
  // SECTION: Private Helper Methods
  // ============================================================================
  
  /// Initializes all animations
  void _initializeAnimations() {
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _animController.forward();
  }

  /// Toggles a safety check item and updates state
  void _toggleSafetyCheck(String key, bool value) {
    setState(() {
      _safetyChecks[key] = value;
    });
    
    // Show feedback to user
    if (value) {
      _showSuccessFeedback('Safety check marked as complete');
    } else {
      _showWarningFeedback('Safety check requires attention');
    }
  }

  /// Generates a safety report
  void _generateSafetyReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.download, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Text('Generating comprehensive safety report...'),
          ],
        ),
        backgroundColor: AppColors.deepBlue1,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// Opens form to report a new incident
  void _reportIncident() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.report_problem, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Text('Opening incident report form...'),
          ],
        ),
        backgroundColor: Colors.orange.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// Shows success feedback to user
  void _showSuccessFeedback(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// Shows warning feedback to user
  void _showWarningFeedback(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
