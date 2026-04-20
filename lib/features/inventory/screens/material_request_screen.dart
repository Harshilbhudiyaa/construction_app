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
  String get _unit => _selectedMaterial?.unitType ?? '';
  
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
    final inventoryRepo = context.watch<InventoryRepository>();
    final allMaterials = inventoryRepo.materials;
    final totalReqs = inventoryRepo.requests.length;

    return Scaffold(
      backgroundColor: bcSurface,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SmartConstructionSliverAppBar(
            title: 'Request Items',
            subtitle: 'Procurement & Requisition Console',
            category: 'INVENTORY LOGISTICS',
            headerStats: [
              HeroStatPill(
                label: 'TOTAL REQS',
                value: '$totalReqs',
                icon: Icons.history_edu_rounded,
                color: bcAmber,
              ),
              HeroStatPill(
                label: 'CATALOG',
                value: '${allMaterials.length}',
                icon: Icons.category_rounded,
                color: bcInfo,
              ),
            ],
          ),
        ],
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          physics: const BouncingScrollPhysics(),
          children: [
            // Request Form Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: bcBorder.withValues(alpha: 0.6)),
                boxShadow: [BoxShadow(color: bcNavy.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 10))],
              ),
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Item Selection', Icons.inventory_2_rounded),
                    const SizedBox(height: 16),
                    _buildMaterialSelector(),
                    const SizedBox(height: 24),
                    
                    _buildSectionHeader('Specifications', Icons.description_rounded),
                    const SizedBox(height: 16),
                    _buildRequestFields(),
                    const SizedBox(height: 20),
                    
                    Text('Purpose', style: TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.2)),
                    const SizedBox(height: 8),
                    _buildHubTextField(
                      controller: _purposeController,
                      hint: 'Why is this material needed?',
                      icon: Icons.lightbulb_outline_rounded,
                    ),
                    const SizedBox(height: 16),

                    Text('Notes (Optional)', style: TextStyle(color: bcNavy, fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(height: 8),
                    _buildHubTextField(
                      controller: _remarksController,
                      hint: 'Any special instructions...',
                      maxLines: 2,
                    ),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: bcNavy,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: _isLoading 
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('SUBMIT REQUISITION', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2, fontSize: 13)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            _buildSectionHeader('Recent Requests', Icons.history_rounded),
            const SizedBox(height: 16),
            
            _buildRecentRequests(),
          ],
        ),
      ),
    );
  }

  Widget _buildHubTextField({required TextEditingController controller, required String hint, IconData? icon, int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: bcSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bcBorder.withValues(alpha: 0.6)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: bcTextSecondary.withValues(alpha: 0.6), size: 18),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: maxLines,
              style: const TextStyle(fontSize: 14, color: bcNavy, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                hintStyle: TextStyle(color: bcTextSecondary.withValues(alpha: 0.5), fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Quantity Required ($_unit)', style: TextStyle(color: bcNavy, fontWeight: FontWeight.w700, fontSize: 12)),
                        const SizedBox(height: 8),
                        _buildHubTextField(controller: _quantityController, hint: '0.00'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: HelpfulDropdown<String>(
                      label: 'Destination Site',
                      value: _site,
                      items: const ['Main Site', 'Site A', 'Site B', 'Warehouse'],
                      onChanged: (value) => setState(() => _site = value!),
                      useGlass: false,
                    ),
                  ),
                ],
              )
            else ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Quantity Required ($_unit)', style: TextStyle(color: bcNavy, fontWeight: FontWeight.w700, fontSize: 12)),
                  const SizedBox(height: 8),
                  _buildHubTextField(controller: _quantityController, hint: '0.00'),
                ],
              ),
              const SizedBox(height: 16),
              HelpfulDropdown<String>(
                label: 'Destination Site',
                value: _site,
                items: const ['Main Site', 'Site A', 'Site B', 'Warehouse'],
                onChanged: (value) => setState(() => _site = value!),
                useGlass: false,
              ),
            ],
            const SizedBox(height: 16),
            HelpfulDropdown<String>(
              label: 'Priority Level',
              value: _priority,
              items: const ['Low', 'Medium', 'High', 'Urgent'],
              onChanged: (value) => setState(() => _priority = value!),
              useGlass: false,
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMaterial == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a material'), backgroundColor: bcDanger));
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final request = MaterialRequestModel(
        id: 'req_${DateTime.now().millisecondsSinceEpoch}',
        materialId: _selectedMaterial!.id,
        materialName: _selectedMaterial!.name,
        quantity: double.tryParse(_quantityController.text) ?? 0.0,
        unit: _selectedMaterial!.unitType,
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
            content: Text('Material requisition submitted successfully'),
            backgroundColor: bcSuccess,
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
    return StreamBuilder<List<MaterialRequestModel>>(
      stream: context.read<InventoryRepository>().getRequestsStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bcNavy.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: bcBorder.withValues(alpha: 0.5)),
            ),
            child: Column(
              children: [
                Icon(Icons.history_edu_rounded, color: bcTextSecondary.withValues(alpha: 0.3), size: 32),
                const SizedBox(height: 12),
                Text('No recent requests', style: TextStyle(color: bcTextSecondary.withValues(alpha: 0.6), fontWeight: FontWeight.w600)),
              ],
            ),
          );
        }

        final requests = snapshot.data!.take(5).toList();
        return Column(
          children: requests.map((req) => _RequestHistoryCard(req: req)).toList(),
        );
      },
    );
  }

  Color _getStatusColor(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending: return bcAmber;
      case RequestStatus.approved: return bcSuccess;
      case RequestStatus.rejected: return bcDanger;
      case RequestStatus.fulfilled: return bcInfo;
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
      label: 'Procurement Target',
      subLabel: 'Find material in inventory catalog',
      techTag: 'REQUISITION-X',
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: bcNavy.withValues(alpha: 0.5)),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            color: bcNavy.withValues(alpha: 0.5),
            fontWeight: FontWeight.w900,
            fontSize: 10,
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
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: bcSurface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: bcNavy.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(2))),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Select Material', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: bcNavy)),
                          Text('CENTRAL CATALOG', style: TextStyle(color: bcAmber, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                        ],
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.close_rounded, color: bcNavy), onPressed: () => Navigator.pop(context)),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: StreamBuilder<List<ConstructionMaterial>>(
                  stream: context.read<InventoryRepository>().getMaterialsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: bcAmber));
                    if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('No materials found'));
                    
                    final materials = snapshot.data!;
                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
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
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: bcBorder.withValues(alpha: 0.6)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44, height: 44,
                                    decoration: BoxDecoration(color: bcNavy.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
                                    child: Center(child: Text(material.name[0].toUpperCase(), style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 18))),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(material.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: bcNavy)),
                                        Text('${material.currentStock} ${material.unitType} in stock', style: TextStyle(color: bcTextSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right_rounded, color: bcInfo),
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

class _RequestHistoryCard extends StatelessWidget {
  final MaterialRequestModel req;
  const _RequestHistoryCard({required this.req});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(req.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bcBorder.withValues(alpha: 0.6)),
        boxShadow: [BoxShadow(color: bcNavy.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(_statusIcon(req.status), color: statusColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(req.materialName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: bcNavy)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('${req.quantity} ${req.unit}', style: TextStyle(color: bcTextSecondary, fontSize: 12, fontWeight: FontWeight.w800)),
                    const SizedBox(width: 8),
                    Container(width: 4, height: 4, decoration: const BoxDecoration(color: bcBorder, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Text(req.priority.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(req.status.label.toUpperCase(), style: TextStyle(color: statusColor, fontWeight: FontWeight.w900, fontSize: 9, letterSpacing: 0.5)),
              ),
              const SizedBox(height: 6),
              Text(_formatTime(req.createdAt), style: TextStyle(color: bcTextSecondary.withValues(alpha: 0.5), fontSize: 10, fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }

  Color _statusColor(RequestStatus s) {
    switch (s) {
      case RequestStatus.pending: return bcAmber;
      case RequestStatus.approved: return bcSuccess;
      case RequestStatus.rejected: return bcDanger;
      case RequestStatus.fulfilled: return bcInfo;
    }
  }

  IconData _statusIcon(RequestStatus s) {
    switch (s) {
      case RequestStatus.pending: return Icons.access_time_rounded;
      case RequestStatus.approved: return Icons.check_circle_outline_rounded;
      case RequestStatus.rejected: return Icons.cancel_outlined;
      case RequestStatus.fulfilled: return Icons.done_all_rounded;
    }
  }

  String _formatTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    final inMinutes = diff.inMinutes;
    if (inMinutes < 60) return '${inMinutes}m ago';
    final inHours = diff.inHours;
    if (inHours < 24) return '${inHours}h ago';
    return '${date.day}/${date.month}';
  }
}
