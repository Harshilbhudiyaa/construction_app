import 'package:flutter/material.dart';
import 'package:construction_app/shared/theme/app_spacing.dart';
import 'package:construction_app/shared/theme/professional_theme.dart';
import 'package:construction_app/shared/widgets/status_chip.dart';
import 'package:construction_app/shared/widgets/professional_page.dart';
import 'models/inward_movement_model.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class InwardBillViewScreen extends StatelessWidget {
  final InwardMovementModel item;

  const InwardBillViewScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    bool isPending = item.status == InwardStatus.pendingApproval;

    return ProfessionalPage(
      title: 'Billing Strategic Detail',
      actions: [
        IconButton(
          onPressed: () => _exportPdf(context),
          icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
        ),
      ],
      children: [
        _buildStatusHeader(isPending),
        
        const ProfessionalSectionHeader(
          title: 'Supply Logistics',
          subtitle: 'Vehicle and driver authentication data',
        ),
        _buildLogisticsCard(),

        const ProfessionalSectionHeader(
          title: 'Strategic Verification',
          subtitle: 'Mandatory photographic evidence',
        ),
        _buildPhotoProofsGrid(),

        const ProfessionalSectionHeader(
          title: 'Financial Settlement',
          subtitle: 'Detailed billing and tax breakdown',
        ),
        _buildBillingCard(),

        if (isPending) _buildApprovalActions(context),

        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildStatusHeader(bool isPending) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ProfessionalCard(
        useGlass: true,
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: (isPending ? Colors.orangeAccent : Colors.greenAccent).withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                isPending ? Icons.pending_rounded : Icons.verified_user_rounded,
                color: isPending ? Colors.orangeAccent : Colors.greenAccent,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.id,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Recorded: ${DateFormat('MMM dd, hh:mm a').format(item.createdAt)}',
                    style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            StatusChip(
              status: isPending ? UiStatus.pending : UiStatus.approved,
              labelOverride: isPending ? 'PENDING' : 'APPROVED',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogisticsCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ProfessionalCard(
        useGlass: true,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _kv('Vehicle', '${item.vehicleNumber} (${item.vehicleType})', icon: Icons.local_shipping_rounded),
            const Divider(height: 32, color: Colors.white10),
            _kv('Transporter', item.transporterName, icon: Icons.business_rounded),
            const Divider(height: 32, color: Colors.white10),
            _kv('Driver', '${item.driverName} (${item.driverMobile})', icon: Icons.person_rounded),
            const Divider(height: 32, color: Colors.white10),
            _kv('License', item.driverLicense, icon: Icons.badge_rounded),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoProofsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.8,
        children: [
          _photoThumbnail('Source', Icons.outbox_rounded),
          _photoThumbnail('Arrival', Icons.sensor_door_rounded),
          _photoThumbnail('Bill/Invc', Icons.receipt_rounded),
        ],
      ),
    );
  }

  Widget _photoThumbnail(String label, IconData icon) {
    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Center(
              child: Icon(icon, color: Colors.white24, size: 32),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label.toUpperCase(),
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5),
        ),
      ],
    );
  }

  Widget _buildBillingCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ProfessionalCard(
        useGlass: true,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _kv('Material', '${item.materialName} • ${item.quantity} ${item.unit}', isHeader: true),
            const SizedBox(height: 16),
            _kv('Rate / Unit', '₹${item.ratePerUnit}', icon: Icons.sell_rounded),
            _kv('Subtotal', '₹${NumberFormat('#,##,###').format(item.subtotal)}'),
            const Divider(height: 24, color: Colors.white10),
            _kv('Transport', '₹${item.transportCharges}', icon: Icons.local_shipping_outlined),
            _kv('Tax (${item.taxPercentage}%)', '₹${NumberFormat('#,##,###').format(item.taxAmount)}', icon: Icons.account_balance_rounded),
            const Divider(height: 32, color: Colors.white10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('TOTAL PAYABLE', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1)),
                Text(
                  '₹${NumberFormat('#,##,###').format(item.totalAmount)}',
                  style: const TextStyle(color: Colors.greenAccent, fontSize: 24, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApprovalActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    side: const BorderSide(color: Colors.redAccent, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('REJECT ENTRY', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900, letterSpacing: 1)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Colors.greenAccent, Colors.teal]),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.greenAccent.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Movement Approved. Inventory updated.')),
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('APPROVE & UPDATE STOCK', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Approval will instantly increment stock levels in the master ledger.',
            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Future<void> _exportPdf(BuildContext context) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('INWARD STRATEGIC BILL', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text('Transaction ID: ${item.id}'),
              pw.Text('Date: ${DateFormat('yyyy-MM-dd HH:mm').format(item.createdAt)}'),
              pw.Divider(),
              pw.Text('LOGISTICS', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('Vehicle: ${item.vehicleNumber} (${item.vehicleType})'),
              pw.Text('Transporter: ${item.transporterName}'),
              pw.Text('Driver: ${item.driverName} (${item.driverMobile})'),
              pw.SizedBox(height: 20),
              pw.Text('MATERIAL DETAILS', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('Material: ${item.materialName}'),
              pw.Text('Quantity: ${item.quantity} ${item.unit}'),
              pw.SizedBox(height: 20),
              pw.Text('FINANCIALS', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('Rate: Rs. ${item.ratePerUnit}'),
              pw.Text('Subtotal: Rs. ${item.subtotal}'),
              pw.Text('Transport: Rs. ${item.transportCharges}'),
              pw.Text('Tax (${item.taxPercentage}%): Rs. ${item.taxAmount.toStringAsFixed(2)}'),
              pw.Divider(),
              pw.Text('TOTAL PAYABLE: Rs. ${item.totalAmount.toStringAsFixed(2)}', 
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 40),
              pw.Text('Generated by Construction App', style: const pw.TextStyle(fontSize: 10)),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Bill_${item.id}.pdf',
    );
  }

  Widget _kv(String k, String v, {IconData? icon, bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: Colors.white24),
            const SizedBox(width: 12),
          ],
          Text(
            k,
            style: TextStyle(
              color: isHeader ? Colors.white : Colors.white54,
              fontSize: isHeader ? 14 : 12,
              fontWeight: isHeader ? FontWeight.w900 : FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            v,
            style: TextStyle(
              color: isHeader ? Colors.white : Colors.white,
              fontSize: isHeader ? 16 : 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
