import 'package:flutter/material.dart';
import 'package:construction_app/shared/widgets/professional_page.dart';
import 'package:construction_app/shared/widgets/helpful_text_field.dart';
import 'package:construction_app/shared/theme/professional_theme.dart';
import 'package:construction_app/services/party_service.dart';
import 'models/party_model.dart';

class PartyFormScreen extends StatefulWidget {
  final PartyModel? party;
  const PartyFormScreen({super.key, this.party});

  @override
  State<PartyFormScreen> createState() => _PartyFormScreenState();
}

class _PartyFormScreenState extends State<PartyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _partyService = PartyService();
  bool _isLoading = false;

  late final TextEditingController _nameCtrl;
  late final TextEditingController _contactCtrl;
  late final TextEditingController _gstCtrl;
  late final TextEditingController _addressCtrl;
  late PartyCategory _selectedCategory;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.party?.name ?? '');
    _contactCtrl = TextEditingController(text: widget.party?.contactNumber ?? '');
    _gstCtrl = TextEditingController(text: widget.party?.gstNumber ?? '');
    _addressCtrl = TextEditingController(text: widget.party?.address ?? '');
    _selectedCategory = widget.party?.category ?? PartyCategory.supplier;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _contactCtrl.dispose();
    _gstCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final party = PartyModel(
          id: widget.party?.id ?? 'PARTY-${DateTime.now().millisecondsSinceEpoch}',
          name: _nameCtrl.text,
          category: _selectedCategory,
          contactNumber: _contactCtrl.text,
          gstNumber: _gstCtrl.text,
          address: _addressCtrl.text,
          createdAt: widget.party?.createdAt ?? DateTime.now(),
        );

        if (widget.party == null) {
          await _partyService.addParty(party);
        } else {
          await _partyService.updateParty(party);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Party saved successfully'), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving party: $e'), backgroundColor: Colors.redAccent),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProfessionalPage(
      title: widget.party == null ? 'Add Party' : 'Edit Party',
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                ProfessionalCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      HelpfulTextField(
                        label: 'Party Name',
                        controller: _nameCtrl,
                        validator: (v) => v!.isEmpty ? 'Name is required' : null,
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<PartyCategory>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(labelText: 'Party Category'),
                        items: PartyCategory.values.map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat.displayName),
                        )).toList(),
                        onChanged: (v) => setState(() => _selectedCategory = v!),
                      ),
                      const SizedBox(height: 20),
                      HelpfulTextField(
                        label: 'Contact Number',
                        controller: _contactCtrl,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 20),
                      HelpfulTextField(
                        label: 'GST Number',
                        controller: _gstCtrl,
                      ),
                      const SizedBox(height: 20),
                      HelpfulTextField(
                        label: 'Address',
                        controller: _addressCtrl,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading ? const CircularProgressIndicator() : const Text('SAVE PARTY'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
