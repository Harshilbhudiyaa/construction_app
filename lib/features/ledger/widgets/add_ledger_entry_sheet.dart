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
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  SiteModel? _selectedSite;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
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

  void _pickSite(List<SiteModel> sites) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(color: bcBorder, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('SELECT SITE',
                style: TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
            const SizedBox(height: 12),
            // Clear option
            _SiteOption(
              label: 'No site (unlinked)',
              icon: Icons.clear_rounded,
              selected: _selectedSite == null,
              onTap: () {
                setState(() => _selectedSite = null);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 6),
            ...sites.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _SiteOption(
                label: s.name,
                icon: Icons.domain_rounded,
                selected: _selectedSite?.id == s.id,
                onTap: () {
                  setState(() => _selectedSite = s);
                  Navigator.pop(context);
                },
              ),
            )),
          ],
        ),
      ),
    );
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
      type: LedgerEntryType.debit,
      description: _descCtrl.text.trim(),
      date: _date,
    );

    await context.read<LedgerRepository>().addEntry(entry);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment of ₹${amount.toStringAsFixed(0)} recorded for ${widget.party.name}.'),
          backgroundColor: bcNavy,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sites = context.watch<SiteRepository>().sites;
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
                  color: bcNavy.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.payments_rounded,
                  color: bcNavy,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pay Supplier',
                      style: TextStyle(
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
                borderSide: const BorderSide(color: bcNavy, width: 2),
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
                borderSide: const BorderSide(color: bcNavy, width: 2),
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
            GestureDetector(
              onTap: () => _pickSite(sites),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                decoration: BoxDecoration(
                  color: _selectedSite != null ? bcNavy.withValues(alpha: 0.04) : Colors.white,
                  border: Border.all(
                    color: _selectedSite != null ? bcNavy.withValues(alpha: 0.3) : bcBorder,
                    width: _selectedSite != null ? 1.5 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.domain_rounded,
                      color: _selectedSite != null ? bcNavy : bcTextSecondary,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SITE',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: _selectedSite != null ? bcNavy : bcTextSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _selectedSite?.name ?? 'Select site (optional)',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: _selectedSite != null ? bcTextPrimary : bcTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: _selectedSite != null ? bcNavy : bcTextSecondary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 24),

          // Save button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: bcNavy,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      'RECORD PAYMENT',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SiteOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _SiteOption({required this.label, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: selected ? bcNavy.withValues(alpha: 0.06) : Colors.white,
          border: Border.all(
            color: selected ? bcNavy.withValues(alpha: 0.25) : const Color(0xFFE2E8F0),
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: selected ? bcNavy : bcTextSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? bcNavy : bcTextPrimary,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded, color: bcNavy, size: 18),
          ],
        ),
      ),
    );
  }
}
