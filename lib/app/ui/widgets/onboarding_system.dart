import 'package:flutter/material.dart';
import '../../theme/professional_theme.dart';

/// Onboarding/Tutorial system for first-time users
class OnboardingOverlay extends StatefulWidget {
  final List<OnboardingStep> steps;
  final VoidCallback onComplete;

  const OnboardingOverlay({
    super.key,
    required this.steps,
    required this.onComplete,
  });

  @override
  State<OnboardingOverlay> createState() => _OnboardingOverlayState();
}

class _OnboardingOverlayState extends State<OnboardingOverlay> {
  int _currentStep = 0;

  void _nextStep() {
    if (_currentStep < widget.steps.length - 1) {
      setState(() => _currentStep++);
    } else {
      widget.onComplete();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _skip() {
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.steps[_currentStep];
    
    return Material(
      color: Colors.black54,
      child: Stack(
        children: [
          // Spotlight effect
          if (step.targetKey != null)
            _buildSpotlight(step.targetKey!),

          // Tutorial card
          Positioned(
            bottom: 80,
            left: 20,
            right: 20,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.deepBlue1.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            step.icon,
                            color: AppColors.deepBlue1,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Step ${_currentStep + 1} of ${widget.steps.length}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                step.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.deepBlue1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Description
                    Text(
                      step.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Progress indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        widget.steps.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentStep == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentStep == index
                                ? AppColors.deepBlue1
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Navigation buttons
                    Row(
                      children: [
                        if (_currentStep > 0)
                          TextButton(
                            onPressed: _previousStep,
                            child: const Text('Back'),
                          )
                        else
                          TextButton(
                            onPressed: _skip,
                            child: Text(
                              'Skip Tour',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: _nextStep,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.deepBlue1,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            _currentStep == widget.steps.length - 1
                                ? 'Get Started!'
                                : 'Next',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpotlight(GlobalKey targetKey) {
    // This would create a spotlight effect on the target widget
    // Implementation would require overlay positioning
    return Container();
  }
}

class OnboardingStep {
  final String title;
  final String description;
  final IconData icon;
  final GlobalKey? targetKey;

  const OnboardingStep({
    required this.title,
    required this.description,
    required this.icon,
    this.targetKey,
  });
}

/// Feature highlight widget
class FeatureHighlight extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback? onDismiss;

  const FeatureHighlight({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: Colors.blue[50],
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.deepBlue1.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.deepBlue1.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.deepBlue1,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.deepBlue1,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'NEW',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppColors.deepBlue1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            if (onDismiss != null)
              IconButton(
                onPressed: onDismiss,
                icon: Icon(Icons.close_rounded, size: 20, color: Colors.grey[400]),
              ),
          ],
        ),
      ),
    );
  }
}

/// Common onboarding flows
class CommonOnboarding {
  static final workerModule = [
    const OnboardingStep(
      title: 'Welcome to Worker Management',
      description: 'Manage your entire workforce from here. Add workers, track their skills, and manage schedules.',
      icon: Icons.groups_rounded,
    ),
    const OnboardingStep(
      title: 'Search & Filter',
      description: 'Use the search bar to quickly find workers by name, skill, or shift. Apply filters to narrow down your list.',
      icon: Icons.search_rounded,
    ),
    const OnboardingStep(
      title: 'Add New Workers',
      description: 'Tap the + button to register new workers. All fields include helpful tooltips and auto-formatting.',
      icon: Icons.person_add_rounded,
    ),
    const OnboardingStep(
      title: 'Quick Actions',
      description: 'Tap any worker to view details, or use the menu to edit or change their status. Confirmations prevent accidents!',
      icon: Icons.touch_app_rounded,
    ),
  ];

  static final contractorDashboard = [
    const OnboardingStep(
      title: 'Your Command Center',
      description: 'This is your dashboard - monitor all operations, track metrics, and access every module from here.',
      icon: Icons.dashboard_rounded,
    ),
    const OnboardingStep(
      title: 'Real-Time Metrics',
      description: 'View live statistics about workforce, inventory, payments, and more at a glance.',
      icon: Icons.analytics_rounded,
    ),
    const OnboardingStep(
      title: 'Quick Navigation',
      description: 'Tap any card to navigate directly to that module. Everything is just one tap away!',
      icon: Icons.navigation_rounded,
    ),
  ];
}
