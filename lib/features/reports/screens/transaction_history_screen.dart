import 'package:construction_app/data/models/inventory_transaction.dart';
import 'package:construction_app/data/repositories/inventory_repository.dart';
import 'package:construction_app/core/theme/aesthetic_tokens.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:construction_app/shared/widgets/loading_indicators.dart';
import 'package:construction_app/shared/widgets/staggered_animation.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  String? _selectedMaterialId;
  TransactionType? _selectedType;
  DateTimeRange? _selectedDateRange;

  @override
  Widget build(BuildContext context) {
    final inventoryService = Provider.of<InventoryRepository>(context);

    return Scaffold(
      backgroundColor: bcSurface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SmartConstructionSliverAppBar(
            title: 'Audit Trail',
            subtitle: 'Real-time movement ledger',
            category: 'INVENTORY MODULE',
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list_rounded, color: Colors.white70),
                onPressed: () => _showFilterDialog(context, inventoryService),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildActiveFilters(),
                  _buildTransactionsStream(inventoryService),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilters() {
    if (_selectedMaterialId == null && _selectedType == null && _selectedDateRange == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Wrap(
        spacing: 8,
        children: [
          if (_selectedType != null) _FilterChip(label: _selectedType!.displayName, onClear: () => setState(() => _selectedType = null)),
          if (_selectedDateRange != null) _FilterChip(label: 'Date Range', onClear: () => setState(() => _selectedDateRange = null)),
          if (_selectedMaterialId != null) _FilterChip(label: 'Specific Material', onClear: () => setState(() => _selectedMaterialId = null)),
        ],
      ),
    );
  }

  Widget _buildTransactionsStream(InventoryRepository service) {
    return StreamBuilder<List<InventoryTransaction>>(
      stream: service.getTransactionsStream(materialId: _selectedMaterialId, type: _selectedType),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: Padding(padding: EdgeInsets.all(40), child: AppLoader(size: 32)));
        if (snapshot.hasError) return const Center(child: Text('Audit records unavailable'));

        var transactions = snapshot.data ?? [];
        if (_selectedDateRange != null) {
          transactions = transactions.where((t) => t.timestamp.isAfter(_selectedDateRange!.start) && t.timestamp.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)))).toList();
        }

        if (transactions.isEmpty) return _buildEmptyState();

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: transactions.length,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemBuilder: (context, index) {
            return StaggeredAnimation(
              index: index,
              child: _TransactionCard(txn: transactions[index]),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        children: [
          SizedBox(height: 60),
          Icon(Icons.history_rounded, size: 48, color: Color(0xFFE2E8F0)),
          SizedBox(height: 16),
          Text('NO LEDGER ENTRIES FOUND', style: TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context, InventoryRepository service) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(color: bcSurface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('FILTER LEDGER', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: bcNavy, letterSpacing: 1)),
            const SizedBox(height: 24),
            DropdownButtonFormField<TransactionType>(
              initialValue: _selectedType,
              decoration: _inputDecoration('Movement Type'),
              items: [
                const DropdownMenuItem(value: null, child: Text('All Types')),
                ...TransactionType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.displayName))),
              ],
              onChanged: (val) => setState(() => _selectedType = val),
            ),
            const SizedBox(height: 16),
            _buildDateRangePicker(),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(backgroundColor: bcNavy, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('APPLY AUDIT FILTERS', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangePicker() {
    return InkWell(
      onTap: () async {
        final picked = await showDateRangePicker(context: context, firstDate: DateTime(2020), lastDate: DateTime.now());
        if (picked != null) setState(() => _selectedDateRange = picked);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: bcCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded, size: 18, color: bcNavy),
            const SizedBox(width: 12),
            Text(
              _selectedDateRange == null ? 'Select Date Range' : '${DateFormat('dd MMM').format(_selectedDateRange!.start)} - ${DateFormat('dd MMM').format(_selectedDateRange!.end)}',
              style: const TextStyle(fontWeight: FontWeight.w700, color: bcNavy, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 12),
      filled: true,
      fillColor: bcCard,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final InventoryTransaction txn;
  const _TransactionCard({required this.txn});

  @override
  Widget build(BuildContext context) {
    final isPositive = txn.stockImpact > 0;
    final color = _getTxnColor(txn.type);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: bcCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(_getTxnIcon(txn.type), color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(txn.materialName.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: bcNavy, letterSpacing: -0.2)),
                  const SizedBox(height: 2),
                  Text(DateFormat('dd MMM yyyy • hh:mm a').format(txn.timestamp), style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isPositive ? "+" : ""}${txn.quantity}',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: color, letterSpacing: -0.5),
                ),
                Text(txn.unit.toUpperCase(), style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getTxnColor(TransactionType type) {
    switch (type) {
      case TransactionType.inward: return bcSuccess;
      case TransactionType.outward: return bcDanger;
      case TransactionType.damage: return Colors.orange;
      case TransactionType.transfer: return Colors.blue;
      default: return bcNavy;
    }
  }

  IconData _getTxnIcon(TransactionType type) {
    switch (type) {
      case TransactionType.inward: return Icons.add_business_rounded;
      case TransactionType.outward: return Icons.local_shipping_rounded;
      case TransactionType.damage: return Icons.warning_amber_rounded;
      case TransactionType.transfer: return Icons.swap_horiz_rounded;
      default: return Icons.history_rounded;
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onClear;
  const _FilterChip({required this.label, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white)),
      backgroundColor: bcNavy,
      deleteIcon: const Icon(Icons.close, size: 14, color: bcAmber),
      onDeleted: onClear,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: BorderSide.none,
    );
  }
}


