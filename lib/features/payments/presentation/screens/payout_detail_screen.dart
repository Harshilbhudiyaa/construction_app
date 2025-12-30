import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/ui/widgets/section_header.dart';
import '../../../../app/ui/widgets/status_chip.dart';

class PayoutDetailScreen extends StatelessWidget {
  final String payoutId;
  final String date;
  final int amount;
  final String mode;
  final String reference;
  final UiStatus status; // approved=Paid, pending=Pending, rejected=Failed

  const PayoutDetailScreen({
    super.key,
    required this.payoutId,
    required this.date,
    required this.amount,
    required this.mode,
    required this.reference,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    String label() {
      if (status == UiStatus.approved) return 'Paid';
      if (status == UiStatus.pending) return 'Pending';
      return 'Failed';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Payout Detail')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: cs.secondaryContainer,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                      ),
                      child: Icon(
                        Icons.payments_rounded,
                        color: cs.onSecondaryContainer,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '₹$amount • $mode',
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$date • $payoutId',
                            style: TextStyle(color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    StatusChip(status: status, labelOverride: label()),
                  ],
                ),
              ),
            ),
          ),

          const SectionHeader(
            title: 'Payment Info',
            subtitle: 'Mode & reference',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _kv('Mode', mode),
                    _kv('Reference', reference),
                    _kv('Status', label()),
                  ],
                ),
              ),
            ),
          ),

          const SectionHeader(
            title: 'Receipt / Proof',
            subtitle: 'UI placeholder',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Card(
              child: ListTile(
                leading: Icon(Icons.receipt_long_rounded, color: cs.primary),
                title: const Text(
                  'Open proof (placeholder)',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: const Text(
                  'In final app: open payment proof image/PDF',
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Open proof (next step)')),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(k, style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
          Text(v),
        ],
      ),
    );
  }
}
