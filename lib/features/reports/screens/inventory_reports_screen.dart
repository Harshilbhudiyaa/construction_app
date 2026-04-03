import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:construction_app/core/theme/professional_theme.dart';
import 'package:construction_app/core/theme/aesthetic_tokens.dart';
import 'package:construction_app/shared/widgets/loading_indicators.dart';
import 'package:construction_app/shared/widgets/staggered_animation.dart';
import 'package:construction_app/data/repositories/inventory_repository.dart';
import 'package:construction_app/data/models/material_model.dart';
import 'package:construction_app/data/models/inventory_transaction.dart';
import 'package:provider/provider.dart';
import 'package:construction_app/core/services/report_export_service.dart';

class InventoryReportsScreen extends StatefulWidget {
  const InventoryReportsScreen({super.key});

  @override
  State<InventoryReportsScreen> createState() => _InventoryReportsScreenState();
}

class _InventoryReportsScreenState extends State<InventoryReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isExporting = false;

  void _showExportDialog(BuildContext context, InventoryRepository inventory, String fileName, List<InventoryTransaction> Function(List<InventoryTransaction>) filter) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ProfessionalCard(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        useGlass: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ProfessionalSectionHeader(title: 'EXPORT FORMAT', subtitle: 'Choose your preferred reporting standard'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.table_view_rounded, color: Colors.green),
              title: const Text('EXCEL SPREADSHEET (.xlsx)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              onTap: () async {
                Navigator.pop(context);
                setState(() => _isExporting = true);
                try {
                  final all = await inventory.getTransactionsStream(type: TransactionType.outward).first;
                  await ReportExportService.exportTransactionsToExcel(filter(all), fileName);
                } finally {
                  setState(() => _isExporting = false);
                }
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_rounded, color: Colors.redAccent),
              title: const Text('PDF DOCUMENT (.pdf)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              onTap: () async {
                Navigator.pop(context);
                setState(() => _isExporting = true);
                try {
                  final all = await inventory.getTransactionsStream(type: TransactionType.outward).first;
                  await ReportExportService.exportTransactionsToPdf(filter(all), fileName);
                } finally {
                  setState(() => _isExporting = false);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
  
  DateTime _selectedDate = DateTime.now();
  DateTime _selectedMonth = DateTime.now();

  bool isSameDay(DateTime d1, DateTime d2) => d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;

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
    return Scaffold(
      backgroundColor: bcSurface,
      body: ProfessionalBackground(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SmartConstructionSliverAppBar(
              title: 'Analytics',
              subtitle: 'Performance and stock valuation',
              category: 'REPORTS MODULE',
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  decoration: const BoxDecoration(color: bcNavy),
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: bcAmber,
                    indicatorWeight: 3,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white60,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1),
                    tabs: const [
                      Tab(text: 'DAILY USAGE'),
                      Tab(text: 'MONTHLY'),
                      Tab(text: 'STOCK VALUE'),
                    ],
                  ),
                ),
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildDailyUsageTab(),
              _buildMonthlyConsumptionTab(),
              _buildStockValueTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyUsageTab() {
    final inventoryService = Provider.of<InventoryRepository>(context);

    return Column(
      children: [
        _buildDatePickerHeader(inventoryService),
        Expanded(
          child: StreamBuilder<List<InventoryTransaction>>(
            stream: inventoryService.getTransactionsStream(type: TransactionType.outward),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: AppLoader(size: 32));

              final dailyTransactions = (snapshot.data ?? []).where((t) => isSameDay(t.timestamp, _selectedDate)).toList();
              if (dailyTransactions.isEmpty) return _buildEmptyState('No usage recorded for this date');

              final Map<String, double> usageMap = {};
              final Map<String, String> unitMap = {};

              for (var txn in dailyTransactions) {
                usageMap[txn.materialName] = (usageMap[txn.materialName] ?? 0) + txn.quantity;
                unitMap[txn.materialName] = txn.unit;
              }

              return ListView.builder(
                itemCount: usageMap.length,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final materialName = usageMap.keys.elementAt(index);
                  return StaggeredAnimation(
                    index: index,
                    child: _ReportItemCard(
                      title: materialName,
                      value: '${usageMap[materialName]} ${unitMap[materialName]}',
                      icon: Icons.inventory_2_rounded,
                      color: bcNavy,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyConsumptionTab() {
    final inventoryService = Provider.of<InventoryRepository>(context);

    return Column(
      children: [
        _buildMonthPickerHeader(inventoryService),
        Expanded(
          child: StreamBuilder<List<InventoryTransaction>>(
            stream: inventoryService.getTransactionsStream(type: TransactionType.outward),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: AppLoader(size: 32));

              final monthlyTransactions = (snapshot.data ?? []).where((t) => t.timestamp.year == _selectedMonth.year && t.timestamp.month == _selectedMonth.month).toList();
              if (monthlyTransactions.isEmpty) return _buildEmptyState('No usage recorded for this month');

              final Map<String, double> usageMap = {};
              final Map<String, String> unitMap = {};

              for (var txn in monthlyTransactions) {
                usageMap[txn.materialName] = (usageMap[txn.materialName] ?? 0) + txn.quantity;
                unitMap[txn.materialName] = txn.unit;
              }

              return ListView.builder(
                itemCount: usageMap.length,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final materialName = usageMap.keys.elementAt(index);
                  return StaggeredAnimation(
                    index: index,
                    child: _ReportItemCard(
                      title: materialName,
                      value: '${usageMap[materialName]} ${unitMap[materialName]}',
                      icon: Icons.analytics_rounded,
                      color: Colors.purple,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStockValueTab() {
    final inventoryService = Provider.of<InventoryRepository>(context);

    return StreamBuilder<List<ConstructionMaterial>>(
      stream: inventoryService.getMaterialsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: AppLoader(size: 32));

        final materials = snapshot.data ?? [];
        if (materials.isEmpty) return _buildEmptyState('No inventory data available');

        double totalValue = 0;
        for (var m in materials) {
          totalValue += (m.currentStock * m.pricePerUnit);
        }

        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildTotalValueCard(totalValue),
                  const SizedBox(height: 24),
                  const ProfessionalSectionHeader(title: 'ASSET BREAKDOWN', subtitle: 'Detailed material valuation'),
                  ...materials.asMap().entries.map((entry) {
                    final m = entry.value;
                    final value = m.currentStock * m.pricePerUnit;
                    return StaggeredAnimation(
                      index: entry.key,
                      child: _ReportItemCard(
                        title: m.name,
                        value: '₹${NumberFormat('#,##,###').format(value)}',
                        subtitle: '${m.currentStock.toInt()} ${m.unitType.label} • ₹${m.pricePerUnit}/${m.unitType.label}',
                        icon: Icons.currency_rupee_rounded,
                        color: Colors.green,
                      ),
                    );
                  }),
                  const SizedBox(height: 80),
                ],
              ),
            ),
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton.extended(
                onPressed: _isExporting ? null : () async {
                  setState(() => _isExporting = true);
                  try {
                    await ReportExportService.exportStockValueToExcel(materials, 'Stock_Value_Report_${DateFormat('yyyyMMdd').format(DateTime.now())}');
                  } finally {
                    setState(() => _isExporting = false);
                  }
                },
                backgroundColor: bcNavy,
                icon: _isExporting ? const AppLoader(size: 20) : const Icon(Icons.file_download_rounded, color: bcAmber),
                label: Text(_isExporting ? 'EXPORTING...' : 'EXPORT EXCEL', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        );
      },
    );
  }


  Widget _buildDatePickerHeader(InventoryRepository inventory) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bcCard.withValues(alpha: 0.5),
        border: const Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('SELECTED PERIOD', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 1)),
              Text(DateFormat('dd MMMM yyyy').format(_selectedDate).toUpperCase(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: bcNavy)),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: () => _showExportDialog(
                  context,
                  inventory,
                  'Daily_Usage_${DateFormat('yyyyMMdd').format(_selectedDate)}',
                  (txns) => txns.where((t) => isSameDay(t.timestamp, _selectedDate)).toList(),
                ),
                icon: _isExporting ? const AppLoader(size: 16) : const Icon(Icons.file_download_rounded, color: bcNavy),
                tooltip: 'Export Report',
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(2020), lastDate: DateTime.now());
                  if (picked != null) setState(() => _selectedDate = picked);
                },
                icon: const Icon(Icons.calendar_today_rounded, size: 16),
                label: const Text('CALENDAR', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                style: ElevatedButton.styleFrom(backgroundColor: bcAmber, foregroundColor: bcNavy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 4),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthPickerHeader(InventoryRepository inventory) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bcCard.withValues(alpha: 0.5),
        border: const Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('REPORTING MONTH', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 1)),
              Text(DateFormat('MMMM yyyy').format(_selectedMonth).toUpperCase(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: bcNavy)),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: () => _showExportDialog(
                  context,
                  inventory,
                  'Monthly_Consumption_${DateFormat('yyyyMM').format(_selectedMonth)}',
                  (txns) => txns.where((t) => t.timestamp.year == _selectedMonth.year && t.timestamp.month == _selectedMonth.month).toList(),
                ),
                icon: _isExporting ? const AppLoader(size: 16) : const Icon(Icons.file_download_rounded, color: bcNavy),
                tooltip: 'Export Report',
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(context: context, initialDate: _selectedMonth, firstDate: DateTime(2020), lastDate: DateTime.now());
                  if (picked != null) setState(() => _selectedMonth = DateTime(picked.year, picked.month));
                },
                icon: const Icon(Icons.calendar_month_rounded, size: 16),
                label: const Text('SELECT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                style: ElevatedButton.styleFrom(backgroundColor: bcAmber, foregroundColor: bcNavy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 4),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalValueCard(double value) {
    return ProfessionalCard(
      padding: const EdgeInsets.all(32),
      useGlass: true,
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(Icons.account_balance_wallet_rounded, size: 140, color: bcNavy.withValues(alpha: 0.05)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('TOTAL INVENTORY ASSET VALUE', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
              const SizedBox(height: 12),
              Text(
                '₹ ${NumberFormat('#,##,###.00').format(value)}',
                style: const TextStyle(color: bcNavy, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: bcAmber.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                child: const Text('LIVE MARKET VALUATION', style: TextStyle(color: bcAmber, fontSize: 9, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReportItemCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;

  const _ReportItemCard({required this.title, required this.value, this.subtitle, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return ProfessionalCard(
      margin: const EdgeInsets.only(bottom: 12),
      useGlass: true,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: bcNavy, letterSpacing: -0.2)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.w600)),
                  ],
                ],
              ),
            ),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: bcNavy, letterSpacing: -0.5)),
          ],
        ),
      ),
    );
  }
}

Widget _buildEmptyState(String message) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.insert_drive_file_outlined, size: 48, color: Color(0xFFE2E8F0)),
        const SizedBox(height: 16),
        Text(message.toUpperCase(), style: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
      ],
    ),
  );
}


