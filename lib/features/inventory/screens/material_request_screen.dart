import 'package:flutter/material.dart';
import 'package:construction_app/core/theme/aesthetic_tokens.dart';
import 'package:construction_app/data/repositories/auth_repository.dart';

import 'package:construction_app/core/theme/design_system.dart';

import 'package:construction_app/shared/widgets/professional_page.dart';
import 'package:construction_app/shared/widgets/tactile_material_selector.dart';

import 'package:construction_app/shared/widgets/helpful_text_field.dart';
import 'package:construction_app/shared/widgets/helpful_dropdown.dart';
import 'package:construction_app/data/models/material_model.dart';
import 'package:construction_app/data/models/material_request_model.dart';
import 'package:construction_app/data/repositories/inventory_repository.dart';
import 'package:provider/provider.dart';


class MaterialRequestScreen extends StatefulWidget {
  final bool showHeader;
  const MaterialRequestScreen({super.key, this.showHeader = true});

  @override
  State<MaterialRequestScreen> createState() => _MaterialRequestScreenState();
}

class _MaterialRequestScreenState extends State<MaterialRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _materialNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _purposeController = TextEditingController();
  final _remarksController = TextEditingController();
  
  String _priority = 'Medium';
  String _site = 'Main Site';
  bool _isLoading = false;
  ConstructionMaterial? _selectedMaterial;
  String get _unit => _selectedMaterial?.unitType.label ?? '';
  
  @override
  void dispose() {
    _materialNameController.dispose();
    _quantityController.dispose();
    _purposeController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryRepository>(
      builder: (context, inventoryRepo, child) {
        final allMaterials = inventoryRepo.materials;
        
        final bodyContent = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Item Selection', Icons.inventory_2_rounded),
                  const SizedBox(height: 16),
                  _buildMaterialSelector(),
                  const SizedBox(height: 32),
                  
                  _buildSectionHeader('Request Specifications', Icons.description_rounded),
                  const SizedBox(height: 16),
                  _buildRequestFields(),
                  const SizedBox(height: 16),
                  
                  // Purpose
                  HelpfulTextField(
                    label: 'Purpose',
                    controller: _purposeController,
                    hintText: 'Why is this material needed?',
                    useGlass: true,
                    validator: (value) => value!.isEmpty ? 'Please enter purpose' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  // Remarks
                  HelpfulTextField(
                    label: 'Additional Notes (Optional)',
                    controller: _remarksController,
                    hintText: 'Any special requirements',
                    maxLines: 3,
                    useGlass: true,
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _submitRequest,
                      icon: const Icon(Icons.send_rounded),
                      label: _isLoading 
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('SUBMIT REQUEST', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: bcAmber, 
                        foregroundColor: bcNavy,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  _buildRecentRequests(),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        );

        if (!widget.showHeader) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: bodyContent,
          );
        }

        return ProfessionalPage(
          title: 'Material Requisition',
          subtitle: 'Create and track site material tickets',
          category: 'INVENTORY MODULE',
          headerStats: [
            HeroStatPill(
              label: 'Active Materials', 
              value: '${allMaterials.length}', 
              color: bcNavy,
              onTap: _showMaterialSelectionSheet,
            ),
            HeroStatPill(
              label: 'Recent Requests', 
              value: '${inventoryRepo.requests.length}', 
              color: bcAmber,
              onTap: () {},
            ),
          ],
          children: [bodyContent],
        );
      }
    );
  }

  Widget _buildRequestFields() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        return Column(
          children: [
            if (isWide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: HelpfulTextField(
                      label: 'Quantity Required ($_unit)',
                      controller: _quantityController,
                      hintText: 'Enter quantity',
                      keyboardType: TextInputType.number,
                      useGlass: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter quantity';
                        final qty = double.tryParse(value);
                        if (qty == null || qty <= 0) return 'Please enter valid quantity';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: HelpfulDropdown<String>(
                      label: 'Destination Site',
                      value: _site,
                      items: const ['Main Site', 'Site A', 'Site B', 'Warehouse'],
                      onChanged: (value) => setState(() => _site = value!),
                      useGlass: true,
                    ),
                  ),
                ],
              )
            else ...[
              HelpfulTextField(
                label: 'Quantity Required ($_unit)',
                controller: _quantityController,
                hintText: 'Enter quantity',
                keyboardType: TextInputType.number,
                useGlass: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter quantity';
                  final qty = double.tryParse(value);
                  if (qty == null || qty <= 0) return 'Please enter valid quantity';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              HelpfulDropdown<String>(
                label: 'Destination Site',
                value: _site,
                items: const ['Main Site', 'Site A', 'Site B', 'Warehouse'],
                onChanged: (value) => setState(() => _site = value!),
                useGlass: true,
              ),
            ],
            const SizedBox(height: 16),
            HelpfulDropdown<String>(
              label: 'Priority',
              value: _priority,
              items: const ['Low', 'Medium', 'High', 'Urgent'],
              onChanged: (value) => setState(() => _priority = value!),
              useGlass: true,
            ),
          ],
        );
      }
    );
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMaterial == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a material'), backgroundColor: DesignSystem.error));
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final request = MaterialRequestModel(
        id: 'req_${DateTime.now().millisecondsSinceEpoch}',
        materialId: _selectedMaterial!.id,
        materialName: _selectedMaterial!.name,
        quantity: double.parse(_quantityController.text),
        unit: _selectedMaterial!.unitType.label,
        priority: _priority,
        siteId: _site, 
        purpose: _purposeController.text,
        remarks: _remarksController.text,
        requestedBy: context.read<AuthRepository>().userName ?? 'Site Personnel',
        createdAt: DateTime.now(),
        status: RequestStatus.pending,
      );

      await context.read<InventoryRepository>().createMaterialRequest(request);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Material request submitted for approval'),
            backgroundColor: DesignSystem.success,
          ),
        );
        _materialNameController.clear();
        _quantityController.clear();
        _purposeController.clear();
        _remarksController.clear();
        setState(() {
          _selectedMaterial = null;
          _priority = 'Medium';
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildRecentRequests() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'RECENT REQUESTS',
            style: TextStyle(
              color: DesignSystem.deepNavy.withValues(alpha: 0.6),
              fontWeight: FontWeight.w800,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<MaterialRequestModel>>(
          stream: context.read<InventoryRepository>().getRequestsStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(24),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: DesignSystem.deepNavy.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: DesignSystem.deepNavy.withValues(alpha: 0.05)),
                ),
                child: Text('No recent requests', style: TextStyle(color: DesignSystem.deepNavy.withValues(alpha: 0.4))),
              );
            }

            final requests = snapshot.data!.take(5).toList();
            return Column(
              children: requests.map((req) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
                  ],
                  border: Border.all(color: _getStatusColor(req.status).withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _getStatusColor(req.status).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_getStatusIcon(req.status), color: _getStatusColor(req.status), size: 18),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            req.materialName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: DesignSystem.deepNavy),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${req.quantity} ${req.unit} • ${req.priority} Priority',
                            style: TextStyle(color: DesignSystem.deepNavy.withValues(alpha: 0.6), fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(req.status).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            req.status.label.toUpperCase(),
                            style: TextStyle(
                              color: _getStatusColor(req.status),
                              fontWeight: FontWeight.w800,
                              fontSize: 10,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(req.createdAt),
                          style: TextStyle(color: DesignSystem.deepNavy.withValues(alpha: 0.4), fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              )).toList(),
            );
          },
        ),
      ],
    );
  }

  Color _getStatusColor(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending: return bcAmber;
      case RequestStatus.approved: return bcSuccess;
      case RequestStatus.rejected: return bcDanger;
      case RequestStatus.fulfilled: return DesignSystem.primaryBlue;
    }
  }

  IconData _getStatusIcon(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending: return Icons.access_time_rounded;
      case RequestStatus.approved: return Icons.check_circle_outline_rounded;
      case RequestStatus.rejected: return Icons.cancel_outlined;
      case RequestStatus.fulfilled: return Icons.done_all_rounded;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${date.day}/${date.month}';
  }

  Widget _buildMaterialSelector() {
    return TactileMaterialSelector(
      selectedMaterial: _selectedMaterial,
      onTap: _showMaterialSelectionSheet,
      themeColor: bcInfo,
      label: 'New Requisition Ticket',
      subLabel: 'Select material to request for site',
      techTag: 'REQUISITION-PLAN',
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: bcNavy.withValues(alpha: 0.6)),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            color: bcNavy.withValues(alpha: 0.6),
            fontWeight: FontWeight.w900,
            fontSize: 11,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  void _showMaterialSelectionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF8FAFC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: bcNavy.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: bcNavy,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.inventory_2_rounded, color: bcInfo, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Select Material',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              color: bcNavy,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            'Available Inventory'.toUpperCase(),
                            style: TextStyle(
                              color: bcNavy.withValues(alpha: 0.4),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: bcNavy),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              Expanded(
                child: StreamBuilder<List<ConstructionMaterial>>(
                  stream: context.read<InventoryRepository>().getMaterialsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: bcInfo));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No materials found'));
                    }
                    
                    final materials = snapshot.data!;
                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(20),
                      itemCount: materials.length,
                      itemBuilder: (context, index) {
                        final material = materials[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedMaterial = material;
                                _materialNameController.text = material.name;
                              });
                              Navigator.pop(context);
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: bcNavy.withValues(alpha: 0.06)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.02),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: bcNavy.withValues(alpha: 0.03),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(material.category.icon, color: bcNavy, size: 22),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          material.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 15,
                                            color: bcNavy,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Stock: ${material.currentStock} ${material.unitType.label} • ${material.brand ?? "No Brand"}',
                                          style: TextStyle(
                                            color: bcNavy.withValues(alpha: 0.5),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right_rounded, color: bcInfo, size: 20),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


