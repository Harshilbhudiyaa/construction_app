import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import 'package:construction_app/data/models/user_model.dart';
import 'package:construction_app/data/repositories/auth_repository.dart';
import 'package:construction_app/features/auth/create_first_site_screen.dart';

// ─── Palette ──────────────────────────────────────────────────────────────────
const _kNavy    = Color(0xFF0A1628);
const _kAmber   = Color(0xFFF5A623);
const _kSurface = Color(0xFFF0F4F8);
const _kDanger  = Color(0xFFEF4444);
const _kCard    = Colors.white;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final _formKey    = GlobalKey<FormState>();
  final _nameCtrl   = TextEditingController();
  final _emailCtrl  = TextEditingController();
  final _passCtrl   = TextEditingController();
  final _confirmCtrl= TextEditingController();

  bool _loading      = false;
  bool _obscurePass  = true;
  bool _obscureConf  = true;
  UserRole _role     = UserRole.admin;

  late AnimationController _pageAnim;
  late AnimationController _gearAnim;
  late AnimationController _shakeAnim;
  late Animation<double>   _shakeOffset;

  @override
  void initState() {
    super.initState();
    _pageAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))..forward();
    _gearAnim = AnimationController(
        vsync: this, duration: const Duration(seconds: 8))..repeat();
    _shakeAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _shakeOffset = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _shakeAnim, curve: Curves.elasticIn));
  }

  @override
  void dispose() {
    _pageAnim.dispose();
    _gearAnim.dispose();
    _shakeAnim.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  // ── Actions ──────────────────────────────────────────────────────────────────

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      _shakeAnim.forward(from: 0);
      return;
    }
    setState(() => _loading = true);

    final error = await context.read<AuthRepository>().registerWithEmail(
          name: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
          role: _role,
        );

    if (!mounted) return;
    setState(() => _loading = false);

    if (error != null) {
      _showError(error);
      _shakeAnim.forward(from: 0);
    } else {
      // Registration successful — go to Create First Site onboarding
      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          pageBuilder: (_, anim, _) => const CreateFirstSiteScreen(),
          transitionsBuilder: (_, anim, _, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
        (_) => false,
      );
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(msg,
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

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kNavy,
      body: Stack(
        children: [
          // Blueprint grid background
          Positioned.fill(
            child: CustomPaint(painter: _BlueprintGridPainter()),
          ),

          // Rotating gear decorations
          Positioned(
            top: -60, left: -60,
            child: AnimatedBuilder(
              animation: _gearAnim,
              builder: (_, _) => Transform.rotate(
                angle: _gearAnim.value * 2 * math.pi,
                child: CustomPaint(
                    size: const Size(200, 200),
                    painter: _GearPainter(opacity: 0.06)),
              ),
            ),
          ),
          Positioned(
            bottom: -80, right: -80,
            child: AnimatedBuilder(
              animation: _gearAnim,
              builder: (_, _) => Transform.rotate(
                angle: -_gearAnim.value * 2 * math.pi,
                child: CustomPaint(
                    size: const Size(250, 250),
                    painter: _GearPainter(opacity: 0.05, teeth: 14)),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 32),
                    AnimatedBuilder(
                      animation: _shakeOffset,
                      builder: (_, child) => Transform.translate(
                        offset: Offset(
                          math.sin(_shakeOffset.value * math.pi * 8) *
                              6 * (1 - _shakeOffset.value),
                          0,
                        ),
                        child: child,
                      ),
                      child: AnimatedBuilder(
                        animation: _pageAnim,
                        builder: (_, child) => Opacity(
                          opacity: _pageAnim.value,
                          child: Transform.translate(
                              offset: Offset(0, 20 * (1 - _pageAnim.value)),
                              child: child),
                        ),
                        child: _buildFormCard(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: Colors.white38, size: 16),
                      label: const Text(
                        'BACK TO LOGIN',
                        style: TextStyle(
                            color: Colors.white38,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            letterSpacing: 1.5),
                      ),
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

  // ── Header ────────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Column(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 900),
          curve: Curves.elasticOut,
          builder: (_, v, child) =>
              Transform.scale(scale: v, child: child),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: _kAmber.withValues(alpha: 0.2), width: 2),
                ),
              ),
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _kAmber,
                  boxShadow: [
                    BoxShadow(
                        color: _kAmber.withValues(alpha: 0.4),
                        blurRadius: 24,
                        spreadRadius: 4),
                  ],
                ),
                child: const Icon(Icons.construction_rounded,
                    size: 38, color: _kNavy),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'JOIN SMARTCONSTRUCTION',
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 4),
        ),
        const SizedBox(height: 6),
        const Text(
          'CREATE YOUR WORKSPACE ACCOUNT',
          style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: _kAmber,
              letterSpacing: 2),
        ),
      ],
    );
  }

  // ── Form Card ─────────────────────────────────────────────────────────────────

  Widget _buildFormCard() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 40,
              offset: const Offset(0, 16)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          _CardHeaderAccent(title: 'Create Account', subtitle: 'Fill in your details to get started'),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Full Name
                  _buildFieldLabel('FULL NAME'),
                  const SizedBox(height: 8),
                  _SmartField(
                    controller: _nameCtrl,
                    label: 'Your name',
                    icon: Icons.person_outline_rounded,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 16),

                  // Email
                  _buildFieldLabel('EMAIL ADDRESS'),
                  const SizedBox(height: 8),
                  _SmartField(
                    controller: _emailCtrl,
                    label: 'example@company.com',
                    icon: Icons.email_rounded,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Email is required';
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password
                  _buildFieldLabel('PASSWORD'),
                  const SizedBox(height: 8),
                  _SmartField(
                    controller: _passCtrl,
                    label: 'Min. 6 characters',
                    icon: Icons.lock_outline_rounded,
                    obscureText: _obscurePass,
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscurePass
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          color: _kNavy.withValues(alpha: 0.35),
                          size: 18),
                      onPressed: () =>
                          setState(() => _obscurePass = !_obscurePass),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Password is required';
                      if (v.length < 6) return 'At least 6 characters required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password
                  _buildFieldLabel('CONFIRM PASSWORD'),
                  const SizedBox(height: 8),
                  _SmartField(
                    controller: _confirmCtrl,
                    label: 'Re-enter your password',
                    icon: Icons.lock_rounded,
                    obscureText: _obscureConf,
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscureConf
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          color: _kNavy.withValues(alpha: 0.35),
                          size: 18),
                      onPressed: () =>
                          setState(() => _obscureConf = !_obscureConf),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Please confirm your password';
                      if (v != _passCtrl.text) return 'Passwords do not match';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Role Selector
                  _buildFieldLabel('YOUR ROLE'),
                  const SizedBox(height: 10),
                  _buildRoleSelector(),
                  const SizedBox(height: 28),

                  // CTA
                  _CTAButton(
                    loading: _loading,
                    label: 'CREATE ACCOUNT',
                    icon: Icons.rocket_launch_rounded,
                    onTap: _handleRegister,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: _kNavy,
          letterSpacing: 2),
    );
  }

  Widget _buildRoleSelector() {
    final roles = [
      (UserRole.admin, Icons.admin_panel_settings_rounded, 'Admin'),
      (UserRole.manager, Icons.manage_accounts_rounded, 'Manager'),
      (UserRole.siteEngineer, Icons.engineering_rounded, 'Engineer'),
      (UserRole.storekeeper, Icons.inventory_2_rounded, 'Store Keeper'),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: roles.map((r) {
        final isSelected = _role == r.$1;
        return GestureDetector(
          onTap: () => setState(() => _role = r.$1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? _kAmber.withValues(alpha: 0.12)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? _kAmber
                    : Colors.grey.withValues(alpha: 0.2),
                width: isSelected ? 2 : 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(r.$2,
                    size: 16,
                    color: isSelected ? _kAmber : Colors.grey[500]),
                const SizedBox(width: 6),
                Text(
                  r.$3,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? _kNavy : Colors.grey[500]),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Sub-Widgets ───────────────────────────────────────────────────────────────

class _CardHeaderAccent extends StatelessWidget {
  final String title, subtitle;
  const _CardHeaderAccent({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 18),
      decoration: const BoxDecoration(
        color: _kNavy,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _BlueprintGridPainter(opacity: 0.3)),
          ),
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: _kAmber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: _kAmber.withValues(alpha: 0.4), width: 1),
                ),
                child: const Icon(Icons.construction_rounded,
                    color: _kAmber, size: 20),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          letterSpacing: 0.3)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmartField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _SmartField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
  });

  @override
  State<_SmartField> createState() => _SmartFieldState();
}

class _SmartFieldState extends State<_SmartField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (f) => setState(() => _focused = f),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _focused ? _kNavy.withValues(alpha: 0.04) : _kSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _focused
                ? _kAmber.withValues(alpha: 0.6)
                : const Color(0xFFDDE3ED),
            width: _focused ? 2 : 1.5,
          ),
          boxShadow: _focused
              ? [BoxShadow(
                  color: _kAmber.withValues(alpha: 0.12), blurRadius: 10)]
              : [],
        ),
        child: TextFormField(
          controller: widget.controller,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          style: const TextStyle(
              fontWeight: FontWeight.w700, color: _kNavy, fontSize: 15),
          decoration: InputDecoration(
            hintText: widget.label,
            hintStyle: TextStyle(
                color: Colors.grey[400], fontWeight: FontWeight.w500, fontSize: 14),
            prefixIcon: Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: _focused
                    ? _kAmber.withValues(alpha: 0.12)
                    : _kNavy.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(widget.icon,
                  color: _focused ? _kAmber : const Color(0xFF94A3B8),
                  size: 18),
            ),
            suffixIcon: widget.suffixIcon,
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          validator: widget.validator,
        ),
      ),
    );
  }
}

