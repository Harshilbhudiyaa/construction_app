import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:construction_app/data/models/user_model.dart';
import 'package:construction_app/data/repositories/auth_repository.dart';
import 'package:construction_app/features/auth/register_screen.dart';
import 'package:construction_app/features/dashboard/contractor_shell.dart';
import 'package:construction_app/shared/widgets/sparkle_effect.dart';

// ─── Palette (mirrors splash/dashboard) ─────────────────────────────────────
const _kAmber = Color(0xFFF5A623);
const _kNavy = Color(0xFF0A1628);
const _kSteel = Color(0xFF1A3A6B);
const _kSuccess = Color(0xFF22C55E);
const _kDanger = Color(0xFFEF4444);
const _kCard = Colors.white;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final List<TextEditingController> _otpCtrl =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocus = List.generate(6, (_) => FocusNode());

  bool _loading = false;
  bool _showOTP = false;
  int _resendTimer = 30;
  bool _rememberMe = true;
  UserRole _selectedRole = UserRole.admin;
  bool _phoneFocused = false;

  // Animation controllers
  late AnimationController _bgController;   // blueprint grid draw-on
  late AnimationController _cardController; // card entrance
  late AnimationController _craneController; // crane swing
  late AnimationController _shakeController; // error shake

  late Animation<double> _bgAnim;
  late Animation<double> _logoAnim;
  late Animation<double> _cardAnim;
  late Animation<double> _craneAnim;
  late Animation<double> _shakeAnim;

  final _phoneFocusNode = FocusNode();

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

    _bgAnim = CurvedAnimation(parent: _bgController, curve: Curves.easeInOut);
    _logoAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _cardController, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)));
    _cardAnim = CurvedAnimation(parent: _cardController, curve: const Interval(0.4, 1.0, curve: Curves.easeOut));
    _craneAnim = Tween<double>(begin: -0.05, end: 0.05).animate(
        CurvedAnimation(parent: _craneController, curve: Curves.easeInOut));
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _shakeController, curve: Curves.elasticOut));

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _cardController.forward();
    });

    _phoneFocusNode.addListener(() {
      setState(() => _phoneFocused = _phoneFocusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _phoneFocusNode.dispose();
    for (var c in _otpCtrl) {
      c.dispose();
    }

    for (var f in _otpFocus) {
      f.dispose();
    }

    _bgController.dispose();
    _cardController.dispose();
    _craneController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() => _resendTimer = 30);
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _resendTimer--);
      return _resendTimer > 0;
    });
  }

  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) {
      _triggerShake();
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      setState(() {
        _loading = false;
        _showOTP = true;
      });
      _startResendTimer();
      _otpFocus[0].requestFocus();
      
      // Show demo OTP
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.mark_email_read_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              const Text('DEMO OTP: 123456', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
            ],
          ),
          backgroundColor: _kSuccess,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        ),
      );
    }
  }

  Future<void> _verifyOTP() async {
    final otp = _otpCtrl.map((c) => c.text).join();
    if (otp.length != 6) {
      _triggerShake();
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1200));

    if (mounted) {
      setState(() => _loading = false);
      final authService = context.read<AuthRepository>();
      try {
        // More resilient phone check for demo
        final phone = _phoneCtrl.text.replaceAll(RegExp(r'\D'), '');
        if (phone == '9999999999') {
          await authService.login(
            userId: _selectedRole.name.toLowerCase(),
            userName: '${_selectedRole.label} User',
            role: _selectedRole,
            persist: _rememberMe,
          );
          if (!mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            _buildRoute(const ContractorShell()),
            (_) => false,
          );
          return;
        }
        _showError('No account found. Try 9999999999');
        _triggerShake();
      } catch (e) {
        _showError('Authentication failed. Please retry.');
      }
    }
  }

  void _autoFillDemo() {
    const demoOtp = '123456';
    for (int i = 0; i < 6; i++) {
      _otpCtrl[i].text = demoOtp[i];
    }
    _verifyOTP();
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
            Text(msg, style: const TextStyle(fontWeight: FontWeight.w700)),
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
          position: Tween<Offset>(
                  begin: const Offset(0, 0.04), end: Offset.zero)
              .animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
          child: child,
        ),
      ),
      transitionDuration: const Duration(milliseconds: 500),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kNavy,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // ── Blueprint grid ──
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bgAnim,
              builder: (_, _) => CustomPaint(
                painter: _BlueprintPainter(progress: _bgAnim.value),
              ),
            ),
          ),

          // ── Crane (top-left) ──
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

          // ── Safety stripe top ──

          // ── Main scrollable content ──
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    children: [
                      // Logo
                      _buildLogo(),
                      const SizedBox(height: 60),

                      // Login card
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

  // ─── Logo ──────────────────────────────────────────────────────────────────

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: _logoAnim,
      builder: (_, child) => Opacity(
        opacity: _logoAnim.value.clamp(0, 1),
        child: Transform.scale(
          scale: 0.6 + 0.4 * _logoAnim.value.clamp(0, 1),
          child: child,
        ),
      ),
      child: Column(
        children: [
          // Icon badge with sparkle particles
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
                        offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: _kAmber.withValues(alpha: 0.15),
                        blurRadius: 40,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Transform.scale(
                    scale: 1.15,
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.cover,
                      cacheWidth: 600,
                    ),
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
          // Divider with rivets
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 60, height: 2, color: _kAmber),
              const SizedBox(width: 8),
              Container(
                width: 8, height: 8,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: _kAmber),
              ),
              const SizedBox(width: 8),
              Container(width: 60, height: 2, color: _kAmber),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Card ──────────────────────────────────────────────────────────────────

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
            offset: const Offset(0, 20),
          ),
          BoxShadow(
            color: _kAmber.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card header
            _buildCardHeader(),
            const SizedBox(height: 24),

            // Fields with animated slide
            AnimatedBuilder(
              animation: _shakeAnim,
              builder: (_, child) => Transform.translate(
                offset: Offset(
                  math.sin(_shakeAnim.value * math.pi * 6) * 8 * (1 - _shakeAnim.value),
                  0,
                ),
                child: child,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, anim) => SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(_showOTP ? 0.12 : -0.12, 0),
                    end: Offset.zero,
                  ).animate(anim),
                  child: FadeTransition(opacity: anim, child: child),
                ),
                child: _showOTP
                    ? _buildOTPSection()
                    : _buildPhoneSection(),
              ),
            ),

            const SizedBox(height: 24),

            // Remember me
            _buildRememberMe(),
            const SizedBox(height: 20),

            // CTA button
            _buildCTAButton(),

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
              child: Icon(
                _showOTP ? Icons.lock_open_rounded : Icons.badge_rounded,
                color: _kAmber,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Column(
                key: ValueKey(_showOTP),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _showOTP ? 'Verify Identity' : 'Site Access',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: _kNavy,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    _showOTP
                        ? 'Enter the code (Demo: 123456)'
                        : 'Login with your registered number',
                    style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Steel beam divider
        Row(
          children: [
            Expanded(
              child: Container(height: 2, color: _kNavy.withValues(alpha: 0.07)),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: _kAmber),
            ),
            Expanded(
              child: Container(height: 2, color: _kNavy.withValues(alpha: 0.07)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhoneSection() {
    return Column(
      key: const ValueKey('phone'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const Text(
          'PHONE NUMBER',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: _kNavy,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _phoneFocused ? _kAmber : Colors.transparent,
              width: 2,
            ),
            boxShadow: _phoneFocused
                ? [BoxShadow(color: _kAmber.withValues(alpha: 0.15), blurRadius: 12)]
                : [],
          ),
          child: TextFormField(
            controller: _phoneCtrl,
            focusNode: _phoneFocusNode,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            style: const TextStyle(
                fontWeight: FontWeight.w800, color: _kNavy, fontSize: 16, letterSpacing: 2),
            decoration: InputDecoration(
              hintText: '98765 43210',
              hintStyle: TextStyle(color: Colors.grey[300], fontWeight: FontWeight.w500, letterSpacing: 1),
              prefixIcon: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.phone_iphone_rounded, color: _kNavy, size: 18),
                    SizedBox(width: 8),
                    Text(
                      '+91',
                      style: TextStyle(
                          fontWeight: FontWeight.w800, color: _kNavy, fontSize: 14),
                    ),
                    SizedBox(width: 8),
                    _VerticalDividerSmall(),
                  ],
                ),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 0),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Colors.transparent),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            ),
            validator: (v) => (v?.length == 10) ? null : 'Enter a valid 10-digit number',
          ),
        ),
        const SizedBox(height: 12),
        // Tip chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _kNavy.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _kNavy.withValues(alpha: 0.06)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded, size: 13, color: _kSteel),
              const SizedBox(width: 6),
              Text(
                'Use 9999999999 for demo access',
                style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOTPSection() {
    return Column(
      key: const ValueKey('otp'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sent-to badge
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _kSuccess.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _kSuccess.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_outline_rounded, color: _kSuccess, size: 15),
              const SizedBox(width: 8),
              Text(
                'Code sent to +91 ${_phoneCtrl.text}',
                style: const TextStyle(
                    fontSize: 12,
                    color: _kSuccess,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'ENTER ACCESS CODE',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: _kNavy,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),

        // OTP boxes
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (i) => _OTPBox(
            controller: _otpCtrl[i],
            focusNode: _otpFocus[i],
            onChanged: (v) {
              if (v.isNotEmpty && i < 5) _otpFocus[i + 1].requestFocus();
              if (v.isEmpty && i > 0) _otpFocus[i - 1].requestFocus();
              // Auto-submit
              if (i == 5 && v.isNotEmpty) _verifyOTP();
            },
          )),
        ),

        const SizedBox(height: 16),

        // Resend row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
        setState(() => _showOTP = false);
              },
              child: Row(
                children: [
                  const Icon(Icons.arrow_back_ios_new_rounded, size: 11, color: _kSteel),
                  const SizedBox(width: 4),
                  Text('Change number',
                      style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _resendTimer > 0
                  ? Text(
                      'Resend in ${_resendTimer}s',
                      key: const ValueKey('timer'),
                      style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 11,
                          fontWeight: FontWeight.w700),
                    )
                  : GestureDetector(
                      onTap: () {
                        _startResendTimer();
                        // re-trigger OTP send
                      },
                      child: const Text(
                        'Resend Code',
                        key: ValueKey('resend'),
                        style: TextStyle(
                            color: _kAmber,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            decoration: TextDecoration.underline,
                            decorationColor: _kAmber),
                      ),
                    ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Center(
          child: InkWell(
            onTap: _autoFillDemo,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.flash_on_rounded, size: 14, color: _kAmber),
                  const SizedBox(width: 6),
                  const Text(
                    'AUTO-FILL FOR DEMO',
                    style: TextStyle(
                      color: _kAmber,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
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
                color: _rememberMe ? _kAmber : Colors.grey.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: _rememberMe
                ? const Icon(Icons.check, size: 13, color: _kNavy)
                : null,
          ),
          const SizedBox(width: 10),
          Text(
            'Keep me logged in',
            style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildCTAButton() {
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
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _loading ? null : (_showOTP ? _verifyOTP : _sendOTP),
            borderRadius: BorderRadius.circular(14),
            splashColor: Colors.black.withValues(alpha: 0.1),
            child: Center(
              child: _loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(_kNavy),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _showOTP ? Icons.verified_rounded : Icons.send_rounded,
                          color: _kNavy,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _showOTP ? 'ENTER DASHBOARD' : 'GET ACCESS CODE',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: _kNavy,
                            fontSize: 14,
                            letterSpacing: 1.5,
                          ),
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
            _FooterBadge(label: 'ISO 9001', icon: Icons.verified_rounded),
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

// ─── Sub-Widgets ──────────────────────────────────────────────────────────────

class _OTPBox extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _OTPBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  State<_OTPBox> createState() => _OTPBoxState();
}

class _OTPBoxState extends State<_OTPBox> {
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(() {
      setState(() => _focused = widget.focusNode.hasFocus);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 44,
      height: 52,
      decoration: BoxDecoration(
        color: _focused ? _kAmber.withValues(alpha: 0.06) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _focused ? _kAmber : Colors.grey.withValues(alpha: 0.18),
          width: _focused ? 2 : 1.5,
        ),
        boxShadow: _focused
            ? [BoxShadow(color: _kAmber.withValues(alpha: 0.18), blurRadius: 10)]
            : [],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(
            fontSize: 20, fontWeight: FontWeight.w900, color: _kNavy),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: widget.onChanged,
      ),
    );
  }
}

class _VerticalDividerSmall extends StatelessWidget {
  const _VerticalDividerSmall();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 18,
      color: Colors.grey.withValues(alpha: 0.2),
    );
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
        Text(
          label,
          style: const TextStyle(
              color: Colors.white24,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5),
        ),
      ],
    );
  }
}

// ─── Painters ─────────────────────────────────────────────────────────────────

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

    // Mast
    canvas.drawLine(
        Offset(size.width * 0.55, size.height),
        Offset(size.width * 0.55, size.height * 0.05), p);
    // Jib
    canvas.drawLine(
        Offset(size.width * 0.55, size.height * 0.1),
        Offset(0, size.height * 0.1), p);
    // Counter-jib
    canvas.drawLine(
        Offset(size.width * 0.55, size.height * 0.1),
        Offset(size.width, size.height * 0.2), thin);
    // Cable
    canvas.drawLine(
        Offset(size.width * 0.18, size.height * 0.1),
        Offset(size.width * 0.18, size.height * 0.45), thin);
    // Hook
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(size.width * 0.18, size.height * 0.48),
          width: 10, height: 10),
      0, math.pi, false, p,
    );
    // Mast cross-hatch
    for (int i = 0; i < 5; i++) {
      final y = size.height * (0.2 + i * 0.14);
      canvas.drawLine(
          Offset(size.width * 0.49, y),
          Offset(size.width * 0.61, y + 14), thin);
      canvas.drawLine(
          Offset(size.width * 0.61, y),
          Offset(size.width * 0.49, y + 14), thin);
    }
    // Support cable from tip to mast top
    canvas.drawLine(
        Offset(0, size.height * 0.1),
        Offset(size.width * 0.55, size.height * 0.03), thin);
  }

  @override
  bool shouldRepaint(covariant _CranePainter old) => old.opacity != opacity;
}


