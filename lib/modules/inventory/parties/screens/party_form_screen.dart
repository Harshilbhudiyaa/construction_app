import 'package:flutter/material.dart';
import 'package:construction_app/shared/widgets/professional_page.dart';
import 'package:construction_app/shared/widgets/helpful_text_field.dart';
import 'package:construction_app/shared/widgets/helpful_dropdown.dart';
import 'package:construction_app/shared/theme/professional_theme.dart';
import 'package:construction_app/shared/theme/design_system.dart';
import 'package:construction_app/services/party_service.dart';
import 'package:construction_app/modules/inventory/parties/models/party_model.dart';

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
            const SnackBar(content: Text('Party saved successfully'), backgroundColor: DesignSystem.success),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving party: $e'), backgroundColor: DesignSystem.error),
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
                  padding: const EdgeInsets.all(24),
                  useGlass: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HelpfulTextField(
                        label: 'Party Name',
                        controller: _nameCtrl,
                        hintText: 'e.g. Acme Constructions',
                        useGlass: true,
                        validator: (v) => v!.isEmpty ? 'Name is required' : null,
                      ),
                      const SizedBox(height: 20),
                      
                      HelpfulDropdown<PartyCategory>(
                        label: 'Party Category',
                        value: _selectedCategory,
                        items: PartyCategory.values,
                        labelMapper: (cat) => cat.displayName,
                        onChanged: (v) => setState(() => _selectedCategory = v!),
                        useGlass: true,
                      ),
                      const SizedBox(height: 20),
                      
                      HelpfulTextField(
                        label: 'Contact Number',
                        controller: _contactCtrl,
                        hintText: 'Mobile or Phone number',
                        keyboardType: TextInputType.phone,
                        useGlass: true,
                      ),
                      const SizedBox(height: 20),
                      
                      HelpfulTextField(
                        label: 'GST Number',
                        controller: _gstCtrl,
                        hintText: 'GSTIN (Optional)',
                        useGlass: true,
                      ),
                      const SizedBox(height: 20),
                      
                      HelpfulTextField(
                        label: 'Address',
                        controller: _addressCtrl,
                        hintText: 'Full billing address',
                        maxLines: 3,
                        useGlass: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DesignSystem.deepNavy,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                    ),
                    child: _isLoading 
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                      : Text(
                          widget.party == null ? 'SAVE PARTY' : 'UPDATE PARTY', 
                          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.white)
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
