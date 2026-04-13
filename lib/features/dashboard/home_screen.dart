import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:construction_app/core/theme/aesthetic_tokens.dart';
import 'package:construction_app/core/theme/professional_theme.dart';
import 'package:construction_app/shared/widgets/enhanced_animations.dart';
import 'package:construction_app/shared/widgets/app_logo_badge.dart';
import 'package:construction_app/data/repositories/auth_repository.dart';
import 'package:construction_app/data/repositories/site_repository.dart';
import 'package:construction_app/data/repositories/worker_repository.dart';
import 'package:construction_app/data/repositories/stock_entry_repository.dart';
import 'package:construction_app/data/repositories/labour_repository.dart';
import 'package:construction_app/data/repositories/party_repository.dart';
import 'package:construction_app/core/routing/app_router.dart';
import 'package:construction_app/data/models/site_model.dart';

class HomeScreen extends StatefulWidget {
  final void Function(int) onNavigateTo;
  const HomeScreen({super.key, required this.onNavigateTo});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final _fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    final siteRepo    = context.watch<SiteRepository>();
    final workerRepo  = context.watch<WorkerRepository>();
    final stockRepo   = context.watch<StockEntryRepository>();
    final labourRepo  = context.watch<LabourRepository>();
    final auth        = context.watch<AuthRepository>();

    final site     = siteRepo.selectedSite;
    final siteId   = site?.id;

    // KPI data
    final materialValue    = siteId != null ? stockRepo.getTotalMaterialValueForSite(siteId) : 0.0;
    final supplierPending  = siteId != null ? stockRepo.getTotalPendingForSite(siteId) : stockRepo.totalPendingAllSites;
    final workerSalaryDue  = siteId != null ? workerRepo.getTotalSalaryDueForSite(siteId) : 0.0;
    final contractorPending = labourRepo.getTotalPending(siteId: siteId);

