import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:construction_app/shared/theme/professional_theme.dart';
import 'package:construction_app/shared/widgets/staggered_animation.dart';
import 'package:construction_app/modules/payments/widgets/payment_status_badge.dart';
import 'package:construction_app/modules/payments/widgets/payment_detail_sheet.dart';
import 'package:construction_app/modules/payments/widgets/payment_form_sheet.dart';
import 'package:construction_app/modules/payments/widgets/delete_confirmation_dialog.dart';
import 'package:construction_app/services/payment_service.dart';

class AllPaymentsTab extends StatefulWidget {
  const AllPaymentsTab({super.key});

  @override
  State<AllPaymentsTab> createState() => _AllPaymentsTabState();
}

class _AllPaymentsTabState extends State<AllPaymentsTab> {
  final NumberFormat _currency = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
  String _searchQuery = '';
  String _categoryFilter = 'All';
  PaymentStatus? _statusFilter;

  final List<Map<String, dynamic>> _allPayments = [
    // Engineers
    {
      'id': 'ENG-001',
      'name': 'Rajesh Kumar',
      'category': 'Engineer',
      'role': 'Site Engineer',
      'amount': 45000,
      'status': PaymentStatus.paid,
      'date': '2026-01-16',
      'site': 'Metropolis Heights',
    },
    {
      'id': 'ENG-002',
      'name': 'Priya Sharma',
      'category': 'Engineer',
      'role': 'Structural Engineer',
      'amount': 52000,
      'status': PaymentStatus.pending,
      'date': '2026-01-18',
      'site': 'Skyline Tower',
    },
    
    // Workers
    {
      'id': 'WRK-101',
      'name': 'Ramesh Singh',
      'category': 'Worker',
      'role': 'Mason',
      'amount': 12000,
      'status': PaymentStatus.pending,
      'date': '2026-01-20',
      'site': 'Metropolis Heights',
    },
    {
      'id': 'WRK-102',
      'name': 'Suresh Kumar',
      'category': 'Worker',
      'role': 'Carpenter',
      'amount': 13500,
      'status': PaymentStatus.paid,
      'date': '2026-01-19',
      'site': 'Skyline Tower',
    },
    
    // Inventory
    {
      'id': 'MAT-501',
      'name': 'Portland Cement',
      'category': 'Inventory',
      'role': '500 bags',
      'amount': 210000,
      'status': PaymentStatus.pending,
      'date': '2026-01-25',
      'site': 'UltraTech Suppliers',
    },
    {
      'id': 'MAT-502',
      'name': 'TMT Steel Bars',
      'category': 'Inventory',
      'role': '10 tons',
      'amount': 650000,
      'status': PaymentStatus.overdue,
      'date': '2026-01-20',
      'site': 'Tata Steel Distributors',
    },
  ];

  List<Map<String, dynamic>> get _filteredPayments {
    return _allPayments.where((payment) {
      final matchesSearch = payment['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          payment['id'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _categoryFilter == 'All' || payment['category'] == _categoryFilter;
      final matchesStatus = _statusFilter == null || payment['status'] == _statusFilter;
      return matchesSearch && matchesCategory && matchesStatus;
    }).toList()
      ..sort((a, b) => DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeaderStats()),
        SliverToBoxAdapter(child: _buildSearch()),
        SliverToBoxAdapter(child: _buildFilterChips()),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final payment = _filteredPayments[index];
                return StaggeredAnimation(
                  index: index,
                  child: _buildPaymentCard(payment),
                );
              },
              childCount: _filteredPayments.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildHeaderStats() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'All Payments',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '₹9,83,500',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'All Categories • Recent First',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildCategoryStat('Engineers', '2', Icons.engineering_rounded, Colors.blueAccent),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCategoryStat('Workers', '2', Icons.construction_rounded, Colors.orangeAccent),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCategoryStat('Inventory', '2', Icons.inventory_2_rounded, Colors.tealAccent),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryStat(String label, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            count,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
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
          hintText: 'Search all payments...',
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
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Engineer', 'Worker', 'Inventory'];
    
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
            final isSelected = _categoryFilter == filter;
            return GestureDetector(
              onTap: () => setState(() => _categoryFilter = filter),
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
                    color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
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

  Widget _buildPaymentCard(Map<String, dynamic> payment) {
    Color categoryColor;
    IconData categoryIcon;
    
    switch (payment['category']) {
      case 'Engineer':
        categoryColor = Colors.blueAccent;
        categoryIcon = Icons.engineering_rounded;
        break;
      case 'Worker':
        categoryColor = Colors.orangeAccent;
        categoryIcon = Icons.construction_rounded;
        break;
      case 'Inventory':
        categoryColor = Colors.tealAccent;
        categoryIcon = Icons.inventory_2_rounded;
        break;
      default:
        categoryColor = Colors.white;
        categoryIcon = Icons.payment_rounded;
    }
    
    return ProfessionalCard(
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: InkWell(
        onTap: () => _viewPaymentDetail(payment),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: categoryColor, width: 2),
                ),
                child: Icon(categoryIcon, color: categoryColor, size: 24),
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
                            payment['name'],
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
                            color: categoryColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            payment['category'],
                            style: TextStyle(
                              color: categoryColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${payment['role']} • ${payment['site']}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      payment['id'],
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _currency.format(payment['amount']),
                    style: TextStyle(
                      color: categoryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  PaymentStatusBadge(status: payment['status'], fontSize: 10),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _viewPaymentDetail(Map<String, dynamic> paymentMap) {
    // Convert map to Payment object for the detail sheet
    final payment = Payment(
      id: paymentMap['id'],
      category: paymentMap['category'].toString().toLowerCase(),
      recipientName: paymentMap['name'],
      recipientId: paymentMap['id'],
      amount: paymentMap['amount'].toDouble(),
      totalPayable: paymentMap['amount'].toDouble(),
      date: DateTime.parse(paymentMap['date']),
      status: paymentMap['status'].toString().split('.').last.toLowerCase(),
      paymentMethod: 'bank', // Mock
      siteName: paymentMap['site'] ?? 'Global',
      role: paymentMap['role'] ?? 'Construction Professional',
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
          _showEditPayment(paymentMap);
        },
        onDelete: () {
          Navigator.pop(context);
          _confirmDelete(paymentMap);
        },
      ),
    );
  }

  void _showEditPayment(Map<String, dynamic> paymentMap) {
    final existingPayment = Payment(
      id: paymentMap['id'],
      category: paymentMap['category'].toString().toLowerCase(),
      recipientName: paymentMap['name'],
      recipientId: paymentMap['id'],
      amount: paymentMap['amount'].toDouble(),
      totalPayable: paymentMap['amount'].toDouble(),
      date: DateTime.parse(paymentMap['date']),
      status: paymentMap['status'].toString().split('.').last.toLowerCase(),
      paymentMethod: 'bank', // Mock
      siteName: paymentMap['site'],
      role: paymentMap['role'],
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.9,
        child: PaymentFormSheet(
          category: paymentMap['category'].toString().toLowerCase(),
          existingPayment: existingPayment,
          onSubmit: (payment) {
            context.read<PaymentService>().updatePayment(payment.id, payment);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.blueAccent),
                    const SizedBox(width: 12),
                    Text('Payment for ${payment.recipientName} updated'),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _confirmDelete(Map<String, dynamic> paymentMap) {
    showDialog(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        title: 'Delete Payment?',
        message: 'Are you sure you want to delete this ${paymentMap['category']} payment for ${paymentMap['name']}?',
        onConfirm: () {
          context.read<PaymentService>().deletePayment(paymentMap['id']);
          Navigator.pop(context);
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
}
