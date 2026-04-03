import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:construction_app/core/theme/aesthetic_tokens.dart';
import 'package:construction_app/data/repositories/ledger_repository.dart';
import 'package:construction_app/data/models/ledger_entry_model.dart';
import 'package:construction_app/shared/widgets/professional_page.dart';
import 'package:construction_app/data/models/party_model.dart';
import '../widgets/add_ledger_entry_sheet.dart';

class PartyLedgerScreen extends StatelessWidget {
  final PartyModel party;
  const PartyLedgerScreen({super.key, required this.party});

  @override
  Widget build(BuildContext context) {
    final ledgerRepo = context.watch<LedgerRepository>();
    final entries = ledgerRepo.getEntriesForParty(party.id);
    final balance = ledgerRepo.getBalanceForParty(party.id);
    final fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final isPositive = balance >= 0;
    final balanceColor = balance == 0 ? bcTextSecondary : (isPositive ? bcSuccess : bcDanger);
    final balanceLabel = balance == 0 ? 'Settled' : (isPositive ? 'Will Give' : 'Will Get');

    // Build running balance list
    double running = 0;
    final displayed = entries.reversed.map((e) {
      running += e.isCredit ? e.amount : -e.amount;
      return _EntryWithBalance(entry: e, runningBalance: running);
    }).toList().reversed.toList();

    return ProfessionalPage(
      title: party.name,
      subtitle: '$balanceLabel: ${fmt.format(balance.abs())}',
      category: party.category.displayName,
      actions: [
        IconButton(
          icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
          tooltip: 'Export PDF',
          onPressed: () => _exportPdf(context, party, entries, balance),
        ),
      ],
      headerStats: [
        HeroStatPill(
          label: balanceLabel,
          value: fmt.format(balance.abs()),
          icon: isPositive ? Icons.account_balance_wallet_rounded : Icons.payments_rounded,
          color: balanceColor,
        ),
      ],
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton.extended(
              heroTag: 'debit_fab',
              onPressed: () => _showAddEntry(context, LedgerEntryType.debit),
              backgroundColor: bcDanger,
              icon: const Icon(Icons.call_made_rounded, color: Colors.white),
              label: const Text('Debit',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 10),
            FloatingActionButton.extended(
              heroTag: 'credit_fab',
              onPressed: () => _showAddEntry(context, LedgerEntryType.credit),
              backgroundColor: bcSuccess,
              icon: const Icon(Icons.call_received_rounded, color: Colors.white),
              label: const Text('Credit',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
      children: [
        if (entries.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 100),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 64, color: bcTextSecondary.withValues(alpha: 0.3)),
                  const SizedBox(height: 12),
                  const Text('No transactions yet',
                      style: TextStyle(
                          color: bcTextSecondary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  const Text('Use Credit / Debit buttons to add entries.',
                      style: TextStyle(color: bcTextSecondary, fontSize: 13)),
                ],
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            child: Column(
              children: List.generate(displayed.length, (i) {
                final item = displayed[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _LedgerEntryTile(
                    item: item,
                    fmt: fmt,
                    onDelete: () => _confirmDelete(context, context, item.entry, ledgerRepo),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  void _showAddEntry(BuildContext context, LedgerEntryType type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddLedgerEntrySheet(
        party: party,
        initialType: type,
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext sheetCtx, BuildContext topCtx,
      LedgerEntryModel entry, LedgerRepository repo) async {
    final confirmed = await showDialog<bool>(
      context: topCtx,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Entry', style: TextStyle(fontWeight: FontWeight.w900, color: bcNavy)),
        content: const Text('Remove this transaction? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(topCtx, false), child: const Text('CANCEL')),
          TextButton(
            onPressed: () => Navigator.pop(topCtx, true),
            child: const Text('DELETE', style: TextStyle(color: bcDanger, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await repo.deleteEntry(entry.id);
    }
  }

  void _exportPdf(BuildContext context, PartyModel party,
      List<LedgerEntryModel> entries, double balance) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('PDF export for ${party.name} coming soon!'),
        backgroundColor: bcNavy,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _EntryWithBalance {
  final LedgerEntryModel entry;
  final double runningBalance;
  const _EntryWithBalance({required this.entry, required this.runningBalance});
}

class _LedgerEntryTile extends StatelessWidget {
  final _EntryWithBalance item;
  final NumberFormat fmt;
  final VoidCallback onDelete;

  const _LedgerEntryTile({required this.item, required this.fmt, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final entry = item.entry;
    final isCredit = entry.isCredit;
    final color = isCredit ? bcSuccess : bcDanger;
    final sign = isCredit ? '+' : '-';
    final balColor = item.runningBalance >= 0 ? bcSuccess : bcDanger;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: bcBorder),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCredit ? Icons.call_received_rounded : Icons.call_made_rounded,
                color: color,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.description,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: bcTextPrimary),
                  ),
                  const SizedBox(height: 3),
                  Row(children: [
                    Text(
                      DateFormat('dd MMM yyyy').format(entry.date),
                      style: const TextStyle(color: bcTextSecondary, fontSize: 11),
                    ),
                    if (entry.siteName != null) ...[
                      const Text(' · ', style: TextStyle(color: bcTextSecondary, fontSize: 11)),
                      Flexible(
                        child: Text(
                          entry.siteName!,
                          style: const TextStyle(color: bcTextSecondary, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ]),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$sign${fmt.format(entry.amount)}',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Bal: ${fmt.format(item.runningBalance.abs())}',
                  style: TextStyle(color: balColor, fontSize: 10, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDelete,
              child: const Icon(Icons.delete_outline_rounded, color: bcDanger, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}
