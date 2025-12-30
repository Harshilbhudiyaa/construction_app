import 'package:flutter/material.dart';
import '../../../../app/routes.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/professional_theme.dart';
import '../../../../core/enums/app_enums.dart';

class RoleSelectScreen extends StatefulWidget {
  const RoleSelectScreen({super.key});

  @override
  State<RoleSelectScreen> createState() => _RoleSelectScreenState();
}

class _RoleSelectScreenState extends State<RoleSelectScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roles = [
      (
        title: 'Worker',
        subtitle: 'Clock in/out, track work hours and earnings',
        icon: Icons.engineering,
        role: AppRole.worker,
      ),
      (
        title: 'Site Engineer',
        subtitle: 'Manage approvals, inventory, blocks and trucks',
        icon: Icons.architecture,
        role: AppRole.engineer,
      ),
      (
        title: 'Contractor',
        subtitle: 'Complete oversight: payments, reports and analytics',
        icon: Icons.business_center,
        role: AppRole.contractor,
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          // Professional Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A237E),
                  Color(0xFF283593),
                  Color(0xFF3949AB),
                  Color(0xFF5C6BC0),
                ],
              ),
            ),
          ),
          
          // Grid Pattern Overlay
          Positioned.fill(
            child: CustomPaint(
              painter: GridPatternPainter(),
            ),
          ),
          
          // Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      // Header
                      const Icon(
                        Icons.construction,
                        size: 64,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Select Your Role',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Choose how you want to access the system',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 48),
                      
                      // Role Cards
                      ...roles.asMap().entries.map((entry) {
                        final index = entry.key;
                        final role = entry.value;
                        
                        return TweenAnimationBuilder<double>(
                          duration: Duration(milliseconds: 600 + (index * 150)),
                          tween: Tween(begin: 0.0, end: 1.0),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 30 * (1 - value)),
                                child: child,
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _RoleCard(
                              title: role.title,
                              subtitle: role.subtitle,
                              icon: role.icon,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.login,
                                  arguments: role.role,
                                );
                              },
                            ),
                          ),
                        );
                      }),
                      
                      const SizedBox(height: 32),
                      
                      // Footer
                      Text(
                        '© 2024 Smart Construction',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        constraints: const BoxConstraints(maxWidth: 500),
        transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(_isHovered ? 0.2 : 0.1),
                    blurRadius: _isHovered ? 30 : 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Icon Container
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A237E).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      widget.icon,
                      size: 32,
                      color: const Color(0xFF1A237E),
                    ),
                  ),
                  
                  const SizedBox(width: 20),
                  
                  // Text Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A237E),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Arrow Icon
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 20,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Grid Pattern Painter
class GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const spacing = 50.0;

    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
