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

class InventoryPaymentsTab extends StatefulWidget {
  const InventoryPaymentsTab({super.key});

  @override
  State<InventoryPaymentsTab> createState() => _InventoryPaymentsTabState();
}

class _InventoryPaymentsTabState extends State<InventoryPaymentsTab> {
  final NumberFormat _currency = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
  String _searchQuery = '';
  String _materialTypeFilter = 'All';
  PaymentStatus? _statusFilter;

  final List<Map<String, dynamic>> _materials = [
    {
      'id': 'MAT-501',
      'name': 'Portland Cement',
      'category': 'Cement',
      'image': 'assets/cement.jpg',
      'quantity': 500,
      'unit': 'bags',
      'unitPrice': 420,
      'totalAmount': 210000,
      'supplier': 'UltraTech Suppliers',
      'supplierContact': '+91 98765 00001',
      'invoiceNumber': 'INV-2026-0145',
      'invoiceDate': '2026-01-10',
      'dueDate': '2026-01-25',
      'paymentStatus': PaymentStatus.pending,
      'method': PaymentMethod.bankTransfer,
      'hasInvoice': true,
    },
    {
      'id': 'MAT-502',
      'name': 'TMT Steel Bars',
      'category': 'Steel',
      'image': 'assets/steel.jpg',
      'quantity': 10,
      'unit': 'tons',
      'unitPrice': 65000,
      'totalAmount': 650000,
      'supplier': 'Tata Steel Distributors',
      'supplierContact': '+91 98765 00002',
      'invoiceNumber': 'INV-2026-0156',
      'invoiceDate': '2026-01-12',
      'dueDate': '2026-01-20',
      'paymentStatus': PaymentStatus.overdue,
      'method': PaymentMethod.bankTransfer,
      'hasInvoice': true,
    },
    {
      'id': 'MAT-503',
      'name': 'River Sand',
      'category': 'Sand',
      'image': 'assets/sand.jpg',
      'quantity': 100,
      'unit': 'tons',
      'unitPrice': 1200,
      'totalAmount': 120000,
      'supplier': 'Prime Sand Suppliers',
      'supplierContact': '+91 98765 00003',
      'invoiceNumber': 'INV-2026-0167',
      'invoiceDate': '2026-01-15',
      'dueDate': '2026-01-30',
      'paymentStatus': PaymentStatus.paid,
      'method': PaymentMethod.cheque,
      'transactionRef': 'CHQ-445566',
      'hasInvoice': true,
    },
    {
      'id': 'MAT-504',
      'name': 'Concrete Blocks',
      'category': 'Blocks',
      'image': 'assets/blocks.jpg',
      'quantity': 5000,
      'unit': 'pieces',
      'unitPrice': 35,
      'totalAmount': 175000,
      'supplier': 'AAC Blocks India',
      'supplierContact': '+91 98765 00004',
      'invoiceNumber': 'INV-2026-0178',
      'invoiceDate': '2026-01-14',
      'dueDate': '2026-01-28',
      'paymentStatus': PaymentStatus.partial,
      'method': PaymentMethod.bankTransfer,
      'transactionRef': 'TXN202601140234',
      'hasInvoice': true,
    },
  ];

