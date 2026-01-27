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

class EngineerPaymentsTab extends StatefulWidget {
  const EngineerPaymentsTab({super.key});

  @override
  State<EngineerPaymentsTab> createState() => _EngineerPaymentsTabState();
}

class _EngineerPaymentsTabState extends State<EngineerPaymentsTab> {
  final NumberFormat _currency = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
  String _searchQuery = '';
  PaymentStatus? _statusFilter;

  final List<Map<String, dynamic>> _engineers = [
    {
      'id': 'ENG-001',
      'name': 'Rajesh Kumar',
      'role': 'Site Engineer',
      'photo': 'assets/engineer1.jpg',
      'site': 'Metropolis Heights - Tower A',
      'contact': '+91 98765 43210',
      'workPeriod': 'Jan 1 - Jan 15, 2026',
      'amount': 45000,
      'paymentDate': '2026-01-16',
      'status': PaymentStatus.paid,
      'method': PaymentMethod.bankTransfer,
      'transactionRef': 'TXN20260116001',
      'hasProof': true,
    },
    {
      'id': 'ENG-002',
      'name': 'Priya Sharma',
      'role': 'Structural Engineer',
      'photo': 'assets/engineer2.jpg',
      'site': 'Skyline Tower - Phase 2',
      'contact': '+91 98765 43211',
      'workPeriod': 'Jan 1 - Jan 15, 2026',
      'amount': 52000,
      'paymentDate': '2026-01-18',
      'status': PaymentStatus.pending,
      'method': PaymentMethod.upi,
      'transactionRef': null,
      'hasProof': false,
    },
    {
      'id': 'ENG-003',
      'name': 'Amit Patel',
      'role': 'Civil Engineer',
      'photo': 'assets/engineer3.jpg',
      'site': 'Central Plaza - Building B',
      'contact': '+91 98765 43212',
      'workPeriod': 'Jan 1 - Jan 15, 2026',
      'amount': 48000,
      'paymentDate': '2026-01-17',
      'status': PaymentStatus.partial,
      'method': PaymentMethod.bankTransfer,
      'transactionRef': 'TXN20260117002',
      'hasProof': true,
    },
    {
      'id': 'ENG-004',
      'name': 'Neha Gupta',
      'role': 'Quality Engineer',
      'photo': 'assets/engineer4.jpg',
      'site': 'Metropolis Heights - Tower B',
      'contact': '+91 98765 43213',
      'workPeriod': 'Jan 1 - Jan 15, 2026',
      'amount': 38000,
      'paymentDate': '2026-01-15',
      'status': PaymentStatus.paid,
      'method': PaymentMethod.cheque,
      'transactionRef': 'CHQ-891234',
      'hasProof': true,
    },
  ];

