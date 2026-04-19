import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:construction_app/core/theme/aesthetic_tokens.dart';
import 'package:construction_app/shared/widgets/professional_page.dart';
import 'package:construction_app/data/models/labour_entry_model.dart';
import 'package:construction_app/data/repositories/labour_repository.dart';
import 'package:construction_app/data/repositories/auth_repository.dart';
import 'package:construction_app/data/repositories/ledger_repository.dart';
import 'package:construction_app/data/models/ledger_entry_model.dart';
import 'package:construction_app/core/routing/app_router.dart';

class LabourDetailScreen extends StatefulWidget {
  final String entryId;
  const LabourDetailScreen({super.key, required this.entryId});

  @override
  State<LabourDetailScreen> createState() => _LabourDetailScreenState();
}

class _LabourDetailScreenState extends State<LabourDetailScreen> {
  final _fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    final labourRepo = context.watch<LabourRepository>();
    final authRepo   = context.watch<AuthRepository>();
    final entry      = labourRepo.entries.firstWhere((e) => e.id == widget.entryId);

    return ProfessionalPage(
      title: 'Deal Detail',
      subtitle: entry.partyName,
      category: 'CONTRACTOR FLOW',
      headerStats: [
        HeroStatPill(
            label: 'Gross',
            value: _fmt.format(entry.totalContractAmount),
            color: bcNavy,
            icon: Icons.handshake_rounded),
        HeroStatPill(
            label: 'Paid',
            value: _fmt.format(entry.totalAdvancePaid + (entry.finalSettlementAmount ?? 0)),
            color: bcSuccess,
            icon: Icons.check_circle_rounded),
        HeroStatPill(
            label: 'Balance',
            value: _fmt.format(entry.pendingAmount),
            color: bcDanger,
            icon: Icons.pending_rounded),
      ],
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusCard(entry, labourRepo),
              const SizedBox(height: 24),
              _buildWorkDetails(entry),
              const SizedBox(height: 24),
              _buildPaymentHistory(entry, labourRepo, authRepo),
              const SizedBox(height: 32),
              _buildActions(entry, labourRepo, authRepo),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(LabourEntryModel entry, LabourRepository repo) {
    Color getStatusColor() {
      switch (entry.status) {
        case LabourStatus.ongoing:   return bcNavy;
        case LabourStatus.completed: return bcAmber;
        case LabourStatus.settled:   return bcSuccess;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: getStatusColor().withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: getStatusColor().withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, color: getStatusColor(), size: 18),
              const SizedBox(width: 10),
              Text(
                'Status: ${entry.status.displayName.toUpperCase()}',
                style: TextStyle(
                    color: getStatusColor(),
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 0.5),
              ),
              const Spacer(),
              if (entry.status == LabourStatus.ongoing)
                TextButton(
                  onPressed: () => _markWorkCompleted(repo, entry),
                  style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      backgroundColor: bcAmber,
                      foregroundColor: bcNavy),
                  child: const Text('MARK COMPLETE',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 10)),
                ),
            ],
          ),
          if (entry.status == LabourStatus.completed) ...[
            const SizedBox(height: 12),
            const Text(
              '⚠️ Work completed. Final payable amount will be calculated after deducting all advances.',
              style: TextStyle(
                  color: Color(0xFF92400E),
                  fontSize: 11,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWorkDetails(LabourEntryModel entry) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('WORK DETAILS',
            style: TextStyle(
                color: bcTextSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1)),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: bcBorder)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailRow('Work Category', entry.workType.displayName),
              _DetailRow('Description', entry.workDescription),
              _DetailRow('Site Location', entry.siteName),
              _DetailRow('Started On', DateFormat('dd MMM yyyy').format(entry.startDate)),
              if (entry.completionDate != null)
                _DetailRow('Completed On', DateFormat('dd MMM yyyy').format(entry.completionDate!)),
              if (entry.workQuantity != null)
                _DetailRow(entry.workType == LabourWorkType.perSqFt ? 'Actual Area' : 'Scope', '${entry.workQuantity} ${entry.workType.unitLabel}'),
              _DetailRow('Rate / Unit', _fmt.format(entry.ratePerUnit)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentHistory(LabourEntryModel entry, LabourRepository repo, AuthRepository auth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('PAYMENT HISTORY',
            style: TextStyle(
                color: bcTextSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: bcBorder)),
          child: entry.advancePayments.isEmpty && entry.finalSettlementAmount == null
              ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(child: Column(children: [
              Icon(Icons.payments_outlined, color: bcTextSecondary.withValues(alpha: 0.4), size: 32),
              const SizedBox(height: 8),
              const Text('No payments recorded yet',
                  style: TextStyle(color: bcTextSecondary, fontSize: 13)),
              const SizedBox(height: 4),
              Text(
                entry.status == LabourStatus.ongoing
                    ? 'Record advance payments first, then settle final balance later'
                    : 'Ready for final payment',
                style: const TextStyle(color: bcTextSecondary, fontSize: 11),
              ),
            ])),
          )
              : Column(
            children: [
              ...entry.advancePayments.map((p) => _PaymentHistoryItem(
                  title: 'Advance Payment',
                  amount: p.amount,
                  date: p.date,
                  isSettlement: false,
                  fmt: _fmt)),
              if (entry.finalSettlementAmount != null)
                _PaymentHistoryItem(
                    title: 'Final Settlement',
                    amount: entry.finalSettlementAmount!,
                    date: entry.settledDate ?? DateTime.now(),
                    isSettlement: true,
                    fmt: _fmt),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActions(LabourEntryModel entry, LabourRepository repo, AuthRepository auth) {
    if (entry.status == LabourStatus.settled) return const SizedBox.shrink();

    return Column(
      children: [
        if (entry.status == LabourStatus.completed)
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () => _showSettleDialog(repo, entry, auth),
              icon: const Icon(Icons.handshake_rounded),
              label: const Text('RECORD FINAL PAYMENT',
                  style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
              style: ElevatedButton.styleFrom(
                  backgroundColor: bcSuccess,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0),
            ),
          ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.labourEntry, arguments: entry),
                icon: const Icon(Icons.edit_rounded, size: 18),
                label: const Text('EDIT CONTRACT'),
                style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _confirmDelete(repo, entry),
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: const Text('DELETE'),
                style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    foregroundColor: bcDanger,
                    side: const BorderSide(color: bcDanger),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Modals & Actions ───────────────────────────────────────────────────────

  void _markWorkCompleted(LabourRepository repo, LabourEntryModel entry) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Mark Work Complete?'),
        content: const Text('This will set the work status to "Completed". After measurement, you can record the final payment.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('CANCEL')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('YES, COMPLETED')),
        ],
      ),
    );
    if (ok == true) {
      await repo.markCompleted(entry.id, DateTime.now());
    }
  }


  void _showSettleDialog(LabourRepository repo, LabourEntryModel entry, AuthRepository auth) {
    final isPerSqFt = entry.workType == LabourWorkType.perSqFt;
    final sqftCtrl  = TextEditingController(text: entry.workQuantity?.toStringAsFixed(0) ?? '');
    final amtCtrl   = TextEditingController(
      text: entry.pendingAmount > 0 ? entry.pendingAmount.toStringAsFixed(0) : '',
    );

    void recalc(StateSetter setDialog) {
      if (!isPerSqFt) return;
      final sqft = double.tryParse(sqftCtrl.text) ?? 0;
      if (sqft > 0) {
        final gross = sqft * entry.ratePerUnit;
        final payable = (gross - entry.totalAdvancePaid).clamp(0.0, double.infinity);
        amtCtrl.text = payable.toStringAsFixed(0);
      } else {
        amtCtrl.text = '';
      }
    }

    showDialog(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setDialog) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Final Payment', style: TextStyle(fontWeight: FontWeight.w900)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary row
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: bcNavy.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(children: [
                    _SettleRow('Gross Amount', _fmt.format(entry.totalContractAmount)),
                    _SettleRow('Advance Given', _fmt.format(entry.totalAdvancePaid)),
                    _SettleRow('Current Balance', _fmt.format(entry.pendingAmount), highlight: true),
                  ]),
                ),
                const SizedBox(height: 16),

                // ── Per Sq.Ft: Enter actual area ─────────────────────────
                if (isPerSqFt) ...[
                  const Text('ACTUAL AREA',
                      style: TextStyle(color: bcTextSecondary, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.8)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: sqftCtrl,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => recalc(setDialog),
                    decoration: InputDecoration(
                      hintText: 'Enter actual measured sq.ft',
                      suffixText: 'sq.ft',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: bcAmber, width: 2)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Rate: ${_fmt.format(entry.ratePerUnit)} / sq.ft  →  Gross = area × rate',
                    style: const TextStyle(color: bcTextSecondary, fontSize: 10),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Final payable = gross amount − advance already given',
                    style: const TextStyle(color: bcTextSecondary, fontSize: 10),
                  ),
                  const SizedBox(height: 14),
                ],

                // ── Settlement amount ─────────────────────────────────────
                const Text('FINAL PAYABLE',
                    style: TextStyle(color: bcTextSecondary, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.8)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: amtCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '0',
                    prefixText: '₹ ',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: bcSuccess, width: 2)),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'For sq.ft deals: final payable = actual area × rate − advance already given.',
                  style: TextStyle(fontSize: 10, color: bcTextSecondary, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c), child: const Text('CANCEL')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: bcSuccess, foregroundColor: Colors.white),
              onPressed: () async {
                final val   = double.tryParse(amtCtrl.text);
                final sqft  = isPerSqFt ? double.tryParse(sqftCtrl.text) : null;
                if (val == null || val <= 0) return;

                // ERP Sync: Create Ledger Entry
                final ledgerRepo = context.read<LedgerRepository>();
                await ledgerRepo.addEntry(LedgerEntryModel(
                  id: 'L-SETTLE-${const Uuid().v4().substring(0, 6).toUpperCase()}',
                  partyId: entry.partyId,
                  partyName: entry.partyName,
                  siteId: entry.siteId,
                  siteName: entry.siteName,
                  amount: val,
                  type: LedgerEntryType.debit,
                  description: 'Labour Settlement: ${entry.workDescription}'
                      '${sqft != null ? ' ($sqft sq.ft)' : ''}',
                  date: DateTime.now(),
                ));

                // If perSqFt, update actual area and gross amount before settlement
                if (isPerSqFt && sqft != null && sqft > 0) {
                  final grossAmount = sqft * entry.ratePerUnit;
                  await repo.updateEntry(
                    entry.copyWith(
                      workQuantity: sqft,
                      totalContractAmount: grossAmount,
                    ),
                  );
                }

                await repo.recordSettlement(
                  entryId: entry.id,
                  settlementAmount: val,
                  settledDate: DateTime.now(),
                );
                if (!context.mounted) return;
                Navigator.pop(c);
              },
              child: const Text('CONFIRM SETTLEMENT'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(LabourRepository repo, LabourEntryModel entry) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete Contract?'),
        content: const Text('This will remove the contract and all its payment history. This action is permanent.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('CANCEL')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('DELETE', style: TextStyle(color: bcDanger))),
        ],
      ),
    );
    if (ok == true) {
      await repo.deleteEntry(entry.id);
      if (!mounted) return;
      Navigator.pop(context);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final String label, value;
  const _DetailRow(this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: bcTextSecondary, fontSize: 10, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(color: bcNavy, fontSize: 14, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _PaymentHistoryItem extends StatelessWidget {
  final String title;
  final double amount;
  final DateTime date;
  final bool isSettlement;
  final NumberFormat fmt;

  const _PaymentHistoryItem(
      {required this.title, required this.amount, required this.date, required this.isSettlement, required this.fmt});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isSettlement ? bcSuccess : bcAmber).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(isSettlement ? Icons.check_circle_rounded : Icons.payments_rounded,
                color: isSettlement ? bcSuccess : bcAmber, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                Text(DateFormat('dd MMM yyyy').format(date),
                    style: const TextStyle(color: bcTextSecondary, fontSize: 11)),
              ],
            ),
          ),
          Text(fmt.format(amount),
              style: TextStyle(
                  color: isSettlement ? bcSuccess : bcNavy, fontWeight: FontWeight.w900, fontSize: 14)),
        ],
      ),
    );
  }
}

class _SettleRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  const _SettleRow(this.label, this.value, {this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(
            color: highlight ? bcNavy : bcTextSecondary,
            fontSize: 11,
            fontWeight: highlight ? FontWeight.w800 : FontWeight.w600,
          )),
          Text(value, style: TextStyle(
            color: highlight ? bcSuccess : bcNavy,
            fontSize: 11,
            fontWeight: FontWeight.w900,
          )),
        ],
      ),
    );
  }
}
