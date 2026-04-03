import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:construction_app/core/theme/aesthetic_tokens.dart';
import 'package:construction_app/shared/widgets/professional_page.dart';
import 'package:construction_app/shared/widgets/staggered_animation.dart';
import 'package:construction_app/core/services/reporting_service.dart';
import 'package:construction_app/core/services/report_export_service.dart';
import 'package:construction_app/data/models/material_model.dart';
import 'package:construction_app/data/models/inward_movement_model.dart';
import '../widgets/report_filter_bar.dart';
import '../widgets/report_summary_cards.dart';

class AdvancedReportsScreen extends StatefulWidget {
  const AdvancedReportsScreen({super.key});

  @override
  State<AdvancedReportsScreen> createState() => _AdvancedReportsScreenState();
}

class _AdvancedReportsScreenState extends State<AdvancedReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTimeRange? _dateRange;
  MaterialCategory? _category;
  bool _isLoading = false;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    setState(() {
      _dateRange = null;
      _category = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportingService>(
      builder: (context, reportService, child) {
        final stats = reportService.getSummaryStats(
          startDate: _dateRange?.start,
          endDate: _dateRange?.end,
        );

        return Stack(
          children: [
            ProfessionalPage(
              title: 'Advanced Reports',
              actions: [
                IconButton(
                  icon: const Icon(Icons.download_rounded, color: Colors.white),
                  onPressed: () => _showExportOptions(context, reportService),
                  tooltip: 'Export Report',
                ),
              ],
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Filter Section
                      ReportFilterBar(
                        dateRange: _dateRange,
                        selectedCategory: _category,
                        onDateRangeChanged: (range) => setState(() => _dateRange = range),
                        onCategoryChanged: (cat) => setState(() => _category = cat),
                        onClearFilters: _clearFilters,
                      ),
                      const SizedBox(height: 24),
                      
                      // Stats Grid
                      GridView.count(
                        crossAxisCount: MediaQuery.of(context).size.width > 600 ? 5 : 2, 
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 2.0,
                        children: [
                          ReportSummaryCard(
                            label: 'Inward Value',
                            value: '₹${NumberFormat('#,##,###').format(stats.totalInwardValue)}',
                            icon: Icons.account_balance_wallet_rounded,
                            color: bcSuccess,
                          ),
                          ReportSummaryCard(
                            label: 'Inventory Val',
                            value: '₹${NumberFormat('#,##,###').format(stats.totalStockValue)}',
                            icon: Icons.inventory_2_rounded,
                            color: bcInfo,
                          ),
                          ReportSummaryCard(
                            label: 'Consump. Qty',
                            value: '${stats.totalOutwardQty.toStringAsFixed(0)} Units',
                            icon: Icons.trending_up_rounded,
                            color: bcNavy,
                          ),
                          ReportSummaryCard(
                            label: 'Total Entries',
                            value: '${stats.totalEntries}',
                            icon: Icons.list_alt_rounded,
                            color: bcAmber,
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Tabbed Content
                      TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        labelColor: bcNavy,
                        unselectedLabelColor: const Color(0xFF94A3B8),
                        indicatorColor: bcNavy,
                        indicatorWeight: 3,
                        labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
                        tabs: const [
                          Tab(text: 'INWARD LOGS'),
                          Tab(text: 'STOCK LEVELS'),
                          Tab(text: 'TRANSACTIONS'),
                          Tab(text: 'PERFORMANCE'),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      SizedBox(
                        height: 600,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildInwardTab(reportService),
                            _buildStockTab(reportService),
                            _buildTransactionTab(reportService),
                            _buildPerformanceTab(reportService),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_isLoading)
              Container(
                color: Colors.black26,
                child: const Center(
                  child: CircularProgressIndicator(color: bcAmber),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildInwardTab(ReportingService service) {
    final logs = service.getInwardReport(
      startDate: _dateRange?.start,
      endDate: _dateRange?.end,
      category: _category,
    );

    if (logs.isEmpty) return const _EmptyState(text: 'No inward logs found for selected filters.');

    return ListView.builder(
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        return StaggeredAnimation(
          index: index,
          child: _ReportListItem(
            title: log.materialName,
            subtitle: '${log.transporterName} • ${DateFormat('dd MMM yyyy').format(log.createdAt)}',
            trailing: '₹${NumberFormat('#,##,###').format(log.totalAmount)}',
            status: log.status.name.toUpperCase(),
            statusColor: log.status == InwardStatus.approved ? bcSuccess : bcAmber,
          ),
        );
      },
    );
  }

  Widget _buildStockTab(ReportingService service) {
    final materials = service.getStockLevelReport(category: _category);

    if (materials.isEmpty) return const _EmptyState(text: 'No materials found.');

    return ListView.builder(
      itemCount: materials.length,
      itemBuilder: (context, index) {
        final m = materials[index];
        final isLow = m.currentStock <= m.minimumStockLimit;
        return StaggeredAnimation(
          index: index,
          child: _ReportListItem(
            title: m.name,
            subtitle: '${m.brand} • ${m.subType}',
            trailing: '${m.currentStock} ${m.unitType.label}',
            status: isLow ? 'LOW STOCK' : 'OPTIMAL',
            statusColor: isLow ? bcDanger : bcSuccess,
          ),
        );
      },
    );
  }

  Widget _buildTransactionTab(ReportingService service) {
    final txns = service.getTransactionReport(
      startDate: _dateRange?.start,
      endDate: _dateRange?.end,
    );

    if (txns.isEmpty) return const _EmptyState(text: 'No transactions found.');

    return ListView.builder(
      itemCount: txns.length,
      itemBuilder: (context, index) {
        final t = txns[index];
        return StaggeredAnimation(
          index: index,
          child: _ReportListItem(
            title: t.materialName,
            subtitle: '${t.type.toString().split('.').last.toUpperCase()} • ${DateFormat('dd MMM yyyy HH:mm').format(t.timestamp)}',
            trailing: '${t.quantity} ${t.unit}',
            status: t.isApproved ? 'VERIFIED' : 'PENDING',
            statusColor: t.isApproved ? bcSuccess : bcAmber,
          ),
        );
      },
    );
  }

  Widget _buildPerformanceTab(ReportingService service) {
    final perf = service.getProjectPerformance();
    final fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    
    return SingleChildScrollView(
      child: Column(
        children: [
          _PerformanceCard(
            title: 'Profit / Loss Estimation',
            value: fmt.format(perf.profitOrLoss),
            color: perf.profitOrLoss >= 0 ? bcSuccess : bcDanger,
            details: [
              _PerfDetail(label: 'Total Budget', value: fmt.format(perf.totalBudget)),
              _PerfDetail(label: 'Total Expenses', value: fmt.format(perf.totalExpense)),
            ],
          ),
          const SizedBox(height: 16),
          _PerformanceCard(
            title: 'Expense Breakdown',
            value: fmt.format(perf.totalExpense),
            color: bcNavy,
            details: [
              _PerfDetail(label: 'Material Cost', value: fmt.format(perf.materialExpense)),
              _PerfDetail(label: 'Labour Cost', value: fmt.format(perf.labourExpense)),
              _PerfDetail(label: 'Overheads (Est.)', value: fmt.format(perf.otherExpense)),
            ],
          ),
          const SizedBox(height: 16),
          _PerformanceCard(
            title: 'Efficiency Metrics',
            value: '${perf.marginPercent.toStringAsFixed(1)}%',
            color: bcAmber,
            details: [
              _PerfDetail(label: 'Wastage (Est. 5%)', value: fmt.format(perf.wastageEstimate)),
              _PerfDetail(label: 'Profit Margin', value: '${perf.marginPercent.toStringAsFixed(1)}%'),
            ],
          ),
        ],
      ),
    );
  }

  void _showExportOptions(BuildContext context, ReportingService service) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: bcSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('EXPORT REPORT', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: bcNavy)),
            const SizedBox(height: 4),
            Text('Current filters will be applied to the data.', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            const SizedBox(height: 24),
            _ExportOption(
              icon: Icons.table_view_rounded,
              label: 'Export to Excel (.xlsx)',
              color: Colors.green[600]!,
              onTap: () async {
                Navigator.pop(context);
                setState(() => _isLoading = true);
                try {
                  if (_tabController.index == 1) { // Stock Tab
                    final data = service.getStockLevelReport(category: _category);
                    await ReportExportService.exportStockToExcel(
                      data, 
                      'Stock_Valuation_${DateFormat('yyyyMMdd').format(DateTime.now())}'
                    );
                  } else { // Default to Inward for now or add Transaction later
                    final data = service.getInwardReport(
                      startDate: _dateRange?.start,
                      endDate: _dateRange?.end,
                      category: _category,
                    );
                    await ReportExportService.exportInwardLogsToExcel(
                      data, 
                      'Inward_Report_${DateFormat('yyyyMMdd').format(DateTime.now())}'
                    );
                  }
                } finally {
                  setState(() => _isLoading = false);
                }
              },
            ),
            const SizedBox(height: 12),
            _ExportOption(
              icon: Icons.picture_as_pdf_rounded,
              label: 'Export to PDF (.pdf)',
              color: bcDanger,
              onTap: () async {
                Navigator.pop(context);
                setState(() => _isLoading = true);
                try {
                  if (_tabController.index == 1) { // Stock Tab
                    final data = service.getStockLevelReport(category: _category);
                    await ReportExportService.exportStockToPdf(
                      data, 
                      'Stock_Valuation_${DateFormat('yyyyMMdd').format(DateTime.now())}'
                    );
                  } else {
                    final data = service.getInwardReport(
                      startDate: _dateRange?.start,
                      endDate: _dateRange?.end,
                      category: _category,
                    );
                    await ReportExportService.exportInwardLogsToPdf(
                      data, 
                      'Inward_Report_${DateFormat('yyyyMMdd').format(DateTime.now())}'
                    );
                  }
                } finally {
                  setState(() => _isLoading = false);
                }
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ReportListItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String trailing;
  final String status;
  final Color statusColor;

  const _ReportListItem({
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bcCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: bcNavy)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(trailing, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: bcNavy)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: statusColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExportOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ExportOption({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: bcNavy)),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String text;
  const _EmptyState({required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.query_stats_rounded, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(text, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
        ],
      ),
    );
  }
}

class _PerformanceCard extends StatelessWidget {
  final String title, value;
  final Color color;
  final List<_PerfDetail> details;

  const _PerformanceCard({required this.title, required this.value, required this.color, required this.details});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bcCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bcBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1, color: bcTextSecondary)),
              Icon(Icons.info_outline_rounded, size: 16, color: bcTextSecondary.withValues(alpha: 0.5)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: color)),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),
          ...details.map((d) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(d.label, style: const TextStyle(fontSize: 13, color: bcTextSecondary, fontWeight: FontWeight.w500)),
                Text(d.value, style: const TextStyle(fontSize: 13, color: bcNavy, fontWeight: FontWeight.w700)),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _PerfDetail {
  final String label, value;
  _PerfDetail({required this.label, required this.value});
}
