import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:construction_app/core/theme/aesthetic_tokens.dart';
import 'package:construction_app/data/repositories/labour_repository.dart';
import 'package:construction_app/data/repositories/site_repository.dart';
import 'package:construction_app/data/repositories/auth_repository.dart';
import 'package:construction_app/data/models/labour_entry_model.dart';
import 'package:construction_app/core/routing/app_router.dart';

class LabourListScreen extends StatefulWidget {
  const LabourListScreen({super.key});

  @override
  State<LabourListScreen> createState() => _LabourListScreenState();
}

class _LabourListScreenState extends State<LabourListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labourRepo = context.watch<LabourRepository>();
    final siteRepo = context.watch<SiteRepository>();
    final selectedSiteId = siteRepo.selectedSiteId;

    final allEntries = selectedSiteId == null
        ? labourRepo.entries
        : labourRepo.entries.where((e) => e.siteId == selectedSiteId).toList();

    final ongoing   = allEntries.where((e) => e.status == LabourStatus.ongoing).toList();
    final completed = allEntries.where((e) => e.status == LabourStatus.completed).toList();
    final settled   = allEntries.where((e) => e.status == LabourStatus.settled).toList();

    final totalContract = labourRepo.getTotalContractValue(siteId: selectedSiteId);
    final totalAdvance  = labourRepo.getTotalAdvancePaid(siteId: selectedSiteId);
    final totalPending  = labourRepo.getTotalPending(siteId: selectedSiteId);
    final needSettlement = labourRepo.getSettlementPendingCount(siteId: selectedSiteId);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          // ── AppBar ─────────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: bcNavy,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0F1F3D), Color(0xFF1E3A5F)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 44),
                        const Text(
                          'Labour & Contractors',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${allEntries.length} contract${allEntries.length != 1 ? 's' : ''} • ${siteRepo.selectedSite?.name ?? 'All Sites'}',
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: bcNavy,
                child: TabBar(
                  controller: _tabController,
                  labelColor: bcAmber,
                  unselectedLabelColor: Colors.white54,
                  indicatorColor: bcAmber,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 12),
                  tabs: [
                    Tab(text: 'ONGOING (${ongoing.length})'),
                    Tab(text: 'DONE (${completed.length})'),
                    Tab(text: 'SETTLED (${settled.length})'),
                  ],
                ),
              ),
            ),
          ),

          // ── Summary Cards ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Column(
                children: [
                  if (needSettlement > 0)
                    _AlertBanner(
                      text:
                          '$needSettlement contractor${needSettlement > 1 ? 's' : ''} awaiting final settlement',
                      onTap: () => _tabController.animateTo(1),
                    ),
                  const SizedBox(height: 12),
                  _SummaryRow(
                    items: [
                      _SumItem('Contract Value', _fmt.format(totalContract),
                          const Color(0xFF6366F1), Icons.handshake_rounded),
                      _SumItem('Advance Paid', _fmt.format(totalAdvance),
                          bcAmber, Icons.payments_rounded),
                      _SumItem('Pending', _fmt.format(totalPending),
                          const Color(0xFFF04438), Icons.pending_actions_rounded),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Tab Content ────────────────────────────────────────────────────
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _LabourListTab(entries: ongoing,   fmt: _fmt),
                _LabourListTab(entries: completed, fmt: _fmt, showSettlementBadge: true),
                _LabourListTab(entries: settled,   fmt: _fmt),
              ],
            ),
          ),
        ],
      ),

      // ── FAB ────────────────────────────────────────────────────────────────
      floatingActionButton: context.watch<AuthRepository>().canManageLabour
          ? FloatingActionButton.extended(
              backgroundColor: bcAmber,
              foregroundColor: bcNavy,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Contract',
                  style: TextStyle(fontWeight: FontWeight.w800)),
              onPressed: () => Navigator.pushNamed(context, AppRoutes.labourEntry),
            )
          : null,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Alert Banner
// ─────────────────────────────────────────────────────────────────────────────
class _AlertBanner extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _AlertBanner({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7ED),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFED7AA)),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: Color(0xFFF59E0B), size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(text,
                  style: const TextStyle(
                      color: Color(0xFF92400E),
                      fontWeight: FontWeight.w700,
                      fontSize: 12)),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: Color(0xFFF59E0B), size: 18),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Summary Row
// ─────────────────────────────────────────────────────────────────────────────
class _SumItem {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const _SumItem(this.label, this.value, this.color, this.icon);
}

