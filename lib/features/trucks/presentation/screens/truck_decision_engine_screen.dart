import 'package:flutter/material.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/professional_theme.dart';
import '../../../../app/ui/widgets/professional_page.dart';

class TruckDecisionEngineScreen extends StatefulWidget {
  final String truckId;
  final String vehicleNumber;

  const TruckDecisionEngineScreen({
    super.key,
    required this.truckId,
    required this.vehicleNumber,
  });

  @override
  State<TruckDecisionEngineScreen> createState() => _TruckDecisionEngineScreenState();
}

class _TruckDecisionEngineScreenState extends State<TruckDecisionEngineScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  final Map<String, dynamic> _criteria = {
    'workerAvailability': {'status': true, 'value': '12 workers ready'},
    'safetyCompliance': {'status': true, 'value': 'All checks passed'},
    'storageSpace': {'status': true, 'value': '450 sq.ft available'},
    'weatherCondition': {'status': false, 'value': 'Heavy rain expected'},
  };

  String _decision = 'Analyzing...';
  Color _decisionColor = Colors.orange;
  IconData _decisionIcon = Icons.hourglass_bottom_rounded;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    _analyzeEntry();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _analyzeEntry() async {
    await Future.delayed(const Duration(seconds: 2));
    
    final allGreen = _criteria.values.every((v) => v['status'] == true);
    final criticalFailure = !_criteria['safetyCompliance']!['status'];

    setState(() {
      if (criticalFailure) {
        _decision = 'STOP ENTRY';
        _decisionColor = Colors.red;
        _decisionIcon = Icons.block_rounded;
      } else if (allGreen) {
        _decision = 'ALLOW ENTRY';
        _decisionColor = Colors.green;
        _decisionIcon = Icons.check_circle_rounded;
      } else {
        _decision = 'HOLD ENTRY';
        _decisionColor = Colors.orange;
        _decisionIcon = Icons.pause_circle_rounded;
      }
    });

    _slideController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return ProfessionalPage(
      title: 'Decision Engine',
      children: [
        // Vehicle Info
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ProfessionalCard(
            gradient: const LinearGradient(
              colors: [AppColors.deepBlue1, AppColors.deepBlue2],
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
                    child: const Icon(
                      Icons.local_shipping_rounded,
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
                          widget.vehicleNumber,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Trip ID: ${widget.truckId}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
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

        const ProfessionalSectionHeader(
          title: 'Entry Criteria Analysis',
          subtitle: 'Real-time assessment of site conditions',
        ),

        // Criteria Cards
        _buildCriteriaCard(
          'Worker Availability',
          _criteria['workerAvailability']!['value'],
          Icons.groups_rounded,
          Colors.blue,
          _criteria['workerAvailability']!['status'],
        ),
        _buildCriteriaCard(
          'Safety Compliance',
          _criteria['safetyCompliance']!['value'],
          Icons.verified_user_rounded,
          Colors.green,
          _criteria['safetyCompliance']!['status'],
        ),
        _buildCriteriaCard(
          'Storage Space',
          _criteria['storageSpace']!['value'],
          Icons.warehouse_rounded,
          Colors.purple,
          _criteria['storageSpace']!['status'],
        ),
        _buildCriteriaCard(
          'Weather Condition',
          _criteria['weatherCondition']!['value'],
          Icons.cloud_rounded,
          Colors.indigo,
          _criteria['weatherCondition']!['status'],
        ),

        const SizedBox(height: 24),

        // Decision Result
        SlideTransition(
          position: _slideAnimation,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ScaleTransition(
              scale: _pulseAnimation,
              child: ProfessionalCard(
                gradient: LinearGradient(
                  colors: [
                    _decisionColor.withValues(alpha: 0.8),
                    _decisionColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        _decisionIcon,
                        color: Colors.white,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _decision,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getDecisionMessage(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Action Buttons
        if (_decision != 'Analyzing...')
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('Cancel'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: _decision == 'STOP ENTRY'
                        ? null
                        : () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Truck entry ${_decision.toLowerCase()}'),
                                backgroundColor: _decisionColor,
                              ),
                            );
                            Navigator.pop(context);
                          },
                    icon: const Icon(Icons.done_rounded),
                    label: Text(_decision == 'ALLOW ENTRY' ? 'Confirm Entry' : 'Acknowledge'),
                    style: FilledButton.styleFrom(
                      backgroundColor: _decisionColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 32),
      ],
    );
  }

  String _getDecisionMessage() {
    switch (_decision) {
      case 'ALLOW ENTRY':
        return 'All systems ready. Truck can proceed to unloading zone.';
      case 'HOLD ENTRY':
        return 'Wait for conditions to improve before proceeding.';
      case 'STOP ENTRY':
        return 'Critical safety violation. Entry denied.';
      default:
        return 'Running automated decision analysis...';
    }
  }

  Widget _buildCriteriaCard(
    String title,
    String value,
    IconData icon,
    Color color,
    bool status,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ProfessionalCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.deepBlue1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: status
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  status ? Icons.check_rounded : Icons.close_rounded,
                  color: status ? Colors.green : Colors.red,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
