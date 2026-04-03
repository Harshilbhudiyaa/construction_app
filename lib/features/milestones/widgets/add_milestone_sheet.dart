import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:construction_app/core/theme/aesthetic_tokens.dart';
import 'package:construction_app/data/repositories/milestone_repository.dart';
import 'package:construction_app/data/repositories/site_repository.dart';
import 'package:construction_app/data/models/milestone_model.dart';
import 'package:construction_app/data/models/site_model.dart';

class AddMilestoneSheet extends StatefulWidget {
  const AddMilestoneSheet({super.key});

  @override
  State<AddMilestoneSheet> createState() => _AddMilestoneSheetState();
}

class _AddMilestoneSheetState extends State<AddMilestoneSheet> {
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  SiteModel? _selectedSite;
  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: bcNavy, secondary: bcAmber),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a milestone title.'), backgroundColor: bcDanger),
      );
      return;
    }
    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0.0;
    if (_selectedSite == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a site.'), backgroundColor: bcDanger),
      );
      return;
    }

    setState(() => _saving = true);
    final milestone = MilestoneModel(
      id: 'MS-${DateTime.now().millisecondsSinceEpoch}',
      siteId: _selectedSite!.id,
      siteName: _selectedSite!.name,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      dueDate: _dueDate,
      amount: amount,
    );

    await context.read<MilestoneRepository>().addMilestone(milestone);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Milestone "${milestone.title}" added.'),
          backgroundColor: bcSuccess,
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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: bcBorder, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: bcAmber.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.flag_rounded, color: bcAmber, size: 18),
                ),
                const SizedBox(width: 12),
                const Text('Add Milestone',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: bcTextPrimary)),
              ],
            ),
            const SizedBox(height: 20),

            // Title
            TextField(
              controller: _titleCtrl,
              decoration: InputDecoration(
                labelText: 'Milestone Title',
                prefixIcon: const Icon(Icons.title_rounded, color: bcNavy),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: bcAmber, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Amount
            TextField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Amount (₹)',
                prefixIcon: const Icon(Icons.currency_rupee_rounded, color: bcNavy),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: bcAmber, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Site selector
            DropdownButtonFormField<SiteModel>(
            initialValue: _selectedSite,
              decoration: InputDecoration(
                labelText: 'Site *',
                prefixIcon: const Icon(Icons.domain_rounded, color: bcNavy),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: sites
                  .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedSite = v),
            ),
            const SizedBox(height: 12),

            // Due date
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Due Date',
                            style: TextStyle(color: bcTextSecondary, fontSize: 11)),
                        Text(
                          DateFormat('dd MMM yyyy').format(_dueDate),
                          style: const TextStyle(fontWeight: FontWeight.w700, color: bcTextPrimary, fontSize: 14),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Icon(Icons.edit_calendar_rounded, color: bcTextSecondary, size: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Description
            TextField(
              controller: _descCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Description (Optional)',
                prefixIcon: const Icon(Icons.notes_rounded, color: bcNavy),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: bcAmber, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: bcAmber,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('SAVE MILESTONE',
                        style: TextStyle(
                            color: bcNavy, fontWeight: FontWeight.w900, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
