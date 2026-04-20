import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:construction_app/data/repositories/auth_repository.dart';
import 'package:construction_app/features/auth/register_screen.dart';
import 'package:construction_app/features/dashboard/contractor_shell.dart';
import 'package:construction_app/shared/widgets/sparkle_effect.dart';

// ─── Palette ──────────────────────────────────────────────────────────────────
const _kAmber  = Color(0xFFF5A623);
const _kNavy   = Color(0xFF0A1628);
const _kSteel  = Color(0xFF1A3A6B);
const _kSuccess = Color(0xFF22C55E);
const _kDanger = Color(0xFFEF4444);
const _kCard   = Colors.white;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _loading       = false;
  bool _obscurePass   = true;
  bool _rememberMe    = true;
  bool _emailFocused  = false;
  bool _passFocused   = false;

  late AnimationController _bgController;
  late AnimationController _cardController;
  late AnimationController _craneController;
  late AnimationController _shakeController;

  late Animation<double> _bgAnim;
  late Animation<double> _logoAnim;
  late Animation<double> _cardAnim;
  late Animation<double> _craneAnim;
  late Animation<double> _shakeAnim;

  final _emailFocusNode = FocusNode();
  final _passFocusNode  = FocusNode();

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1600))
      ..forward();

    _cardController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));

    _craneController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2800))
      ..repeat(reverse: true);

    _shakeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));

    _bgAnim   = CurvedAnimation(parent: _bgController, curve: Curves.easeInOut);
    _logoAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _cardController,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOut)));
    _cardAnim = CurvedAnimation(parent: _cardController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut));
    _craneAnim = Tween<double>(begin: -0.05, end: 0.05).animate(
        CurvedAnimation(parent: _craneController, curve: Curves.easeInOut));
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _shakeController, curve: Curves.elasticOut));

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _cardController.forward();
    });

    _emailFocusNode.addListener(
        () => setState(() => _emailFocused = _emailFocusNode.hasFocus));
    _passFocusNode.addListener(
        () => setState(() => _passFocused = _passFocusNode.hasFocus));
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _emailFocusNode.dispose();
    _passFocusNode.dispose();
    _bgController.dispose();
    _cardController.dispose();
    _craneController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  // ── Actions ──────────────────────────────────────────────────────────────────

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) {
      _triggerShake();
      return;
    }
    setState(() => _loading = true);

    final error = await context.read<AuthRepository>().signInWithEmail(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        );

    if (!mounted) return;
    setState(() => _loading = false);

    if (error != null) {
      _showError(error);
      _triggerShake();
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        _buildRoute(const ContractorShell()),
        (_) => false,
      );
    }
  }

  void _triggerShake() {
    _shakeController.reset();
    _shakeController.forward();
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
                child: Text(msg,
                    style: const TextStyle(fontWeight: FontWeight.w700))),
          ],
        ),
        backgroundColor: _kDanger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  PageRouteBuilder _buildRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, anim, _) => page,
      transitionsBuilder: (_, anim, _, child) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
              .animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
          child: child,
        ),
      ),
      transitionDuration: const Duration(milliseconds: 500),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kNavy,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Blueprint grid background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bgAnim,
              builder: (_, _) => CustomPaint(
                painter: _BlueprintPainter(progress: _bgAnim.value),
              ),
            ),
          ),

          // Swaying crane
          Positioned(
            top: 0,
            left: -10,
            child: AnimatedBuilder(
              animation: _craneAnim,
              builder: (_, _) => Transform(
                alignment: const Alignment(0.6, -1),
                transform: Matrix4.rotationZ(_craneAnim.value),
                child: CustomPaint(
                  size: const Size(100, 200),
                  painter: _CranePainter(opacity: 0.22),
                ),
              ),
            ),
          ),

          // Main scrollable content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    children: [
                      _buildLogo(),
                      const SizedBox(height: 48),
                      AnimatedBuilder(
                        animation: _cardAnim,
                        builder: (_, child) => Opacity(
                          opacity: _cardAnim.value,
                          child: Transform.translate(
                            offset: Offset(0, 30 * (1 - _cardAnim.value)),
                            child: child,
                          ),
                        ),
                        child: _buildCard(),
                      ),
                      const SizedBox(height: 32),
                      _buildFooter(),
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

  // ── Logo ─────────────────────────────────────────────────────────────────────

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: _logoAnim,
      builder: (_, child) => Opacity(
        opacity: _logoAnim.value.clamp(0, 1),
        child: Transform.scale(
            scale: 0.6 + 0.4 * _logoAnim.value.clamp(0, 1), child: child),
      ),
      child: Column(
        children: [
          SparkleOverlay(
            particleCount: 18,
            sparkleColor: _kAmber,
            maxParticleSize: 2.0,
            child: SizedBox(
              width: 220,
              height: 220,
              child: Center(
                child: Container(
                  width: 160,
                  height: 160,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 30,
                          offset: const Offset(0, 10)),
                      BoxShadow(
                          color: _kAmber.withValues(alpha: 0.15),
                          blurRadius: 40,
                          spreadRadius: 4),
                    ],
                  ),
                  child: Transform.scale(
                    scale: 1.15,
                    child: Image.asset('assets/images/logo.png',
                        fit: BoxFit.cover, cacheWidth: 600),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 48),
          const Text(
            'SmartConstruction',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 2,
              height: 1,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 60, height: 2, color: _kAmber),
              const SizedBox(width: 8),
              Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: _kAmber)),
              const SizedBox(width: 8),
              Container(width: 60, height: 2, color: _kAmber),
            ],
          ),
        ],
      ),
    );
  }

  // ── Card ──────────────────────────────────────────────────────────────────────

  Widget _buildCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.28),
              blurRadius: 40,
              offset: const Offset(0, 20)),
          BoxShadow(
              color: _kAmber.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader(),
            const SizedBox(height: 24),

            AnimatedBuilder(
              animation: _shakeAnim,
              builder: (_, child) => Transform.translate(
                offset: Offset(
                    math.sin(_shakeAnim.value * math.pi * 6) *
                        8 *
                        (1 - _shakeAnim.value),
                    0),
                child: child,
              ),
              child: _buildFields(),
            ),

            const SizedBox(height: 20),
            _buildRememberMe(),
            const SizedBox(height: 20),
            _buildSignInButton(),
            const SizedBox(height: 18),

            // Register link
            Center(
              child: GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen())),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                    const Text(
                      'Register',
                      style: TextStyle(
                          color: _kNavy,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          decoration: TextDecoration.underline,
                          decorationColor: _kAmber),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _kAmber.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _kAmber.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.badge_rounded, color: _kAmber, size: 18),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Site Access',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: _kNavy,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'Sign in to your workspace',
                  style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: Container(height: 2, color: _kNavy.withValues(alpha: 0.07))),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              width: 5, height: 5,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: _kAmber),
            ),
            Expanded(child: Container(height: 2, color: _kNavy.withValues(alpha: 0.07))),
          ],
        ),
      ],
    );
  }

  Widget _buildFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Email ──
        const Text('EMAIL ADDRESS',
            style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w800,
                color: _kNavy, letterSpacing: 2)),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: _emailFocused ? _kAmber : Colors.transparent, width: 2),
            boxShadow: _emailFocused
                ? [BoxShadow(color: _kAmber.withValues(alpha: 0.15), blurRadius: 12)]
                : [],
          ),
          child: TextFormField(
            controller: _emailCtrl,
            focusNode: _emailFocusNode,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(
                fontWeight: FontWeight.w700, color: _kNavy, fontSize: 15),
            decoration: InputDecoration(
              hintText: 'example@company.com',
              hintStyle: TextStyle(color: Colors.grey[300], fontWeight: FontWeight.w500),
              prefixIcon: const Icon(Icons.email_rounded, color: _kNavy, size: 18),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.15))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Colors.transparent)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please enter your email';
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                return 'Enter a valid email address';
              }
              return null;
            },
          ),
        ),

        const SizedBox(height: 16),

        // ── Password ──
        const Text('PASSWORD',
            style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w800,
                color: _kNavy, letterSpacing: 2)),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: _passFocused ? _kAmber : Colors.transparent, width: 2),
            boxShadow: _passFocused
                ? [BoxShadow(color: _kAmber.withValues(alpha: 0.15), blurRadius: 12)]
                : [],
          ),
          child: TextFormField(
            controller: _passwordCtrl,
            focusNode: _passFocusNode,
            obscureText: _obscurePass,
            style: const TextStyle(
                fontWeight: FontWeight.w700, color: _kNavy, fontSize: 15),
            decoration: InputDecoration(
              hintText: '••••••••',
              hintStyle: TextStyle(color: Colors.grey[300]),
              prefixIcon: const Icon(Icons.lock_rounded, color: _kNavy, size: 18),
              suffixIcon: IconButton(
                icon: Icon(
                    _obscurePass
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: _kNavy.withValues(alpha: 0.4),
                    size: 18),
                onPressed: () => setState(() => _obscurePass = !_obscurePass),
              ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.15))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Colors.transparent)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please enter your password';
              if (v.length < 6) return 'Password must be at least 6 characters';
              return null;
            },
            onFieldSubmitted: (_) => _signIn(),
          ),
        ),
      ],
    );
  }

  Widget _buildRememberMe() {
    return GestureDetector(
      onTap: () => setState(() => _rememberMe = !_rememberMe),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: _rememberMe ? _kAmber : Colors.transparent,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                  color: _rememberMe
                      ? _kAmber
                      : Colors.grey.withValues(alpha: 0.3),
                  width: 2),
            ),
            child: _rememberMe
                ? const Icon(Icons.check, size: 13, color: _kNavy)
                : null,
          ),
          const SizedBox(width: 10),
          Text(
            'Keep me signed in',
            style: TextStyle(
                color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE8960A), _kAmber, Color(0xFFFFC85A)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: _kAmber.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 6)),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _loading ? null : _signIn,
            borderRadius: BorderRadius.circular(14),
            splashColor: Colors.black.withValues(alpha: 0.1),
            child: Center(
              child: _loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(_kNavy)),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.login_rounded, color: _kNavy, size: 18),
                        SizedBox(width: 10),
                        Text(
                          'SIGN IN',
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: _kNavy,
                              fontSize: 14,
                              letterSpacing: 1.5),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 20, height: 1, color: Colors.white12),
            const SizedBox(width: 10),
            const Text(
              'ENTERPRISE SECURE ACCESS',
              style: TextStyle(
                  color: Colors.white24,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2),
            ),
            const SizedBox(width: 10),
            Container(width: 20, height: 1, color: Colors.white12),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _FooterBadge(label: 'Firebase Auth', icon: Icons.verified_rounded),
            const SizedBox(width: 12),
            _FooterBadge(label: 'SSL Secured', icon: Icons.lock_rounded),
            const SizedBox(width: 12),
            _FooterBadge(label: 'v2.0', icon: Icons.info_outline_rounded),
          ],
        ),
      ],
    );
  }
}

