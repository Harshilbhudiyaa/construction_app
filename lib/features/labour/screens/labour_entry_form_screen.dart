import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:construction_app/core/theme/aesthetic_tokens.dart';
import 'package:construction_app/shared/widgets/professional_page.dart';
import 'package:construction_app/shared/widgets/helpful_text_field.dart';
import 'package:construction_app/shared/widgets/helpful_dropdown.dart';
import 'package:construction_app/data/models/labour_entry_model.dart';
import 'package:construction_app/data/models/party_model.dart';
import 'package:construction_app/data/models/site_model.dart';
import 'package:construction_app/data/repositories/labour_repository.dart';
import 'package:construction_app/data/repositories/party_repository.dart';
import 'package:construction_app/data/repositories/site_repository.dart';
import 'package:construction_app/data/repositories/auth_repository.dart';

class LabourEntryFormScreen extends StatefulWidget {
  final LabourEntryModel? editingEntry;
  const LabourEntryFormScreen({super.key, this.editingEntry});

  @override
  State<LabourEntryFormScreen> createState() => _LabourEntryFormScreenState();
}

class _LabourEntryFormScreenState extends State<LabourEntryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Form Fields
  SiteModel? _selectedSite;
  PartyModel? _selectedContractor;
  LabourWorkType _workType = LabourWorkType.fixedContract;

  final _descriptionCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  final _totalAmountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  DateTime _startDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    final siteRepo = context.read<SiteRepository>();
    _selectedSite = siteRepo.selectedSite;

    if (widget.editingEntry != null) {
      _loadEditingData();
    }
  }

  void _loadEditingData() {
    final e = widget.editingEntry!;
    _workType = e.workType;
    _descriptionCtrl.text = e.workDescription;
    _quantityCtrl.text = e.workQuantity?.toString() ?? '';
    _rateCtrl.text = e.ratePerUnit.toString();
    _totalAmountCtrl.text = e.totalContractAmount.toString();
    _notesCtrl.text = e.notes ?? '';
    _startDate = e.startDate;
  }

  @override
  void dispose() {
    _descriptionCtrl.dispose();
    _quantityCtrl.dispose();
    _rateCtrl.dispose();
    _totalAmountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _calculateTotal() {
    if (_workType == LabourWorkType.fixedContract) return;

    final qty = double.tryParse(_quantityCtrl.text) ?? 0;
    final rate = double.tryParse(_rateCtrl.text) ?? 0;

    setState(() {
      _totalAmountCtrl.text = (qty * rate).toStringAsFixed(2);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSite == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a site')));
      return;
    }
    if (_selectedContractor == null && widget.editingEntry == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a contractor')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final labourRepo = context.read<LabourRepository>();
      final authRepo = context.read<AuthRepository>();

      final total = double.tryParse(_totalAmountCtrl.text) ?? 0;

      if (widget.editingEntry != null) {
        final updated = widget.editingEntry!.copyWith(
          siteId: _selectedSite!.id,
          siteName: _selectedSite!.name,
          workType: _workType,
          workDescription: _descriptionCtrl.text,
          workQuantity: (_workType == LabourWorkType.fixedContract || _workType == LabourWorkType.perSqFt)
              ? null
              : double.tryParse(_quantityCtrl.text),
          ratePerUnit: double.parse(_rateCtrl.text),
          totalContractAmount: total,
          startDate: _startDate,
          notes: _notesCtrl.text,
        );
        await labourRepo.updateEntry(updated);
      } else {
        final entryId = 'LAB-${const Uuid().v4().substring(0, 8).toUpperCase()}';
        final entry = LabourEntryModel(
          id: entryId,
          partyId: _selectedContractor!.id,
          partyName: _selectedContractor!.name,
          partyContact: _selectedContractor!.contactNumber,
          siteId: _selectedSite!.id,
          siteName: _selectedSite!.name,
          workType: _workType,
          workDescription: _descriptionCtrl.text,
          // For perSqFt contracts: workQuantity is entered at settlement, not here
          workQuantity: (_workType == LabourWorkType.fixedContract || _workType == LabourWorkType.perSqFt)
              ? null
              : double.tryParse(_quantityCtrl.text),
          ratePerUnit: double.parse(_rateCtrl.text),
          totalContractAmount: total,
          advancePayments: const [],
          startDate: _startDate,
          createdBy: authRepo.userName ?? 'System',
          createdAt: DateTime.now(),
          notes: _notesCtrl.text,
        );
        await labourRepo.addEntry(entry);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.editingEntry != null ? 'Deal updated' : 'Deal created successfully'),
            backgroundColor: bcSuccess,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: bcDanger),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProfessionalPage(
      title: widget.editingEntry != null ? 'Edit Deal' : 'New Contractor Deal',
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSitePicker(),
                const SizedBox(height: 24),
                _buildContractorPicker(),
                const SizedBox(height: 24),
                _buildWorkDetailsSection(),
                const SizedBox(height: 24),
                _buildFinancialSection(),
                const SizedBox(height: 32),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSitePicker() {
    return Consumer<SiteRepository>(
      builder: (context, siteRepo, child) {
        return HelpfulDropdown<SiteModel?>(
          label: 'WORK SITE',
          value: _selectedSite,
          items: siteRepo.sites,
          labelMapper: (s) => s?.name ?? 'Select Site',
          onChanged: (s) => setState(() => _selectedSite = s),
        );
      },
    );
  }

  Widget _buildContractorPicker() {
    if (widget.editingEntry != null) {
      return HelpfulTextField(
        label: 'CONTRACTOR',
        controller: TextEditingController(text: widget.editingEntry!.partyName),
        enabled: false,
      );
    }
    return Consumer<PartyRepository>(
      builder: (context, partyRepo, child) {
        final contractors = partyRepo.parties.where((p) => p.category == PartyCategory.contractor).toList();
        return HelpfulDropdown<PartyModel?>(
          label: 'CONTRACTOR / AGENCY',
          value: _selectedContractor,
          items: contractors,
          labelMapper: (p) => p == null ? 'Select Contractor' : '${p.name} (${p.contactNumber ?? "No contact"})',
          onChanged: (p) => setState(() => _selectedContractor = p),
        );
      },
    );
  }

  Widget _buildWorkDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('WORK SPECIFICATIONS',
            style: TextStyle(color: bcTextSecondary, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: bcBorder),
          ),
          child: Column(
            children: [
              HelpfulDropdown<LabourWorkType>(
                label: 'Deal Type',
                value: _workType,
                items: LabourWorkType.values,
                labelMapper: (t) => t.displayName,
                onChanged: (t) {
                  if (t != null) {
                    setState(() {
                      _workType = t;
                      if (t == LabourWorkType.fixedContract) {
                        _quantityCtrl.clear();
                      }
                      _calculateTotal();
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              HelpfulTextField(
                label: 'Work Description',
                controller: _descriptionCtrl,
                hintText: 'e.g. Slab work, painting, block plaster...',
                maxLines: 2,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: _startDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (d != null) setState(() => _startDate = d);
                      },
                      child: AbsorbPointer(
                        child: HelpfulTextField(
                          label: 'Start Date',
                          controller: TextEditingController(text: DateFormat('dd MMM yyyy').format(_startDate)),
                          suffixIcon: const Icon(Icons.calendar_today_rounded, size: 18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('RATE & PAYMENT TERMS',
            style: TextStyle(color: bcTextSecondary, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: bcBorder),
          ),
          child: Column(
            children: [
              if (_workType != LabourWorkType.fixedContract && _workType != LabourWorkType.perSqFt) ...[
                Row(
                  children: [
                    Expanded(
                      child: HelpfulTextField(
                        label: 'Estimated ${_workType.unitLabel}',
                        controller: _quantityCtrl,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => _calculateTotal(),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: HelpfulTextField(
                        label: 'Rate / ${_workType.unitLabel}',
                        controller: _rateCtrl,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => _calculateTotal(),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              // For perSqFt: only rate, area at settlement time
              if (_workType == LabourWorkType.perSqFt) ...[
                HelpfulTextField(
                  label: 'Rate per Sq.Ft (₹)',
                  controller: _rateCtrl,
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBF0),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: bcAmber.withValues(alpha: 0.3)),
                  ),
                  child: const Row(children: [
                    Icon(Icons.info_outline_rounded, color: bcAmber, size: 14),
                    SizedBox(width: 8),
                    Expanded(child: Text(
                      'Actual measured sq.ft will be entered at final payment time. Advance given earlier will be deducted there.',
                      style: TextStyle(color: Color(0xFF92400E), fontSize: 11),
                    )),
                  ]),
                ),
                const SizedBox(height: 16),
              ],
              HelpfulTextField(
                label: _workType == LabourWorkType.fixedContract
                    ? 'Total Contract Amount (₹)'
                    : _workType == LabourWorkType.perSqFt
                    ? 'Estimated Total (₹) — optional'
                    : 'Estimated Total (₹)',
                controller: _totalAmountCtrl,
                keyboardType: TextInputType.number,
                enabled: _workType == LabourWorkType.fixedContract || _workType == LabourWorkType.perSqFt,
                validator: (v) => (v!.isEmpty && _workType == LabourWorkType.fixedContract) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              HelpfulTextField(
                label: 'Advance / Payment Terms',
                controller: _notesCtrl,
                hintText: 'e.g. Pay ₹5000 when slab is filled, remaining after final measurement',
                maxLines: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: bcNavy,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(
          widget.editingEntry != null ? 'UPDATE DEAL' : 'CREATE DEAL',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1),
        ),
      ),
    );
  }
}
