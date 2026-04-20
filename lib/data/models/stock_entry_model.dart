import 'package:construction_app/core/utils/date_parser.dart';

enum StockEntryType {
  directEntry,
  supplierBill,
  miscExpense;

  String get displayName {
    switch (this) {
      case StockEntryType.directEntry:   return 'Direct Entry';
      case StockEntryType.supplierBill:  return 'Supplier Bill';
      case StockEntryType.miscExpense:   return 'Misc Expense';
    }
  }
}

/// A single line-item purchase record.
/// When entryType == miscExpense, materialId / subType may be empty
/// and the entry does NOT affect inventory stock counts.
class StockEntryModel {
  final String id;
  final String siteId;
  final String supplierId;   // PartyModel.id
  final String supplierName;
  final String? billId;      // non-null when part of a SupplierBill
  final String materialId;   // ConstructionMaterial.id (empty for misc)
  final String materialName;
  final String subType;
  final String unit;
  final double quantity;
  final double unitPrice;
  final double totalAmount;  // quantity * unitPrice (or manual for misc)
  final double paidAmount;
  final DateTime? dueDate;
  final DateTime entryDate;
  final StockEntryType entryType;
  final bool isInventoryItem; // false → misc expense (no stock update)
  final double? bagWeightKg;  // kg per bag (only when unit == 'bag')
  final String? remarks;

  StockEntryModel({
    required this.id,
    required this.siteId,
    required this.supplierId,
    required this.supplierName,
    this.billId,
    required this.materialId,
    required this.materialName,
    required this.subType,
    required this.unit,
    required this.quantity,
    required this.unitPrice,
    required this.totalAmount,
    this.paidAmount = 0,
    this.dueDate,
    required this.entryDate,
    this.entryType = StockEntryType.directEntry,
    this.isInventoryItem = true,
    this.bagWeightKg,
    this.remarks,
  });

  double get pendingAmount => (totalAmount - paidAmount).clamp(0, double.infinity);

  Map<String, dynamic> toJson() => {
    'id': id,
    'siteId': siteId,
    'supplierId': supplierId,
    'supplierName': supplierName,
    'billId': billId,
    'materialId': materialId,
    'materialName': materialName,
    'subType': subType,
    'unit': unit,
    'quantity': quantity,
    'unitPrice': unitPrice,
    'totalAmount': totalAmount,
    'paidAmount': paidAmount,
    'dueDate': dueDate?.toIso8601String(),
    'entryDate': entryDate.toIso8601String(),
    'entryType': entryType.name,
    'isInventoryItem': isInventoryItem,
    'bagWeightKg': bagWeightKg,
    'remarks': remarks,
  };

  factory StockEntryModel.fromJson(Map<String, dynamic> json) {
    StockEntryType et;
    try {
      et = StockEntryType.values.byName(json['entryType'] ?? 'directEntry');
    } catch (_) {
      et = StockEntryType.directEntry;
    }
    return StockEntryModel(
      id: json['id'],
      siteId: json['siteId'] ?? '',
      supplierId: json['supplierId'] ?? '',
      supplierName: json['supplierName'] ?? '',
      billId: json['billId'],
      materialId: json['materialId'] ?? '',
      materialName: json['materialName'] ?? '',
      subType: json['subType'] ?? '',
      unit: json['unit'] ?? '',
      quantity: (json['quantity'] as num? ?? 0).toDouble(),
      unitPrice: (json['unitPrice'] as num? ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] as num? ?? 0).toDouble(),
      paidAmount: (json['paidAmount'] as num? ?? 0).toDouble(),
      dueDate: DateParser.parseNullable(json['dueDate']),
      entryDate: DateParser.parse(json['entryDate']),
      entryType: et,
      isInventoryItem: json['isInventoryItem'] ?? true,
      bagWeightKg: (json['bagWeightKg'] as num?)?.toDouble(),
      remarks: json['remarks'],
    );
  }

  StockEntryModel copyWith({double? paidAmount, DateTime? dueDate, double? bagWeightKg, String? remarks}) =>
      StockEntryModel(
        id: id,
        siteId: siteId,
        supplierId: supplierId,
        supplierName: supplierName,
        billId: billId,
        materialId: materialId,
        materialName: materialName,
        subType: subType,
        unit: unit,
        quantity: quantity,
        unitPrice: unitPrice,
        totalAmount: totalAmount,
        paidAmount: paidAmount ?? this.paidAmount,
        dueDate: dueDate ?? this.dueDate,
        entryDate: entryDate,
        entryType: entryType,
        isInventoryItem: isInventoryItem,
        bagWeightKg: bagWeightKg ?? this.bagWeightKg,
        remarks: remarks ?? this.remarks,
      );
}

/// A supplier bill — a single purchase event containing multiple StockEntryModels.
/// All items in a bill share the same supplier and bill date.
class SupplierBill {
  final String id;
  final String siteId;
  final String supplierId;
  final String supplierName;
  final List<StockEntryModel> items;
  final double paidAmount;
  final DateTime billDate;
  final String? billNumber;
  final DateTime? dueDate;
  final String? remarks;

  SupplierBill({
    required this.id,
    required this.siteId,
    required this.supplierId,
    required this.supplierName,
    required this.items,
    this.paidAmount = 0,
    required this.billDate,
    this.billNumber,
    this.dueDate,
    this.remarks,
  });

  double get totalAmount => items.fold(0.0, (s, i) => s + i.totalAmount);
  double get pendingAmount => (totalAmount - paidAmount).clamp(0, double.infinity);

  Map<String, dynamic> toJson() => {
    'id': id,
    'siteId': siteId,
    'supplierId': supplierId,
    'supplierName': supplierName,
    'items': items.map((i) => i.toJson()).toList(),
    'paidAmount': paidAmount,
    'billDate': billDate.toIso8601String(),
    'billNumber': billNumber,
    'dueDate': dueDate?.toIso8601String(),
    'remarks': remarks,
  };

  factory SupplierBill.fromJson(Map<String, dynamic> json) => SupplierBill(
    id: json['id'],
    siteId: json['siteId'] ?? '',
    supplierId: json['supplierId'] ?? '',
    supplierName: json['supplierName'] ?? '',
    items: (json['items'] as List? ?? [])
        .map((e) => StockEntryModel.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    paidAmount: (json['paidAmount'] as num? ?? 0).toDouble(),
    billDate: DateParser.parse(json['billDate']),
    billNumber: json['billNumber'],
    dueDate: DateParser.parseNullable(json['dueDate']),
    remarks: json['remarks'],
  );

  SupplierBill copyWith({double? paidAmount, String? remarks}) => SupplierBill(
    id: id,
    siteId: siteId,
    supplierId: supplierId,
    supplierName: supplierName,
    items: items,
    paidAmount: paidAmount ?? this.paidAmount,
    billDate: billDate,
    billNumber: billNumber,
    dueDate: dueDate,
    remarks: remarks ?? this.remarks,
  );
}