  List<Map<String, dynamic>> get _filteredEngineers {
    return _engineers.where((eng) {
      final matchesSearch = eng['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          eng['id'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = _statusFilter == null || eng['status'] == _statusFilter;
      return matchesSearch && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          // Header Stats
          SliverToBoxAdapter(child: _buildHeaderStats()),
          
          // Search
          SliverToBoxAdapter(child: _buildSearch()),
          
          // Filter Chips
          SliverToBoxAdapter(child: _buildFilterChips()),

          // Engineer List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final engineer = _filteredEngineers[index];
                  return StaggeredAnimation(
                    index: index,
                    child: _buildEngineerCard(engineer),
                  );
                },
                childCount: _filteredEngineers.length,
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
  }

  void _showCreatePayment() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.9,
        child: PaymentFormSheet(
          category: 'engineer',
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

  Widget _buildHeaderStats() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Engineer Payments',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '₹1,83,000',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'January 2026 Disbursements',
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
                child: _buildMiniStat('Paid', '2', Colors.greenAccent),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMiniStat('Pending', '1', Colors.orangeAccent),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMiniStat('Partial', '1', Colors.yellowAccent),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              fontSize: 11,
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
          hintText: 'Search engineers...',
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
    final filters = [
      {'label': 'All', 'status': null},
      {'label': 'Paid', 'status': PaymentStatus.paid},
      {'label': 'Pending', 'status': PaymentStatus.pending},
      {'label': 'Partial', 'status': PaymentStatus.partial},
    ];

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
            final isSelected = _statusFilter == filter['status'];
            return GestureDetector(
              onTap: () => setState(() => _statusFilter = filter['status'] as PaymentStatus?),
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
                  filter['label'] as String,
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

  Widget _buildEngineerCard(Map<String, dynamic> engineer) {
    return ProfessionalCard(
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: InkWell(
        onTap: () => _viewPaymentDetail(engineer),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF1A237E).withOpacity(0.1), width: 2),
                      color: const Color(0xFF1A237E).withOpacity(0.05),
                    ),
                    child: Center(
                      child: Text(
                        engineer['name'].toString().substring(0, 1),
                        style: const TextStyle(
                          color: Color(0xFF1A237E),
                          fontSize: 24,
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
                                engineer['name'],
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            PaymentStatusBadge(status: engineer['status']),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.purpleAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            engineer['role'],
                            style: const TextStyle(
                              color: Colors.purpleAccent,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(color: Theme.of(context).dividerColor.withOpacity(0.05), height: 1),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.location_on_outlined, engineer['site']),
              _buildInfoRow(Icons.phone_outlined, engineer['contact']),
              _buildInfoRow(Icons.calendar_today_outlined, engineer['workPeriod']),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment Amount',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        _currency.format(engineer['amount']),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  if (engineer['hasProof'])
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified_rounded,
                        color: Colors.greenAccent,
                        size: 20,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Theme.of(context).colorScheme.primary.withOpacity(0.4)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditPayment(Map<String, dynamic> engineer) {
    final existingPayment = Payment(
      id: engineer['id'],
      category: 'engineer',
      recipientName: engineer['name'],
      recipientId: engineer['id'], // Assuming id is same for now
      amount: engineer['amount'].toDouble(),
      totalPayable: engineer['amount'].toDouble(),
      date: DateTime.parse(engineer['paymentDate']),
      status: engineer['status'].toString().split('.').last.toLowerCase(),
      paymentMethod: engineer['method'].toString().split('.').last.toLowerCase(),
      siteName: engineer['assignedSite'] ?? 'No Site',
      role: engineer['role'] ?? 'Engineer',
      periodStart: DateTime.parse(engineer['paymentDate']).subtract(const Duration(days: 30)),
      periodEnd: DateTime.parse(engineer['paymentDate']),
      description: 'Monthly salary: ${engineer['workPeriod']}',
      transactionRef: engineer['transactionRef'],
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.9,
        child: PaymentFormSheet(
          category: 'engineer',
          existingPayment: existingPayment,
          onSubmit: (payment) {
            context.read<PaymentService>().updatePayment(payment.id, payment);
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

  void _confirmDelete(Map<String, dynamic> engineer) {
    showDialog(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        title: 'Delete Payment?',
        message: 'Are you sure you want to delete payment for ${engineer['name']}? This action cannot be undone.',
        onConfirm: () {
          context.read<PaymentService>().deletePayment(engineer['id']);
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

  void _viewPaymentDetail(Map<String, dynamic> engineerMap) {
    final payment = Payment(
      id: engineerMap['id'],
      category: 'engineer',
      recipientName: engineerMap['name'],
      recipientId: engineerMap['id'],
      amount: engineerMap['amount'].toDouble(),
      totalPayable: engineerMap['amount'].toDouble(),
      date: DateTime.parse(engineerMap['paymentDate']),
      status: engineerMap['status'].toString().split('.').last.toLowerCase(),
      paymentMethod: engineerMap['method'].toString().split('.').last.toLowerCase(),
      siteName: engineerMap['site'] ?? 'Unassigned',
      role: engineerMap['role'] ?? 'Engineer',
      periodStart: DateTime.parse(engineerMap['paymentDate']).subtract(const Duration(days: 30)),
      periodEnd: DateTime.parse(engineerMap['paymentDate']),
      transactionRef: engineerMap['transactionRef'],
      createdAt: DateTime.now(),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PaymentDetailSheet(
        payment: payment,
        onEdit: () {
          Navigator.pop(context);
          _showEditPayment(engineerMap);
        },
        onDelete: () {
          Navigator.pop(context);
          _confirmDelete(engineerMap);
        },
      ),
    );
  }
}
