import 'package:flutter/material.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/professional_theme.dart';
import '../../../../app/ui/widgets/professional_page.dart';

class SafetyComplianceScreen extends StatefulWidget {
  const SafetyComplianceScreen({super.key});

  @override
  State<SafetyComplianceScreen> createState() => _SafetyComplianceScreenState();
}

class _SafetyComplianceScreenState extends State<SafetyComplianceScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  final Map<String, bool> _safetyChecks = {
    'helmet': true,
    'shoes': true,
    'firstAid': false,
    'supervisor': true,
    'fireExtinguisher': true,
    'emergencyExit': true,
  };

  @override
  void initState() {
    super.initState();
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

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  bool get _allCompliant => !_safetyChecks.values.contains(false);

  @override
  Widget build(BuildContext context) {
    return ProfessionalPage(
      title: 'Safety Compliance',
      children: [
        // Overall Status Banner
        FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ProfessionalCard(
              gradient: LinearGradient(
                colors: _allCompliant
                    ? [Colors.green.shade700, Colors.green.shade500]
                    : [Colors.red.shade700, Colors.red.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
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
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
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
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const ProfessionalSectionHeader(
          title: 'Safety Checklist',
          subtitle: 'Daily mandatory compliance items',
        ),

        // Safety Items
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

        const SizedBox(height: 16),

        // Action Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Generating safety report...')),
              );
            },
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

        const SizedBox(height: 32),
      ],
    );
  }

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
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          trailing: Switch(
            value: isCompliant,
            onChanged: (value) {
              setState(() {
                _safetyChecks[key] = value;
              });
            },
            activeColor: Colors.green,
            inactiveThumbColor: Colors.red,
          ),
        ),
      ),
    );
  }

  Widget _buildIncidentTile(
    String title,
    String timestamp,
    String location,
    IconData icon,
    Color color,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
          const SizedBox(height: 2),
          Text(
            location,
            style: TextStyle(fontSize: 11, color: Colors.grey[700]),
          ),
          Text(
            timestamp,
            style: TextStyle(fontSize: 10, color: Colors.grey[500]),
          ),
        ],
      ),
      isThreeLine: true,
    );
  }
}
