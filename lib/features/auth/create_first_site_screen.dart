import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:construction_app/data/models/site_model.dart';
import 'package:construction_app/data/repositories/site_repository.dart';
import 'package:construction_app/features/dashboard/contractor_shell.dart';

// ─── Palette ──────────────────────────────────────────────────────────────────
const _kNavy   = Color(0xFF0A1628);
const _kAmber  = Color(0xFFF5A623);
const _kSurface= Color(0xFFF0F4F8);
const _kCard   = Colors.white;
const _kDanger = Color(0xFFEF4444);

class CreateFirstSiteScreen extends StatefulWidget {
  const CreateFirstSiteScreen({super.key});

  @override
  State<CreateFirstSiteScreen> createState() => _CreateFirstSiteScreenState();
}

class _CreateFirstSiteScreenState extends State<CreateFirstSiteScreen>
    with TickerProviderStateMixin {

  final _formKey      = GlobalKey<FormState>();
  final _nameCtrl     = TextEditingController();
  final _addressCtrl  = TextEditingController();
  final _clientCtrl   = TextEditingController();
  final _budgetCtrl   = TextEditingController();

  bool _loading       = false;
  bool _hasBudget     = false;
  SiteStatus _status  = SiteStatus.active;
  DateTime? _startDate;

  late AnimationController _bgAnim;
  late AnimationController _cardAnim;
  late AnimationController _gearAnim;
  late Animation<double> _bgFade;
  late Animation<double> _cardSlide;
  late Animation<double> _cardFade;

  @override
  void initState() {
    super.initState();

    _bgAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))..forward();
    _cardAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _gearAnim = AnimationController(
        vsync: this, duration: const Duration(seconds: 12))..repeat();

    _bgFade   = CurvedAnimation(parent: _bgAnim, curve: Curves.easeIn);
    _cardSlide= Tween<double>(begin: 60, end: 0).animate(
        CurvedAnimation(parent: _cardAnim, curve: Curves.easeOutCubic));
    _cardFade = CurvedAnimation(parent: _cardAnim, curve: Curves.easeOut);

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _cardAnim.forward();
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _clientCtrl.dispose();
    _budgetCtrl.dispose();
    _bgAnim.dispose();
    _cardAnim.dispose();
    _gearAnim.dispose();
    super.dispose();
  }

  // ── Actions ──────────────────────────────────────────────────────────────────

  Future<void> _createSite() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final siteId = const Uuid().v4();
    final now    = DateTime.now();

    final data = <String, dynamic>{
      'id':              siteId,
      'name':            _nameCtrl.text.trim(),
      'address':         _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
      'clientName':      _clientCtrl.text.trim().isEmpty  ? null : _clientCtrl.text.trim(),
      'startDate':       (_startDate ?? now).toIso8601String(),
      'status':          SiteStatus.active.name,
      'hasBudget':       _hasBudget,
      'budgetAmount':    _hasBudget && _budgetCtrl.text.isNotEmpty
                           ? double.tryParse(_budgetCtrl.text.replaceAll(',', ''))
                           : null,
      'createdAt':       FieldValue.serverTimestamp(),
      'updatedAt':       FieldValue.serverTimestamp(),
    };

    try {
      // Write DIRECTLY to Firestore — no stream delay
      await FirebaseFirestore.instance
          .collection('sites')
          .doc(siteId)
          .set(data);

      // Also notify the local repository
      if (mounted) {
        context.read<SiteRepository>().getSiteName(siteId); // triggers refresh
      }

      if (!mounted) return;

      // Navigate to Dashboard
      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          pageBuilder: (_, anim, _) => const ContractorShell(),
          transitionsBuilder: (_, anim, _, child) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.04, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
              child: child,
            ),
          ),
          transitionDuration: const Duration(milliseconds: 500),
        ),
        (_) => false,
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);

      // Show user-friendly Firestore error
      String msg;
      if (e.code == 'permission-denied') {
        msg = '❌ Permission Denied!\n\nGo to Firebase Console → Firestore → Rules → Publish the rules shown in the setup guide.';
      } else if (e.code == 'unavailable') {
        msg = '❌ No internet connection. Please check your network and try again.';
      } else {
        msg = '❌ Firestore error: [${e.code}] ${e.message}';
      }

      _showError(msg);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showError('❌ Unexpected error: $e');
    }
  }

  void _showError(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Could Not Create Site',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        content: Text(msg,
            style: const TextStyle(fontSize: 13, height: 1.6, color: Color(0xFF374151))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK',
                style: TextStyle(color: Color(0xFF0A1628), fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }


  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _kNavy,
            onPrimary: Colors.white,
            secondary: _kAmber,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kNavy,
      body: Stack(
        children: [
          // Blueprint grid
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bgFade,
              builder: (_, _) => CustomPaint(
                painter: _GridPainter(opacity: _bgFade.value),
              ),
            ),
          ),

          // Rotating gear top-right
          Positioned(
            top: -40, right: -40,
            child: AnimatedBuilder(
              animation: _gearAnim,
              builder: (_, _) => Transform.rotate(
                angle: _gearAnim.value * 2 * math.pi,
                child: CustomPaint(
                  size: const Size(180, 180),
                  painter: _GearPainter(opacity: 0.08),
                ),
              ),
            ),
          ),

          // Bottom-left gear
          Positioned(
            bottom: -60, left: -60,
            child: AnimatedBuilder(
              animation: _gearAnim,
              builder: (_, _) => Transform.rotate(
                angle: -_gearAnim.value * 2 * math.pi,
                child: CustomPaint(
                  size: const Size(220, 220),
                  painter: _GearPainter(opacity: 0.05, teeth: 14),
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 32),
                      AnimatedBuilder(
                        animation: _cardAnim,
                        builder: (_, child) => Opacity(
                          opacity: _cardFade.value,
                          child: Transform.translate(
                            offset: Offset(0, _cardSlide.value),
                            child: child,
                          ),
                        ),
                        child: _buildCard(),
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

  // ── Header ────────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Column(
      children: [
        // Step badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          decoration: BoxDecoration(
            color: _kAmber.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: _kAmber.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_rounded, color: _kAmber, size: 14),
              const SizedBox(width: 8),
              const Text(
                'Account Created  →  Setup Your First Site',
                style: TextStyle(
                    color: _kAmber,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Icon
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 900),
          curve: Curves.elasticOut,
          builder: (_, v, child) =>
              Transform.scale(scale: v.clamp(0.0, 1.0), child: child),
          child: Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _kAmber,
              boxShadow: [
                BoxShadow(
                    color: _kAmber.withValues(alpha: 0.35),
                    blurRadius: 24, spreadRadius: 4),
              ],
            ),
            child: const Icon(Icons.domain_add_rounded, size: 40, color: _kNavy),
          ),
        ),
        const SizedBox(height: 18),

        const Text(
          'Create Your First Site',
          style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Add your construction project details to get started',
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ── Card ──────────────────────────────────────────────────────────────────────

  Widget _buildCard() {
    return Container(
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.28),
              blurRadius: 40,
              offset: const Offset(0, 20)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 18),
            decoration: const BoxDecoration(color: _kNavy),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _kAmber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _kAmber.withValues(alpha: 0.4)),
                  ),
                  child: const Icon(Icons.construction_rounded,
                      color: _kAmber, size: 20),
                ),
                const SizedBox(width: 14),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Site Details',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 16)),
                    SizedBox(height: 2),
                    Text('Fill in basic information about your project',
                        style: TextStyle(
                            color: Colors.white38,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),

          // Form body
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Site Name (required)
                  _label('SITE / PROJECT NAME *'),
                  const SizedBox(height: 8),
                  _Field(
                    controller: _nameCtrl,
                    hint: 'e.g. Hillview Apartment Block A',
                    icon: Icons.apartment_rounded,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Site name is required' : null,
                  ),
                  const SizedBox(height: 16),

                  // Address (optional)
                  _label('SITE ADDRESS'),
                  const SizedBox(height: 8),
                  _Field(
                    controller: _addressCtrl,
                    hint: 'Street, City, State',
                    icon: Icons.location_on_rounded,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),

                  // Client Name (optional)
                  _label('CLIENT NAME'),
                  const SizedBox(height: 8),
                  _Field(
                    controller: _clientCtrl,
                    hint: 'e.g. Mr. Ramesh Patel',
                    icon: Icons.person_rounded,
                  ),
                  const SizedBox(height: 16),

                  // Start Date
                  _label('START DATE'),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: _kSurface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: const Color(0xFFDDE3ED), width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: _kNavy.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.calendar_today_rounded,
                                color: Color(0xFF94A3B8), size: 18),
                          ),
                          Text(
                            _startDate == null
                                ? 'Select start date (optional)'
                                : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                            style: TextStyle(
                              color: _startDate == null
                                  ? Colors.grey[400]
                                  : _kNavy,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Budget toggle
                  _label('PROJECT BUDGET'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _hasBudget = !_hasBudget),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 48, height: 26,
                          decoration: BoxDecoration(
                            color: _hasBudget ? _kAmber : Colors.grey[300],
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: AnimatedAlign(
                            duration: const Duration(milliseconds: 200),
                            alignment: _hasBudget
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.all(3),
                              width: 20, height: 20,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _hasBudget ? 'Budget set' : 'No budget (skip)',
                        style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                            fontSize: 13),
                      ),
                    ],
                  ),
                  if (_hasBudget) ...[
                    const SizedBox(height: 12),
                    _Field(
                      controller: _budgetCtrl,
                      hint: 'e.g. 5000000',
                      icon: Icons.currency_rupee_rounded,
                      keyboardType: TextInputType.number,
                      prefix: '₹ ',
                    ),
                  ],
                  const SizedBox(height: 28),

                  // Create Site Button
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE8960A), _kAmber, Color(0xFFFFC85A)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: _kAmber.withValues(alpha: 0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8)),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _loading ? null : _createSite,
                          borderRadius: BorderRadius.circular(16),
                          splashColor: Colors.black.withValues(alpha: 0.1),
                          child: Center(
                            child: _loading
                                ? const SizedBox(
                                    width: 24, height: 24,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor: AlwaysStoppedAnimation<Color>(_kNavy)),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.rocket_launch_rounded,
                                          color: _kNavy, size: 20),
                                      SizedBox(width: 12),
                                      Text(
                                        'CREATE SITE & OPEN DASHBOARD',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            color: _kNavy,
                                            fontSize: 13,
                                            letterSpacing: 1),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Tip
                  Center(
                    child: Text(
                      '💡 You can add more sites later from the dashboard',
                      style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 11,
                          fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: _kNavy,
            letterSpacing: 2),
      );
}

