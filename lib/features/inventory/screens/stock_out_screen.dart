import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:construction_app/core/theme/aesthetic_tokens.dart';
import 'package:construction_app/data/models/inventory_transaction.dart';
import 'package:construction_app/data/models/material_model.dart';
import 'package:construction_app/data/repositories/inventory_repository.dart';
import 'package:construction_app/data/repositories/auth_repository.dart';
import 'package:construction_app/shared/widgets/helpful_text_field.dart';
import 'package:construction_app/shared/widgets/helpful_dropdown.dart';
import 'package:construction_app/shared/widgets/app_search_field.dart';
import 'package:construction_app/shared/widgets/staggered_animation.dart';

// ──────────────────────────────────────────────────────────────────────────────
// STOCK OUT SCREEN — Full Standalone Page
// ──────────────────────────────────────────────────────────────────────────────

class StockOutScreen extends StatefulWidget {
  const StockOutScreen({super.key});

  @override
  State<StockOutScreen> createState() => _StockOutScreenState();
}

class _StockOutScreenState extends State<StockOutScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fabAnimCtrl;
  late Animation<double> _fabScaleAnim;

  String _searchQuery = '';
  String _filterType = 'All'; // All, Today, This Week

  @override
  void initState() {
    super.initState();
    _fabAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fabScaleAnim = CurvedAnimation(
      parent: _fabAnimCtrl,
      curve: Curves.elasticOut,
    );
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _fabAnimCtrl.forward();
    });
  }

  @override
  void dispose() {
    _fabAnimCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bcSurface,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildSliverHeader(),
        ],
        body: _buildBody(),
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabScaleAnim,
        child: FloatingActionButton.extended(
          heroTag: 'stock_out_fab',
          onPressed: () => _showStockOutForm(context),
          backgroundColor: const Color(0xFFEF4444),
          foregroundColor: Colors.white,
          elevation: 12,
          icon: const Icon(Icons.output_rounded, size: 22),
          label: const Text(
            'Stock Out',
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
          ),
        ),
      ),
    );
  }

  // ── Animated Sliver App Bar ──────────────────────────────────────────────────

  Widget _buildSliverHeader() {
    return StreamBuilder<List<InventoryTransaction>>(
      stream: context
          .read<InventoryRepository>()
          .getTransactionsStream(type: TransactionType.outward),
      builder: (ctx, snap) {
        final txns = snap.data ?? [];
        final now = DateTime.now();
        final today = txns.where((t) =>
            t.timestamp.year == now.year &&
            t.timestamp.month == now.month &&
            t.timestamp.day == now.day).length;
        final totalQty = txns.fold<double>(0, (s, t) => s + t.quantity);

        return SmartConstructionSliverAppBar(
          title: 'Stock Out',
          subtitle: 'Material consumption & issue management',
          category: 'INVENTORY OUTWARD',
          isFull: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.bar_chart_rounded, color: bcAmber),
              tooltip: 'Analytics',
              onPressed: () => _showAnalyticsSheet(context, txns),
            ),
          ],
          headerStats: [
            HeroStatPill(
              label: 'Total Issues',
              value: '${txns.length}',
              icon: Icons.output_rounded,
              color: const Color(0xFFEF4444),
            ),
            HeroStatPill(
              label: 'Issued Today',
              value: '$today',
              icon: Icons.today_rounded,
              color: bcAmber,
            ),
            HeroStatPill(
              label: 'Total Qty',
              value: totalQty.toStringAsFixed(0),
              icon: Icons.scale_rounded,
              color: bcSuccess,
            ),
          ],
        );
      },
    );
  }

  // ── Body ─────────────────────────────────────────────────────────────────────

  Widget _buildBody() {
    return Column(
      children: [
        _buildControlBar(),
        Expanded(child: _buildTransactionList()),
      ],
    );
  }

  Widget _buildControlBar() {
    return Container(
      color: bcSurface,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        children: [
          AppSearchField(
            hint: 'Search by material name, purpose...',
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
          const SizedBox(height: 12),
          _buildFilterChips(),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Today', 'This Week'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isActive = _filterType == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _filterType = f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFFEF4444) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isActive
                        ? const Color(0xFFEF4444)
                        : const Color(0xFFE2E8F0),
                    width: 1.5,
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : [],
                ),
                child: Text(
                  f,
                  style: TextStyle(
                    color: isActive ? Colors.white : bcTextSecondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTransactionList() {
    return StreamBuilder<List<InventoryTransaction>>(
      stream: context
          .read<InventoryRepository>()
          .getTransactionsStream(type: TransactionType.outward),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFEF4444)),
          );
        }

        final now = DateTime.now();
        var txns = snapshot.data ?? [];

        // Apply time filter
        if (_filterType == 'Today') {
          txns = txns
              .where((t) =>
                  t.timestamp.year == now.year &&
                  t.timestamp.month == now.month &&
                  t.timestamp.day == now.day)
              .toList();
        } else if (_filterType == 'This Week') {
          final weekAgo = now.subtract(const Duration(days: 7));
          txns = txns.where((t) => t.timestamp.isAfter(weekAgo)).toList();
        }

        // Apply search
        if (_searchQuery.isNotEmpty) {
          final q = _searchQuery.toLowerCase();
          txns = txns
              .where((t) =>
                  t.materialName.toLowerCase().contains(q) ||
                  (t.remarks?.toLowerCase().contains(q) ?? false))
              .toList();
        }

        if (txns.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          itemCount: txns.length,
          itemBuilder: (context, index) {
            return StaggeredAnimation(
              index: index,
              child: _StockOutCard(transaction: txns[index]),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFEF4444).withValues(alpha: 0.12),
                    const Color(0xFFEF4444).withValues(alpha: 0.04),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.output_rounded,
                size: 44,
                color: Color(0xFFEF4444),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Stock Out Records',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: bcNavy,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _searchQuery.isNotEmpty || _filterType != 'All'
                  ? 'No records match your current filter.\nTry changing the filter or search term.'
                  : 'Start recording material consumption\nby tapping the Stock Out button below.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: bcTextSecondary,
                fontSize: 14,
                height: 1.6,
              ),
            ),
            if (_filterType != 'All' || _searchQuery.isNotEmpty) ...[
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () => setState(() {
                  _filterType = 'All';
                  _searchQuery = '';
                }),
                icon: const Icon(Icons.clear_all_rounded, size: 18),
                label: const Text('Clear Filters'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFEF4444),
                  side: const BorderSide(color: Color(0xFFEF4444)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Stock Out Form (bottom sheet) ────────────────────────────────────────────

  void _showStockOutForm(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _StockOutFormSheet(),
    );
  }

  // ── Analytics Sheet ──────────────────────────────────────────────────────────

  void _showAnalyticsSheet(
      BuildContext context, List<InventoryTransaction> txns) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _AnalyticsSheet(transactions: txns),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// STOCK OUT CARD
// ──────────────────────────────────────────────────────────────────────────────

class _StockOutCard extends StatelessWidget {
  final InventoryTransaction transaction;

  const _StockOutCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMM, hh:mm a').format(transaction.timestamp);
    final amtStr = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    ).format(transaction.totalAmount ?? 0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showDetail(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon Box
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEF4444), Color(0xFFF87171)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: const Icon(Icons.output_rounded,
                      color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),

                // Info section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.materialName,
                        style: const TextStyle(
                          color: bcNavy,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _chip(
                            '${transaction.quantity} ${transaction.unit}',
                            const Color(0xFFEF4444),
                            Icons.scale_rounded,
                          ),
                          const SizedBox(width: 6),
                          if (transaction.siteId != null)
                            _chip(
                              transaction.siteId!,
                              bcInfo,
                              Icons.location_on_rounded,
                            ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded,
                              size: 11, color: bcTextSecondary),
                          const SizedBox(width: 4),
                          Text(
                            dateStr,
                            style: const TextStyle(
                              color: bcTextSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (transaction.remarks != null &&
                          transaction.remarks!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          transaction.remarks!,
                          style: TextStyle(
                            color: bcNavy.withValues(alpha: 0.45),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                // Amount + by
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        amtStr,
                        style: const TextStyle(
                          color: Color(0xFFEF4444),
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'By ${transaction.createdBy}',
                      style: TextStyle(
                        color: bcNavy.withValues(alpha: 0.35),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _TransactionDetailSheet(transaction: transaction),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// TRANSACTION DETAIL SHEET
// ──────────────────────────────────────────────────────────────────────────────

class _TransactionDetailSheet extends StatelessWidget {
  final InventoryTransaction transaction;

  const _TransactionDetailSheet({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final amtFmt = NumberFormat.currency(
        locale: 'en_IN', symbol: '₹', decimalDigits: 2);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEF4444), Color(0xFFF87171)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.output_rounded,
                        color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.materialName,
                          style: const TextStyle(
                            color: bcNavy,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'STOCK OUTWARD RECORD',
                          style: TextStyle(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.8),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: bcNavy),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 24, indent: 24, endIndent: 24),
            Expanded(
              child: ListView(
                controller: ctrl,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _DetailRow(
                    label: 'Quantity Issued',
                    value: '${transaction.quantity} ${transaction.unit}',
                    color: const Color(0xFFEF4444),
                    icon: Icons.scale_rounded,
                  ),
                  _DetailRow(
                    label: 'Rate per Unit',
                    value: amtFmt.format(transaction.rate ?? 0),
                    color: bcSuccess,
                    icon: Icons.currency_rupee_rounded,
                  ),
                  _DetailRow(
                    label: 'Total Value',
                    value: amtFmt.format(transaction.totalAmount ?? 0),
                    color: bcNavy,
                    icon: Icons.account_balance_wallet_rounded,
                  ),
                  if (transaction.siteId != null)
                    _DetailRow(
                      label: 'Site',
                      value: transaction.siteId!,
                      color: bcInfo,
                      icon: Icons.location_on_rounded,
                    ),
                  _DetailRow(
                    label: 'Date & Time',
                    value: DateFormat('dd MMM yyyy, hh:mm a')
                        .format(transaction.timestamp),
                    color: bcAmber,
                    icon: Icons.access_time_filled_rounded,
                  ),
                  _DetailRow(
                    label: 'Recorded By',
                    value: transaction.createdBy,
                    color: bcTextSecondary,
                    icon: Icons.person_rounded,
                  ),
                  if (transaction.remarks != null &&
                      transaction.remarks!.isNotEmpty)
                    _DetailRow(
                      label: 'Notes / Purpose',
                      value: transaction.remarks!,
                      color: bcTextSecondary,
                      icon: Icons.notes_rounded,
                      multiLine: true,
                    ),
                  _DetailRow(
                    label: 'Transaction ID',
                    value: transaction.id,
                    color: bcTextSecondary,
                    icon: Icons.tag_rounded,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  final bool multiLine;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    this.multiLine = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Row(
          crossAxisAlignment:
              multiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: bcTextSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      color: bcNavy,
                      fontSize: multiLine ? 13 : 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// STOCK OUT FORM BOTTOM SHEET
// ──────────────────────────────────────────────────────────────────────────────

class _StockOutFormSheet extends StatefulWidget {
  const _StockOutFormSheet();

  @override
  State<_StockOutFormSheet> createState() => _StockOutFormSheetState();
}

class _StockOutFormSheetState extends State<_StockOutFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _qtyCtrl = TextEditingController();
  final _purposeCtrl = TextEditingController();
  final _remarksCtrl = TextEditingController();

  ConstructionMaterial? _selectedMaterial;
  String _usageType = 'Project Use';
  bool _isLoading = false;

  final List<String> _usageTypes = [
    'Project Use',
    'Foundation Work',
    'Slab Casting',
    'Brickwork',
    'Plastering',
    'Finishing',
    'Testing/Sample',
    'Other',
  ];

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _purposeCtrl.dispose();
    _remarksCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF8FAFC),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // Handle bar
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            _buildFormHeader(),
            // Form Body
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  controller: ctrl,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                  children: [
                    // ── Material Selection ──────────────────────────────────
                    _FormSection(
                      label: 'ITEM SELECTION',
                      icon: Icons.inventory_2_rounded,
                      child: _buildMaterialTile(),
                    ),
                    const SizedBox(height: 16),

                    // ── Selected Material Stock Info ────────────────────────
                    if (_selectedMaterial != null)
                      _buildStockInfoCard(),

                    const SizedBox(height: 16),

                    // ── Quantity & Usage Type ──────────────────────────────
                    _FormSection(
                      label: 'QUANTITY & USAGE',
                      icon: Icons.tune_rounded,
                      child: Column(
                        children: [
                          HelpfulTextField(
                            label: _selectedMaterial != null
                                ? 'Quantity (${_selectedMaterial!.unitType})'
                                : 'Quantity',
                            controller: _qtyCtrl,
                            hintText: 'e.g. 50',
                            keyboardType:
                                const TextInputType.numberWithOptions(decimal: true),
                            icon: Icons.scale_rounded,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Please enter quantity';
                              }
                              final qty = double.tryParse(v);
                              if (qty == null || qty <= 0) {
                                return 'Enter a valid positive number';
                              }
                              if (_selectedMaterial != null &&
                                  qty > _selectedMaterial!.currentStock) {
                                return 'Exceeds available stock (${_selectedMaterial!.currentStock} ${_selectedMaterial!.unitType})';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          HelpfulDropdown<String>(
                            label: 'Usage Type',
                            value: _usageType,
                            items: _usageTypes,
                            onChanged: (v) =>
                                setState(() => _usageType = v!),
                            useGlass: false,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Purpose & Remarks ──────────────────────────────────
                    _FormSection(
                      label: 'DETAILS',
                      icon: Icons.edit_note_rounded,
                      child: Column(
                        children: [
                          HelpfulTextField(
                            label: 'Purpose / Location',
                            controller: _purposeCtrl,
                            hintText:
                                'e.g. Floor 2 slab casting, Column A foundation',
                            icon: Icons.place_rounded,
                            validator: (v) =>
                                v!.isEmpty ? 'Please enter purpose' : null,
                          ),
                          const SizedBox(height: 14),
                          HelpfulTextField(
                            label: 'Remarks (Optional)',
                            controller: _remarksCtrl,
                            hintText: 'Additional notes...',
                            icon: Icons.notes_rounded,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Submit Button ──────────────────────────────────────
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEF4444), Color(0xFFF87171)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.output_rounded,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Record Stock Out',
                  style: TextStyle(
                    color: bcNavy,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'MATERIAL CONSUMPTION ENTRY',
                  style: TextStyle(
                    color: Color(0xFFEF4444),
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: bcNavy),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialTile() {
    if (_selectedMaterial == null) {
      return GestureDetector(
        onTap: _showMaterialPicker,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEF4444).withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFEF4444).withValues(alpha: 0.2),
              width: 1.5,
              style: BorderStyle.solid,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.add_box_rounded,
                    color: Color(0xFFEF4444), size: 22),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tap to select material',
                      style: TextStyle(
                        color: bcNavy,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Choose from your inventory',
                      style: TextStyle(
                        color: bcTextSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: Color(0xFFEF4444), size: 22),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: _showMaterialPicker,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFEF4444).withValues(alpha: 0.07),
              const Color(0xFFEF4444).withValues(alpha: 0.02),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFEF4444).withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: bcNavy,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.inventory_2_rounded,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedMaterial!.name,
                    style: const TextStyle(
                      color: bcNavy,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_selectedMaterial!.brand ?? "No Brand"} • ${_selectedMaterial!.subType}',
                    style: const TextStyle(
                      color: bcTextSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: bcNavy.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Change',
                style: TextStyle(
                  color: bcNavy.withValues(alpha: 0.6),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockInfoCard() {
    final m = _selectedMaterial!;
    final isLow = m.isLowStock;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isLow
            ? const Color(0xFFEF4444).withValues(alpha: 0.05)
            : bcSuccess.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isLow
              ? const Color(0xFFEF4444).withValues(alpha: 0.2)
              : bcSuccess.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isLow ? Icons.warning_amber_rounded : Icons.check_circle_rounded,
            color: isLow ? const Color(0xFFEF4444) : bcSuccess,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLow ? 'LOW STOCK WARNING' : 'STOCK AVAILABLE',
                  style: TextStyle(
                    color: isLow ? const Color(0xFFEF4444) : bcSuccess,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Current: ${m.currentStock} ${m.unitType}  •  Min Limit: ${m.minimumStockLimit} ${m.unitType}',
                  style: TextStyle(
                    color: bcNavy.withValues(alpha: 0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEF4444),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          shadowColor: const Color(0xFFEF4444).withValues(alpha: 0.4),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_rounded, size: 20, color: Colors.white),
                  SizedBox(width: 10),
                  Text(
                    'FINALIZE STOCK OUT',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _showMaterialPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, ctrl) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF8FAFC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: bcNavy,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.inventory_2_rounded,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Select Material',
                              style: TextStyle(
                                  color: bcNavy,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18)),
                          Text('Available in inventory',
                              style: TextStyle(
                                  color: bcTextSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: bcNavy),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: StreamBuilder<List<ConstructionMaterial>>(
                  stream: context
                      .read<InventoryRepository>()
                      .getMaterialsStream(),
                  builder: (ctx, snap) {
                    final materials = snap.data ?? [];
                    if (materials.isEmpty) {
                      return const Center(
                          child: Text('No materials in inventory'));
                    }
                    return ListView.builder(
                      controller: ctrl,
                      padding: const EdgeInsets.all(16),
                      itemCount: materials.length,
                      itemBuilder: (ctx, i) {
                        final m = materials[i];
                        final isLow = m.isLowStock;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                setState(() => _selectedMaterial = m);
                                Navigator.pop(context);
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isLow
                                        ? const Color(0xFFEF4444).withValues(alpha: 0.2)
                                        : const Color(0xFFE2E8F0),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.03),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: bcNavy.withValues(alpha: 0.05),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                          Icons.foundation_rounded,
                                          color: bcNavy,
                                          size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            m.name,
                                            style: const TextStyle(
                                              color: bcNavy,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${m.brand ?? "No Brand"}  •  ${m.subType}',
                                            style: const TextStyle(
                                              color: bcTextSecondary,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '${m.currentStock} ${m.unitType}',
                                          style: TextStyle(
                                            color: isLow
                                                ? const Color(0xFFEF4444)
                                                : bcSuccess,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 13,
                                          ),
                                        ),
                                        if (isLow)
                                          const Text(
                                            'LOW STOCK',
                                            style: TextStyle(
                                              color: Color(0xFFEF4444),
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.8,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.chevron_right_rounded,
                                        color: bcTextSecondary, size: 18),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMaterial == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a material first'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final quantity = double.tryParse(_qtyCtrl.text) ?? 0.0;
      final repo = context.read<InventoryRepository>();
      final auth = context.read<AuthRepository>();

      final purpose = _purposeCtrl.text.trim();
      final remarks = '$_usageType — $purpose'
          '${_remarksCtrl.text.trim().isNotEmpty ? " | ${_remarksCtrl.text.trim()}" : ""}';

      await repo.recordStockOut(
        materialId: _selectedMaterial!.id,
        quantity: quantity,
        remarks: remarks,
        purpose: purpose,
        issuedTo: _usageType,
        siteId: _selectedMaterial!.siteId,
        recordedBy: auth.userName ?? 'System',
      );

      if (mounted) {
        HapticFeedback.lightImpact();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: Colors.white, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Stock Out recorded: ${quantity.toStringAsFixed(0)} ${_selectedMaterial!.unitType} of ${_selectedMaterial!.name}',
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// ANALYTICS SHEET
// ──────────────────────────────────────────────────────────────────────────────

class _AnalyticsSheet extends StatelessWidget {
  final List<InventoryTransaction> transactions;

  const _AnalyticsSheet({required this.transactions});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = transactions
        .where((t) =>
            t.timestamp.year == now.year &&
            t.timestamp.month == now.month &&
            t.timestamp.day == now.day)
        .toList();
    final thisWeek = transactions
        .where((t) => t.timestamp.isAfter(now.subtract(const Duration(days: 7))))
        .toList();

    // Group by material
    final Map<String, double> byMaterial = {};
    for (final t in transactions) {
      byMaterial[t.materialName] =
          (byMaterial[t.materialName] ?? 0) + t.quantity;
    }
    final topMaterials = byMaterial.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final totalValue = transactions.fold<double>(
        0, (s, t) => s + (t.totalAmount ?? 0));

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: bcNavy,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.bar_chart_rounded,
                        color: bcAmber, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Stock Out Analytics',
                    style: TextStyle(
                      color: bcNavy,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: bcNavy),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                controller: ctrl,
                padding: const EdgeInsets.all(20),
                children: [
                  // KPI row
                  Row(
                    children: [
                      _KpiTile(
                        label: 'Today',
                        value: '${today.length}',
                        sub: 'entries',
                        color: bcAmber,
                        icon: Icons.today_rounded,
                      ),
                      const SizedBox(width: 12),
                      _KpiTile(
                        label: 'This Week',
                        value: '${thisWeek.length}',
                        sub: 'entries',
                        color: bcInfo,
                        icon: Icons.date_range_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _KpiTile(
                        label: 'Total',
                        value: '${transactions.length}',
                        sub: 'all time',
                        color: const Color(0xFFEF4444),
                        icon: Icons.output_rounded,
                      ),
                      const SizedBox(width: 12),
                      _KpiTile(
                        label: 'Total Value',
                        value: NumberFormat.compactCurrency(
                                locale: 'en_IN',
                                symbol: '₹',
                                decimalDigits: 0)
                            .format(totalValue),
                        sub: 'issued',
                        color: bcSuccess,
                        icon: Icons.currency_rupee_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Top consumed materials
                  if (topMaterials.isNotEmpty) ...[
                    const Text(
                      'TOP CONSUMED MATERIALS',
                      style: TextStyle(
                        color: bcNavy,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...topMaterials.take(5).map((e) => _MaterialBar(
                          name: e.key,
                          qty: e.value,
                          maxQty: topMaterials.first.value,
                        )),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KpiTile extends StatelessWidget {
  final String label, value, sub;
  final Color color;
  final IconData icon;

  const _KpiTile({
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: bcNavy.withValues(alpha: 0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ),
            Text(
              sub,
              style: TextStyle(
                color: bcNavy.withValues(alpha: 0.4),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MaterialBar extends StatelessWidget {
  final String name;
  final double qty;
  final double maxQty;

  const _MaterialBar({
    required this.name,
    required this.qty,
    required this.maxQty,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = maxQty > 0 ? qty / maxQty : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    color: bcNavy,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                qty.toStringAsFixed(1),
                style: const TextStyle(
                  color: Color(0xFFEF4444),
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFEF4444)),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// HELPERS
// ──────────────────────────────────────────────────────────────────────────────

class _FormSection extends StatelessWidget {
  final String label;
  final IconData icon;
  final Widget child;

  const _FormSection({
    required this.label,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: const Color(0xFFEF4444)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: bcNavy.withValues(alpha: 0.6),
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Divider(color: bcNavy.withValues(alpha: 0.08)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}
