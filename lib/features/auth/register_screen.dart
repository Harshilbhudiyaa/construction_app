import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:construction_app/features/dashboard/contractor_shell.dart';

// ─── Palette (consistent with splash + dashboard) ────────────────────────────
const _kNavy = Color(0xFF0A1628);
const _kAmber = Color(0xFFF5A623);
const _kSurface = Color(0xFFF0F4F8);
const _kSuccess = Color(0xFF22C55E);
const _kCard = Colors.white;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _siteNameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _otpControllers = List.generate(6, (_) => TextEditingController());
  final _otpFocusNodes = List.generate(6, (_) => FocusNode());

  bool _loading = false;
  bool _showOTPField = false;
  int _resendTimer = 30;
  int _currentStep = 0; // 0=details, 1=project, 2=otp

  // Animation controllers
  late AnimationController _pageAnim;
  late AnimationController _gearAnim;
  late AnimationController _shakeAnim;
  late Animation<double> _shakeOffset;

  @override
  void initState() {
    super.initState();
    _pageAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..forward();

    _gearAnim = AnimationController(
        vsync: this, duration: const Duration(seconds: 8))
      ..repeat();

    _shakeAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _shakeOffset = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeAnim, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _pageAnim.dispose();
    _gearAnim.dispose();
    _shakeAnim.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _siteNameCtrl.dispose();
    _addressCtrl.dispose();
    for (var c in _otpControllers) {
      c.dispose();
    }
    for (var f in _otpFocusNodes) {
      f.dispose();
    }

    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      _shakeAnim.forward(from: 0);
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() {
      _loading = false;
      _showOTPField = true;
      _currentStep = 2;
      _resendTimer = 30;
    });
    _startResendTimer();
    _pageAnim.forward(from: 0);
    _otpFocusNodes[0].requestFocus();

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

  Future<void> _verifyOTP() async {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length != 6) {
      _shakeAnim.forward(from: 0);
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, anim, _) => const ContractorShell(),
          transitionsBuilder: (_, anim, _, child) => FadeTransition(
            opacity: anim,
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  void _autoFillDemo() {
    const demoOtp = '123456';
    for (int i = 0; i < 6; i++) {
      _otpControllers[i].text = demoOtp[i];
    }
    _verifyOTP();
  }

  void _startResendTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted || _resendTimer == 0) return;
      setState(() => _resendTimer--);
      _startResendTimer();
    });
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_nameCtrl.text.trim().isEmpty || _phoneCtrl.text.trim().isEmpty) {
        _shakeAnim.forward(from: 0);
        return;
      }
      _handleRegister();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kNavy,
      body: Stack(
        children: [
          // Blueprint grid
          Positioned.fill(
            child: CustomPaint(painter: _BlueprintGridPainter()),
          ),

          // Rotating gear bg decoration
          Positioned(
            top: -60,
            left: -60,
            child: AnimatedBuilder(
              animation: _gearAnim,
              builder: (_, _) => Transform.rotate(
                angle: _gearAnim.value * 2 * math.pi,
                child: CustomPaint(
                  size: const Size(200, 200),
                  painter: _GearPainter(opacity: 0.06),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -80,
            child: AnimatedBuilder(
              animation: _gearAnim,
              builder: (_, _) => Transform.rotate(
                angle: -_gearAnim.value * 2 * math.pi,
                child: CustomPaint(
                  size: const Size(250, 250),
                  painter: _GearPainter(opacity: 0.05, teeth: 14),
                ),
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
                    // Header badge
                    _buildHeader(),

                    const SizedBox(height: 32),

                    // Step indicator
                    _buildStepIndicator(),

                    const SizedBox(height: 28),

                    // Card
                    AnimatedBuilder(
                      animation: _shakeOffset,
                      builder: (_, child) => Transform.translate(
                        offset: Offset(
                          math.sin(_shakeOffset.value * math.pi * 8) * 6 * (1 - _shakeOffset.value),
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
                            child: child,
                          ),
                        ),
                        child: _buildFormCard(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Back to login
                    TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white38, size: 16),
                      label: const Text(
                        'BACK TO LOGIN',
                        style: TextStyle(
                          color: Colors.white38,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
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
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Animated logo ring
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 900),
          curve: Curves.elasticOut,
          builder: (_, v, child) => Transform.scale(scale: v, child: child),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer glow ring
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _kAmber.withValues(alpha: 0.2), width: 2),
                ),
              ),
              // Inner circle
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _kAmber,
                  boxShadow: [
                    BoxShadow(
                      color: _kAmber.withValues(alpha: 0.4),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(Icons.construction_rounded, size: 38, color: _kNavy),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'JOIN SMARTCONSTRUCTION',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 5,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'INDUSTRIAL MANAGEMENT NETWORK',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: _kAmber,
            letterSpacing: 2.5,
          ),
        ),
      ],
    );
  }

  Widget _buildStepIndicator() {
    final steps = ['Your Info', 'Verify'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          // Connector line
          final stepIdx = i ~/ 2;
          final done = _currentStep > stepIdx;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: 40,
            height: 2,
            color: done ? _kAmber : Colors.white12,
          );
        }
        final idx = i ~/ 2;
        final active = _currentStep == idx;
        final done = _currentStep > idx;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          width: active ? 36 : 30,
          height: active ? 36 : 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done
                ? _kSuccess
                : active
                    ? _kAmber
                    : Colors.white10,
            border: Border.all(
              color: active ? _kAmber : done ? _kSuccess : Colors.white12,
              width: 2,
            ),
            boxShadow: active
                ? [BoxShadow(color: _kAmber.withValues(alpha: 0.4), blurRadius: 10, spreadRadius: 2)]
                : done
                    ? [BoxShadow(color: _kSuccess.withValues(alpha: 0.3), blurRadius: 8)]
                    : [],
          ),
          child: Center(
            child: done
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                : Text(
                    '${idx + 1}',
                    style: TextStyle(
                      color: active ? _kNavy : Colors.white38,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
          ),
        );
      }),
    );
  }

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
            offset: const Offset(0, 16),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header accent
          _CardHeaderAccent(
            title: _showOTPField
                ? 'Identity Verification'
                : 'Your Details',
            subtitle: _showOTPField
                ? 'Enter the code (Demo: 123456)'
                : 'Personal information',
            step: _currentStep + 1,
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  if (!_showOTPField) ...[
                    _SmartConstructionField(
                      controller: _nameCtrl,
                      label: 'Full Name',
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 16),
                    _SmartConstructionField(
                      controller: _phoneCtrl,
                      label: 'Mobile Number',
                      icon: Icons.phone_iphone_rounded,
                      prefix: '+91 ',
                      type: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ] else ...[
                    _OTPRow(
                      controllers: _otpControllers,
                      focusNodes: _otpFocusNodes,
                    ),
                    const SizedBox(height: 16),
                    // Resend
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Didn\'t receive code? ',
                          style: TextStyle(color: Colors.grey[500], fontSize: 13),
                        ),
                        _resendTimer > 0
                            ? Text(
                                'Resend in ${_resendTimer}s',
                                style: const TextStyle(
                                    color: _kNavy,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13),
                              )
                            : GestureDetector(
                                onTap: () {
                                  setState(() => _resendTimer = 30);
                                  _startResendTimer();
                                },
                                child: const Text(
                                  'Resend OTP',
                                  style: TextStyle(
                                    color: _kAmber,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 28),

                  // CTA button
                  _CTAButton(
                    loading: _loading,
                    label: _showOTPField
                        ? 'VERIFY & JOIN'
                        : _currentStep == 0
                            ? 'NEXT STEP'
                            : 'SEND OTP',
                    icon: _showOTPField
                        ? Icons.verified_user_rounded
                        : _currentStep == 0
                            ? Icons.arrow_forward_rounded
                            : Icons.send_rounded,
                    onTap: _showOTPField ? _verifyOTP : _nextStep,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

class _CardHeaderAccent extends StatelessWidget {
  final String title, subtitle;
  final int step;

  const _CardHeaderAccent(
      {required this.title, required this.subtitle, required this.step});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 18),
      decoration: BoxDecoration(
        color: _kNavy,
        borderRadius: const BorderRadius.only(
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _kAmber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _kAmber.withValues(alpha: 0.4), width: 1),
                ),
                child: Center(
                  child: Text(
                    '0$step',
                    style: const TextStyle(
                      color: _kAmber,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmartConstructionField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? prefix;
  final TextInputType? type;
  final List<TextInputFormatter>? inputFormatters;

  const _SmartConstructionField({
    required this.controller,
    required this.label,
    required this.icon,
    this.prefix,
    this.type,
    this.inputFormatters,
  });

  @override
  State<_SmartConstructionField> createState() => _SmartConstructionFieldState();
}

class _SmartConstructionFieldState extends State<_SmartConstructionField> {
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
            color: _focused ? _kAmber.withValues(alpha: 0.6) : const Color(0xFFDDE3ED),
            width: _focused ? 2 : 1.5,
          ),
        ),
        child: TextFormField(
          controller: widget.controller,
          keyboardType: widget.type,
          maxLines: 1,
          inputFormatters: widget.inputFormatters,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: _kNavy,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            labelText: widget.label,
            labelStyle: TextStyle(
              color: _focused ? _kAmber : const Color(0xFF94A3B8),
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
            prefixText: widget.prefix,
            prefixStyle: const TextStyle(color: _kNavy, fontWeight: FontWeight.w700),
            prefixIcon: Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: _focused ? _kAmber.withValues(alpha: 0.12) : _kNavy.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(widget.icon,
                  color: _focused ? _kAmber : const Color(0xFF94A3B8), size: 18),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: (v) => (v != null && v.trim().isNotEmpty) ? null : 'Required',
        ),
      ),
    );
  }
}

class _OTPRow extends StatelessWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;

  const _OTPRow({required this.controllers, required this.focusNodes});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (i) {
        return _OTPBox(
          controller: controllers[i],
          focusNode: focusNodes[i],
          onChanged: (v) {
            if (v.isNotEmpty && i < 5) focusNodes[i + 1].requestFocus();
            if (v.isEmpty && i > 0) focusNodes[i - 1].requestFocus();
          },
        );
      }),
    );
  }
}

