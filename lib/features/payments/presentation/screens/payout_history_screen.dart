import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/professional_theme.dart';
import '../../../../app/ui/widgets/app_search_field.dart';
import '../../../../app/ui/widgets/empty_state.dart';
import '../../../../app/ui/widgets/status_chip.dart';
import '../../../../app/ui/widgets/professional_page.dart';
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
    const _PayoutRow(
      id: 'PY-2201',
      date: 'Today',
      amount: 1200,
      mode: 'UPI',
      status: PayoutStatus.pending,
    ),
    const _PayoutRow(
      id: 'PY-2199',
      date: 'Yesterday',
      amount: 800,
      mode: 'Bank',
      status: PayoutStatus.paid,
    ),
    const _PayoutRow(
      id: 'PY-2196',
      date: 'Earlier',
      amount: 500,
      mode: 'Cash',
      status: PayoutStatus.failed,
    ),
  ];

  UiStatus _toUi(PayoutStatus s) {
    switch (s) {
      case PayoutStatus.paid:
        return UiStatus.approved;
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
      return ('${p.id} ${p.date} ${p.mode} ${p.amount}').toLowerCase().contains(
        q,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ProfessionalPage(
      title: 'Payout History',
      children: [
        AppSearchField(
          hint: 'Search payout ID, mode, date...',
          onChanged: (v) => setState(() => _query = v),
        ),

        const ProfessionalSectionHeader(
          title: 'Status Filters',
          subtitle: 'Segment your transaction history',
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ProfessionalCard(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    label: const Text('Paid'),
                    selected: _filter == PayoutStatus.paid,
                    onSelected: (_) => setState(() => _filter = PayoutStatus.paid),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Pending'),
                    selected: _filter == PayoutStatus.pending,
                    onSelected: (_) => setState(() => _filter = PayoutStatus.pending),
                  ),
                  const SizedBox(width: 8),
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

        const ProfessionalSectionHeader(
          title: 'Transactions',
          subtitle: 'Detailed list of all payouts',
        ),

        if (_filtered.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: EmptyState(
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
                  return Colors.orange;
                case PayoutStatus.failed:
                  return Colors.red;
              }
            }

            final chip = _toUi(p.status);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ProfessionalCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: iconColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.account_balance_wallet_rounded, color: iconColor()),
                  ),
                  title: Text(
                    '₹${p.amount} • ${p.mode}',
                    style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.deepBlue1),
                  ),
                  subtitle: Text(
                    '${p.date} • ID: ${p.id}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  trailing: StatusChip(
                    status: chip,
                    labelOverride: _label(p.status),
                  ),
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

        const SizedBox(height: 32),
      ],
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
