import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:construction_app/core/theme/aesthetic_tokens.dart';
import 'package:construction_app/data/models/labour_entry_model.dart';
import 'package:construction_app/data/repositories/labour_repository.dart';
import 'package:construction_app/data/repositories/site_repository.dart';
import 'package:construction_app/core/routing/app_router.dart';

/// Contractor List Screen — backed by the existing LabourRepository and
/// LabourEntryModel. This is a new, cleaner UI over the same data layer;
/// the old LabourListScreen is kept for backward compatibility in the router.
class ContractorListScreen extends StatefulWidget {
  const ContractorListScreen({super.key});

  @override
  State<ContractorListScreen> createState() => _ContractorListScreenState();
}

class _ContractorListScreenState extends State<ContractorListScreen>
    with SingleTickerProviderStateMixin {
  String _search = '';
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labourRepo = context.watch<LabourRepository>();
    final siteRepo   = context.watch<SiteRepository>();
    final siteId     = siteRepo.selectedSiteId;
    final fmt        = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    List<LabourEntryModel> all = siteId != null
        ? labourRepo.getEntriesForSite(siteId)
        : labourRepo.entries;

    if (_search.isNotEmpty) {
      all = all.where((e) => e.partyName.toLowerCase().contains(_search.toLowerCase())).toList();
    }

    final active   = all.where((e) => e.status == LabourStatus.ongoing).toList();
    final due      = all.where((e) => e.pendingAmount > 0 && e.status != LabourStatus.settled).toList();
    final complete = all.where((e) => e.status == LabourStatus.completed || e.status == LabourStatus.settled).toList();

    final totalPending = labourRepo.getTotalPending(siteId: siteId);

    return Scaffold(
      backgroundColor: bcSurface,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SmartConstructionSliverAppBar(
            title: 'Contractors',
            subtitle: siteId != null ? 'Site Workforce Management' : 'Global Contractor Console',
            category: 'LABOUR MANAGEMENT',
            actions: [
               IconButton(
                icon: const Icon(Icons.analytics_outlined, color: bcAmber),
                onPressed: () {},
              )
            ],
            headerStats: [
               HeroStatPill(
                  label: 'TOTAL DUE',
                  value: fmt.format(totalPending),
                  icon: Icons.payments_rounded,
                  color: totalPending > 0 ? bcDanger : bcSuccess,
               ),
               HeroStatPill(
                  label: 'ACTIVE',
                  value: '${active.length}',
                  icon: Icons.engineering_rounded,
                  color: bcInfo,
               ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Container(
                color: Colors.transparent,
                child: TabBar(
                  controller: _tabCtrl,
                  indicatorColor: bcAmber,
                  indicatorWeight: 4,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelColor: bcAmber,
                  unselectedLabelColor: Colors.white.withValues(alpha: 0.5),
                  labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
                  tabs: [
                    Tab(text: 'ACTIVE (${active.length})'),
                    Tab(text: 'DUE (${due.length})'),
                    Tab(text: 'DONE (${complete.length})'),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: bcSurface,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: _SearchBar(onChanged: (v) => setState(() => _search = v)),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            _ContractorTab(entries: active, fmt: fmt),
            _ContractorTab(entries: due, fmt: fmt, highlightPending: true),
            _ContractorTab(entries: complete, fmt: fmt),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.labourEntry),
        backgroundColor: bcAmber,
        foregroundColor: bcNavy,
        icon: const Icon(Icons.handyman_rounded),
        label: const Text('Add Contractor', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
    );
  }
}

// ─── Tab Contents ─────────────────────────────────────────────────────────────

class _ContractorTab extends StatelessWidget {
  final List<LabourEntryModel> entries;
  final NumberFormat fmt;
  final bool highlightPending;

  const _ContractorTab({required this.entries, required this.fmt, this.highlightPending = false});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const _EmptyContractor();
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
      physics: const BouncingScrollPhysics(),
      itemCount: entries.length,
      itemBuilder: (_, i) => _ContractorCard(
        entry: entries[i],
        fmt: fmt,
        highlightPending: highlightPending,
        onTap: () => Navigator.pushNamed(context, AppRoutes.labourDetail, arguments: entries[i].id),
      ),
    );
  }
}

class _EmptyContractor extends StatelessWidget {
  const _EmptyContractor();

  @override
  Widget build(BuildContext context) => const Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.handyman_outlined, size: 60, color: Color(0xFFCBD5E1)),
      SizedBox(height: 14),
      Text('No contractors here', style: TextStyle(color: bcNavy, fontWeight: FontWeight.w800, fontSize: 16)),
      SizedBox(height: 6),
      Text('Use the button below to add a contractor', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
    ]),
  );
}

