import 'package:flutter/material.dart';
import 'package:construction_app/core/theme/professional_theme.dart';
import 'package:construction_app/core/theme/aesthetic_tokens.dart';
import 'package:construction_app/shared/widgets/status_badge.dart';
import 'package:construction_app/shared/widgets/professional_page.dart';
import 'package:construction_app/data/models/inward_movement_model.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:construction_app/data/repositories/inventory_repository.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import 'inward_entry_form_screen.dart';
import 'package:construction_app/data/repositories/auth_repository.dart';

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
          icon: Icon(Icons.picture_as_pdf_rounded, color: Theme.of(context).colorScheme.onPrimary),
        ),
      ],
      children: [
        _buildStatusHeader(context, isPending),
        
        const ProfessionalSectionHeader(
          title: 'Supply Logistics',
          subtitle: 'Vehicle and driver authentication data',
        ),
        _buildLogisticsCard(context),

        const ProfessionalSectionHeader(
          title: 'Strategic Verification',
          subtitle: 'Mandatory photographic evidence',
        ),
        _buildPhotoProofsGrid(context),

        const ProfessionalSectionHeader(
          title: 'Financial Settlement',
          subtitle: 'Detailed billing and tax breakdown',
        ),
        _buildBillingCard(context),

        if (isPending && context.watch<AuthRepository>().canApprove) 
          _buildActionButtons(context),

        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildStatusHeader(BuildContext context, bool isPending) {
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
                color: (isPending ? Colors.orangeAccent : Colors.greenAccent).withValues(alpha: 0.1),
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
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Recorded: ${DateFormat('MMM dd, hh:mm a').format(item.createdAt)}',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            StatusBadge(
              label: isPending ? 'PENDING' : 'APPROVED',
              type: isPending ? StatusBadgeType.warning : StatusBadgeType.success,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogisticsCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ProfessionalCard(
        useGlass: true,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _kv(context, 'Vehicle', '${item.vehicleNumber} (${item.vehicleType})', icon: Icons.local_shipping_rounded),
            Divider(height: 32, color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
            _kv(context, 'Transporter', item.transporterName, icon: Icons.business_rounded),
            Divider(height: 32, color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
            _kv(context, 'Driver', '${item.driverName} (${item.driverMobile})', icon: Icons.person_rounded),
            Divider(height: 32, color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
            _kv(context, 'License', item.driverLicense, icon: Icons.badge_rounded),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoProofsGrid(BuildContext context) {
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
          _photoThumbnail(context, 'Source', Icons.outbox_rounded),
          _photoThumbnail(context, 'Arrival', Icons.sensor_door_rounded),
          _photoThumbnail(context, 'Bill/Invc', Icons.receipt_rounded),
        ],
      ),
    );
  }

  Widget _photoThumbnail(BuildContext context, String label, IconData icon) {
    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
            ),
            child: Center(
              child: Icon(icon, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.24), size: 32),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label.toUpperCase(),
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5),
        ),
      ],
    );
  }

  Widget _buildBillingCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ProfessionalCard(
        useGlass: true,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _kv(context, 'Material', '${item.materialName} • ${item.quantity} ${item.unit}', isHeader: true),
            if (item.availableSizes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: item.availableSizes.map((s) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.2)),
                  ),
                  child: Text(s, style: const TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                )).toList(),
              ),
            ],
            const SizedBox(height: 16),
            _kv(context, 'Rate / Unit', '₹${item.ratePerUnit}', icon: Icons.sell_rounded),
            _kv(context, 'Subtotal', '₹${NumberFormat('#,##,###').format(item.subtotal)}'),
            Divider(height: 24, color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
            _kv(context, 'Transport', '₹${item.transportCharges}', icon: Icons.local_shipping_outlined),
            _kv(context, 'Tax (${item.taxPercentage}%)', '₹${NumberFormat('#,##,###').format(item.taxAmount)}', icon: Icons.account_balance_rounded),
            Divider(height: 32, color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('TOTAL PAYABLE', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1)),
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

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 1,
                child: OutlinedButton(
                  onPressed: () => _confirmReject(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: bcDanger,
                    side: const BorderSide(color: bcDanger, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('REJECT ENTRY', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () => _approveLog(context, item),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('APPROVE & UPDATE STOCK', 
                        style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5, fontSize: 13)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SecondaryActionButton(
                  label: 'EDIT DETAILS',
                  icon: Icons.edit_rounded,
                  color: Colors.blueAccent,
                  onTap: () => _editEntry(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SecondaryActionButton(
                  label: 'DELETE LOG',
                  icon: Icons.delete_forever_rounded,
                  color: bcDanger,
                  onTap: () => _deleteEntry(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Approval will instantly increment stock levels in the master ledger.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: bcTextSecondary.withValues(alpha: 0.5),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmReject(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('REJECT DELIVERY', style: TextStyle(fontWeight: FontWeight.w900, color: bcNavy)),
        content: const Text('This entry will be marked as REJECTED and no stock will be updated.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ABORT')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _rejectLog(context, item.id);
            },
            child: const Text('CONFIRM REJECT', style: TextStyle(color: bcDanger, fontWeight: FontWeight.bold)),
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
              if (item.availableSizes.isNotEmpty) 
                pw.Text('Sizes: ${item.availableSizes.join(', ')}'),
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

  Future<void> _approveLog(BuildContext context, InwardMovementModel item) async {
    final service = Provider.of<InventoryRepository>(context, listen: false);
    try {
      final auth = context.read<AuthRepository>();
      await service.approveInwardLog(item.id, auth.userName ?? 'Admin');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Movement Approved. Inventory updated.'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _rejectLog(BuildContext context, String id) async {
    final service = Provider.of<InventoryRepository>(context, listen: false);
    try {
      final auth = context.read<AuthRepository>();
      await service.rejectInwardLog(id, auth.userName ?? 'Admin', 'User Rejected');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entry Rejected'), backgroundColor: Colors.orange),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _editEntry(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InwardEntryFormScreen(
          siteId: item.siteId,
          editingLog: item,
        ),
      ),
    );
  }

  Future<void> _deleteEntry(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Log?'),
        content: const Text('Are you sure you want to permanently delete this inward entry? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true), 
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final service = Provider.of<InventoryRepository>(context, listen: false);
      try {
        await service.deleteInwardLog(item.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Log deleted successfully.')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Widget _kv(BuildContext context, String k, String v, {IconData? icon, bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.24)),
            const SizedBox(width: 12),
          ],
          Text(
            k,
            style: TextStyle(
              color: isHeader ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54),
              fontSize: isHeader ? 14 : 12,
              fontWeight: isHeader ? FontWeight.w900 : FontWeight.w600,
            ),
          ),
          const Spacer(),
          Expanded(
            child: Text(
              v,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: isHeader ? 16 : 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SecondaryActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: color.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
   