class _SummaryRow extends StatelessWidget {
  final List<_SumItem> items;
  const _SummaryRow({required this.items});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: items.asMap().entries.map((entry) {
        final item = entry.value;
        return Expanded(
          child: Container(
            margin:
                EdgeInsets.only(right: entry.key < items.length - 1 ? 8 : 0),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(item.icon, color: item.color, size: 18),
                const SizedBox(height: 8),
                Text(item.value,
                    style: TextStyle(
                        color: item.color,
                        fontSize: 14,
                        fontWeight: FontWeight.w900),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(item.label,
                    style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 10,
                        fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab — list of entries
// ─────────────────────────────────────────────────────────────────────────────
class _LabourListTab extends StatelessWidget {
  final List<LabourEntryModel> entries;
  final NumberFormat fmt;
  final bool showSettlementBadge;

  const _LabourListTab({
    required this.entries,
    required this.fmt,
    this.showSettlementBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.engineering_outlined,
                size: 56, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text('No entries here',
                style: TextStyle(
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w700,
                    fontSize: 15)),
            const SizedBox(height: 6),
            Text('Tap + Add Contract to get started',
                style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: entries.length,
      itemBuilder: (context, i) => _LabourCard(
        entry: entries[i],
        fmt: fmt,
        showSettlementBadge: showSettlementBadge,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Labour Card
// ─────────────────────────────────────────────────────────────────────────────
class _LabourCard extends StatelessWidget {
  final LabourEntryModel entry;
  final NumberFormat fmt;
  final bool showSettlementBadge;

  const _LabourCard({
    required this.entry,
    required this.fmt,
    required this.showSettlementBadge,
  });

  Color get _statusColor {
    switch (entry.status) {
      case LabourStatus.ongoing:    return const Color(0xFF3B82F6);
      case LabourStatus.completed:  return const Color(0xFFF59E0B);
      case LabourStatus.settled:    return const Color(0xFF10B981);
    }
  }

  @override
  Widget build(BuildContext context) {
    final progressPct = entry.totalContractAmount > 0
        ? ((entry.totalAdvancePaid + (entry.finalSettlementAmount ?? 0)) /
                entry.totalContractAmount)
            .clamp(0.0, 1.0)
        : 0.0;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.labourDetail,
        arguments: entry.id,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 3))
          ],
        ),
        child: Column(
          children: [
            // ── Header ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.engineering_rounded,
                        color: _statusColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  // Name & Site
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.partyName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: Color(0xFF0F1F3D)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${entry.workType.displayName} • ${entry.siteName}',
                          style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 11,
                              fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Status chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      entry.status.displayName.toUpperCase(),
                      style: TextStyle(
                          color: _statusColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5),
                    ),
                  ),
                ],
              ),
            ),

            // ── Work Description ─────────────────────────────────────────
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(
                entry.workDescription,
                style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 12,
                    fontWeight: FontWeight.w500),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // ── Progress Bar ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Paid: ${fmt.format(entry.totalAdvancePaid + (entry.finalSettlementAmount ?? 0))}',
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF64748B)),
                      ),
                      Text(
                        'Total: ${fmt.format(entry.totalContractAmount)}',
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F1F3D)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progressPct,
                      backgroundColor: const Color(0xFFE2E8F0),
                      color: _statusColor,
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),

            // ── Footer ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              child: Row(
                children: [
                  _FooterStat(
                    label: 'Pending',
                    value: fmt.format(entry.pendingAmount.clamp(0, double.infinity)),
                    color: entry.pendingAmount > 0
                        ? const Color(0xFFF04438)
                        : const Color(0xFF10B981),
                  ),
                  const SizedBox(width: 16),
                  if (entry.workQuantity != null)
                    _FooterStat(
                      label: entry.workType.unitLabel,
                      value: entry.workQuantity!.toStringAsFixed(0),
                      color: const Color(0xFF6366F1),
                    ),
                  const Spacer(),
                  if (showSettlementBadge &&
                      entry.needsSettlement &&
                      context.watch<AuthRepository>().canSettleLabour)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFED7AA)),
                      ),
                      child: const Text(
                        '⚡ Settle Now',
                        style: TextStyle(
                            color: Color(0xFFB45309),
                            fontSize: 10,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right_rounded,
                      color: Color(0xFFCBD5E1), size: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _FooterStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: TextStyle(
                color: color, fontSize: 13, fontWeight: FontWeight.w900)),
        Text(label,
            style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 10,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}
