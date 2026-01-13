import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  late AnimationController _borderController;
  late Animation<double> _borderAnimation;

  final Map<String, dynamic> _criteria = {
    'workerAvailability': {'status': true, 'value': '12 workers ready', 'progress': 0.85},
    'safetyCompliance': {'status': true, 'value': 'All checks passed', 'progress': 1.0},
    'storageSpace': {'status': true, 'value': '450 sq.ft available', 'progress': 0.75},
    'weatherCondition': {'status': false, 'value': 'Heavy rain expected', 'progress': 0.3},
  };

  String _decision = 'Analyzing...';
  Color _decisionColor = Colors.orange;
  IconData _decisionIcon = Icons.hourglass_bottom_rounded;
  DateTime _analysisStartTime = DateTime.now();

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

    _borderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _borderAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _borderController, curve: Curves.easeInOut),
    );

    _analyzeEntry();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    _borderController.dispose();
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
    _borderController.stop();
  }

  @override
  Widget build(BuildContext context) {
    return ProfessionalPage(
      title: 'Dispatch Intelligence',
      children: [
        // Enhanced Greeting/Status
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI-Powered Analysis',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('EEEE, h:mm a').format(DateTime.now()),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: const Icon(Icons.psychology_rounded, color: Colors.cyanAccent, size: 24),
              ),
            ],
          ),
        ),

        // Enhanced Vehicle Meta Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: ProfessionalCard(
            useGlass: true,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                      ),
                      child: const Icon(Icons.local_shipping_rounded, color: Colors.blueAccent, size: 32),
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
                              fontSize: 22, 
                              fontWeight: FontWeight.w900, 
                              letterSpacing: -0.5
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.badge_rounded, size: 12, color: Colors.white.withOpacity(0.5)),
                              const SizedBox(width: 4),
                              Text(
                                'ID: ${widget.truckId}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5), 
                                  fontSize: 11, 
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _borderAnimation,
                      builder: (context, child) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _decision == 'Analyzing...' 
                              ? Colors.orange.withOpacity(0.1 + (_borderAnimation.value * 0.1))
                              : Colors.greenAccent.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _decision == 'Analyzing...'
                                ? Colors.orange.withOpacity(_borderAnimation.value)
                                : Colors.greenAccent.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            _decision == 'Analyzing...' ? 'ANALYZING' : 'SECURED',
                            style: TextStyle(
                              color: _decision == 'Analyzing...' ? Colors.orange : Colors.greenAccent,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMetricItem('ARRIVAL', DateFormat('h:mm a').format(DateTime.now())),
                      Container(width: 1, height: 20, color: Colors.white.withOpacity(0.1)),
                      _buildMetricItem('OPERATOR', 'Rajesh Kumar'),
                      Container(width: 1, height: 20, color: Colors.white.withOpacity(0.1)),
                      _buildMetricItem('LOAD', 'Cement'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const ProfessionalSectionHeader(
          title: 'Intelligence Assessment',
          subtitle: 'Real-time multi-vector condition analysis',
        ),

        // Enhanced Analysis Grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.15,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              _buildEnhancedAnalysisTile(
                'WORKERS',
                _criteria['workerAvailability']!['value'],
                Icons.groups_rounded,
                Colors.blueAccent,
                _criteria['workerAvailability']!['status'],
                _criteria['workerAvailability']!['progress'],
              ),
              _buildEnhancedAnalysisTile(
                'SAFETY',
                _criteria['safetyCompliance']!['value'],
                Icons.verified_user_rounded,
                Colors.greenAccent,
                _criteria['safetyCompliance']!['status'],
                _criteria['safetyCompliance']!['progress'],
              ),
              _buildEnhancedAnalysisTile(
                'STORAGE',
                _criteria['storageSpace']!['value'],
                Icons.warehouse_rounded,
                Colors.purpleAccent,
                _criteria['storageSpace']!['status'],
                _criteria['storageSpace']!['progress'],
              ),
              _buildEnhancedAnalysisTile(
                'WEATHER',
                _criteria['weatherCondition']!['value'],
                Icons.cloud_rounded,
                Colors.indigoAccent,
                _criteria['weatherCondition']!['status'],
                _criteria['weatherCondition']!['progress'],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Decision Summary (if decided)
        if (_decision != 'Analyzing...')
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ProfessionalCard(
              useGlass: true,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.insights_rounded, color: Colors.white.withOpacity(0.7), size: 16),
                      const SizedBox(width: 8),
                      const Text(
                        'DECISION FACTORS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _getDecisionMessage(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.schedule_rounded, size: 12, color: Colors.white.withOpacity(0.4)),
                      const SizedBox(width: 6),
                      Text(
                        'Analysis completed in ${DateTime.now().difference(_analysisStartTime).inSeconds}s',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 24),

        // Enhanced Central Decision Orb
        Center(
          child: SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _pulseAnimation,
              child: _buildEnhancedDecisionOrb(),
            ),
          ),
        ),

        const SizedBox(height: 40),

        // Enhanced Action Bar
        if (_decision != 'Analyzing...')
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ProfessionalCard(
              useGlass: true,
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildEnhancedActionButton(
                      'DISMISS',
                      Icons.close_rounded,
                      Colors.white.withOpacity(0.1),
                      () => Navigator.pop(context),
                      isPrimary: false,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: _buildEnhancedActionButton(
                      _decision == 'ALLOW ENTRY' ? 'CONFIRM ENTRY' : 'ACKNOWLEDGE',
                      _decision == 'ALLOW ENTRY' ? Icons.check_circle_rounded : Icons.done_all_rounded,
                      _decisionColor,
                      _decision == 'STOP ENTRY' ? null : () => Navigator.pop(context),
                      isPrimary: true,
                    ),
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildMetricItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedAnalysisTile(
    String label, 
    String value, 
    IconData icon, 
    Color color, 
    bool status,
    double progress,
  ) {
    return ProfessionalCard(
      useGlass: true,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: (status ? Colors.greenAccent : Colors.orangeAccent).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  status ? Icons.check_rounded : Icons.info_rounded,
                  color: status ? Colors.greenAccent : Colors.orangeAccent,
                  size: 14,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.05),
              color: color,
              minHeight: 3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedDecisionOrb() {
    return Container(
      width: 260,
      height: 260,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _decisionColor.withOpacity(0.3),
            blurRadius: 80,
            spreadRadius: 15,
          ),
        ],
        gradient: RadialGradient(
          colors: [
            _decisionColor.withOpacity(0.25),
            _decisionColor.withOpacity(0.05),
          ],
        ),
        border: Border.all(color: _decisionColor.withOpacity(0.5), width: 2.5),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Inner glowing ring
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _decisionColor.withOpacity(0.1),
              border: Border.all(color: _decisionColor.withOpacity(0.3), width: 1.5),
            ),
          ),
          // Content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _decisionColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(_decisionIcon, color: _decisionColor, size: 56),
              ),
              const SizedBox(height: 20),
              Text(
                _decision,
                style: TextStyle(
                  color: _decisionColor,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  shadows: [
                    Shadow(color: _decisionColor.withOpacity(0.5), blurRadius: 15),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getStatusLabel().toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedActionButton(
    String label, 
    IconData icon, 
    Color color, 
    VoidCallback? onTap, 
    {bool isPrimary = false}
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isPrimary ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: isPrimary ? null : Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon, 
                color: isPrimary ? Colors.white : Colors.white.withOpacity(0.6), 
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: isPrimary ? Colors.white : Colors.white.withOpacity(0.8),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDecisionMessage() {
    switch (_decision) {
      case 'ALLOW ENTRY':
        return 'All systems are ready and conditions are optimal. The truck can proceed directly to the unloading zone. Workers are on standby and safety protocols are in place.';
      case 'HOLD ENTRY':
        return 'Weather conditions are not optimal for unloading operations. Please wait for conditions to improve or move to covered area. All other systems are ready.';
      case 'STOP ENTRY':
        return 'Critical safety compliance violation detected. Entry is denied until all safety checks are completed and approved by authorized personnel.';
      default:
        return 'Running comprehensive automated decision analysis across multiple data points...';
    }
  }

  String _getStatusLabel() {
    switch (_decision) {
      case 'ALLOW ENTRY':
        return 'Proceed to Zone';
      case 'HOLD ENTRY':
        return 'Weather Advisory';
      case 'STOP ENTRY':
        return 'Safety Block';
      default:
        return 'Processing...';
    }
  }
}
