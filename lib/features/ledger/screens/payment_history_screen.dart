import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:construction_app/data/repositories/payment_repository.dart';
import 'package:construction_app/data/repositories/party_repository.dart';
import 'package:construction_app/data/models/payment_model.dart';
import 'package:construction_app/data/models/party_model.dart';
import 'package:construction_app/core/services/workflow_service.dart';
import 'package:construction_app/core/theme/design_system.dart';
import 'package:construction_app/shared/widgets/professional_page.dart';
import 'package:construction_app/shared/widgets/adaptive_card.dart';
import 'package:construction_app/shared/widgets/status_badge.dart';
import 'package:construction_app/core/theme/aesthetic_tokens.dart';

import 'package:construction_app/shared/widgets/helpful_dropdown.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final paymentRepo = context.watch<PaymentRepository>();
    final payments = paymentRepo.payments;

    return ProfessionalPage(
      title: 'Payment Ledger',
      subtitle: 'Financial Flow & Transaction History',
      category: 'FINANCIAL MANAGEMENT',
      actions: [
        IconButton(
          icon: const Icon(Icons.add_chart_rounded, color: Colors.white),
          onPressed: () => _showAddPaymentDialog(context, null),
        ),
      ],
      headerStats: [
        _HeaderStat(label: 'TOTAL SUCCESS', value: '₹${paymentRepo.getTotalSuccess().toStringAsFixed(0)}', color: bcSuccess),
        _HeaderStat(label: 'TOTAL PENDING', value: '₹${paymentRepo.getTotalPending().toStringAsFixed(0)}', color: bcAmber),
      ],
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: payments.isEmpty
              ? const SliverFillRemaining(
                  child: Center(child: Text('No payment records found', style: TextStyle(color: Colors.grey))),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final payment = payments[index];
                      return _PaymentListItem(
                        payment: payment,
                        onEdit: () => _showAddPaymentDialog(context, payment),
                        onDelete: () => _deletePayment(context, payment),
                      );
                    },
                    childCount: payments.length,
                  ),
                ),
        ),
      ],
    );
  }

  Future<void> _deletePayment(BuildContext context, PaymentModel payment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Payment', style: TextStyle(fontWeight: FontWeight.w900)),
        content: Text('Delete payment of ₹${payment.amount.toStringAsFixed(0)} to ${payment.partyName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DELETE', style: TextStyle(color: bcDanger, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<PaymentRepository>().deletePayment(payment.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment deleted.'), backgroundColor: bcDanger),
      );
    }
  }

  void _showAddPaymentDialog(BuildContext context, PaymentModel? existing) {
    final amountCtrl = TextEditingController(text: existing?.amount.toStringAsFixed(0) ?? '');
    final remarksCtrl = TextEditingController(text: existing?.remarks ?? '');
    final partyCtrl = TextEditingController(text: existing?.partyName ?? '');
    PaymentStatus status = existing?.status ?? PaymentStatus.success;
    PaymentType type = existing?.type ?? PaymentType.given;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(existing == null ? 'Record Payment' : 'Edit Payment', style: TextStyle(fontWeight: FontWeight.w900, color: bcNavy)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Consumer<PartyRepository>(
                  builder: (context, partyRepo, child) {
                    return HelpfulDropdown<PartyModel?>(
                      label: 'Party (Supplier/Customer) *',
                      value: null,
                      items: [null, ...partyRepo.parties],
                      labelMapper: (p) => p?.name ?? 'Other / Custom',
                      onChanged: (p) {
                        if (p != null) {
                          setDialogState(() => partyCtrl.text = p.name);
                        }
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Amount', prefixIcon: Icon(Icons.currency_rupee_rounded)),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<PaymentType>(
                  initialValue: type,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: PaymentType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.name.toUpperCase()))).toList(),
                  onChanged: (v) => setDialogState(() => type = v!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<PaymentStatus>(
                  initialValue: status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: PaymentStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.name.toUpperCase()))).toList(),
                  onChanged: (v) => setDialogState(() => status = v!),
                ),
                TextField(
                  controller: remarksCtrl,
                  decoration: const InputDecoration(labelText: 'Remarks (Optional)', prefixIcon: Icon(Icons.notes_rounded)),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bill Upload Placeholder - Camera/Gallery')));
                  },
                  icon: const Icon(Icons.cloud_upload_rounded),
                  label: const Text('UPLOAD BILL (OPTIONAL)'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: bcAmber,
                    side: BorderSide(color: bcAmber),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: bcAmber,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                if (amountCtrl.text.isNotEmpty && partyCtrl.text.isNotEmpty) {
                  final payment = PaymentModel(
                    id: existing?.id ?? 'P-${DateTime.now().millisecondsSinceEpoch}',
                    partyId: existing?.partyId ?? 'U-001',
                    partyName: partyCtrl.text,
                    siteId: existing?.siteId ?? 'S-001',
                    siteName: existing?.siteName ?? 'Main Site',
                    amount: double.tryParse(amountCtrl.text) ?? 0,
                    status: status,
                    type: type,
                    remarks: remarksCtrl.text,
                    timestamp: existing?.timestamp ?? DateTime.now(),
                  );
                  if (existing == null) {
                    context.read<WorkflowService>().recordPayment(payment);
                  } else {
                    context.read<PaymentRepository>().updatePayment(payment);
                  }
                  Navigator.pop(context);
                }
              },
              child: Text(existing == null ? 'SAVE' : 'UPDATE', style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      ),
    );
  }
}


class _HeaderStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _HeaderStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white60, letterSpacing: 1)),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
      ],
    );
  }
}

class _PaymentListItem extends StatelessWidget {
  final PaymentModel payment;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _PaymentListItem({required this.payment, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isReceived = payment.type == PaymentType.received;
    
    return AdaptiveCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (isReceived ? bcSuccess : bcAmber).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isReceived ? Icons.call_received_rounded : Icons.call_made_rounded,
                  color: isReceived ? bcSuccess : bcAmber,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(payment.partyName, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: bcNavy)),
                    Text(payment.siteName, style: TextStyle(fontSize: 12, color: DesignSystem.textSecondary, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('₹${payment.amount.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: bcNavy)),
                  const SizedBox(height: 4),
                  StatusBadge(
                    label: payment.status.name.toUpperCase(),
                    type: payment.status == PaymentStatus.success ? StatusBadgeType.success : StatusBadgeType.warning,
                  ),
                ],
              ),
            ],
          ),
          if (payment.remarks != null && payment.remarks!.isNotEmpty) ...[
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.notes_rounded, size: 14, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(child: Text(payment.remarks!, style: const TextStyle(fontSize: 11, color: Colors.grey))),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(DateFormat('dd MMM yyyy, hh:mm a').format(payment.timestamp), style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600)),
              Row(
                children: [
                  if (payment.billImageUrl != null)
                    const Icon(Icons.receipt_long_rounded, size: 18, color: bcAmber),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onEdit,
                    child: const Icon(Icons.edit_rounded, size: 18, color: Colors.blueAccent),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: onDelete,
                    child: const Icon(Icons.delete_rounded, size: 18, color: bcDanger),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

