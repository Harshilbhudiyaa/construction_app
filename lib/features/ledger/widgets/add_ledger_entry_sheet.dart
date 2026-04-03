import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:construction_app/core/theme/aesthetic_tokens.dart';
import 'package:construction_app/data/repositories/ledger_repository.dart';
import 'package:construction_app/data/repositories/site_repository.dart';
import 'package:construction_app/data/models/ledger_entry_model.dart';
import 'package:construction_app/data/models/party_model.dart';
import 'package:construction_app/data/models/site_model.dart';

class AddLedgerEntrySheet extends StatefulWidget {
  final PartyModel party;
  final LedgerEntryType initialType;
  const AddLedgerEntrySheet({
    super.key,
    required this.party,
    this.initialType = LedgerEntryType.credit,
  });

  @override
  State<AddLedgerEntrySheet> createState() => _AddLedgerEntrySheetState();
}

class _AddLedgerEntrySheetState extends State<AddLedgerEntrySheet> {
  late LedgerEntryType _type;
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  SiteModel? _selectedSite;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: bcNavy, secondary: bcAmber),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount.'), backgroundColor: bcDanger),
      );
      return;
    }
    if (_descCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a description.'), backgroundColor: bcDanger),
      );
      return;
    }

    setState(() => _saving = true);
    final entry = LedgerEntryModel(
      id: 'LE-${DateTime.now().millisecondsSinceEpoch}',
      partyId: widget.party.id,
      partyName: widget.party.name,
      siteId: _selectedSite?.id,
      siteName: _selectedSite?.name,
      amount: amount,
      type: _type,
      description: _descCtrl.text.trim(),
      date: _date,
    );

    await context.read<LedgerRepository>().addEntry(entry);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${_type == LedgerEntryType.credit ? 'Credit' : 'Debit'} of ₹${amount.toStringAsFixed(0)} recorded.'),
          backgroundColor: _type == LedgerEntryType.credit ? bcSuccess : bcDanger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final siteRepo = context.watch<SiteRepository>();
    final sites = siteRepo.sites;
    final isCredit = _type == LedgerEntryType.credit;
    final typeColor = isCredit ? bcSuccess : bcDanger;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: bcBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCredit ? Icons.call_received_rounded : Icons.call_made_rounded,
                  color: typeColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCredit ? 'Add Credit Entry' : 'Add Debit Entry',
                      style: const TextStyle(
                          fontWeight: FontWeight.w900, fontSize: 18, color: bcTextPrimary),
                    ),
                    Text(
                      widget.party.name,
                      style: const TextStyle(color: bcTextSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Type toggle
          Row(
            children: [
              Expanded(
                child: _TypeToggle(
                  label: 'Credit',
                  icon: Icons.call_received_rounded,
                  color: bcSuccess,
                  selected: _type == LedgerEntryType.credit,
                  onTap: () => setState(() => _type = LedgerEntryType.credit),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TypeToggle(
                  label: 'Debit',
                  icon: Icons.call_made_rounded,
                  color: bcDanger,
                  selected: _type == LedgerEntryType.debit,
                  onTap: () => setState(() => _type = LedgerEntryType.debit),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Amount
          TextField(
            controller: _amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: bcTextPrimary),
            decoration: InputDecoration(
              labelText: 'Amount (₹)',
              prefixIcon: const Icon(Icons.currency_rupee_rounded, color: bcNavy),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: typeColor, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Description
          TextField(
            controller: _descCtrl,
            decoration: InputDecoration(
              labelText: 'Description / Note',
              prefixIcon: const Icon(Icons.notes_rounded, color: bcNavy),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: typeColor, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Date row
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                border: Border.all(color: bcBorder),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, color: bcNavy, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    DateFormat('dd MMM yyyy').format(_date),
                    style: const TextStyle(fontWeight: FontWeight.w700, color: bcTextPrimary),
                  ),
                  const Spacer(),
                  const Icon(Icons.edit_calendar_rounded, color: bcTextSecondary, size: 16),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Site selector
          if (sites.isNotEmpty)
            DropdownButtonFormField<SiteModel>(
              initialValue: _selectedSite,
              decoration: InputDecoration(
                labelText: 'Site (Optional)',
                prefixIcon: const Icon(Icons.domain_rounded, color: bcNavy),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('No site')),
                ...sites.map((s) => DropdownMenuItem(value: s, child: Text(s.name))),
              ],
              onChanged: (v) => setState(() => _selectedSite = v),
            ),
          const SizedBox(height: 24),

          // Save button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: typeColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      isCredit ? 'SAVE CREDIT' : 'SAVE DEBIT',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeToggle extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  const _TypeToggle(
      {required this.label,
      required this.icon,
      required this.color,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.1) : Colors.white,
          border: Border.all(
              color: selected ? color : bcBorder, width: selected ? 1.5 : 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? color : bcTextSecondary, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? color : bcTextSecondary,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
