import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:construction_app/data/repositories/auth_repository.dart';
import 'package:construction_app/core/routing/app_router.dart';
import 'package:construction_app/core/theme/aesthetic_tokens.dart';
import 'package:construction_app/shared/widgets/sparkle_effect.dart';
import 'package:construction_app/features/auth/create_first_site_screen.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Main entrance animation
  late AnimationController _entranceController;
  // Blueprint grid draw-on animation
  late AnimationController _blueprintController;
  // Progress bar / loading bar
  late AnimationController _loadingController;
  // Crane arm swing
  late AnimationController _craneController;
  // Logo pulse
  late AnimationController _pulseController;

  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<double> _textSlide;
  late Animation<double> _textFade;
  late Animation<double> _gridDraw;
  late Animation<double> _loadingProgress;
  late Animation<double> _craneAngle;
  late Animation<double> _taglineFade;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _blueprintController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 2200),
      vsync: this,
    );

    _craneController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat(reverse: true);

    // Logo animations
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    // Text animations
    _textSlide = Tween<double>(begin: 40.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.4, 0.9, curve: Curves.easeOutCubic),
      ),
    );
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.4, 0.85, curve: Curves.easeOut),
      ),
    );

    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
      ),
    );

    // Blueprint grid draw
    _gridDraw = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _blueprintController,
        curve: Curves.easeInOut,
      ),
    );

    // Loading progress
    _loadingProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _loadingController,
        curve: Curves.easeInOut,
      ),
    );

    // Crane swing
    _craneAngle = Tween<double>(begin: -0.08, end: 0.08).animate(
      CurvedAnimation(
        parent: _craneController,
        curve: Curves.easeInOut,
      ),
    );

    // Start animation sequence
    _blueprintController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _entranceController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      _loadingController.forward();
    });

    _checkSessionAndNavigate();
  }

  Future<void> _checkSessionAndNavigate() async {
    await Future.delayed(const Duration(milliseconds: 3200));
    if (!mounted) return;

    final authRepo = Provider.of<AuthRepository>(context, listen: false);
    await authRepo.initialization;
    // Extra buffer to ensure animations finish
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    if (authRepo.isLoggedIn) {
      // Check if this user has at least one site
      final hasSites = await _checkUserHasSites();
      if (!mounted) return;

      if (hasSites) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.dashboard,
          (route) => false,
        );
      } else {
        // New user with no site yet — send to onboarding
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const CreateFirstSiteScreen()),
          (route) => false,
        );
      }
    } else {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    }
  }

  /// Returns true if at least one site document exists in Firestore.
  Future<bool> _checkUserHasSites() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('sites')
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 5));
      return snap.docs.isNotEmpty;
    } catch (e) {
      // If check fails, default to dashboard (don't block existing users)
      return true;
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _blueprintController.dispose();
    _loadingController.dispose();
    _craneController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: bcNavy,

      body: Stack(
        children: [
          // Blueprint grid background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _gridDraw,
              builder: (context, _) => CustomPaint(
                painter: _BlueprintGridPainter(progress: _gridDraw.value),
              ),
            ),
          ),

          // Animated crane in top-right
          Positioned(
            top: 0,
            right: 20,
            child: AnimatedBuilder(
              animation: _craneAngle,
              builder: (context, _) => Transform(
                alignment: const Alignment(0, -1),
                transform: Matrix4.rotationZ(_craneAngle.value),
                child: _CraneWidget(height: size.height * 0.36),
              ),
            ),
          ),


          // Main content
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Logo badge with sparkle particles
                SparkleOverlay(
                  particleCount: 24,
                  sparkleColor: bcAmber,
                  maxParticleSize: 2.5,
                  child: SizedBox(
                    width: 260,
                    height: 260,
                    child: Center(
                      child: AnimatedBuilder(
                        animation: Listenable.merge([_logoFade, _logoScale, _pulseController]),
                        builder: (context, _) {
                          final pulse = 1.0 + (_pulseController.value * 0.025);
                          return FadeTransition(
                            opacity: _logoFade,
                            child: ScaleTransition(
                              scale: _logoScale,
                              child: Transform.scale(
                                scale: pulse,
                                child: _LogoBadge(),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 60),

                // App name
                AnimatedBuilder(
                  animation: Listenable.merge([_textFade, _textSlide]),
                  builder: (context, _) {
                    return Transform.translate(
                      offset: Offset(0, _textSlide.value),
                      child: Opacity(
                        opacity: _textFade.value,
                        child: Column(
                          children: [
                            // Steel beam divider
                            _SteelBeamDivider(),
                            const SizedBox(height: 24),
                            const Text(
                              'SmartConstruction',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: bcAmber,
                                letterSpacing: 2,
                                height: 1,
                              ),
                            ),
                            const SizedBox(height: 24),
                            _SteelBeamDivider(),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Tagline
                FadeTransition(
                  opacity: _taglineFade,
                  child: const Text(
                    'Build smarter. Deliver faster.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF7A9FC0),
                      letterSpacing: 1.2,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

                const Spacer(flex: 3),

                // Loading section
                AnimatedBuilder(
                  animation: _loadingProgress,
                  builder: (context, _) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48),
                      child: Column(
                        children: [
                          // Progress bar styled as steel beam
                          _ConstructionProgressBar(progress: _loadingProgress.value),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _loadingLabel(_loadingProgress.value),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF5B8DB8),
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '${(_loadingProgress.value * 100).toInt()}%',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFFF5A623),
                                  letterSpacing: 1,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 40),

                // Bottom badge
                const _BottomBadge(),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _loadingLabel(double progress) {
    if (progress < 0.3) return 'INITIALIZING SYSTEMS...';
    if (progress < 0.6) return 'LOADING PROJECT DATA...';
    if (progress < 0.85) return 'VERIFYING CREDENTIALS...';
    return 'READY TO BUILD';
  }
}

// ─── Widgets ─────────────────────────────────────────────────────────────────

class _LogoBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: bcAmber.withValues(alpha: 0.25),
            blurRadius: 40,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Transform.scale(
        scale: 1.15, // Slightly reduced for better fit
        child: Image.asset(
          'assets/images/logo.png',
          fit: BoxFit.cover,
          cacheWidth: 800, 
        ),
      ),
    );
  }
}

class _SteelBeamDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(width: 60, height: 2, color: const Color(0xFFF5A623)),
        const SizedBox(width: 8),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFF5A623).withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(width: 8),
        Container(width: 60, height: 2, color: const Color(0xFFF5A623)),
      ],
    );
  }
}

class _ConstructionProgressBar extends StatelessWidget {
  final double progress;
  const _ConstructionProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 10,
      decoration: BoxDecoration(
        color: const Color(0xFF0D1F3C),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: const Color(0xFF1E3A5F), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(1),
        child: Stack(
          children: [
            FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE8960A), Color(0xFFF5C842)],
                  ),
                ),
                child: CustomPaint(painter: _HatchPainter()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HatchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.15)
      ..strokeWidth = 3;
    const spacing = 10.0;
    for (double x = -size.height; x < size.width + size.height; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x + size.height, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}



class _CraneWidget extends StatelessWidget {
  final double height;
  const _CraneWidget({required this.height});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(90, height),
      painter: _CranePainter(),
    );
  }
}

class _CranePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF5A623).withValues(alpha: 0.55)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final thinPaint = Paint()
      ..color = const Color(0xFFF5A623).withValues(alpha: 0.35)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Vertical mast
    canvas.drawLine(Offset(size.width * 0.6, size.height),
        Offset(size.width * 0.6, size.height * 0.1), paint);

    // Horizontal jib (arm)
    canvas.drawLine(Offset(size.width * 0.6, size.height * 0.12),
        Offset(0, size.height * 0.12), paint);

    // Counter-jib
    canvas.drawLine(Offset(size.width * 0.6, size.height * 0.12),
        Offset(size.width, size.height * 0.18), thinPaint);

    // Support cables from tip
    canvas.drawLine(Offset(0, size.height * 0.12),
        Offset(size.width * 0.6, size.height * 0.05), thinPaint);

    // Hook line
    canvas.drawLine(Offset(size.width * 0.15, size.height * 0.12),
        Offset(size.width * 0.15, size.height * 0.38), thinPaint);

    // Hook
    final hookPaint = Paint()
      ..color = const Color(0xFFF5A623).withValues(alpha: 0.55)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width * 0.15, size.height * 0.41),
        width: 12,
        height: 12,
      ),
      0,
      math.pi,
      false,
      hookPaint,
    );

    // Mast cross-hatching
    for (int i = 0; i < 6; i++) {
      final y = size.height * (0.2 + i * 0.13);
      canvas.drawLine(
        Offset(size.width * 0.54, y),
        Offset(size.width * 0.66, y + 14),
        thinPaint,
      );
      canvas.drawLine(
        Offset(size.width * 0.66, y),
        Offset(size.width * 0.54, y + 14),
        thinPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BlueprintGridPainter extends CustomPainter {
  final double progress;
  _BlueprintGridPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final majorPaint = Paint()
      ..color = const Color(0xFF1A3A6B).withValues(alpha: 0.5 * progress)
      ..strokeWidth = 0.8;
    final minorPaint = Paint()
      ..color = const Color(0xFF1A3A6B).withValues(alpha: 0.22 * progress)
      ..strokeWidth = 0.4;

    const majorSpacing = 60.0;
    const minorSpacing = 15.0;

    // Draw animated reveal - lines appear from top to bottom
    final revealHeight = size.height * progress;

    // Minor grid
    for (double x = 0; x < size.width; x += minorSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, revealHeight), minorPaint);
    }
    for (double y = 0; y < revealHeight; y += minorSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), minorPaint);
    }

    // Major grid
    for (double x = 0; x < size.width; x += majorSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, revealHeight), majorPaint);
    }
    for (double y = 0; y < revealHeight; y += majorSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), majorPaint);
    }

    // Corner coordinates (blueprint style)
    if (progress > 0.8) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'REV.A  SC-001',
          style: TextStyle(
            fontSize: 9,
            color: const Color(0xFF2A5A8B).withValues(alpha: (progress - 0.8) * 5),
            letterSpacing: 1.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(12, size.height - 24));
    }
  }

  @override
  bool shouldRepaint(_BlueprintGridPainter old) => old.progress != progress;
}

class _BottomBadge extends StatelessWidget {
  const _BottomBadge();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFF5A623),
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'ENTERPRISE GRADE  ·  ISO 9001  ·  SECURED',
          style: TextStyle(
            fontSize: 9,
            color: Color(0xFF3A5F80),
            letterSpacing: 2,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFF5A623),
          ),
        ),
      ],
    );
  }
}

