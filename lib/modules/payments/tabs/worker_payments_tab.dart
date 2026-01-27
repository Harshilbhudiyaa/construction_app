import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:construction_app/shared/theme/professional_theme.dart';
import 'package:construction_app/shared/widgets/staggered_animation.dart';
import 'package:construction_app/modules/payments/widgets/payment_status_badge.dart';
import 'package:construction_app/modules/payments/widgets/payment_method_selector.dart';
import 'package:construction_app/modules/payments/widgets/payment_proof_upload_widget.dart';
import 'package:construction_app/modules/payments/widgets/payment_form_sheet.dart';
import 'package:construction_app/modules/payments/widgets/payment_detail_sheet.dart';
import 'package:construction_app/modules/payments/widgets/delete_confirmation_dialog.dart';
import 'package:construction_app/services/payment_service.dart';

class WorkerPaymentsTab extends StatefulWidget {
  const WorkerPaymentsTab({super.key});

  @override
  State<WorkerPaymentsTab> createState() => _WorkerPaymentsTabState();
}

class _WorkerPaymentsTabState extends State<WorkerPaymentsTab> {
  final NumberFormat _currency = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
  String _searchQuery = '';
  String _workerTypeFilter = 'All';
  String? _statusFilter; // Using String to match Payment model status

  @override
  Widget build(BuildContext context) {
    return Consumer<PaymentService>(
      builder: (context, paymentService, child) {
        final allWorkerPayments = paymentService.getPaymentsByCategory('worker');
        
        final filteredPayments = allWorkerPayments.where((payment) {
          final matchesSearch = payment.recipientName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              payment.id.toLowerCase().contains(_searchQuery.toLowerCase());
          final matchesType = _workerTypeFilter == 'All' || payment.role == _workerTypeFilter;
          final matchesStatus = _statusFilter == null || payment.status == _statusFilter;
          return matchesSearch && matchesType && matchesStatus;
        }).toList();

        final totalWages = allWorkerPayments.fold(0.0, (sum, p) => sum + p.totalPayable);
        final paidCount = allWorkerPayments.where((p) => p.status == 'paid').length;
        final pendingCount = allWorkerPayments.where((p) => p.status == 'pending').length;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _buildHeaderStats(
                  totalWages: totalWages,
                  workerCount: allWorkerPayments.length,
                  paidCount: paidCount,
                  pendingCount: pendingCount,
                ),
              ),
              SliverToBoxAdapter(child: _buildSearch()),
              SliverToBoxAdapter(child: _buildFilterChips()),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final payment = filteredPayments[index];
                      return StaggeredAnimation(
                        index: index,
                        child: _buildWorkerCard(payment),
                      );
                    },
                    childCount: filteredPayments.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showCreatePayment(),
            backgroundColor: Theme.of(context).colorScheme.primary,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: const Text(
              'New Payment',
              style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  void _showCreatePayment() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.9,
        child: PaymentFormSheet(
          category: 'worker',
          onSubmit: (payment) {
            context.read<PaymentService>().createPayment(payment);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.greenAccent),
                    SizedBox(width: 12),
                    Text('Payment created successfully'),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderStats({
    required double totalWages,
    required int workerCount,
    required int paidCount,
    required int pendingCount,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Worker Wages',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _currency.format(totalWages),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'This Month • $workerCount Workers',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickStat('Workers', '$workerCount', Icons.people_rounded, Colors.blueAccent),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildQuickStat('Paid', '$paidCount', Icons.check_circle_rounded, Colors.greenAccent),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildQuickStat('Pending', '$pendingCount', Icons.schedule_rounded, Colors.orangeAccent),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v),
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: 'Search workers...',
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
          prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
          filled: true,
          fillColor: Theme.of(context).cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Mason', 'Carpenter', 'Laborer', 'Electrician', 'Plumber'];
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: filters.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final filter = filters[index];
            final isSelected = _workerTypeFilter == filter;
            return GestureDetector(
              onTap: () => setState(() => _workerTypeFilter = filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor.withOpacity(0.1),
                  ),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWorkerCard(Payment payment) {
    final isPending = payment.status == 'pending';
    
    return ProfessionalCard(
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF1A237E).withOpacity(0.1)),
                    color: const Color(0xFF1A237E).withOpacity(0.05),
                  ),
                  child: Center(
                    child: Text(
                      payment.recipientName.substring(0, 1),
                      style: const TextStyle(
                        color: Color(0xFF1A237E),
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              payment.recipientName,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.cyanAccent.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              payment.role ?? 'Worker',
                              style: const TextStyle(
                                color: Colors.cyanAccent,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
                          const SizedBox(width: 4),
                          Text(
                            payment.siteName ?? 'Unassigned',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.03),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDetailItem('Work Days', '${payment.quantity?.toInt() ?? 0} days', Icons.calendar_today_outlined),
                  Container(width: 1, height: 30, color: Theme.of(context).dividerColor.withOpacity(0.1)),
                  _buildDetailItem('Wage Type', 'Daily', Icons.monetization_on_outlined),
                  Container(width: 1, height: 30, color: Theme.of(context).dividerColor.withOpacity(0.1)),
                  _buildDetailItem('Daily Rate', '₹${payment.unitPrice?.toInt() ?? 0}', Icons.currency_rupee),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Payable',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _currency.format(payment.totalPayable),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                PaymentStatusBadge(status: _mapStatus(payment.status)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (isPending) ...[
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () => _showEditPayment(payment),
                      icon: const Icon(Icons.payment_rounded, size: 18),
                      label: const Text('Pay Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _viewPaymentDetail(payment),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.onSurface,
                      side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Details', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  PaymentStatus _mapStatus(String status) {
    switch (status) {
      case 'paid': return PaymentStatus.paid;
      case 'partial': return PaymentStatus.partial;
      case 'pending': return PaymentStatus.pending;
      case 'overdue': return PaymentStatus.overdue;
      case 'failed': return PaymentStatus.failed;
      default: return PaymentStatus.pending;
    }
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              fontSize: 9,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showEditPayment(Payment payment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.9,
        child: PaymentFormSheet(
          category: 'worker',
          existingPayment: payment,
          onSubmit: (updated) {
            context.read<PaymentService>().updatePayment(updated.id, updated);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.blueAccent),
                    SizedBox(width: 12),
                    Text('Payment updated successfully'),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _confirmDelete(Payment payment) {
    showDialog(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        title: 'Delete Payment?',
        message: 'Are you sure you want to delete payment for ${payment.recipientName}? This action cannot be undone.',
        onConfirm: () {
          context.read<PaymentService>().deletePayment(payment.id);
          Navigator.pop(context); // Close detail sheet
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.delete_rounded, color: Colors.redAccent),
                  SizedBox(width: 12),
                  Text('Payment deleted successfully'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _viewPaymentDetail(Payment payment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PaymentDetailSheet(
        payment: payment,
        onEdit: () {
          Navigator.pop(context);
          _showEditPayment(payment);
        },
        onDelete: () {
          Navigator.pop(context);
          _confirmDelete(payment);
        },
      ),
    );
  }
}
