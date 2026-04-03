import 'package:flutter/material.dart';
import 'package:construction_app/shared/widgets/app_logo_badge.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:construction_app/core/theme/design_system.dart';
import 'package:construction_app/core/theme/aesthetic_tokens.dart';
import 'package:construction_app/core/theme/professional_theme.dart';
import 'package:construction_app/shared/widgets/professional_page.dart';
import 'package:construction_app/shared/widgets/adaptive_card.dart';
import 'package:construction_app/shared/widgets/status_badge.dart';
import 'package:construction_app/data/repositories/payment_repository.dart';
import 'package:construction_app/data/repositories/inventory_repository.dart';
import 'package:construction_app/data/repositories/site_repository.dart';
import 'package:construction_app/data/repositories/ledger_repository.dart';
import 'package:construction_app/data/repositories/milestone_repository.dart';
import 'package:construction_app/features/inventory/screens/inward_entry_form_screen.dart';
import 'package:construction_app/data/models/payment_model.dart';
import 'package:construction_app/core/routing/app_router.dart';
import 'package:construction_app/data/models/inward_movement_model.dart';
import 'package:construction_app/shared/widgets/enhanced_animations.dart';
import 'package:construction_app/data/repositories/auth_repository.dart';

class CommandCenterScreen extends StatefulWidget {
  final void Function(int tabIndex) onNavigateTo;

  const CommandCenterScreen({super.key, required this.onNavigateTo});

  @override
  State<CommandCenterScreen> createState() => _CommandCenterScreenState();
}