  List<Map<String, dynamic>> get _filteredMaterials {
    return _materials.where((material) {
      final matchesSearch = material['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          material['supplier'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesType = _materialTypeFilter == 'All' || material['category'] == _materialTypeFilter;
      final matchesStatus = _statusFilter == null || material['paymentStatus'] == _statusFilter;
      return matchesSearch && matchesType && matchesStatus;
    }).toList();
  }

  int _daysUntilDue(String dueDate) {
    final due = DateTime.parse(dueDate);
    final now = DateTime.now();
    return due.difference(now).inDays;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeaderStats()),
          SliverToBoxAdapter(child: _buildSearch()),
          SliverToBoxAdapter(child: _buildFilterChips()),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final material = _filteredMaterials[index];
                  return StaggeredAnimation(
                    index: index,
                    child: _buildMaterialCard(material),
                  );
                },
                childCount: _filteredMaterials.length,
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
          category: 'inventory',
          onSubmit: (payment) {
            context.read<PaymentService>().createPayment(payment);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.tealAccent),
                    SizedBox(width: 12),
                    Text('Inventory payment created successfully'),
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
            'Inventory Payments',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '₹11,55,000',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'January Procurement • 4 Suppliers',
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
                child: _buildStatCard('Overdue', '1', Icons.warning_rounded, Colors.redAccent),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard('Pending', '1', Icons.schedule_rounded, Colors.orangeAccent),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard('Paid', '1', Icons.check_circle_rounded, Colors.greenAccent),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
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
          hintText: 'Search materials or suppliers...',
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
    final filters = ['All', 'Cement', 'Steel', 'Sand', 'Blocks'];
    
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
            final isSelected = _materialTypeFilter == filter;
            return GestureDetector(
              onTap: () => setState(() => _materialTypeFilter = filter),
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

  Widget _buildMaterialCard(Map<String, dynamic> material) {
    final daysUntilDue = _daysUntilDue(material['dueDate']);
    final isOverdue = daysUntilDue < 0;
    
    return ProfessionalCard(
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: InkWell(
        onTap: () => _viewPaymentDetail(material),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                      border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.1)),
                    ),
                    child: Center(
                      child: Icon(
                        _getMaterialIcon(material['category']),
                        size: 32,
                        color: Theme.of(context).colorScheme.primary,
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
                                material['name'],
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
                                color: Colors.tealAccent.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                material['category'],
                                style: const TextStyle(
                                  color: Colors.tealAccent,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${material['quantity']} ${material['unit']} @ ₹${material['unitPrice']}/${material['unit']}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.business_rounded, size: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                material['supplier'],
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                  fontSize: 11,
                                ),
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
              Divider(color: Theme.of(context).dividerColor.withOpacity(0.05), height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      'Invoice',
                      material['invoiceNumber'],
                      Icons.receipt_long_outlined,
                    ),
                  ),
                  Container(width: 1, height: 30, color: Theme.of(context).dividerColor.withOpacity(0.1)),
                  Expanded(
                    child: _buildInfoItem(
                      'Invoice Date',
                      DateFormat('MMM dd').format(DateTime.parse(material['invoiceDate'])),
                      Icons.calendar_today_outlined,
                    ),
                  ),
                  Container(width: 1, height: 30, color: Theme.of(context).dividerColor.withOpacity(0.1)),
                  Expanded(
                    child: _buildInfoItem(
                      'Due In',
                      isOverdue ? 'Overdue' : '$daysUntilDue days',
                      Icons.alarm_rounded,
                      color: isOverdue ? Colors.redAccent : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Amount',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        _currency.format(material['totalAmount']),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  PaymentStatusBadge(status: material['paymentStatus']),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getMaterialIcon(String category) {
    switch (category) {
      case 'Cement':
        return Icons.construction_rounded;
      case 'Steel':
        return Icons.hardware_rounded;
      case 'Sand':
        return Icons.grain_rounded;
      case 'Blocks':
        return Icons.view_module_rounded;
      default:
        return Icons.inventory_2_rounded;
    }
  }

  Widget _buildInfoItem(String label, String value, IconData icon, {Color? color}) {
    return Column(
      children: [
        Icon(icon, size: 14, color: color?.withOpacity(0.5) ?? Theme.of(context).colorScheme.primary.withOpacity(0.4)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color ?? Theme.of(context).colorScheme.primary,
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            fontSize: 9,
            fontWeight: FontWeight.w800,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _showEditPayment(Map<String, dynamic> material) {
    final existingPayment = Payment(
      id: material['id'],
      category: 'inventory',
      recipientName: material['supplier'],
      recipientId: material['id'], // Assuming supplier ID
      amount: material['totalAmount'].toDouble(),
      totalPayable: material['totalAmount'].toDouble(),
      date: DateTime.parse(material['invoiceDate']),
      status: material['paymentStatus'].toString().split('.').last.toLowerCase(),
      paymentMethod: material['method'].toString().split('.').last.toLowerCase(),
      quantity: material['quantity']?.toDouble(),
      unitPrice: (material['totalAmount'] / (material['quantity'] ?? 1)).toDouble(),
      unit: material['unit'] ?? 'kg',
      description: '${material['name']} Procurement',
      transactionRef: material['transactionRef'],
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.9,
        child: PaymentFormSheet(
          category: 'inventory',
          existingPayment: existingPayment,
          onSubmit: (payment) {
            context.read<PaymentService>().updatePayment(payment.id, payment);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.tealAccent),
                    SizedBox(width: 12),
                    Text('Inventory payment updated successfully'),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _confirmDelete(Map<String, dynamic> material) {
    showDialog(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        title: 'Delete Payment?',
        message: 'Are you sure you want to delete payment for ${material['name']} from ${material['supplier']}? This action cannot be undone.',
        onConfirm: () {
          context.read<PaymentService>().deletePayment(material['id']);
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

  void _viewPaymentDetail(Map<String, dynamic> materialMap) {
    final payment = Payment(
      id: materialMap['id'],
      category: 'inventory',
      recipientName: materialMap['supplier'],
      recipientId: materialMap['id'],
      amount: materialMap['totalAmount'].toDouble(),
      totalPayable: materialMap['totalAmount'].toDouble(),
      date: DateTime.parse(materialMap['invoiceDate']),
      status: materialMap['paymentStatus'].toString().split('.').last.toLowerCase(),
      paymentMethod: materialMap['method'].toString().split('.').last.toLowerCase(),
      siteName: materialMap['site'] ?? 'Unassigned',
      role: materialMap['category'] ?? 'Supplier',
      periodStart: DateTime.parse(materialMap['invoiceDate']).subtract(const Duration(days: 10)),
      periodEnd: DateTime.parse(materialMap['invoiceDate']),
      transactionRef: materialMap['transactionRef'],
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
          _showEditPayment(materialMap);
        },
        onDelete: () {
          Navigator.pop(context);
          _confirmDelete(materialMap);
        },
      ),
    );
  }
}
