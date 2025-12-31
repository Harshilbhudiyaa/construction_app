import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/professional_theme.dart';
import '../../../../app/ui/widgets/app_search_field.dart';
import '../../../../app/ui/widgets/empty_state.dart';
import '../../../../app/ui/widgets/status_chip.dart';
import '../../../../app/ui/widgets/professional_page.dart';

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
    const LedgerEntry(
      id: 'LD-0105',
      date: 'Today 03:10 PM',
      item: 'Cement (Bags)',
      qty: 10,
      unit: 'bags',
      type: LedgerEntryType.outward,
      ref: 'Work: Concrete',
    ),
    const LedgerEntry(
      id: 'LD-0104',
      date: 'Today 11:20 AM',
      item: 'Sand',
      qty: 3,
      unit: 'tons',
      type: LedgerEntryType.inward,
      ref: 'Supplier: ABC',
    ),
    const LedgerEntry(
      id: 'LD-0101',
      date: 'Yesterday 06:30 PM',
      item: 'Steel Rod',
      qty: 50,
      unit: 'kg',
      type: LedgerEntryType.outward,
      ref: 'Work: Block',
    ),
  ];

  List<LedgerEntry> get _filteredItems {
    final q = _query.trim().toLowerCase();
    return _items.where((x) {
      if (_filter != null && x.type != _filter) return false;
      if (q.isEmpty) return true;
      return ('${x.id} ${x.item} ${x.ref} ${x.date} ${x.qty}')
          .toLowerCase()
          .contains(q);
    }).toList();
  }

  UiStatus _toUi(LedgerEntryType t) =>
      t == LedgerEntryType.inward ? UiStatus.approved : UiStatus.pending;

  String _label(LedgerEntryType t) =>
      t == LedgerEntryType.inward ? 'Inward' : 'Outward';

  @override
  Widget build(BuildContext context) {
    return ProfessionalPage(
      title: 'Inventory Ledger',
      children: [
        AppSearchField(
          hint: 'Search item, id, reference...',
          onChanged: (v) => setState(() => _query = v),
        ),

        const ProfessionalSectionHeader(
          title: 'Timeline & Filters',
          subtitle: 'Track stock movements',
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Today', 'This Week', 'This Month'].map((r) {
                final selected = _range == r;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(r),
                    selected: selected,
                    onSelected: (_) => setState(() => _range = r),
                    backgroundColor: Colors.white.withOpacity(0.1),
                    selectedColor: Colors.white,
                    labelStyle: TextStyle(
                      color: selected ? AppColors.deepBlue1 : Colors.white,
                      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ProfessionalCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                   FilterChip(
                    label: const Text('All'),
                    selected: _filter == null,
                    onSelected: (_) => setState(() => _filter = null),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Inward'),
                    selected: _filter == LedgerEntryType.inward,
                    onSelected: (_) => setState(() => _filter = LedgerEntryType.inward),
                  ),
                  const SizedBox(width: 8),
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

        const ProfessionalSectionHeader(
          title: 'Ledger Entries',
          subtitle: 'Detailed history of materials',
        ),

        if (_filteredItems.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: EmptyState(
              icon: Icons.receipt_long_rounded,
              title: 'No entries found',
              message: 'Try changing filter or search.',
            ),
          )
        else
          ..._filteredItems.map((x) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ProfessionalCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.deepBlue1.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      x.type == LedgerEntryType.inward
                          ? Icons.arrow_downward_rounded
                          : Icons.arrow_upward_rounded,
                      color: x.type == LedgerEntryType.inward ? Colors.green : Colors.orange,
                    ),
                  ),
                  title: Text(
                    '${x.item} • ${x.qty} ${x.unit}',
                    style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.deepBlue1),
                  ),
                  subtitle: Text(
                    '${x.date}\nRef: ${x.ref} • ${x.id}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  isThreeLine: true,
                  trailing: StatusChip(
                    status: _toUi(x.type),
                    labelOverride: _label(x.type),
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Open detail: ${x.id}')),
                    );
                  },
                ),
              ),
            );
          }),

        const SizedBox(height: 32),
      ],
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