class _CommandCenterScreenState extends State<CommandCenterScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final siteRepo = context.watch<SiteRepository>();
    final selectedSite = siteRepo.selectedSite;
    final selectedSiteId = selectedSite?.id;

    final paymentRepo = context.watch<PaymentRepository>();
    final inventoryRepo = context.watch<InventoryRepository>();
    final ledgerRepo = context.watch<LedgerRepository>();
    final milestoneRepo = context.watch<MilestoneRepository>();
    final authRepo = context.watch<AuthRepository>();
    final isAdvanced = authRepo.isAdvancedMode;
    final fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    
    final totalSuccess = paymentRepo.getTotalSuccess(siteId: selectedSiteId);
    final totalPending = paymentRepo.getTotalPending(siteId: selectedSiteId);
    final overdueCount = milestoneRepo.getOverdueCount(siteId: selectedSiteId);

    return ProfessionalPage(
      title: 'Command Center',
      titleWidget: _buildSiteSelector(context, siteRepo),
      subtitle: selectedSite != null ? 'Operations for ${selectedSite.name}' : 'All Construction Operations',
      category: isAdvanced ? 'ADVANCED ERP DASHBOARD' : 'SIMPLE SITE TRACKER',
      headerStats: [
        _LiveIndicator(),
        const SizedBox(width: 12),
        ModeToggleWidget(
          isAdvanced: isAdvanced,
          onToggle: (val) => authRepo.toggleAppMode(),
        ),
      ],
      actions: [
        IconButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.calculatorHome),
          icon: const Icon(Icons.calculate_rounded, color: bcAmber, size: 22),
          tooltip: 'Calculators',
        ),
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
          onPressed: () => setState(() {}),
        ),
      ],
      slivers: [
        // KPI Section
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              children: [
                // Quick Actions Section (Always visible for simplicity)
                _buildQuickActions(context),
                const SizedBox(height: 24),
                
                // Overdue milestone warning banner
                if (overdueCount > 0 && isAdvanced)
                  BounceFadeIn(
                    delay: const Duration(milliseconds: 100),
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(context, AppRoutes.milestones),
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: bcDanger.withValues(alpha: 0.07),
                          border: Border.all(color: bcDanger.withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: bcDanger, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '$overdueCount milestone${overdueCount > 1 ? "s are" : " is"} overdue!',
                                style: const TextStyle(
                                    color: bcDanger,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13),
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded, color: bcDanger, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),

                LayoutBuilder(
                  builder: (context, constraints) {
                    final isSmall = constraints.maxWidth < 600;
                    
                    final cards = [
                      BounceFadeIn(
                        delay: const Duration(milliseconds: 200),
                        child: _buildKPICard(
                          label: 'TOTAL SUCCESS',
                          value: fmt.format(totalSuccess),
                          icon: Icons.check_circle_rounded,
                          color: bcSuccess,
                          onTap: () => Navigator.pushNamed(context, AppRoutes.paymentHistory),
                        ),
                      ),
                      BounceFadeIn(
                        delay: const Duration(milliseconds: 300),
                        child: _buildKPICard(
                          label: 'PAYMENT PENDING',
                          value: fmt.format(totalPending),
                          icon: Icons.pending_actions_rounded,
                          color: bcAmber,
                          onTap: () => _showPendingPaymentsDialog(context, paymentRepo),
                        ),
                      ),
                    ];

                    final ledgerCards = isAdvanced ? [
                      BounceFadeIn(
                        delay: const Duration(milliseconds: 400),
                        child: _buildKPICard(
                          label: 'RECEIVABLE',
                          value: fmt.format(ledgerRepo.getTotalReceivable(siteId: selectedSiteId)),
                          icon: Icons.call_received_rounded,
                          color: bcInfo,
                          onTap: () => Navigator.pushNamed(context, AppRoutes.partyLedger),
                        ),
                      ),
                      BounceFadeIn(
                        delay: const Duration(milliseconds: 500),
                        child: _buildKPICard(
                          label: 'PAYABLE',
                          value: fmt.format(ledgerRepo.getTotalPayable(siteId: selectedSiteId)),
                          icon: Icons.call_made_rounded,
                          color: bcDanger,
                          onTap: () => Navigator.pushNamed(context, AppRoutes.partyLedger),
                        ),
                      ),
                    ] : <Widget>[];
 
                    if (isSmall) {
                      return Column(children: [
                        cards[0], const SizedBox(height: 12), cards[1],
                        if (isAdvanced) ...[
                          const SizedBox(height: 12),
                          ledgerCards[0], const SizedBox(height: 12), ledgerCards[1],
                        ]
                      ]);
                    }
 
                    return Column(
                      children: [
                        Row(children: [
                          Expanded(child: cards[0]),
                          const SizedBox(width: 16),
                          Expanded(child: cards[1]),
                        ]),
                        if (isAdvanced) ...[
                          const SizedBox(height: 12),
                          Row(children: [
                            Expanded(child: ledgerCards[0]),
                            const SizedBox(width: 16),
                            Expanded(child: ledgerCards[1]),
                          ]),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        // Features Section
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              if (isAdvanced) ...[
                const ProfessionalSectionHeader(
                  title: 'QUICK ACCESS',
                  subtitle: 'Full operational shortcuts',
                ),
                const SizedBox(height: 16),
                _buildQuickAccessGrid(context),
                const SizedBox(height: 24),
              ],

              const ProfessionalSectionHeader(
                title: 'SITE MANAGEMENT',
                subtitle: 'Add & manage all your sites',
              ),
              const SizedBox(height: 12),
              _buildSiteManagementBanner(context, context.read<SiteRepository>()),
              
              if (isAdvanced) ...[
                const SizedBox(height: 32),
                const ProfessionalSectionHeader(
                  title: 'BUSINESS FLOW',
                  subtitle: 'Supply chain & financial loop',
                ),
                const SizedBox(height: 12),
                _buildBusinessFlowCard(),
              ],

              const SizedBox(height: 32),
              ProfessionalSectionHeader(
                title: 'STOCK MAINTENANCE',
                subtitle: isAdvanced ? 'Critical inventory alerts' : 'Low stock items',
              ),
              const SizedBox(height: 12),
              _buildStockMaintenanceSection(inventoryRepo, selectedSiteId),
              
              const SizedBox(height: 32),
              const ProfessionalSectionHeader(
                title: 'RECENT ACTIVITY',
                subtitle: 'Latest transactions',
              ),
              const SizedBox(height: 12),
              _buildRecentActivity(context, paymentRepo, inventoryRepo, selectedSiteId),

              if (isAdvanced) ...[
                const SizedBox(height: 32),
                const ProfessionalSectionHeader(
                  title: 'SMART SUGGESTIONS',
                  subtitle: 'Proactive operational guidance',
                ),
                const SizedBox(height: 12),
                _buildSmartSuggestionsArea(paymentRepo, inventoryRepo, selectedSiteId),
              ],
              
              const SizedBox(height: 100),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ProfessionalSectionHeader(
          title: 'QUICK ACTIONS',
          subtitle: 'Essential one-tap shortcuts',
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: PremiumActionCard(
                title: 'Add Material',
                subtitle: 'Inward entry',
                icon: Icons.add_circle_outline_rounded,
                color: bcAmber,
                onTap: () => Navigator.pushNamed(context, AppRoutes.inwardEntry),
                isCompact: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PremiumActionCard(
                title: 'Use Material',
                subtitle: 'Stock out',
                icon: Icons.remove_circle_outline_rounded,
                color: bcDanger,
                onTap: () => Navigator.pushNamed(context, AppRoutes.stockOperations),
                isCompact: true,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: PremiumActionCard(
                title: 'Add Work',
                subtitle: 'New contract',
                icon: Icons.engineering_rounded,
                color: bcSuccess,
                onTap: () => Navigator.pushNamed(context, AppRoutes.labourEntry),
                isCompact: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PremiumActionCard(
                title: 'Add Payment',
                subtitle: 'Debit/Credit',
                icon: Icons.account_balance_wallet_rounded,
                color: bcInfo,
                onTap: () => Navigator.pushNamed(context, AppRoutes.partyLedger),
                isCompact: true,
              ),
            ),
          ],
        ),
      ],
    );
  }


  Widget _buildKPICard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return AdaptiveCard(
      onTap: onTap,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: DesignSystem.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: DesignSystem.primary,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessGrid(BuildContext context) {
    final actions = [
      _QuickAction(
        label: 'Material Master',
        icon: Icons.inventory_2_rounded,
        color: const Color(0xFFF59E0B),
        subtitle: 'Define catalog items',
        onTap: () => Navigator.pushNamed(context, AppRoutes.materialMaster),
      ),
      _QuickAction(
        label: 'Suppliers',
        icon: Icons.people_alt_rounded,
        color: const Color(0xFF34D399),
        subtitle: 'View & manage vendors',
        onTap: () => Navigator.pushNamed(context, AppRoutes.suppliers),
      ),
      _QuickAction(
        label: 'Payments',
        icon: Icons.receipt_long_rounded,
        color: const Color(0xFFA78BFA),
        subtitle: 'Ledger & billing history',
        onTap: () => Navigator.pushNamed(context, AppRoutes.paymentHistory),
      ),
      _QuickAction(
        label: 'Party Ledger',
        icon: Icons.account_balance_wallet_rounded,
        color: const Color(0xFF10B981),
        subtitle: 'Party credits & debits',
        onTap: () => Navigator.pushNamed(context, AppRoutes.partyLedger),
      ),
      _QuickAction(
        label: 'Milestones',
        icon: Icons.flag_rounded,
        color: const Color(0xFFF59E0B),
        subtitle: 'Track due payments',
        onTap: () => Navigator.pushNamed(context, AppRoutes.milestones),
      ),
      _QuickAction(
        label: 'Stock View',
        icon: Icons.inventory_2_rounded,
        color: const Color(0xFF60A5FA),
        subtitle: 'Browse inward logs',
        onTap: () => Navigator.pushNamed(context, AppRoutes.inwardManagement),
      ),
      _QuickAction(
        label: 'Stock Op',
        icon: Icons.swap_horiz_rounded,
        color: const Color(0xFFFB7185),
        subtitle: 'Restock & consumption',
        onTap: () => Navigator.pushNamed(context, AppRoutes.stockOperations),
      ),
      _QuickAction(
        label: 'Calculators',
        icon: Icons.precision_manufacturing_rounded,
        color: const Color(0xFFFBBF24),
        subtitle: 'Engineering & unit conversion',
        onTap: () => Navigator.pushNamed(context, AppRoutes.calculatorHome),
      ),
      _QuickAction(
        label: 'Labour',
        icon: Icons.engineering_rounded,
        color: const Color(0xFF10B981),
        subtitle: 'Contracts & contractors',
        onTap: () => Navigator.pushNamed(context, AppRoutes.labourList),
      ),
      _QuickAction(
        label: 'Reports',
        icon: Icons.analytics_rounded,
        color: const Color(0xFF818CF8),
        subtitle: 'Performance & PDF exports',
        onTap: () => Navigator.pushNamed(context, AppRoutes.reports),
      ),
      _QuickAction(
        label: 'Site Expense',
        icon: Icons.receipt_long_rounded,
        color: const Color(0xFFFB7185),
        subtitle: 'Fuel, tea & petty cash',
        onTap: () => Navigator.pushNamed(context, AppRoutes.partyLedger),
      ),
    ];

    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width >= 768 ? 3 : 2;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: width >= 768 ? 1.5 : 1.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: actions.length,
      itemBuilder: (context, i) => _buildQuickActionButton(actions[i]),
    );
  }

  Widget _buildQuickActionButton(_QuickAction a) {
    return AdaptiveCard(
      onTap: a.onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: a.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(a.icon, color: a.color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            a.label,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 13,
              color: DesignSystem.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            a.subtitle,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 10,
              color: Color(0xFF94A3B8),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSiteManagementBanner(BuildContext context, SiteRepository siteRepo) {
    return AdaptiveCard(
      onTap: () => Navigator.pushNamed(context, AppRoutes.siteManagement),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
            const AppLogoBadge(size: 28, zoom: 1.25),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Site Registry', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: bcNavy)),
                const SizedBox(height: 4),
                Text(
                  '${siteRepo.sites.length} site${siteRepo.sites.length != 1 ? 's' : ''} • Tap to Add, Edit or Delete',
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: bcAmber.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('MANAGE', style: TextStyle(color: bcAmber, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios_rounded, color: bcAmber, size: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSiteSelector(BuildContext context, SiteRepository siteRepo) {
    if (siteRepo.sites.isEmpty) {
      return const Text(
        'Command Center',
        style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900),
      );
    }

    return Theme(
      data: Theme.of(context).copyWith(canvasColor: bcNavyMid),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: siteRepo.selectedSiteId,
          dropdownColor: bcNavyMid,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: bcAmber),
          selectedItemBuilder: (context) {
            return siteRepo.sites.map((site) {
              return Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  site.name.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22, // Slightly smaller than default title but bold
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
              );
            }).toList();
          },
          items: [
            ...siteRepo.sites.map((site) => DropdownMenuItem(
                  value: site.id,
                  child: Text(
                    site.name,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                )),
          ],
          onChanged: (val) {
            if (val != null) siteRepo.selectSite(val);
          },
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context, PaymentRepository paymentRepo, InventoryRepository inventoryRepo, String? siteId) {
    final recentPayments = paymentRepo.payments
        .where((p) => siteId == null || p.siteId == siteId)
        .take(3)
        .toList();
    final recentInward = inventoryRepo.logs
        .where((l) => siteId == null || l.siteId == siteId)
        .take(3)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Recent Payments sub-header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Payments', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: bcNavy)),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, AppRoutes.paymentHistory),
              child: const Text('See all →', style: TextStyle(color: bcAmber, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (recentPayments.isEmpty)
          _emptyActivityHint('No payments recorded yet. Tap Payments to add one.', Icons.account_balance_wallet_rounded)
        else
          ...recentPayments.map((p) => _buildPaymentTile(context, p)),

        const SizedBox(height: 20),

        // Recent Inward sub-header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Inward Entries', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: bcNavy)),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, AppRoutes.inwardManagement),
              child: const Text('See all →', style: TextStyle(color: bcAmber, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (recentInward.isEmpty)
          _emptyActivityHint('No inward entries yet. Tap Inward Entry to add stock.', Icons.inventory_2_rounded)
        else
          ...recentInward.map((entry) => _buildInwardTile(context, entry)),
      ],
    );
  }

  Widget _emptyActivityHint(String text, IconData icon) {
    return AdaptiveCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFFCBD5E1)),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildPaymentTile(BuildContext context, PaymentModel p) {
    final isSuccess = p.status == PaymentStatus.success;
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.paymentHistory),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: (isSuccess ? bcSuccess : bcAmber).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                p.type == PaymentType.received ? Icons.call_received_rounded : Icons.call_made_rounded,
                color: isSuccess ? bcSuccess : bcAmber,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.partyName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: bcNavy), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(p.siteName, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('₹${p.amount.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: isSuccess ? bcSuccess : bcAmber)),
                Container(
                  margin: const EdgeInsets.only(top: 3),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: (isSuccess ? bcSuccess : bcAmber).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(p.status.name.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: isSuccess ? bcSuccess : bcAmber)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInwardTile(BuildContext context, InwardMovementModel entry) {
    final isPending = entry.status == InwardStatus.pendingApproval;
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.inwardManagement),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF60A5FA).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.local_shipping_rounded, color: Color(0xFF60A5FA), size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.materialName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: bcNavy), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text('${entry.quantity} ${entry.unit} • ${entry.transporterName}', style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('₹${entry.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: bcNavy)),
                Container(
                  margin: const EdgeInsets.only(top: 3),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: (isPending ? bcAmber : bcSuccess).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(isPending ? 'PENDING' : 'APPROVED', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: isPending ? bcAmber : bcSuccess)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessFlowCard() {
    return AdaptiveCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SYSTEMATIC WORKFLOW GUIDE',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: bcAmber, letterSpacing: 1),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStepIcon('SITES', Icons.business_rounded, bcAmber, () => Navigator.pushNamed(context, AppRoutes.siteManagement)),
              _buildConnector(),
              _buildStepIcon('VENDORS', Icons.people_alt_rounded, const Color(0xFF10B981), () => Navigator.pushNamed(context, AppRoutes.suppliers)),
              _buildConnector(),
              _buildStepIcon('MASTER', Icons.inventory_2_rounded, const Color(0xFFF59E0B), () => Navigator.pushNamed(context, AppRoutes.materialMaster)),
              _buildConnector(),
              _buildStepIcon('INWARD', Icons.add_shopping_cart_rounded, const Color(0xFFF87171), () => Navigator.pushNamed(context, AppRoutes.inwardEntry)),
              _buildConnector(),
              _buildStepIcon('ACCOUNTS', Icons.account_balance_wallet_rounded, const Color(0xFF818CF8), () => Navigator.pushNamed(context, AppRoutes.partyLedger)),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bcNavy.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: bcNavy.withValues(alpha: 0.05)),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome_rounded, color: bcAmber, size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Atomic ERP Logic: Inward entries now auto-update stock and sync with supplier ledgers instantly.',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: bcNavy),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIcon(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: bcNavy, letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildConnector() {
    return Container(
      width: 12,
      height: 2,
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(1)),
    );
  }


  Widget _buildStockMaintenanceSection(InventoryRepository repo, String? siteId) {
    final lowStock = repo.getLowStockMaterials(siteId: siteId);
    
    if (lowStock.isEmpty) {
      return AdaptiveCard(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: bcSuccess, size: 20),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'All stock levels healthy. No immediate restock needed.',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: DesignSystem.textSecondary),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: lowStock.take(2).map((m) => AdaptiveCard(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => InwardEntryFormScreen(preselectedMaterial: m.id))
        ),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(m.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text('${m.currentStock} remaining · Min: ${m.minimumStockLimit}', style: TextStyle(fontSize: 11, color: DesignSystem.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            StatusBadge(label: 'RESTOCK', type: StatusBadgeType.warning),
          ],
        ),
      )).toList(),
    );
  }




  void _showPendingPaymentsDialog(BuildContext context, PaymentRepository repo) {
    final pending = repo.payments.where((p) => p.status == PaymentStatus.pending).toList();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: bcSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('PENDING PAYMENTS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: bcNavy)),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: pending.isEmpty 
                ? const Center(child: Text('No pending payments at this time.'))
                : ListView.builder(
                    itemCount: pending.length,
                    itemBuilder: (context, i) {
                      final p = pending[i];
                      return ListTile(
                        leading: CircleAvatar(backgroundColor: bcAmber.withValues(alpha: 0.1), child: const Icon(Icons.pending_rounded, color: bcAmber, size: 18)),
                        title: Text(p.partyName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Site: ${p.siteName}'),
                        trailing: Text('₹${p.amount}', style: const TextStyle(fontWeight: FontWeight.w900, color: bcNavy)),
                      );
                    },
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.paymentHistory);
                },
                style: ElevatedButton.styleFrom(backgroundColor: bcNavy, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('VIEW FULL HISTORY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildSmartSuggestionsArea(PaymentRepository pRepo, InventoryRepository iRepo, String? siteId) {
    final suggestions = <Widget>[];
    
    // Suggest payment follow-up
    final pendingCount = pRepo.payments
        .where((p) => p.status == PaymentStatus.pending && (siteId == null || p.siteId == siteId))
        .length;
    if (pendingCount > 0) {
      suggestions.add(_buildSuggestion(
        'Follow up on $pendingCount pending payments',
        Icons.monetization_on_rounded,
        bcAmber,
        () => _showPendingPaymentsDialog(context, pRepo),
      ));
    }
    
    // Suggest restock if any low stock
    final lowStock = iRepo.getLowStockMaterials(siteId: siteId);
    if (lowStock.isNotEmpty) {
      suggestions.add(_buildSuggestion(
        '${lowStock.length} materials reaching critical levels',
        Icons.inventory_rounded,
        Colors.redAccent,
        () => Navigator.pushNamed(context, AppRoutes.inwardManagement),
      ));
    }

    // Default suggestion if nothing else
    if (suggestions.isEmpty) {
      suggestions.add(_buildSuggestion(
        'All site operations running smoothly',
        Icons.check_circle_outline_rounded,
        bcSuccess,
        () {},
      ));
    }

    return Column(children: suggestions);
  }

  Widget _buildSuggestion(String text, IconData icon, Color color, VoidCallback onTap) {
    return AdaptiveCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
          const Icon(Icons.chevron_right_rounded, color: Colors.black12),
        ],
      ),
    );
  }
}


class _LiveIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bcSuccess.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bcSuccess.withValues(alpha: 0.3)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _BlinkingDot(),
          SizedBox(width: 6),
          Text(
            'LIVE SYSTEM',
            style: TextStyle(color: bcSuccess, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }
}

class _BlinkingDot extends StatefulWidget {
  const _BlinkingDot();

  @override
  State<_BlinkingDot> createState() => _BlinkingDotState();
}

class _BlinkingDotState extends State<_BlinkingDot> with SingleTickerProviderStateMixin {
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(color: bcSuccess, shape: BoxShape.circle),
      ),
    );
  }
}

class _QuickAction {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