class _OTPBox extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _OTPBox(
      {required this.controller,
      required this.focusNode,
      required this.onChanged});

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
      duration: const Duration(milliseconds: 200),
      width: 44,
      height: 54,
      decoration: BoxDecoration(
        color: _focused ? _kNavy.withValues(alpha: 0.04) : _kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _focused ? _kAmber : const Color(0xFFDDE3ED),
          width: _focused ? 2.5 : 1.5,
        ),
        boxShadow: _focused
            ? [BoxShadow(color: _kAmber.withValues(alpha: 0.2), blurRadius: 10)]
            : [],
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w900,
          color: _kNavy,
          letterSpacing: 0,
        ),
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

class _CTAButton extends StatefulWidget {
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
  State<_CTAButton> createState() => _CTAButtonState();
}

class _CTAButtonState extends State<_CTAButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _press;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.97,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _press.reverse(),
      onTapUp: (_) {
        _press.forward();
        widget.onTap();
      },
      onTapCancel: () => _press.forward(),
      child: ScaleTransition(
        scale: _press,
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: widget.loading ? _kAmber.withValues(alpha: 0.7) : _kAmber,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: _kAmber.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: widget.loading
              ? const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(_kNavy),
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.label,
                      style: const TextStyle(
                        color: _kNavy,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _kNavy.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(widget.icon, color: _kNavy, size: 16),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ─── Painters ────────────────────────────────────────────────────────────────

class _BlueprintGridPainter extends CustomPainter {
  final double opacity;
  _BlueprintGridPainter({this.opacity = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    final major = Paint()
      ..color = const Color(0xFF1A3A6B).withValues(alpha: 0.45 * opacity)
      ..strokeWidth = 0.7;
    final minor = Paint()
      ..color = const Color(0xFF1A3A6B).withValues(alpha: 0.18 * opacity)
      ..strokeWidth = 0.3;

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

  _GearPainter({this.opacity = 0.08, this.teeth = 10});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final outerR = size.width * 0.46;
    final innerR = size.width * 0.34;
    final toothH = size.width * 0.10;
    final toothW = (2 * math.pi * outerR / teeth) * 0.4;

    final paint = Paint()
      ..color = _kAmber.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    final path = Path();
    for (int i = 0; i < teeth; i++) {
      final angle = 2 * math.pi * i / teeth;
      final nextAngle = 2 * math.pi * (i + 1) / teeth;
      final midAngle = (angle + nextAngle) / 2;

      // Inner arc start
      path.moveTo(cx + innerR * math.cos(angle - toothW / outerR),
          cy + innerR * math.sin(angle - toothW / outerR));
      // Tooth outer left
      path.lineTo(
          cx + (outerR + toothH) * math.cos(angle),
          cy + (outerR + toothH) * math.sin(angle));
      // Tooth top
      path.lineTo(
          cx + (outerR + toothH) * math.cos(midAngle - toothW / outerR),
          cy + (outerR + toothH) * math.sin(midAngle - toothW / outerR));
      path.lineTo(
          cx + (outerR + toothH) * math.cos(midAngle + toothW / outerR),
          cy + (outerR + toothH) * math.sin(midAngle + toothW / outerR));
      // Tooth outer right
      path.lineTo(
          cx + (outerR + toothH) * math.cos(nextAngle),
          cy + (outerR + toothH) * math.sin(nextAngle));
      // Inner arc
      path.lineTo(
          cx + innerR * math.cos(nextAngle + toothW / outerR),
          cy + innerR * math.sin(nextAngle + toothW / outerR));
    }
    path.close();
    canvas.drawPath(path, paint);

    // Center bore
    canvas.drawCircle(
      Offset(cx, cy),
      size.width * 0.12,
      Paint()..color = _kNavy.withValues(alpha: 0.8),
    );
  }

  @override
  bool shouldRepaint(covariant _GearPainter old) =>
      old.opacity != opacity || old.teeth != teeth;
}

