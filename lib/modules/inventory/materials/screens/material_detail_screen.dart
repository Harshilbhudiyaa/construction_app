import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:construction_app/shared/theme/professional_theme.dart';
import 'package:construction_app/shared/theme/design_system.dart';
import 'package:construction_app/shared/widgets/professional_page.dart';
import 'package:construction_app/shared/widgets/status_chip.dart';
import 'package:construction_app/shared/widgets/empty_state.dart';
import 'package:construction_app/services/mock_inventory_service.dart';
import 'package:construction_app/services/party_service.dart';
import 'package:construction_app/services/master_material_service.dart';


import 'package:construction_app/modules/inventory/parties/models/party_model.dart';
import 'package:construction_app/modules/inventory/materials/models/master_material_model.dart';
import 'package:construction_app/modules/inventory/materials/models/material_model.dart';
import 'package:construction_app/modules/inventory/inward/models/inward_movement_model.dart';
import 'package:intl/intl.dart';
import 'package:construction_app/modules/inventory/parties/screens/party_card_screen.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class MaterialDetailScreen extends StatefulWidget {
  final String materialId;
  const MaterialDetailScreen({super.key, required this.materialId});

  @override
  State<MaterialDetailScreen> createState() => _MaterialDetailScreenState();
}

class _MaterialDetailScreenState extends State<MaterialDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inventoryService = context.watch<MockInventoryService>();

    return StreamBuilder<ConstructionMaterial?>(
      stream: inventoryService.getMaterialStream(widget.materialId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary)),
          );
        }
        
        final material = snapshot.data;
        if (material == null) {
          return Scaffold(
            body: Center(child: Text('Material not found', style: TextStyle(color: Theme.of(context).colorScheme.primary))),
          );
        }

        return ProfessionalPage(
          title: material.name,
          children: [
            _buildImageHero(material),
            const SizedBox(height: 8),
            _buildTabNavigation(),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 1200, // Reduced fixed height or make dynamic
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildGeneralTab(material),
                    _buildLogisticsTab(material),
                    _buildFinanceTab(material),
                    _buildHistoryTab(material),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).textTheme.bodySmall?.color,
          fontWeight: FontWeight.w900,
          fontSize: 11,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildImageHero(ConstructionMaterial material) {
    return Container(
      width: double.infinity,
      height: 350,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.05),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: material.photoUrl != null
                ? Image(
                    image: (kIsWeb || material.photoUrl!.startsWith('http') || material.photoUrl!.startsWith('blob:'))
                        ? NetworkImage(material.photoUrl!) as ImageProvider
                        : FileImage(File(material.photoUrl!)),
                    fit: BoxFit.cover,
                  )
                : Center(child: Icon(material.category.icon, size: 100, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05))),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.transparent,
                    Colors.black.withOpacity(0.9),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
                  ),
                  child: Text(
                    '${material.category.displayName} • ${material.subType}'.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  material.name,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 32, letterSpacing: -1),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                  child: const Text('SITE: Warehouse', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabNavigation() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Theme.of(context).colorScheme.primary,
        unselectedLabelColor: Theme.of(context).textTheme.bodySmall?.color,
        labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5),
        tabs: const [
          Tab(text: 'GENERAL'),
          Tab(text: 'LOGISTICS'),
          Tab(text: 'FINANCE'),
          Tab(text: 'HISTORY'),
        ],
      ),
    );
  }

  Widget _buildGeneralTab(ConstructionMaterial material) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusAndCategory(context, material),
          const SizedBox(height: 24),
          _sectionHeader(context, 'Technical Specifications'),
          _buildDetailGrid(context, material),
          const SizedBox(height: 24),
          if (material.availableSizes.isNotEmpty) ...[
            _sectionHeader(context, 'Standard Sizes'),
            _buildSizesList(context, material.availableSizes),
            const SizedBox(height: 24),
          ],
          if (material.customDimensions.isNotEmpty) ...[
            _sectionHeader(context, 'Custom Dimensions'),
            _buildCustomDimensionsSection(context, material.customDimensions),
            const SizedBox(height: 24),
          ],
          _buildPricingCard(context, material),
        ],
      ),
    );
  }

  Widget _buildLogisticsTab(ConstructionMaterial material) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(context, 'Movement History'),
          _buildInwardLogsSection(context, material.name),
        ],
      ),
    );
  }

  Widget _buildFinanceTab(ConstructionMaterial material) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(context, 'Financial Breakdown'),
          ProfessionalCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _financeRow('Price per Unit', '₹${material.pricePerUnit}'),
                _financeRow('Quantity', '${material.currentStock} ${material.unitType.label}'),
                _financeRow('GST (${material.gstPercentage}%)', '₹${(material.totalAmount - (material.pricePerUnit * material.currentStock)).toStringAsFixed(2)}'),
                const Divider(height: 32),
                _financeRow('Total Value', '₹${material.totalAmount.toStringAsFixed(2)}', isBold: true),
                _financeRow('Paid Amount', '₹${material.paidAmount.toStringAsFixed(2)}', color: Colors.green),
                _financeRow('Pending Balance', '₹${material.pendingAmount.toStringAsFixed(2)}', color: Colors.redAccent, isBold: true),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (material.partyId != null) ...[
            _sectionHeader(context, 'Associated Party'),
            StreamBuilder<List<PartyModel>>(
              stream: PartyService().getPartiesStream(),
              builder: (context, snapshot) {
                final party = snapshot.data?.firstWhere((p) => p.id == material.partyId, orElse: () => PartyModel(id: '', name: 'Unknown', category: PartyCategory.other, createdAt: DateTime.now()));
                return ProfessionalCard(
                  padding: const EdgeInsets.all(0),
                  child: InkWell(
                    onTap: party != null ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => PartyCardScreen(party: party))) : null,
                    borderRadius: BorderRadius.circular(16),
                    child: ListTile(
                      leading: Icon(Icons.business_rounded, color: DesignSystem.deepNavy),
                      title: Text(party?.name ?? 'Loading...', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(party?.contactNumber ?? ''),
                      trailing: Icon(Icons.chevron_right_rounded, color: DesignSystem.coolGrey),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
          if (material.billingDetails != null) ...[
            const SizedBox(height: 24),
            _sectionHeader(context, 'Invoicing'),
            ProfessionalCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                   ListTile(
                    leading: const Icon(Icons.picture_as_pdf_rounded, color: Colors.redAccent),
                    title: const Text('Export Invoice PDF', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Generate a professional PDF bill'),
                    onTap: () => _exportMaterialPdf(context, material),
                    trailing: Icon(Icons.download_rounded, color: DesignSystem.coolGrey),
                  ),
                  if (material.billingDetails?.billPhotoUrl != null) ...[
                    const Divider(),
                    ListTile(
                      leading: Icon(Icons.image_rounded, color: DesignSystem.electricBlue),
                      title: const Text('View Bill Photo', style: TextStyle(fontWeight: FontWeight.bold)),
                      onTap: () => _openFullImage(context, material.billingDetails!.billPhotoUrl!, 'Invoice'),
                      trailing: Icon(Icons.visibility_rounded, color: DesignSystem.coolGrey),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _financeRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: DesignSystem.coolGrey, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color, fontSize: isBold ? 16 : 14)),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(ConstructionMaterial material) {
    final history = material.history.reversed.toList();
    if (history.isEmpty) {
      return const EmptyState(icon: Icons.history_rounded, title: 'No History', message: 'No changes have been recorded yet.');
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final log = history[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ProfessionalCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: DesignSystem.deepNavy.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(Icons.edit_note_rounded, size: 16, color: DesignSystem.deepNavy),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(log.action, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(log.description, style: TextStyle(fontSize: 12, color: DesignSystem.coolGrey)),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd MMM, hh:mm a').format(log.timestamp),
                        style: TextStyle(fontSize: 10, color: DesignSystem.coolGrey.withOpacity(0.7)),
                      ),
                    ],
                  ),
                ),
                Text(log.performedBy, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _exportMaterialPdf(BuildContext context, ConstructionMaterial material) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('MATERIAL INVOICE / LEDGER', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text('Material: ${material.name}'),
              pw.Text('Date: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}'),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Text('FINANCIAL BREAKDOWN', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Price per Unit:'),
                  pw.Text('Rs. ${material.pricePerUnit}'),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Current Quantity:'),
                  pw.Text('${material.currentStock} ${material.unitType.label}'),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('GST Basis (${material.gstPercentage}%):'),
                  pw.Text('Rs. ${(material.totalAmount - (material.pricePerUnit * material.currentStock)).toStringAsFixed(2)}'),
                ],
              ),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TOTAL VALUE:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('Rs. ${material.totalAmount.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Amount Paid:'),
                  pw.Text('Rs. ${material.paidAmount.toStringAsFixed(2)}'),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('PENDING BALANCE:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.red)),
                  pw.Text('Rs. ${material.pendingAmount.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.red)),
                ],
              ),
              pw.SizedBox(height: 30),
              pw.Text('TRANSACTION HISTORY', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Divider(),
              ...material.history.reversed.map((log) => pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(log.action, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      pw.Text(DateFormat('dd MMM yyyy, hh:mm a').format(log.timestamp), style: const pw.TextStyle(fontSize: 8)),
                    ],
                  ),
                  pw.Text(log.description, style: const pw.TextStyle(fontSize: 9)),
                  pw.SizedBox(height: 5),
                ],
              )),
              pw.SizedBox(height: 40),
              pw.Text('Generated by Construction App', style: const pw.TextStyle(fontSize: 10)),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Invoice_${material.name.replaceAll(' ', '_')}.pdf',
    );
  }

  Widget _buildStatusAndCategory(BuildContext context, ConstructionMaterial material) {
    return Row(
      children: [
        StatusChip(
          status: material.isActive ? UiStatus.ok : UiStatus.stop,
          labelOverride: material.isActive ? 'IN STOCK' : 'OUT OF STOCK',
        ),
        const SizedBox(width: 12),
        if (material.isActive)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'READY TO DISPATCH',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.greenAccent 
                    : const Color(0xFF2E7D32), 
                fontSize: 9, 
                fontWeight: FontWeight.w800, 
                letterSpacing: 0.5
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDetailGrid(BuildContext context, ConstructionMaterial material) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildDetailTile(context, 'Brand', material.brand ?? 'Standard', Icons.branding_watermark_rounded)),
            const SizedBox(width: 16),
            Expanded(child: _buildDetailTile(context, 'Stock', '${material.currentStock} ${material.unitType.label}', Icons.inventory_2_rounded)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildDetailTile(context, 'Unit', material.unitType.label.toUpperCase(), Icons.scale_rounded)),
            const SizedBox(width: 16),
            Expanded(
              child: FutureBuilder<MasterMaterial?>(
                future: MasterMaterialService().getMasterMaterialsStream().first.then((list) => list.firstWhere((m) => m.id == material.masterMaterialId)),
                builder: (context, mmSnap) {
                  final catName = mmSnap.data?.category == MaterialCategory.other ? (mmSnap.data?.customCategoryName ?? 'Other') : mmSnap.data?.category.displayName ?? 'N/A';
                  return _buildDetailTile(context, 'Registry Category', catName, Icons.category_rounded);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailTile(BuildContext context, String label, String value, IconData icon) {
    return ProfessionalCard(
      useGlass: true,
      padding: const EdgeInsets.all(18),
      margin: EdgeInsets.zero,
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 16),
          Text(label.toUpperCase(), style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: -0.2)),
        ],
      ),
    );
  }

  Widget _buildSizesList(BuildContext context, List<String> sizes) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: sizes.map((size) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
        ),
        child: Text(
          size,
          style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 14),
        ),
      )).toList(),
    );
  }

  Widget _buildPricingCard(BuildContext context, ConstructionMaterial material) {
    return ProfessionalCard(
      padding: const EdgeInsets.all(28),
      margin: EdgeInsets.zero,
      borderRadius: 24,
      color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('MARKET RATE', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    const Text('₹', style: TextStyle(color: Colors.greenAccent, fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 4),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          material.pricePerUnit.toString(),
                          style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 42, fontWeight: FontWeight.w900, letterSpacing: -1),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('per ${material.unitType.label}', style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 14, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Theme.of(context).colorScheme.primary.withOpacity(0.2), Theme.of(context).colorScheme.primary.withOpacity(0.05)],
              ),
              shape: BoxShape.circle,
              border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
            ),
            child: const Icon(Icons.show_chart_rounded, color: Colors.greenAccent, size: 36),
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierCard(BuildContext context, SupplierDetails supplier) {
    return ProfessionalCard(
      useGlass: true,
      padding: const EdgeInsets.all(24),
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.business_rounded, color: Theme.of(context).colorScheme.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      supplier.companyName,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                    if (supplier.gstNumber != null)
                      Text(
                        'GST: ${supplier.gstNumber}',
                        style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (supplier.address != null) ...[
            const SizedBox(height: 20),
            _infoRow(context, Icons.location_on_rounded, supplier.address!),
          ],
          const SizedBox(height: 24),
          Divider(color: Theme.of(context).dividerColor.withOpacity(0.1)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CONTACT PERSON',
                      style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      supplier.contactPerson ?? 'N/A',
                      style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 15, fontWeight: FontWeight.w900),
                    ),
                    if (supplier.contactRole != null)
                      Text(
                        supplier.contactRole!,
                        style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
              ),
              if (supplier.contactPhone != null)
                Container(
                  decoration: BoxDecoration(color: Colors.greenAccent.withOpacity(0.1), shape: BoxShape.circle),
                  child: IconButton(
                    onPressed: () {}, // Would launch phone in real app
                    icon: const Icon(Icons.phone_rounded, color: Colors.greenAccent, size: 20),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Theme.of(context).textTheme.bodySmall?.color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), fontSize: 14, height: 1.4),
          ),
        ),
      ],
    );
  }

  Widget _buildBillingCard(BuildContext context, BillingDetails billing) {
    return ProfessionalCard(
      useGlass: true,
      padding: const EdgeInsets.all(24),
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bill Photo Section
          if (billing.billPhotoUrl != null) ...[
            Text(
              'INVOICE / BILL',
              style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image(
                image: (kIsWeb || billing.billPhotoUrl!.startsWith('http'))
                    ? NetworkImage(billing.billPhotoUrl!) as ImageProvider
                    : FileImage(File(billing.billPhotoUrl!)),
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 24),
            Divider(color: Theme.of(context).dividerColor.withOpacity(0.1)),
            const SizedBox(height: 24),
          ],
          // Billing Person Details
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person_rounded, color: Colors.greenAccent, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      billing.billingPersonName ?? 'N/A',
                      style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                    if (billing.billingPersonRole != null)
                      Text(
                        billing.billingPersonRole!,
                        style: TextStyle(color: Colors.greenAccent.withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
              ),
              if (billing.billingPersonContact != null)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () {}, // Would launch phone in real app
                    icon: const Icon(Icons.phone_rounded, color: Colors.greenAccent, size: 20),
                  ),
                ),
            ],
          ),
          if (billing.remarks != null) ...[
            const SizedBox(height: 20),
            Text(
              'NOTES',
              style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.03),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.05)),
              ),
              child: Text(
                billing.remarks!,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), fontSize: 13, height: 1.5),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _openFullImage(BuildContext context, String imageUrl, String stage) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, _, _) {
          return Scaffold(
            backgroundColor: Colors.black.withOpacity(0.95),
            body: Stack(
              children: [
                Center(
                  child: InteractiveViewer(
                    maxScale: 4,
                    child: Hero(
                      tag: imageUrl,
                      child: (kIsWeb || imageUrl.startsWith('http') || imageUrl.startsWith('blob:'))
                          ? Image.network(imageUrl, fit: BoxFit.contain)
                          : Image.file(File(imageUrl), fit: BoxFit.contain),
                    ),
                  ),
                ),
                Positioned(
                  top: 50,
                  right: 25,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 60,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Text(
                        stage.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: 40,
                        height: 3,
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInwardLogsSection(BuildContext context, String materialName) {
    final inventoryService = context.read<MockInventoryService>();

    return StreamBuilder<List<InwardMovementModel>>(
      stream: inventoryService.getInwardLogsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        final allLogs = snapshot.data ?? [];
        final filteredLogs = allLogs.where((log) => log.materialName == materialName).toList();

        if (filteredLogs.isEmpty) {
          return const EmptyState(
            icon: Icons.history_rounded,
            title: 'No Inward Movements',
            message: 'There are no recorded logistics entries for this material yet.',
            useGlass: true,
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredLogs.length,
          separatorBuilder: (_, _) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final log = filteredLogs[index];
            return ProfessionalCard(
              useGlass: true,
              padding: const EdgeInsets.all(0),
              margin: EdgeInsets.zero,
              borderRadius: 20,
              child: InkWell(
                onTap: () {}, // Future details
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Theme.of(context).colorScheme.surface.withOpacity(0.05), Colors.transparent],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('dd MMM yyyy • hh:mm a').format(log.createdAt),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${log.quantity} ${log.unit}',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                          StatusChip(
                            status: log.status == InwardStatus.approved ? UiStatus.approved : UiStatus.pending,
                            labelOverride: log.status == InwardStatus.approved ? 'VERIFIED' : 'PENDING',
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLogMinorTile(context, 'Vehicle & Transporter', '${log.vehicleNumber} • ${log.transporterName}', Icons.local_shipping_rounded),
                          const SizedBox(height: 12),
                          _buildLogMinorTile(context, 'Driver Info', '${log.driverName} (${log.driverMobile})', Icons.person_pin_rounded),
                          if (log.photoProofs.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            Text(
                              'LOGISTICS PROOFS',
                              style: TextStyle(
                                color: Theme.of(context).textTheme.bodySmall?.color,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 120,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                itemCount: log.photoProofs.length,
                                separatorBuilder: (_, _) => const SizedBox(width: 14),
                                itemBuilder: (context, pIndex) {
                                  final proof = log.photoProofs[pIndex];
                                  return Hero(
                                    tag: proof.photoUrl,
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () => _openFullImage(context, proof.photoUrl, proof.stage),
                                        borderRadius: BorderRadius.circular(16),
                                        child: Container(
                                          width: 140,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(16),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.2),
                                                blurRadius: 8,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(16),
                                            child: Stack(
                                              children: [
                                                Positioned.fill(
                                                  child: Image(
                                                    image: (kIsWeb || proof.photoUrl.startsWith('http') || proof.photoUrl.startsWith('blob:'))
                                                        ? NetworkImage(proof.photoUrl) as ImageProvider
                                                        : FileImage(File(proof.photoUrl)),
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context, error, stackTrace) => Container(
                                                      color: Theme.of(context).colorScheme.surface.withOpacity(0.05),
                                                      child: Icon(Icons.broken_image_rounded, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.24)),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  bottom: 0,
                                                  left: 0,
                                                  right: 0,
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        begin: Alignment.topCenter,
                                                        end: Alignment.bottomCenter,
                                                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                                                      ),
                                                    ),
                                                    child: Text(
                                                      proof.stage.toUpperCase(),
                                                      textAlign: TextAlign.center,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 8,
                                                        fontWeight: FontWeight.w900,
                                                        letterSpacing: 0.8,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 8,
                                                  right: 8,
                                                  child: Container(
                                                    padding: const EdgeInsets.all(4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.black.withOpacity(0.38),
                                                      shape: BoxShape.circle,
                                                      border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.24), width: 0.5),
                                                    ),
                                                    child: const Icon(Icons.fullscreen_rounded, color: Colors.white, size: 14),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.deepBlue1.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green.withOpacity(0.1)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'TOTAL TRANSACTION',
                                  style: TextStyle(
                                    color: Theme.of(context).textTheme.bodySmall?.color,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  '₹${NumberFormat('#,##,###').format(log.totalAmount)}',
                                  style: const TextStyle(
                                    color: Colors.greenAccent,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLogMinorTile(BuildContext context, String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 10, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 6),
            Text(label.toUpperCase(), style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8), fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildCustomDimensionsSection(BuildContext context, List<CustomDimension> dimensions) {
    return ProfessionalCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: dimensions.map((dim) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.blueAccent.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.straighten_rounded, size: 16, color: Colors.blueAccent),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dim.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text(dim.unit, style: const TextStyle(fontSize: 11, color: AppColors.steelBlue)),
                  ],
                ),
              ),
              Text(
                dim.value.toString(),
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.blueAccent),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }
}
