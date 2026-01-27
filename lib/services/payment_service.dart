import 'package:flutter/foundation.dart';

/// Payment model for managing payment records
class Payment {
  final String id;
  final String category; // 'engineer', 'worker', 'inventory'
  final String recipientName;
  final String recipientId;
  final double amount;
  final double totalPayable; // For balance tracking
  final DateTime date;
  final String status; // 'paid', 'pending', 'partial', 'overdue', 'failed'
  final String paymentMethod; // 'cash', 'upi', 'bank', 'cheque'
  final String? description;
  final String? proofUrl;
  final String? transactionRef;
  
  // Role-specific fields
  final String? siteId;
  final String? siteName;
  final String? role;
  final double? quantity;
  final double? unitPrice;
  final String? unit;
  final DateTime? periodStart;
  final DateTime? periodEnd;

  final DateTime createdAt;
  final DateTime? updatedAt;

  Payment({
    required this.id,
    required this.category,
    required this.recipientName,
    required this.recipientId,
    required this.amount,
    required this.totalPayable,
    required this.date,
    required this.status,
    required this.paymentMethod,
    this.description,
    this.proofUrl,
    this.transactionRef,
    this.siteId,
    this.siteName,
    this.role,
    this.quantity,
    this.unitPrice,
    this.unit,
    this.periodStart,
    this.periodEnd,
    required this.createdAt,
    this.updatedAt,
  });

  double get balanceAmount => totalPayable - amount;

  Payment copyWith({
    String? recipientName,
    double? amount,
    double? totalPayable,
    DateTime? date,
    String? status,
    String? paymentMethod,
    String? description,
    String? proofUrl,
    String? transactionRef,
    String? siteId,
    String? siteName,
    String? role,
    double? quantity,
    double? unitPrice,
    String? unit,
    DateTime? periodStart,
    DateTime? periodEnd,
    DateTime? updatedAt,
  }) {
    return Payment(
      id: id,
      category: category,
      recipientName: recipientName ?? this.recipientName,
      recipientId: recipientId,
      amount: amount ?? this.amount,
      totalPayable: totalPayable ?? this.totalPayable,
      date: date ?? this.date,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      description: description ?? this.description,
      proofUrl: proofUrl ?? this.proofUrl,
      transactionRef: transactionRef ?? this.transactionRef,
      siteId: siteId ?? this.siteId,
      siteName: siteName ?? this.siteName,
      role: role ?? this.role,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      unit: unit ?? this.unit,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'recipientName': recipientName,
      'recipientId': recipientId,
      'amount': amount,
      'totalPayable': totalPayable,
      'date': date.toIso8601String(),
      'status': status,
      'paymentMethod': paymentMethod,
      'description': description,
      'proofUrl': proofUrl,
      'transactionRef': transactionRef,
      'siteId': siteId,
      'siteName': siteName,
      'role': role,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'unit': unit,
      'periodStart': periodStart?.toIso8601String(),
      'periodEnd': periodEnd?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      category: json['category'],
      recipientName: json['recipientName'],
      recipientId: json['recipientId'],
      amount: json['amount'].toDouble(),
      totalPayable: json['totalPayable']?.toDouble() ?? json['amount'].toDouble(),
      date: DateTime.parse(json['date']),
      status: json['status'],
      paymentMethod: json['paymentMethod'],
      description: json['description'],
      proofUrl: json['proofUrl'],
      transactionRef: json['transactionRef'],
      siteId: json['siteId'],
      siteName: json['siteName'],
      role: json['role'],
      quantity: json['quantity']?.toDouble(),
      unitPrice: json['unitPrice']?.toDouble(),
      unit: json['unit'],
      periodStart: json['periodStart'] != null ? DateTime.parse(json['periodStart']) : null,
      periodEnd: json['periodEnd'] != null ? DateTime.parse(json['periodEnd']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}

/// Mock service for payment CRUD operations
class PaymentService extends ChangeNotifier {
  final List<Payment> _payments = [];

  PaymentService() {
    _initializeMockData();
  }

  List<Payment> get allPayments => List.unmodifiable(_payments);

  List<Payment> getPaymentsByCategory(String category) {
    return _payments.where((p) => p.category == category).toList();
  }

  Payment? getPaymentById(String id) {
    try {
      return _payments.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> createPayment(Payment payment) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate API call
    _payments.add(payment);
    notifyListeners();
  }

  Future<void> updatePayment(String id, Payment updatedPayment) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _payments.indexWhere((p) => p.id == id);
    if (index != -1) {
      _payments[index] = updatedPayment;
      notifyListeners();
    }
  }

  Future<void> deletePayment(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _payments.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void _initializeMockData() {
    // Engineer payments
    _payments.addAll([
      Payment(
        id: 'eng_001',
        category: 'engineer',
        recipientName: 'Rajesh Kumar',
        recipientId: 'ENG001',
        amount: 45000,
        totalPayable: 45000,
        date: DateTime(2026, 1, 15),
        status: 'paid',
        paymentMethod: 'bank',
        siteName: 'Metropolis Heights',
        siteId: 'S-001',
        role: 'Site Engineer',
        periodStart: DateTime(2026, 1, 1),
        periodEnd: DateTime(2026, 1, 31),
        description: 'Site supervision - January 2026',
        createdAt: DateTime(2026, 1, 15),
      ),
    ]);

    // Worker payments
    _payments.addAll([
      Payment(
        id: 'work_001',
        category: 'worker',
        recipientName: 'Ramesh Singh',
        recipientId: 'WRK015',
        amount: 4200,
        totalPayable: 4200,
        date: DateTime(2026, 1, 18),
        status: 'paid',
        paymentMethod: 'cash',
        role: 'Mason',
        siteName: 'Metropolis Heights',
        siteId: 'S-001',
        createdAt: DateTime(2026, 1, 18),
      ),
      Payment(
        id: 'work_002',
        category: 'worker',
        recipientName: 'Suresh Yadav',
        recipientId: 'WRK022',
        amount: 2000,
        totalPayable: 3800,
        date: DateTime(2026, 1, 20),
        status: 'partial',
        paymentMethod: 'cash',
        role: 'Laborer',
        siteName: 'Skyline Tower',
        siteId: 'S-002',
        createdAt: DateTime(2026, 1, 20),
      ),
    ]);

    // Inventory payments
    _payments.addAll([
      Payment(
        id: 'inv_001',
        category: 'inventory',
        recipientName: 'Steel Traders Ltd',
        recipientId: 'SUP001',
        amount: 185000,
        totalPayable: 185000,
        date: DateTime(2026, 1, 10),
        status: 'paid',
        paymentMethod: 'bank',
        quantity: 500,
        unitPrice: 370,
        unit: 'kg',
        description: '500kg TMT Steel Rods',
        transactionRef: 'TXN20260110STL',
        siteName: 'Metropolis Heights',
        siteId: 'S-001',
        createdAt: DateTime(2026, 1, 10),
      ),
    ]);
  }
}