// ─── Sub-Widgets ───────────────────────────────────────────────────────────────

class _VerticalDividerSmall extends StatelessWidget {
  const _VerticalDividerSmall();
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 18, color: Colors.grey.withValues(alpha: 0.2));
  }
}

class _FooterBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  const _FooterBadge({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 10, color: Colors.white24),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                color: Colors.white24,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5)),
      ],
    );
  }
}

// ─── Painters ──────────────────────────────────────────────────────────────────

class _BlueprintPainter extends CustomPainter {
  final double progress;
  const _BlueprintPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final major = Paint()
      ..color = const Color(0xFF1A3A6B).withValues(alpha: 0.45 * progress)
      ..strokeWidth = 0.7;
    final minor = Paint()
      ..color = const Color(0xFF1A3A6B).withValues(alpha: 0.18 * progress)
      ..strokeWidth = 0.35;

    final revealY = size.height * progress;
    for (double x = 0; x < size.width; x += 15) {
      canvas.drawLine(Offset(x, 0), Offset(x, revealY), minor);
    }
    for (double y = 0; y < revealY; y += 15) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), minor);
    }
    for (double x = 0; x < size.width; x += 60) {
      canvas.drawLine(Offset(x, 0), Offset(x, revealY), major);
    }
    for (double y = 0; y < revealY; y += 60) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), major);
    }
  }

  @override
  bool shouldRepaint(_BlueprintPainter old) => old.progress != progress;
}