// ─── Reusable Field Widget ────────────────────────────────────────────────────

class _Field extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final String? prefix;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.hint,
    required this.icon,
    this.prefix,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  @override
  State<_Field> createState() => _FieldState();
}

class _FieldState extends State<_Field> {
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
            color: _focused ? _kAmber.withValues(alpha: 0.7) : const Color(0xFFDDE3ED),
            width: _focused ? 2 : 1.5,
          ),
          boxShadow: _focused
              ? [BoxShadow(color: _kAmber.withValues(alpha: 0.12), blurRadius: 12)]
              : [],
        ),
        child: TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          maxLines: widget.maxLines,
          style: const TextStyle(
              fontWeight: FontWeight.w700, color: _kNavy, fontSize: 14),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(
                color: Colors.grey[400],
                fontWeight: FontWeight.w500,
                fontSize: 13),
            prefixText: widget.prefix,
            prefixStyle: const TextStyle(color: _kNavy, fontWeight: FontWeight.w700),
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
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          ),
          validator: widget.validator,
        ),
      ),
    );
  }
}

// ─── Painters ─────────────────────────────────────────────────────────────────

class _GridPainter extends CustomPainter {
  final double opacity;
  _GridPainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final minor = Paint()
      ..color = const Color(0xFF1A3A6B).withValues(alpha: 0.15 * opacity)
      ..strokeWidth = 0.35;
    final major = Paint()
      ..color = const Color(0xFF1A3A6B).withValues(alpha: 0.4 * opacity)
      ..strokeWidth = 0.7;

    for (double x = 0; x < size.width; x += 15)
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), minor);
    for (double y = 0; y < size.height; y += 15)
      canvas.drawLine(Offset(0, y), Offset(size.width, y), minor);
    for (double x = 0; x < size.width; x += 60)
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), major);
    for (double y = 0; y < size.height; y += 60)
      canvas.drawLine(Offset(0, y), Offset(size.width, y), major);
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.opacity != opacity;
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
    final step   = (2 * math.pi) / teeth;

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
  bool shouldRepaint(_GearPainter old) =>
      old.opacity != opacity || old.teeth != teeth;
}