class _CTAButton extends StatelessWidget {
  final bool loading;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _CTAButton({
    required this.loading,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Container(
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
            onTap: loading ? null : onTap,
            borderRadius: BorderRadius.circular(14),
            splashColor: Colors.black.withValues(alpha: 0.1),
            child: Center(
              child: loading
                  ? const SizedBox(
                      width: 22, height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(_kNavy)))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, color: _kNavy, size: 18),
                        const SizedBox(width: 10),
                        Text(label,
                            style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                color: _kNavy,
                                fontSize: 14,
                                letterSpacing: 1.5)),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Painters ──────────────────────────────────────────────────────────────────

class _BlueprintGridPainter extends CustomPainter {
  final double opacity;
  _BlueprintGridPainter({this.opacity = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    final minor = Paint()
      ..color = const Color(0xFF1A3A6B).withValues(alpha: 0.15 * opacity)
      ..strokeWidth = 0.35;
    final major = Paint()
      ..color = const Color(0xFF1A3A6B).withValues(alpha: 0.4 * opacity)
      ..strokeWidth = 0.7;

    for (double x = 0; x < size.width; x += 15) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), minor);
    }
    for (double y = 0; y < size.height; y += 15) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), minor);
    }
    for (double x = 0; x < size.width; x += 60) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), major);
    }
    for (double y = 0; y < size.height; y += 60) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), major);
    }
  }

  @override
  bool shouldRepaint(covariant _BlueprintGridPainter old) =>
      old.opacity != opacity;
}

