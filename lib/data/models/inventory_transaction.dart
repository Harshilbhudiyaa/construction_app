
import 'package:construction_app/core/utils/date_parser.dart';

/// Types of inventory transactions
enum TransactionType {
  inward,     // Material coming in (purchase, return)
  outward,    // Material going out (issue, sale)
  transfer,   // Material transfer between sites
  damage,     // Damaged material write-off
  adjustment, // Manual stock adjustment
}

extension TransactionTypeExtension on TransactionType {
  String get displayName {
    switch (this) {
      case TransactionType.inward:
        return 'Inward';
      case TransactionType.outward:
        return 'Outward';
      case TransactionType.transfer:
        return 'Transfer';
      case TransactionType.damage:
        return 'Damage';
      case TransactionType.adjustment:
        return 'Adjustment';
    }
  }

  /// Returns true if this transaction increases stock
  bool get increasesStock => this == TransactionType.inward;
  
  /// Returns true if this transaction decreases stock
  bool get decreasesStock => 
      this == TransactionType.outward || 
      this == TransactionType.damage ||
      this == TransactionType.transfer;
}

/// Central model for all inventory transactions
/// This is the single source of truth for all stock movements
class InventoryTransaction {
  final String id;
  final TransactionType type;
  final String materialId;
  final String materialName;
  final double quantity;
  final String unit;
  final DateTime timestamp;
  final String? siteId;
  final String? siteName;
  final String? partyId;
  final String? partyName;
  final String? billNumber;
  final double? rate;
  final double? totalAmount;
  final String? remarks;
  final String createdBy;
  final bool isApproved;
  final String? approvedBy;
  final DateTime? approvedAt;
  
  /// Reference to the original document (inward log ID, outward log ID, etc.)
  final String? referenceId;

  const InventoryTransaction({
    required this.id,
    required this.type,
    required this.materialId,
    required this.materialName,
    required this.quantity,
    required this.unit,
    required this.timestamp,
    this.siteId,
    this.siteName,
    this.partyId,
    this.partyName,
    this.billNumber,
    this.rate,
    this.totalAmount,
    this.remarks,
    required this.createdBy,
    this.isApproved = false,
    this.approvedBy,
    this.approvedAt,
    this.referenceId,
  });

  /// Calculate the impact on stock (+ve for inward, -ve for outward/damage)
  double get stockImpact {
    if (!isApproved) return 0.0; // Unapproved transactions don't affect stock
    
    switch (type) {
      case TransactionType.inward:
        return quantity;
      case TransactionType.outward:
      case TransactionType.damage:
      case TransactionType.transfer:
        return -quantity;
      case TransactionType.adjustment:
        return quantity; // Can be +ve or -ve
    }
  }

  InventoryTransaction copyWith({
    String? id,
    TransactionType? type,
    String? materialId,
    String? materialName,
    double? quantity,
    String? unit,
    DateTime? timestamp,
    String? siteId,
    String? siteName,
    String? partyId,
    String? partyName,
    String? billNumber,
    double? rate,
    double? totalAmount,
    String? remarks,
    String? createdBy,
    bool? isApproved,
    String? approvedBy,
    DateTime? approvedAt,
    String? referenceId,
  }) {
    return InventoryTransaction(
      id: id ?? this.id,
      type: type ?? this.type,
      materialId: materialId ?? this.materialId,
      materialName: materialName ?? this.materialName,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      timestamp: timestamp ?? this.timestamp,
      siteId: siteId ?? this.siteId,
      siteName: siteName ?? this.siteName,
      partyId: partyId ?? this.partyId,
      partyName: partyName ?? this.partyName,
      billNumber: billNumber ?? this.billNumber,
      rate: rate ?? this.rate,
      totalAmount: totalAmount ?? this.totalAmount,
      remarks: remarks ?? this.remarks,
      createdBy: createdBy ?? this.createdBy,
      isApproved: isApproved ?? this.isApproved,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      referenceId: referenceId ?? this.referenceId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.index,
      'materialId': materialId,
      'materialName': materialName,
      'quantity': quantity,
      'unit': unit,
      'timestamp': timestamp.toIso8601String(),
      'siteId': siteId,
      'siteName': siteName,
      'partyId': partyId,
      'partyName': partyName,
      'billNumber': billNumber,
      'rate': rate,
      'totalAmount': totalAmount,
      'remarks': remarks,
      'createdBy': createdBy,
      'isApproved': isApproved,
      'approvedBy': approvedBy,
      'approvedAt': approvedAt?.toIso8601String(),
      'referenceId': referenceId,
    };
  }

  factory InventoryTransaction.fromJson(Map<String, dynamic> json) {
    return InventoryTransaction(
      id: json['id'] as String,
      type: TransactionType.values[json['type'] as int],
      materialId: json['materialId'] as String,
      materialName: json['materialName'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      timestamp: DateParser.parse(json['timestamp']),
      siteId: json['siteId'] as String?,
      siteName: json['siteName'] as String?,
      partyId: json['partyId'] as String?,
      partyName: json['partyName'] as String?,
      billNumber: json['billNumber'] as String?,
      rate: json['rate'] != null ? (json['rate'] as num).toDouble() : null,
      totalAmount: json['totalAmount'] != null ? (json['totalAmount'] as num).toDouble() : null,
      remarks: json['remarks'] as String?,
      createdBy: json['createdBy'] as String,
      isApproved: json['isApproved'] as bool? ?? false,
      approvedBy: json['approvedBy'] as String?,
      approvedAt: DateParser.parseNullable(json['approvedAt']),
      referenceId: json['referenceId'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InventoryTransaction &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'InventoryTransaction(id: $id, type: ${type.displayName}, material: $materialName, qty: $quantity $unit, approved: $isApproved)';
  }
}
