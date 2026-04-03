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
      appBar: AppBar(
        backgroundColor: bcNavy,
        foregroundColor: Colors.white,
        title: const Text('Contractors', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
        actions: [
          if (totalPending > 0)
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: bcDanger.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
              child: Text('Due: ${fmt.format(totalPending)}',
                  style: const TextStyle(color: bcDanger, fontWeight: FontWeight.w800, fontSize: 11)),
            ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: bcAmber,
          indicatorWeight: 3,
          labelColor: bcAmber,
          unselectedLabelColor: Colors.white54,
          labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
          tabs: [
            Tab(text: 'Active (${active.length})'),
            Tab(text: 'Due (${due.length})'),
            Tab(text: 'Done (${complete.length})'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: _SearchBar(onChanged: (v) => setState(() => _search = v)),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _ContractorTab(entries: active, fmt: fmt),
                _ContractorTab(entries: due, fmt: fmt, highlightPending: true),
                _ContractorTab(entries: complete, fmt: fmt),
              ],
            ),
          ),
        ],
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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasPending && highlightPending
                ? bcDanger.withValues(alpha: 0.35)
                : const Color(0xFFE2E8F0),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.025), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                    child: Center(
                      child: Text(
                        entry.partyName.isNotEmpty ? entry.partyName[0].toUpperCase() : 'C',
                        style: TextStyle(color: statusColor, fontWeight: FontWeight.w900, fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(entry.partyName,
                            style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w800, fontSize: 14)),
                        const SizedBox(height: 3),
                        Row(children: [
                          _Tag(workTypeLabel, const Color(0xFF60A5FA)),
                          const SizedBox(width: 6),
                          _Tag(entry.workDescription.isNotEmpty
                              ? (entry.workDescription.length > 20 ? '${entry.workDescription.substring(0, 20)}…' : entry.workDescription)
                              : 'General Work', const Color(0xFFF59E0B)),
                        ]),
                      ],
                    ),
                  ),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(_statusLabel(entry.status),
                        style: TextStyle(color: statusColor, fontSize: 9.5, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ),
            // Bottom row: amounts
            Container(
              margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: bcSurface, borderRadius: BorderRadius.circular(10)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _AmountPair('Contract', fmt.format(entry.totalContractAmount)),
                  _AmountPair('Paid', fmt.format(entry.totalAdvancePaid), color: bcSuccess),
                  _AmountPair('Pending', fmt.format(entry.pendingAmount),
                      color: hasPending ? bcDanger : const Color(0xFF94A3B8)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(LabourStatus s) {
    switch (s) {
      case LabourStatus.ongoing:   return bcInfo;
      case LabourStatus.completed: return bcSuccess;
      case LabourStatus.settled:   return const Color(0xFF94A3B8);
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
      case LabourWorkType.perSqFt:       return 'Per Sq.Ft';
      case LabourWorkType.perDay:         return 'Per Day';
      case LabourWorkType.perUnit:        return 'Per Unit';
    }
  }
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
    height: 40,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: bcSurface, borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: Row(children: [
      const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 18),
      const SizedBox(width: 8),
      Expanded(
        child: TextField(
          onChanged: onChanged,
          style: const TextStyle(fontSize: 13, color: bcNavy),
          decoration: const InputDecoration(
            hintText: 'Search contractors…', border: InputBorder.none,
            hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            contentPadding: EdgeInsets.zero, isDense: true,
          ),
        ),
      ),
    ]),
  );
}
