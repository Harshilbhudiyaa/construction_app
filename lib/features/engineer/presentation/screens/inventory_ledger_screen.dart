import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/ui/widgets/app_search_field.dart';
import '../../../../app/ui/widgets/empty_state.dart';
import '../../../../app/ui/widgets/section_header.dart';
import '../../../../app/ui/widgets/status_chip.dart';

enum LedgerEntryType { inward, outward }

class InventoryLedgerScreen extends StatefulWidget {
  const InventoryLedgerScreen({super.key});

  @override
  State<InventoryLedgerScreen> createState() => _InventoryLedgerScreenState();
}

class _InventoryLedgerScreenState extends State<InventoryLedgerScreen> {
  String _query = '';
  LedgerEntryType? _filter;
  String _range = 'This Week';

  final _items = <LedgerEntry>[
    const LedgerEntry(id: 'LD-0105', date: 'Today 03:10 PM', item: 'Cement (Bags)', qty: 10, unit: 'bags', type: LedgerEntryType.outward, ref: 'Work: Concrete'),
    const LedgerEntry(id: 'LD-0104', date: 'Today 11:20 AM', item: 'Sand', qty: 3, unit: 'tons', type: LedgerEntryType.inward, ref: 'Supplier: ABC'),
    const LedgerEntry(id: 'LD-0101', date: 'Yesterday 06:30 PM', item: 'Steel Rod', qty: 50, unit: 'kg', type: LedgerEntryType.outward, ref: 'Work: Block'),
  ];

  List<LedgerEntry> get _filteredItems {
    final q = _query.trim().toLowerCase();
    return _items.where((x) {
      if (_filter != null && x.type != _filter) return false;
      if (q.isEmpty) return true;
      return ('${x.id} ${x.item} ${x.ref} ${x.date} ${x.qty}').toLowerCase().contains(q);
    }).toList();
  }

  UiStatus _toUi(LedgerEntryType t) => t == LedgerEntryType.inward ? UiStatus.approved : UiStatus.pending;

  String _label(LedgerEntryType t) => t == LedgerEntryType.inward ? 'In' : 'Out';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory Ledger')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: [
          AppSearchField(
            hint: 'Search item, id, ref...',
            onChanged: (v) => setState(() => _query = v),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['Today', 'This Week', 'This Month'].map((r) {
                final selected = _range == r;
                return ChoiceChip(
                  label: Text(r),
                  selected: selected,
                  onSelected: (_) => setState(() => _range = r),
                );
              }).toList(),
            ),
          ),

          const SectionHeader(title: 'Filters', subtitle: 'Inward / Outward'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: _filter == null,
                      onSelected: (_) => setState(() => _filter = null),
                    ),
                    FilterChip(
                      label: const Text('Inward'),
                      selected: _filter == LedgerEntryType.inward,
                      onSelected: (_) => setState(() => _filter = LedgerEntryType.inward),
                    ),
                    FilterChip(
                      label: const Text('Outward'),
                      selected: _filter == LedgerEntryType.outward,
                      onSelected: (_) => setState(() => _filter = LedgerEntryType.outward),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SectionHeader(title: 'Entries', subtitle: 'Stock movement log (UI-only)'),

          if (_filteredItems.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: const EmptyState(
                icon: Icons.receipt_long_rounded,
                title: 'No entries found',
                message: 'Try changing filter or search.',
              ),
            )
          else
            ..._filteredItems.map((x) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Card(
                  child: ListTile(
                    leading: Icon(x.type == LedgerEntryType.inward ? Icons.input_rounded : Icons.output_rounded),
                    title: Text('${x.item} • ${x.qty} ${x.unit}', style: const TextStyle(fontWeight: FontWeight.w900)),
                    subtitle: Text('${x.date}\n${x.ref} • ${x.id}'),
                    isThreeLine: true,
                    trailing: StatusChip(status: _toUi(x.type), labelOverride: _label(x.type)),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Open ledger detail (${x.id}) — next UI step')),
                      );
                    },
                  ),
                ),
              );
            }),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class LedgerEntry {
  final String id;
  final String date;
  final String item;
  final int qty;
  final String unit;
  final LedgerEntryType type;
  final String ref;

  const LedgerEntry({
    required this.id,
    required this.date,
    required this.item,
    required this.qty,
    required this.unit,
    required this.type,
    required this.ref,
  });
}
