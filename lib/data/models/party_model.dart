import 'package:construction_app/core/utils/date_parser.dart';

enum PartyCategory {
  supplier,
  contractor,
  siteStaff,
  customer,
  engineer,
  other
}

extension PartyCategoryExtension on PartyCategory {
  String get displayName {
    switch (this) {
      case PartyCategory.supplier:    return 'Supplier';
      case PartyCategory.contractor:  return 'Contractor';
      case PartyCategory.siteStaff:   return 'Site Staff';
      case PartyCategory.customer:    return 'Customer';
      case PartyCategory.engineer:    return 'Engineer';
      case PartyCategory.other:       return 'Other';
    }
  }
}

class PartyModel {
  final String id;
  final String name;
  final PartyCategory category;
  final String? contactNumber;
  final String? gstNumber;
  final String? address;
  final String? paymentTerms; // e.g. "Net 30", "On delivery", "Credit 7 days"
  final String? billingName; // Legal Name / Bill Party
  final DateTime createdAt;

  PartyModel({
    required this.id,
    required this.name,
    required this.category,
    this.contactNumber,
    this.gstNumber,
    this.address,
    this.paymentTerms,
    this.billingName,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category.name,
      'contactNumber': contactNumber,
      'gstNumber': gstNumber,
      'address': address,
      'paymentTerms': paymentTerms,
      'billingName': billingName,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PartyModel.fromJson(Map<String, dynamic> json) {
    return PartyModel(
      id: json['id'],
      name: json['name'],
      category: PartyCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => PartyCategory.other,
      ),
      contactNumber: json['contactNumber'],
      gstNumber: json['gstNumber'],
      address: json['address'],
      paymentTerms: json['paymentTerms'],
      billingName: json['billingName'],
      createdAt: DateParser.parse(json['createdAt']),
    );
  }

  PartyModel copyWith({
    String? name,
    PartyCategory? category,
    String? contactNumber,
    String? gstNumber,
    String? address,
    String? paymentTerms,
    String? billingName,
  }) {
    return PartyModel(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      contactNumber: contactNumber ?? this.contactNumber,
      gstNumber: gstNumber ?? this.gstNumber,
      address: address ?? this.address,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      billingName: billingName ?? this.billingName,
      createdAt: createdAt,
    );
  }
}

/// A financial transaction record linked to a supplier (PartyModel).
/// Stored separately in PartyRepository (key: supplier_transactions_v1)
/// rather than inside PartyModel to keep the per-party record lean.
class SupplierTransaction {
  final String id;
  final String supplierId;
  final String siteId;
  final String description; // e.g. "Cement OPC — 200 bags"
  final double amount;
  final double paidAmount;
  final String? billId; // links to StockEntryModel.billId when applicable
  final DateTime date;
  final String? remarks;

  SupplierTransaction({
    required this.id,
    required this.supplierId,
    required this.siteId,
    required this.description,
    required this.amount,
    this.paidAmount = 0,
    this.billId,
    required this.date,
    this.remarks,
  });

  double get pendingAmount => (amount - paidAmount).clamp(0, double.infinity);

  Map<String, dynamic> toJson() => {
    'id': id,
    'supplierId': supplierId,
    'siteId': siteId,
    'description': description,
    'amount': amount,
    'paidAmount': paidAmount,
    'billId': billId,
    'date': date.toIso8601String(),
    'remarks': remarks,
  };

  factory SupplierTransaction.fromJson(Map<String, dynamic> json) =>
      SupplierTransaction(
        id: json['id'],
        supplierId: json['supplierId'],
        siteId: json['siteId'] ?? '',
        description: json['description'],
        amount: (json['amount'] as num).toDouble(),
        paidAmount: (json['paidAmount'] as num? ?? 0).toDouble(),
        billId: json['billId'],
        date: DateParser.parse(json['date']),
        remarks: json['remarks'],
      );

  SupplierTransaction copyWith({double? paidAmount, String? remarks}) =>
      SupplierTransaction(
        id: id,
        supplierId: supplierId,
        siteId: siteId,
        description: description,
        amount: amount,
        paidAmount: paidAmount ?? this.paidAmount,
        billId: billId,
        date: date,
        remarks: remarks ?? this.remarks,
      );
}