class _GearPainter extends CustomPainter {
  final double opacity;
  final int teeth;
  _GearPainter({required this.opacity, this.teeth = 10});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _kAmber.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);
    final outerR = size.width * 0.45;
    final innerR = outerR * 0.72;
    final toothH = outerR - innerR;
    final step    = (2 * math.pi) / teeth;

    final path = Path();
    for (int i = 0; i < teeth; i++) {
      final a0 = i * step - step * 0.3;
      final a1 = i * step + step * 0.3;
      final a2 = i * step + step * 0.7;
      final a3 = (i + 1) * step - step * 0.3;

      final p0 = center + Offset(math.cos(a0) * innerR, math.sin(a0) * innerR);
      final p1 = center + Offset(math.cos(a1) * outerR, math.sin(a1) * outerR);
      final p2 = center + Offset(math.cos(a2) * outerR, math.sin(a2) * outerR);
      final p3 = center + Offset(math.cos(a3) * innerR, math.sin(a3) * innerR);

      i == 0 ? path.moveTo(p0.dx, p0.dy) : path.lineTo(p0.dx, p0.dy);
      path..lineTo(p1.dx, p1.dy)..lineTo(p2.dx, p2.dy)..lineTo(p3.dx, p3.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
    canvas.drawCircle(center, innerR * 0.35, paint);
  }

  @override
  bool shouldRepaint(covariant _GearPainter old) =>
      old.opacity != opacity || old.teeth != teeth;
}
