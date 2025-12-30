import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/ui/widgets/app_search_field.dart';
import '../../../../app/ui/widgets/empty_state.dart';
import '../../../../app/ui/widgets/section_header.dart';
import '../../../../app/ui/widgets/status_chip.dart';
import 'payout_detail_screen.dart';

enum PayoutStatus { paid, pending, failed }

class PayoutHistoryScreen extends StatefulWidget {
  const PayoutHistoryScreen({super.key});

  @override
  State<PayoutHistoryScreen> createState() => _PayoutHistoryScreenState();
}

class _PayoutHistoryScreenState extends State<PayoutHistoryScreen> {
  String _query = '';
  PayoutStatus? _filter; // null = all

  final _items = <_PayoutRow>[
    const _PayoutRow(id: 'PY-2201', date: 'Today', amount: 1200, mode: 'UPI', status: PayoutStatus.pending),
    const _PayoutRow(id: 'PY-2199', date: 'Yesterday', amount: 800, mode: 'Bank', status: PayoutStatus.paid),
    const _PayoutRow(id: 'PY-2196', date: 'Earlier', amount: 500, mode: 'Cash', status: PayoutStatus.failed),
  ];

  UiStatus _toUi(PayoutStatus s) {
    switch (s) {
      case PayoutStatus.paid:
        return UiStatus.approved; // green chip
      case PayoutStatus.pending:
        return UiStatus.pending;
      case PayoutStatus.failed:
        return UiStatus.rejected;
    }
  }

  String _label(PayoutStatus s) {
    switch (s) {
      case PayoutStatus.paid:
        return 'Paid';
      case PayoutStatus.pending:
        return 'Pending';
      case PayoutStatus.failed:
        return 'Failed';
    }
  }

  List<_PayoutRow> get _filtered {
    final q = _query.trim().toLowerCase();
    return _items.where((p) {
      if (_filter != null && p.status != _filter) return false;
      if (q.isEmpty) return true;
      return ('${p.id} ${p.date} ${p.mode} ${p.amount}').toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Payout History')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: [
          AppSearchField(
            hint: 'Search payout id, mode, date...',
            onChanged: (v) => setState(() => _query = v),
          ),

          const SectionHeader(
            title: 'Filters',
            subtitle: 'Paid / Pending / Failed',
          ),

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
                      label: const Text('Paid'),
                      selected: _filter == PayoutStatus.paid,
                      onSelected: (_) => setState(() => _filter = PayoutStatus.paid),
                    ),
                    FilterChip(
                      label: const Text('Pending'),
                      selected: _filter == PayoutStatus.pending,
                      onSelected: (_) => setState(() => _filter = PayoutStatus.pending),
                    ),
                    FilterChip(
                      label: const Text('Failed'),
                      selected: _filter == PayoutStatus.failed,
                      onSelected: (_) => setState(() => _filter = PayoutStatus.failed),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SectionHeader(
            title: 'Payouts',
            subtitle: 'Tap any payout to open details',
          ),

          if (_filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: const EmptyState(
                icon: Icons.receipt_long_rounded,
                title: 'No payouts found',
                message: 'Try clearing filters or changing search.',
              ),
            )
          else
            ..._filtered.map((p) {
              Color iconColor() {
                switch (p.status) {
                  case PayoutStatus.paid:
                    return Colors.green;
                  case PayoutStatus.pending:
                    return cs.tertiary;
                  case PayoutStatus.failed:
                    return cs.error;
                }
              }

              final chip = _toUi(p.status);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Card(
                  child: ListTile(
                    leading: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: iconColor().withOpacity(0.12),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      child: Icon(Icons.payments_rounded, color: iconColor()),
                    ),
                    title: Text('₹${p.amount} • ${p.mode}', style: const TextStyle(fontWeight: FontWeight.w900)),
                    subtitle: Text('${p.date} • ${p.id}'),
                    trailing: StatusChip(status: chip, labelOverride: _label(p.status)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PayoutDetailScreen(
                            payoutId: p.id,
                            date: p.date,
                            amount: p.amount,
                            mode: p.mode,
                            reference: 'REF-${p.id}',
                            status: chip,
                          ),
                        ),
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

class _PayoutRow {
  final String id;
  final String date;
  final int amount;
  final String mode;
  final PayoutStatus status;

  const _PayoutRow({
    required this.id,
    required this.date,
    required this.amount,
    required this.mode,
    required this.status,
  });
}
