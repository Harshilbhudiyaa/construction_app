import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/professional_theme.dart';
import '../../../../app/ui/widgets/app_search_field.dart';
import '../../../../app/ui/widgets/empty_state.dart';
import '../../../../app/ui/widgets/status_chip.dart';
import '../../../../app/ui/widgets/professional_page.dart';
import '../../../../app/ui/widgets/staggered_animation.dart';

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
      t == LedgerEntryType.inward ? 'INWARD' : 'OUTWARD';

  @override
  Widget build(BuildContext context) {
    return ProfessionalPage(
      title: 'Inventory Ledger',
      children: [
        _buildTacticalHeader(),

        const ProfessionalSectionHeader(
          title: 'Tactical Filter',
          subtitle: 'Segment stock movements',
        ),

        _buildFilterBar(),

        const ProfessionalSectionHeader(
          title: 'Movement Stream',
          subtitle: 'Detailed strategic logs',
        ),

        _buildEntryList(),

        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildTacticalHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          AppSearchField(
            hint: 'Search item, id, reference...',
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
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
                    backgroundColor: Colors.white.withOpacity(0.05),
                    selectedColor: Colors.blueAccent.withOpacity(0.3),
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : Colors.white60,
                      fontWeight: selected ? FontWeight.w900 : FontWeight.w500,
                      fontSize: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: selected ? Colors.blueAccent.withOpacity(0.5) : Colors.white.withOpacity(0.1),
                      ),
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildFilterChip('ALL', null),
          const SizedBox(width: 8),
          _buildFilterChip('INWARD', LedgerEntryType.inward),
          const SizedBox(width: 8),
          _buildFilterChip('OUTWARD', LedgerEntryType.outward),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, LedgerEntryType? type) {
    final selected = _filter == type;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _filter = type),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.blueAccent : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.white60,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEntryList() {
    if (_filteredItems.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 40),
        child: EmptyState(
          icon: Icons.receipt_long_rounded,
          title: 'NO STRATEGIC LOGS',
          message: 'Refine your search or filter parameters.',
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        final x = _filteredItems[index];
        return StaggeredAnimation(
          index: index,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ProfessionalCard(
              useGlass: true,
              padding: const EdgeInsets.all(16),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.08),
                  Colors.white.withOpacity(0.02),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: (x.type == LedgerEntryType.inward ? Colors.greenAccent : Colors.orangeAccent).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      x.type == LedgerEntryType.inward ? Icons.south_rounded : Icons.north_rounded,
                      color: x.type == LedgerEntryType.inward ? Colors.greenAccent : Colors.orangeAccent,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${x.item.toUpperCase()} • ${x.qty}${x.unit[0]}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${x.date} • ${x.id}',
                          style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            x.ref.toUpperCase(),
                            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 9, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusChip(
                    status: _toUi(x.type),
                    labelOverride: _label(x.type),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
