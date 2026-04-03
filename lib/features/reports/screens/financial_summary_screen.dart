import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:construction_app/core/theme/aesthetic_tokens.dart';
import 'package:construction_app/data/repositories/ledger_repository.dart';
import 'package:construction_app/data/repositories/milestone_repository.dart';
import 'package:construction_app/data/repositories/site_repository.dart';
import 'package:construction_app/shared/widgets/professional_page.dart';

// ── Palette ───────────────────────────────────────────────────────────────────
const _kSurface  = Colors.white;
const _kBorder   = Color(0xFFEAEDF3);
const _kNavy     = Color(0xFF0F1F3D);
const _kNavyMid  = Color(0xFF1E3A5F);
const _kGreen    = Color(0xFF12B76A);
const _kGreenBg  = Color(0xFFECFDF5);
const _kRed      = Color(0xFFF04438);
const _kRedBg    = Color(0xFFFFF1F0);
const _kAmber    = Color(0xFFF79009);
const _kAmberBg  = Color(0xFFFFFAEB);
const _kText     = Color(0xFF101828);
const _kMuted    = Color(0xFF667085);

class FinancialSummaryScreen extends StatefulWidget {
  const FinancialSummaryScreen({super.key});

  @override
  State<FinancialSummaryScreen> createState() =>
      _FinancialSummaryScreenState();
}

