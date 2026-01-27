import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:construction_app/shared/theme/professional_theme.dart';
import 'package:construction_app/services/payment_service.dart';
import 'payment_status_badge.dart';

class PaymentDetailSheet extends StatelessWidget {
  final Payment payment;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PaymentDetailSheet({
    super.key,
    required this.payment,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payment.recipientName,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      payment.role ?? payment.category.toUpperCase(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  _buildIconButton(
                    context,
                    Icons.edit_rounded,
                    Theme.of(context).colorScheme.primary,
                    onEdit,
                  ),
                  const SizedBox(width: 12),
                  _buildIconButton(
                    context,
                    Icons.delete_rounded,
                    Colors.redAccent,
                    onDelete,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          PaymentStatusBadge(status: _parseStatus(payment.status), fontSize: 13),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.05)),
            ),
            child: Column(
              children: [
                _buildInfoRow(context, 'Recipient ID', payment.recipientId),
                _buildDivider(context),
                _buildInfoRow(context, 'Site Assignment', payment.siteName ?? 'Global'),
                _buildDivider(context),
                _buildInfoRow(context, 'Work Period', _formatPeriod()),
                _buildDivider(context),
                _buildInfoRow(context, 'Payment Date', DateFormat('yyyy-MM-dd').format(payment.date)),
                if (payment.transactionRef != null) ...[
                  _buildDivider(context),
                  _buildInfoRow(context, 'Transaction Ref', payment.transactionRef!),
                ],
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Total Amount',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                currency.format(payment.amount),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          if (payment.status == 'pending')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download_rounded),
                label: const Text('Download Receipt'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
            ),
          if (payment.proofUrl == null && payment.status == 'pending') ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.cloud_upload_rounded),
                label: const Text('Upload Proof'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orangeAccent,
                  side: const BorderSide(color: Colors.orangeAccent),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatPeriod() {
    if (payment.periodStart != null && payment.periodEnd != null) {
      final f = DateFormat('MMM d');
      return '${f.format(payment.periodStart!)} - ${f.format(payment.periodEnd!)}, ${payment.periodStart!.year}';
    }
    return 'Not Specified';
  }

  PaymentStatus _parseStatus(String status) {
    switch (status) {
      case 'paid': return PaymentStatus.paid;
      case 'partial': return PaymentStatus.partial;
      case 'overdue': return PaymentStatus.overdue;
      default: return PaymentStatus.pending;
    }
  }

  Widget _buildIconButton(BuildContext context, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Divider(color: Theme.of(context).dividerColor.withOpacity(0.05), height: 1),
    );
  }
}
