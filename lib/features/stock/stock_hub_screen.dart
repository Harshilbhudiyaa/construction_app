import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:construction_app/core/theme/aesthetic_tokens.dart';
import 'package:construction_app/data/models/material_model.dart';
import 'package:construction_app/data/models/party_model.dart';
import 'package:construction_app/data/models/stock_entry_model.dart';
import 'package:construction_app/data/repositories/inventory_repository.dart';
import 'package:construction_app/data/repositories/party_repository.dart';
import 'package:construction_app/data/repositories/site_repository.dart';
import 'package:construction_app/data/repositories/stock_entry_repository.dart';
import 'package:construction_app/features/stock/widgets/stock_entry_sheets.dart';

/// Hub screen offering two stock entry methods plus misc expense.
class StockHubScreen extends StatelessWidget {
  const StockHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bcSurface,
      appBar: AppBar(
        backgroundColor: bcNavy,
        foregroundColor: Colors.white,
        title: const Text('Stock Entry', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [bcNavy, Color(0xFF1E293B)]),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: bcAmber.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.add_box_rounded, color: bcAmber, size: 24),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Record Material Purchase', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15)),
                        SizedBox(height: 2),
                        Text('Select entry method below', style: TextStyle(color: Colors.white54, fontSize: 12)),
                      ]),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),
              const _SectionLabel('ENTRY METHODS'),
              const SizedBox(height: 12),

              // Method 1: Direct Entry
              _MethodCard(
                icon: Icons.add_circle_rounded,
                color: bcAmber,
                title: 'Direct Material Entry',
                subtitle: 'Add one material at a time\nAuto-calculates total from qty × rate',
                onTap: () => _openDirectEntry(context),
              ),

              const SizedBox(height: 12),

              // Method 2: Supplier Bill
              _MethodCard(
                icon: Icons.receipt_long_rounded,
                color: const Color(0xFF60A5FA),
                title: 'Supplier Bill Entry',
                subtitle: 'Multiple materials in one bill\nLinks all items to one supplier invoice',
                onTap: () => _openBillEntry(context),
              ),

              const SizedBox(height: 12),

              // Method 3: Misc Expense
              _MethodCard(
                icon: Icons.shopping_cart_outlined,
                color: const Color(0xFFA78BFA),
                title: 'Misc / Petty Expense',
                subtitle: 'Small purchases (nails, tools, transport)\nExpense-only — no inventory impact',
                onTap: () => _openMiscExpense(context),
              ),

              const SizedBox(height: 32),

              // Recent Entries
              const _SectionLabel('RECENT ENTRIES'),
              const SizedBox(height: 12),
              _RecentEntriesPreview(),
            ],
          ),
        ),
      ),
    );
  }

  void _openDirectEntry(BuildContext context) {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => const DirectEntrySheet(),
    );
  }

  void _openBillEntry(BuildContext context) {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => const SupplierBillSheet(),
    );
  }

  void _openMiscExpense(BuildContext context) {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => const MiscExpenseSheet(),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) => Text(label,
      style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.5));
}

// ─── Method Card ────────────────────────────────────────────────────────────

class _MethodCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MethodCard({required this.icon, required this.color, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w800, fontSize: 15)),
                const SizedBox(height: 3),
                Text(subtitle, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, height: 1.4)),
              ]),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: color),
          ],
        ),
      ),
    );
  }
}

// ─── Recent Entries Preview ────────────────────────────────────────────────────

class _RecentEntriesPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final stockRepo = context.watch<StockEntryRepository>();
    final siteId    = context.watch<SiteRepository>().selectedSiteId;
    final fmt       = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    final entries = siteId != null
        ? stockRepo.getEntriesForSite(siteId).take(5).toList()
        : stockRepo.entries.take(5).toList();

    if (entries.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
        child: const Row(children: [
          Icon(Icons.info_outline_rounded, color: Color(0xFFCBD5E1), size: 22),
          SizedBox(width: 12),
          Expanded(child: Text('No entries yet. Use a method above to record your first purchase.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12))),
        ]),
      );
    }

    return Column(
      children: entries.map((e) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
        child: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: _entryTypeColor(e.entryType).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(_entryTypeIcon(e.entryType), color: _entryTypeColor(e.entryType), size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(e.materialName.isEmpty ? e.subType : e.materialName,
                  style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w800, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(e.supplierName, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(fmt.format(e.totalAmount), style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 12)),
              if (e.pendingAmount > 0)
                Text('Due ${fmt.format(e.pendingAmount)}', style: const TextStyle(color: bcDanger, fontSize: 9.5, fontWeight: FontWeight.w700)),
            ]),
          ],
        ),
      )).toList(),
    );
  }

  IconData _entryTypeIcon(StockEntryType t) {
    switch (t) {
      case StockEntryType.directEntry:  return Icons.add_box_rounded;
      case StockEntryType.supplierBill: return Icons.receipt_long_rounded;
      case StockEntryType.miscExpense:  return Icons.shopping_cart_outlined;
    }
  }

  Color _entryTypeColor(StockEntryType t) {
    switch (t) {
      case StockEntryType.directEntry:  return bcAmber;
      case StockEntryType.supplierBill: return const Color(0xFF60A5FA);
      case StockEntryType.miscExpense:  return const Color(0xFFA78BFA);
    }
  }
}

// (Private widgets removed - refactored to stock_entry_sheets.dart)