    return Scaffold(
      backgroundColor: bcSurface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Hero App Bar ──────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: bcNavy,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.menu_rounded, color: bcAmber),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.calculate_rounded, color: bcAmber, size: 22),
                tooltip: 'Calculator',
                onPressed: () => Navigator.pushNamed(context, AppRoutes.calculatorHome),
              ),
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.white70),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Blueprint grid
                  CustomPaint(painter: BlueprintGridPainter(opacity: 0.1, gridColor: bcAmber.withValues(alpha: 0.15))),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _greeting(),
                                  style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  auth.userName ?? 'Admin',
                                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, height: 1.1),
                                ),
                              ],
                            ),
                            const Spacer(),
                            // Site selector pill
                            _SiteSelectorPill(siteRepo: siteRepo),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Content ───────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ── KPI Cards ─────────────────────────────────────────────
                BounceFadeIn(
                  delay: const Duration(milliseconds: 50),
                  child: _SectionLabel('OVERVIEW', 'Key numbers at a glance'),
                ),
                const SizedBox(height: 12),
                BounceFadeIn(
                  delay: const Duration(milliseconds: 100),
                  child: _KpiGrid(
                    kpis: [
                      _KpiData('Material Value', _fmt.format(materialValue), Icons.layers_rounded, bcAmber, () => Navigator.pushNamed(context, AppRoutes.materialCatalog, arguments: {'inStock': true})),
                      _KpiData('Supplier Due', _fmt.format(supplierPending), Icons.people_alt_rounded, bcDanger, () => Navigator.pushNamed(context, AppRoutes.supplierList)),
                      _KpiData('Worker Salary', _fmt.format(workerSalaryDue), Icons.engineering_rounded, bcInfo, () => widget.onNavigateTo(2)),
                      _KpiData('Contractor Due', _fmt.format(contractorPending), Icons.handyman_rounded, bcSuccess, () => widget.onNavigateTo(3)),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ── Quick Actions ─────────────────────────────────────────
                BounceFadeIn(
                  delay: const Duration(milliseconds: 200),
                  child: _SectionLabel('QUICK ACTIONS', 'One-tap shortcuts'),
                ),
                const SizedBox(height: 12),
                BounceFadeIn(
                  delay: const Duration(milliseconds: 250),
                  child: _QuickActionsGrid(context: context, onNavigate: widget.onNavigateTo),
                ),

                const SizedBox(height: 28),

                // ── Active Sites Banner ───────────────────────────────────
                BounceFadeIn(
                  delay: const Duration(milliseconds: 300),
                  child: _SectionLabel('ACTIVE SITES', '${siteRepo.sites.where((s) => s.status == SiteStatus.active).length} sites running'),
                ),
                const SizedBox(height: 12),
                BounceFadeIn(
                  delay: const Duration(milliseconds: 350),
                  child: siteRepo.sites.isEmpty
                      ? _EmptyHint('No sites yet. Go to More → Sites to add one.', Icons.location_city_rounded)
                      : _SiteListPreview(sites: siteRepo.sites.take(3).toList(), siteRepo: siteRepo),
                ),

                const SizedBox(height: 28),

                // ── Recent Stock Entries ──────────────────────────────────
                BounceFadeIn(
                  delay: const Duration(milliseconds: 400),
                  child: Row(
                    children: [
                      Expanded(child: _SectionLabel('RECENT STOCK', 'Latest purchases')),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, AppRoutes.stockHub),
                        child: const Text('See all →', style: TextStyle(color: bcAmber, fontSize: 11, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                BounceFadeIn(
                  delay: const Duration(milliseconds: 450),
                  child: _RecentStockPreview(stockRepo: stockRepo, siteId: siteId),
                ),

                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning,';
    if (h < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }
}

// ─── Site Selector Pill ───────────────────────────────────────────────────────

class _SiteSelectorPill extends StatelessWidget {
  final SiteRepository siteRepo;
  const _SiteSelectorPill({required this.siteRepo});

  @override
  Widget build(BuildContext context) {
    if (siteRepo.sites.isEmpty) {
      return GestureDetector(
        onTap: () => Navigator.pushNamed(context, AppRoutes.siteManagement),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: bcAmber.withValues(alpha: 0.4)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, color: bcAmber, size: 14),
              SizedBox(width: 4),
              Text('Add Site', style: TextStyle(color: bcAmber, fontSize: 11, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      );
    }

    return Theme(
      data: Theme.of(context).copyWith(canvasColor: bcNavyMid),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: siteRepo.selectedSiteId ?? siteRepo.sites.first.id,
          dropdownColor: bcNavyMid,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: bcAmber, size: 18),
          isDense: true,
          selectedItemBuilder: (_) => siteRepo.sites.map((s) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: bcAmber.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on_rounded, color: bcAmber, size: 12),
                const SizedBox(width: 5),
                Text(
                  s.name.length > 12 ? '${s.name.substring(0, 12)}…' : s.name,
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          )).toList(),
          items: siteRepo.sites.map((s) => DropdownMenuItem(
            value: s.id,
            child: Text(s.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
          )).toList(),
          onChanged: (val) { if (val != null) siteRepo.selectSite(val); },
        ),
      ),
    );
  }
}

// ─── KPI Grid ─────────────────────────────────────────────────────────────────

class _KpiData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _KpiData(this.label, this.value, this.icon, this.color, this.onTap);
}

class _KpiGrid extends StatelessWidget {
  final List<_KpiData> kpis;
  const _KpiGrid({required this.kpis});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.55,
      ),
      itemCount: kpis.length,
      itemBuilder: (_, i) => _KpiCard(data: kpis[i]),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final _KpiData data;
  const _KpiCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: data.onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: data.color.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(color: data.color.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: data.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(data.icon, color: data.color, size: 16),
                ),
                const Spacer(),
                Icon(Icons.arrow_forward_ios_rounded, size: 10, color: data.color.withValues(alpha: 0.5)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.value,
                  style: const TextStyle(color: bcNavy, fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  data.label,
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.3),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Quick Actions Grid ───────────────────────────────────────────────────────

class _QuickActionsGrid extends StatelessWidget {
  final BuildContext context;
  final void Function(int) onNavigate;
  const _QuickActionsGrid({required this.context, required this.onNavigate});

  @override
  Widget build(BuildContext outerContext) {
    final actions = [
      _QA('Add Stock',     Icons.add_box_rounded,         bcAmber,              () => Navigator.pushNamed(outerContext, AppRoutes.stockHub)),
      _QA('Add Worker',    Icons.person_add_rounded,       bcInfo,               () => onNavigate(2)),
      _QA('Add Contractor',Icons.handyman_rounded,         const Color(0xFF34D399), () => onNavigate(3)),
      _QA('Suppliers',     Icons.people_alt_rounded,       const Color(0xFFA78BFA), () => Navigator.pushNamed(outerContext, AppRoutes.supplierList)),
    ];

    return Row(
      children: actions.map((a) => Expanded(
        child: GestureDetector(
          onTap: a.onTap,
          child: Container(
            margin: EdgeInsets.only(right: a == actions.last ? 0 : 10),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: a.color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: a.color.withValues(alpha: 0.2)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: a.color.withValues(alpha: 0.15), shape: BoxShape.circle),
                  child: Icon(a.icon, color: a.color, size: 18),
                ),
                const SizedBox(height: 6),
                Text(a.label, style: const TextStyle(color: bcNavy, fontSize: 9.5, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      )).toList(),
    );
  }
}

class _QA {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _QA(this.label, this.icon, this.color, this.onTap);
}

// ─── Site List Preview ────────────────────────────────────────────────────────

class _SiteListPreview extends StatelessWidget {
  final List<SiteModel> sites;
  final SiteRepository siteRepo;
  const _SiteListPreview({required this.sites, required this.siteRepo});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...sites.map((s) => _SiteTile(site: s, isSelected: siteRepo.selectedSiteId == s.id,
            onTap: () => siteRepo.selectSite(s.id))),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRoutes.siteManagement),
          child: Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: bcAmber.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: bcAmber.withValues(alpha: 0.2), style: BorderStyle.solid),
            ),
            child: const Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, color: bcAmber, size: 16),
                  SizedBox(width: 6),
                  Text('Manage Sites', style: TextStyle(color: bcAmber, fontSize: 12, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SiteTile extends StatelessWidget {
  final SiteModel site;
  final bool isSelected;
  final VoidCallback onTap;
  const _SiteTile({required this.site, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final Color statusColor = site.status == SiteStatus.active
        ? bcSuccess
        : site.status == SiteStatus.onHold ? bcAmber : const Color(0xFF94A3B8);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? bcAmber.withValues(alpha: 0.06) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? bcAmber.withValues(alpha: 0.4) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.location_city_rounded, color: statusColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(site.name, style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w800, fontSize: 13)),
                  if (site.address != null || site.clientName != null)
                    Text(
                      [site.clientName, site.address].where((s) => s != null).join(' • '),
                      style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w500),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(site.status.displayName,
                  style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Recent Stock Preview ─────────────────────────────────────────────────────

class _RecentStockPreview extends StatelessWidget {
  final StockEntryRepository stockRepo;
  final String? siteId;
  const _RecentStockPreview({required this.stockRepo, this.siteId});

  @override
  Widget build(BuildContext context) {
    final entries = siteId != null
        ? stockRepo.getEntriesForSite(siteId!).take(3).toList()
        : stockRepo.entries.take(3).toList();

    if (entries.isEmpty) {
      return _EmptyHint('No stock entries yet. Tap "Add Stock" to record your first purchase.', Icons.add_box_rounded);
    }

    final fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    return Column(
      children: entries.map((e) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: bcAmber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(e.isInventoryItem ? Icons.layers_rounded : Icons.receipt_rounded, color: bcAmber, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.materialName.isEmpty ? e.subType : e.materialName,
                      style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w800, fontSize: 13),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text('${e.supplierName} • ${e.quantity} ${e.unit}',
                      style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11), maxLines: 1),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(fmt.format(e.totalAmount), style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 13)),
                if (e.pendingAmount > 0)
                  Text('Due: ${fmt.format(e.pendingAmount)}', style: const TextStyle(color: bcDanger, fontSize: 10, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      )).toList(),
    );
  }
}

// ─── Shared helpers ───────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SectionLabel(this.title, this.subtitle);

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: const TextStyle(color: bcNavy, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.4)),
      const SizedBox(height: 1),
      Text(subtitle, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w500)),
    ],
  );
}

class _EmptyHint extends StatelessWidget {
  final String text;
  final IconData icon;
  const _EmptyHint(this.text, this.icon);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: Row(
      children: [
        Icon(icon, size: 22, color: const Color(0xFFCBD5E1)),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w500))),
      ],
    ),
  );
}