// ─── Contractor Card ──────────────────────────────────────────────────────────

class _ContractorCard extends StatelessWidget {
  final LabourEntryModel entry;
  final NumberFormat fmt;
  final bool highlightPending;
  final VoidCallback onTap;

  const _ContractorCard({required this.entry, required this.fmt, this.highlightPending = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(entry.status);
    final workTypeLabel = _workTypeLabel(entry.workType);
    final hasPending = entry.pendingAmount > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: bcNavy.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 10)),
        ],
        border: Border.all(
          color: (hasPending && highlightPending) 
              ? bcDanger.withValues(alpha: 0.4) 
              : bcBorder.withValues(alpha: 0.5)
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 52, height: 52,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [statusColor.withValues(alpha: 0.1), statusColor.withValues(alpha: 0.05)],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: statusColor.withValues(alpha: 0.15)),
                      ),
                      child: Center(
                        child: Text(
                          entry.partyName.isNotEmpty ? entry.partyName[0].toUpperCase() : 'C',
                          style: TextStyle(color: statusColor, fontWeight: FontWeight.w900, fontSize: 22),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry.partyName,
                              style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: -0.4)),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              StatusPill(label: workTypeLabel, color: bcInfo),
                              const SizedBox(width: 8),
                              StatusPill(label: _statusLabel(entry.status), color: statusColor),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1)),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: bcSurface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _AmountItem('CONTRACT', fmt.format(entry.totalContractAmount), bcNavy),
                      _AmountItem('PAID', fmt.format(entry.totalAdvancePaid), bcSuccess),
                      _AmountItem('PENDING', fmt.format(entry.pendingAmount), hasPending ? bcDanger : bcTextSecondary),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _statusColor(LabourStatus s) {
    switch (s) {
      case LabourStatus.ongoing:   return bcInfo;
      case LabourStatus.completed: return bcSuccess;
      case LabourStatus.settled:   return const Color(0xFF64748B);
    }
  }

  String _statusLabel(LabourStatus s) {
    switch (s) {
      case LabourStatus.ongoing:   return 'ONGOING';
      case LabourStatus.completed: return 'DONE';
      case LabourStatus.settled:   return 'SETTLED';
    }
  }

  String _workTypeLabel(LabourWorkType t) {
    switch (t) {
      case LabourWorkType.fixedContract: return 'Fixed';
      case LabourWorkType.perSqFt:       return 'Sq.Ft';
      case LabourWorkType.perDay:         return 'Daily';
      case LabourWorkType.perUnit:        return 'Unit';
    }
  }
}

class _AmountItem extends StatelessWidget {
  final String label, value;
  final Color color;
  const _AmountItem(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
      const SizedBox(height: 2),
      Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: -0.2)),
    ],
  );
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag(this.label, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(5)),
    child: Text(label, style: TextStyle(color: color, fontSize: 9.5, fontWeight: FontWeight.w700)),
  );
}

class _AmountPair extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _AmountPair(this.label, this.value, {this.color = bcNavy});

  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 12)),
    const SizedBox(height: 1),
    Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 9.5, fontWeight: FontWeight.w500)),
  ]);
}

class _SearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) => Container(
    height: 56,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: bcBorder.withValues(alpha: 0.8)),
      boxShadow: [
        BoxShadow(color: bcNavy.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4)),
      ],
    ),
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: [
        const Icon(Icons.search_rounded, color: bcAmber, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            onChanged: onChanged,
            style: const TextStyle(fontSize: 15, color: bcNavy, fontWeight: FontWeight.w600),
            decoration: const InputDecoration(
              hintText: 'Filter contractors by name...',
              border: InputBorder.none,
              hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14, fontWeight: FontWeight.w400),
              isDense: false,
              contentPadding: EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    ),
  );
}