class _FinancialSummaryScreenState extends State<FinancialSummaryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  int _touchedPie = -1;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 480));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ledger     = context.watch<LedgerRepository>();
    final milestones = context.watch<MilestoneRepository>();
    final sites      = context.watch<SiteRepository>().sites;
    final fmt        = NumberFormat.currency(
        locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    final totalCredit = ledger.entries
        .where((e) => e.isCredit)
        .fold(0.0, (s, e) => s + e.amount);
    final totalDebit = ledger.entries
        .where((e) => !e.isCredit)
        .fold(0.0, (s, e) => s + e.amount);
    final net       = totalCredit - totalDebit;
    final surplus   = net >= 0;

    return ProfessionalPage(
      title:    'P&L Overview',
      subtitle: 'Net ${surplus ? "Surplus" : "Deficit"}: ${fmt.format(net.abs())}',
      category: 'FINANCIAL SUMMARY',
      headerStats: [
        HeroStatPill(label: 'Credits',        value: fmt.format(totalCredit),               color: bcSuccess, icon: Icons.call_received_rounded),
        HeroStatPill(label: 'Debits',         value: fmt.format(totalDebit),                color: bcDanger,  icon: Icons.call_made_rounded),
        HeroStatPill(label: 'Milestone Due',  value: fmt.format(milestones.getTotalUnpaid()), color: bcAmber,   icon: Icons.flag_rounded),
      ],
      children: [
        FadeTransition(
          opacity: _fade,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Receivable ───────────────────────────────────────────
                _ReceivableCard(
                  value:   fmt.format(ledger.getTotalReceivable()),
                  net:     net,
                  surplus: surplus,
                  fmt:     fmt,
                ),
                const SizedBox(height: 28),

                // ── Chart ────────────────────────────────────────────────
                if (totalCredit > 0 || totalDebit > 0) ...[
                  _SectionLabel(title: 'Credit vs Debit'),
                  const SizedBox(height: 12),
                  _DonutCard(
                    credit:       totalCredit,
                    debit:        totalDebit,
                    fmt:          fmt,
                    touchedIndex: _touchedPie,
                    onTouch:      (i) => setState(() => _touchedPie = i),
                  ),
                  const SizedBox(height: 28),
                ],

                // ── Sites ────────────────────────────────────────────────
                if (sites.isNotEmpty) ...[
                  _SectionLabel(
                    title: 'Site-wise Breakdown',
                    badge: '${sites.length} sites',
                  ),
                  const SizedBox(height: 12),
                  ...sites.asMap().entries.map((entry) {
                    final i    = entry.key;
                    final site = entry.value;
                    final sc   = ledger.entries.where((e) => e.siteId == site.id &&  e.isCredit).fold(0.0, (s, e) => s + e.amount);
                    final sd   = ledger.entries.where((e) => e.siteId == site.id && !e.isCredit).fold(0.0, (s, e) => s + e.amount);
                    final sn   = sc - sd;
                    final sm   = milestones.getMilestonesForSite(site.id).where((m) => !m.isPaid).fold(0.0, (s, m) => s + m.amount);
                    return _SiteCard(
                      key:         ValueKey(site.id),
                      index:       i,
                      name:        site.name,
                      credit:      sc,
                      debit:       sd,
                      net:         sn,
                      milestones:  sm,
                      fmt:         fmt,
                    );
                  }),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section Label
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String title;
  final String? badge;
  const _SectionLabel({required this.title, this.badge});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 3, height: 18,
            decoration: BoxDecoration(color: _kNavy, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(
                color: _kText, fontWeight: FontWeight.w800,
                fontSize: 15, letterSpacing: -0.2)),
        if (badge != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: const Color(0xFFF2F4F7),
                borderRadius: BorderRadius.circular(20)),
            child: Text(badge!,
                style: const TextStyle(
                    color: _kMuted, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Receivable Card  (dark navy)
// ─────────────────────────────────────────────────────────────────────────────

class _ReceivableCard extends StatelessWidget {
  final String value;
  final double net;
  final bool surplus;
  final NumberFormat fmt;
  const _ReceivableCard(
      {required this.value,
      required this.net,
      required this.surplus,
      required this.fmt});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _kNavy,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: _kNavy.withValues(alpha: 0.22),
              blurRadius: 20,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Stack(children: [
        // decorative circles
        Positioned(right: -24, top: -24,
            child: _Circle(120, Colors.white.withValues(alpha: 0.04))),
        Positioned(right: 28, bottom: -28,
            child: _Circle(80, const Color(0xFF2563EB).withValues(alpha: 0.14))),

        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(13)),
              child: const Icon(Icons.account_balance_wallet_rounded,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Total Receivable',
                    style: TextStyle(
                        color: Colors.white60, fontSize: 12,
                        fontWeight: FontWeight.w600, letterSpacing: 0.3)),
                const SizedBox(height: 6),
                Text(value,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w900,
                        fontSize: 26, letterSpacing: -1)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (surplus ? _kGreen : _kRed).withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Net ${surplus ? "+" : ""}${fmt.format(net)}',
                    style: TextStyle(
                        color: surplus
                            ? const Color(0xFF6EE7B7)
                            : const Color(0xFFFCA5A5),
                        fontSize: 11,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ]),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _Circle extends StatelessWidget {
  final double size;
  final Color color;
  const _Circle(this.size, this.color);
  @override
  Widget build(BuildContext context) => Container(
      width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color));
}

// ─────────────────────────────────────────────────────────────────────────────
// Donut Chart Card
// ─────────────────────────────────────────────────────────────────────────────

class _DonutCard extends StatelessWidget {
  final double credit, debit;
  final NumberFormat fmt;
  final int touchedIndex;
  final ValueChanged<int> onTouch;

  const _DonutCard({
    required this.credit,
    required this.debit,
    required this.fmt,
    required this.touchedIndex,
    required this.onTouch,
  });

  @override
  Widget build(BuildContext context) {
    final total      = credit + debit;
    final creditPct  = total > 0 ? credit / total * 100 : 0.0;
    final debitPct   = total > 0 ? debit  / total * 100 : 0.0;
    final cpStr      = creditPct.toStringAsFixed(1);
    final dpStr      = debitPct.toStringAsFixed(1);

    // Center label
    String centerVal;
    Color  centerColor;
    String centerSub;
    if (touchedIndex == 1) {
      centerVal   = '$dpStr%'; centerColor = _kRed;   centerSub = 'Debit';
    } else {
      centerVal   = '$cpStr%'; centerColor = _kGreen; centerSub = 'Credit';
    }

    return Container(
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kBorder),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        Row(children: [
          // Donut
          SizedBox(
            width: 148, height: 148,
            child: Stack(alignment: Alignment.center, children: [
              PieChart(PieChartData(
                sectionsSpace:     4,
                centerSpaceRadius: 44,
                startDegreeOffset: -90,
                pieTouchData: PieTouchData(
                  touchCallback: (_, resp) => onTouch(
                      resp?.touchedSection?.touchedSectionIndex ?? -1),
                ),
                sections: [
                  PieChartSectionData(
                    value:  credit,
                    color:  _kGreen,
                    title:  '',
                    radius: touchedIndex == 0 ? 38 : 30,
                  ),
                  PieChartSectionData(
                    value:  debit,
                    color:  _kRed,
                    title:  '',
                    radius: touchedIndex == 1 ? 38 : 30,
                  ),
                ],
              )),
              Column(mainAxisSize: MainAxisSize.min, children: [
                Text(centerVal,
                    style: TextStyle(
                        color: centerColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 19)),
                Text(centerSub,
                    style: const TextStyle(color: _kMuted, fontSize: 10)),
              ]),
            ]),
          ),

          const SizedBox(width: 20),

          // Legend
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _LegendRow(
                color: _kGreen, bg: _kGreenBg,
                label: 'Credits', value: fmt.format(credit),
                pct: '$cpStr%',   active: touchedIndex == 0,
              ),
              Container(height: 1, color: _kBorder,
                  margin: const EdgeInsets.symmetric(vertical: 10)),
              _LegendRow(
                color: _kRed,   bg: _kRedBg,
                label: 'Debits', value: fmt.format(debit),
                pct: '$dpStr%', active: touchedIndex == 1,
              ),
            ]),
          ),
        ]),

        const SizedBox(height: 18),

        // Ratio bar
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Credit ratio',
                style: TextStyle(color: _kMuted, fontSize: 11, fontWeight: FontWeight.w500)),
            Text('$cpStr%',
                style: const TextStyle(color: _kText, fontSize: 11, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 8,
              child: Row(children: [
                Flexible(
                  flex: (creditPct * 10).round(),
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Color(0xFF34D399), _kGreen])),
                  ),
                ),
                Flexible(
                  flex: (debitPct * 10).round(),
                  child: Container(color: const Color(0xFFFFE4E4)),
                ),
              ]),
            ),
          ),
        ]),
      ]),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color, bg;
  final String label, value, pct;
  final bool active;
  const _LegendRow({
    required this.color, required this.bg,
    required this.label, required this.value,
    required this.pct,   required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: active ? bg : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(children: [
        Container(width: 10, height: 10,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label,
              style: TextStyle(
                  color: active ? color : _kMuted,
                  fontSize: 12, fontWeight: FontWeight.w600)),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(value,
              style: TextStyle(
                  color: active ? color : _kText,
                  fontSize: 12, fontWeight: FontWeight.w800)),
          Text(pct,
              style: TextStyle(
                  color: color.withValues(alpha: 0.65),
                  fontSize: 10, fontWeight: FontWeight.w600)),
        ]),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Site Card
// ─────────────────────────────────────────────────────────────────────────────

class _SiteCard extends StatefulWidget {
  final int    index;
  final String name;
  final double credit, debit, net, milestones;
  final NumberFormat fmt;

  const _SiteCard({
    super.key,
    required this.index,
    required this.name,
    required this.credit,
    required this.debit,
    required this.net,
    required this.milestones,
    required this.fmt,
  });

  @override
  State<_SiteCard> createState() => _SiteCardState();
}

class _SiteCardState extends State<_SiteCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _fade;
  late Animation<Offset>   _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 420));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: 60 * widget.index),
        () { if (mounted) _ctrl.forward(); });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final surplus = widget.net >= 0;
    final total   = widget.credit + widget.debit;
    final ratio   = total > 0 ? widget.credit / total : 0.5;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _kBorder),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12, offset: const Offset(0, 3)),
            ],
          ),
          child: Column(children: [

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF2F4F7),
                      borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.domain_rounded,
                      color: _kNavyMid, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(widget.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 14,
                          color: _kText, letterSpacing: -0.2)),
                ),
                // Net chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: surplus ? _kGreenBg : _kRedBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(
                      surplus
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      color: surplus ? _kGreen : _kRed, size: 13),
                    const SizedBox(width: 4),
                    Text(
                      '${surplus ? "+" : ""}${widget.fmt.format(widget.net)}',
                      style: TextStyle(
                          color: surplus ? _kGreen : _kRed,
                          fontWeight: FontWeight.w800, fontSize: 12)),
                  ]),
                ),
              ]),
            ),

            // Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  height: 6,
                  child: Row(children: [
                    Flexible(
                      flex: (ratio * 1000).round(),
                      child: Container(color: _kGreen)),
                    Flexible(
                      flex: ((1 - ratio) * 1000).round(),
                      child: Container(color: const Color(0xFFFFE4E4))),
                  ]),
                ),
              ),
            ),

            // Stats
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
              child: Row(children: [
                _Stat(label: 'Credits',        value: widget.fmt.format(widget.credit),     color: _kGreen, bg: _kGreenBg, icon: Icons.call_received_rounded),
                const SizedBox(width: 8),
                _Stat(label: 'Debits',         value: widget.fmt.format(widget.debit),      color: _kRed,   bg: _kRedBg,   icon: Icons.call_made_rounded),
                const SizedBox(width: 8),
                _Stat(label: 'Milestones Due', value: widget.fmt.format(widget.milestones), color: _kAmber, bg: _kAmberBg, icon: Icons.flag_rounded),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label, value;
  final Color  color, bg;
  final IconData icon;
  const _Stat({required this.label, required this.value,
    required this.color, required this.bg, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
            color: bg, borderRadius: BorderRadius.circular(10)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, color: color.withValues(alpha: 0.7), size: 11),
            const SizedBox(width: 4),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      color: color.withValues(alpha: 0.75), fontSize: 9,
                      fontWeight: FontWeight.w700, letterSpacing: 0.2),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ]),
          const SizedBox(height: 5),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.w900),
              maxLines: 1, overflow: TextOverflow.ellipsis),
        ]),
      ),
    );
  }
}