class _CranePainter extends CustomPainter {
  final double opacity;
  const _CranePainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = _kAmber.withValues(alpha: opacity)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final thin = Paint()
      ..color = _kAmber.withValues(alpha: opacity * 0.6)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(size.width * 0.55, size.height),
        Offset(size.width * 0.55, size.height * 0.05), p);
    canvas.drawLine(Offset(size.width * 0.55, size.height * 0.1),
        Offset(0, size.height * 0.1), p);
    canvas.drawLine(Offset(size.width * 0.55, size.height * 0.1),
        Offset(size.width, size.height * 0.2), thin);
    canvas.drawLine(Offset(size.width * 0.18, size.height * 0.1),
        Offset(size.width * 0.18, size.height * 0.45), thin);
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(size.width * 0.18, size.height * 0.48),
          width: 10,
          height: 10),
      0, math.pi, false, p,
    );
    for (int i = 0; i < 5; i++) {
      final y = size.height * (0.2 + i * 0.14);
      canvas.drawLine(Offset(size.width * 0.49, y),
          Offset(size.width * 0.61, y + 14), thin);
      canvas.drawLine(Offset(size.width * 0.61, y),
          Offset(size.width * 0.49, y + 14), thin);
    }
    canvas.drawLine(Offset(0, size.height * 0.1),
        Offset(size.width * 0.55, size.height * 0.03), thin);
  }

  @override
  bool shouldRepaint(covariant _CranePainter old) => old.opacity != opacity;
}
