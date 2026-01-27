import 'package:flutter/material.dart';

enum MaterialCategory {
  cement('Cement', Icons.architecture_rounded),
  steel('Steel', Icons.reorder_rounded),
  sand('Sand', Icons.grain_rounded),
  bricks('Bricks', Icons.grid_view_rounded),
  electrical('Electrical', Icons.electric_bolt_rounded),
  plumbing('Plumbing', Icons.plumbing_rounded),
  paint('Paint', Icons.format_paint_rounded),
  tools('Tools', Icons.build_rounded),
  other('Other', Icons.category_rounded);

  final String displayName;
  final IconData icon;
  const MaterialCategory(this.displayName, this.icon);
}

enum UnitType {
  kg('kg'),
  bag('bag'),
  piece('piece'),
  meter('meter'),
  liter('liter'),
  ton('ton'),
  unit('unit');

  final String label;
  const UnitType(this.label);
}

class SupplierDetails {
  final String companyName;
  final String? address;
  final String? gstNumber;
  final String? contactPerson;
  final String? contactPhone;
  final String? contactRole;

  SupplierDetails({
    required this.companyName,
    this.address,
    this.gstNumber,
    this.contactPerson,
    this.contactPhone,
    this.contactRole,
  });

  Map<String, dynamic> toJson() {
    return {
      'companyName': companyName,
      'address': address,
      'gstNumber': gstNumber,
      'contactPerson': contactPerson,
      'contactPhone': contactPhone,
      'contactRole': contactRole,
    };
  }

  factory SupplierDetails.fromJson(Map<String, dynamic> json) {
    return SupplierDetails(
      companyName: json['companyName'] ?? '',
      address: json['address'],
      gstNumber: json['gstNumber'],
      contactPerson: json['contactPerson'],
      contactPhone: json['contactPhone'],
      contactRole: json['contactRole'],
    );
  }
}

class BillingDetails {
  final String? billPhotoUrl;
  final String? billingPersonName;
  final String? billingPersonContact;
  final String? billingPersonRole;
  final String? remarks;
  final String? invoiceNumber;
  final DateTime? billingDate;

  BillingDetails({
    this.billPhotoUrl,
    this.billingPersonName,
    this.billingPersonContact,
    this.billingPersonRole,
    this.remarks,
    this.invoiceNumber,
    this.billingDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'billPhotoUrl': billPhotoUrl,
      'billingPersonName': billingPersonName,
      'billingPersonContact': billingPersonContact,
      'billingPersonRole': billingPersonRole,
      'remarks': remarks,
      'invoiceNumber': invoiceNumber,
      'billingDate': billingDate?.toIso8601String(),
    };
  }

  factory BillingDetails.fromJson(Map<String, dynamic> json) {
    return BillingDetails(
      billPhotoUrl: json['billPhotoUrl'],
      billingPersonName: json['billingPersonName'],
      billingPersonContact: json['billingPersonContact'],
      billingPersonRole: json['billingPersonRole'],
      remarks: json['remarks'],
      invoiceNumber: json['invoiceNumber'],
      billingDate: json['billingDate'] != null ? DateTime.parse(json['billingDate']) : null,
    );
  }
}
class MaterialHistoryLog {
  final String id;
  final String action; // e.g., 'Created', 'Updated Quantity', 'Updated Price'
  final String description;
  final DateTime timestamp;
  final String performedBy;
  final Map<String, dynamic>? metadata;

  MaterialHistoryLog({
    required this.id,
    required this.action,
    required this.description,
    required this.timestamp,
    required this.performedBy,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'action': action,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'performedBy': performedBy,
      'metadata': metadata,
    };
  }

  factory MaterialHistoryLog.fromJson(Map<String, dynamic> json) {
    return MaterialHistoryLog(
      id: json['id'],
      action: json['action'],
      description: json['description'],
      timestamp: DateTime.parse(json['timestamp']),
      performedBy: json['performedBy'],
      metadata: json['metadata'] != null ? Map<String, dynamic>.from(json['metadata']) : null,
    );
  }
}

class CustomDimension {
  final String label;
  final double value;
  final String unit;

  CustomDimension({
    required this.label,
    required this.value,
    required this.unit,
  });

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'value': value,
      'unit': unit,
    };
  }

  factory CustomDimension.fromJson(Map<String, dynamic> json) {
    return CustomDimension(
      label: json['label'] ?? '',
      value: (json['value'] as num? ?? 0).toDouble(),
      unit: json['unit'] ?? '',
    );
  }
}

class ConstructionMaterial {
  final String id;
  final String masterMaterialId; // Reference to Master Material
  final String name; // Redundant but good for history snapshots
  final MaterialCategory category;
  final String subType;
  final String? photoUrl;
  final String? brand;
  final List<String> availableSizes;
  final double pricePerUnit;
  final UnitType unitType;
  final double currentStock;
  final bool isActive;
  final SupplierDetails? supplier;
  final BillingDetails? billingDetails;
  
  // Financial Fields
  final double gstPercentage;
  final double totalAmount;
  final double paidAmount;
  final double pendingAmount;
  final String? partyId;
  final String? paymentMode;
  final DateTime? purchaseDate;

  // Measurement Fields
  final List<CustomDimension> customDimensions;

  final String siteId;
  final List<MaterialHistoryLog> history;
  final DateTime createdAt;
  final DateTime updatedAt;

  ConstructionMaterial({
    required this.id,
    required this.masterMaterialId,
    required this.siteId,
    required this.name,
    required this.category,
    required this.subType,
    this.photoUrl,
    this.brand,
    this.availableSizes = const [],
    required this.pricePerUnit,
    required this.unitType,
    this.currentStock = 0,
    this.isActive = true,
    this.supplier,
    this.billingDetails,
    this.gstPercentage = 0,
    this.totalAmount = 0,
    this.paidAmount = 0,
    this.pendingAmount = 0,
    this.partyId,
    this.paymentMode,
    this.purchaseDate,
    this.customDimensions = const [],
    this.history = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'masterMaterialId': masterMaterialId,
      'siteId': siteId,
      'name': name,
      'category': category.name,
      'subType': subType,
      'photoUrl': photoUrl,
      'brand': brand,
      'availableSizes': availableSizes,
      'pricePerUnit': pricePerUnit,
      'unitType': unitType.name,
      'currentStock': currentStock,
      'isActive': isActive,
      'supplier': supplier?.toJson(),
      'billingDetails': billingDetails?.toJson(),
      'gstPercentage': gstPercentage,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'pendingAmount': pendingAmount,
      'partyId': partyId,
      'paymentMode': paymentMode,
      'purchaseDate': purchaseDate?.toIso8601String(),
      'customDimensions': customDimensions.map((e) => e.toJson()).toList(),
      'history': history.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ConstructionMaterial.fromJson(Map<String, dynamic> json) {
    return ConstructionMaterial(
      id: json['id'],
      masterMaterialId: json['masterMaterialId'] ?? '',
      siteId: json['siteId'] ?? 'S-001',
      name: json['name'],
      category: MaterialCategory.values.byName(json['category']),
      subType: json['subType'] ?? '',
      photoUrl: json['photoUrl'],
      brand: json['brand'],
      availableSizes: json['availableSizes'] != null ? List<String>.from(json['availableSizes']) : [],
      pricePerUnit: (json['pricePerUnit'] as num).toDouble(),
      unitType: UnitType.values.byName(json['unitType']),
      currentStock: (json['currentStock'] as num? ?? 0).toDouble(),
      isActive: json['isActive'] ?? true,
      supplier: json['supplier'] != null ? SupplierDetails.fromJson(Map<String, dynamic>.from(json['supplier'])) : null,
      billingDetails: json['billingDetails'] != null ? BillingDetails.fromJson(Map<String, dynamic>.from(json['billingDetails'])) : null,
      gstPercentage: (json['gstPercentage'] as num? ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] as num? ?? 0).toDouble(),
      paidAmount: (json['paidAmount'] as num? ?? 0).toDouble(),
      pendingAmount: (json['pendingAmount'] as num? ?? 0).toDouble(),
      partyId: json['partyId'],
      paymentMode: json['paymentMode'],
      purchaseDate: json['purchaseDate'] != null ? DateTime.parse(json['purchaseDate']) : null,
      customDimensions: (json['customDimensions'] as List? ?? []).map((e) => CustomDimension.fromJson(Map<String, dynamic>.from(e))).toList(),
      history: (json['history'] as List? ?? []).map((e) => MaterialHistoryLog.fromJson(Map<String, dynamic>.from(e))).toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  ConstructionMaterial copyWith({
    String? masterMaterialId,
    String? siteId,
    String? name,
    MaterialCategory? category,
    String? subType,
    String? photoUrl,
    String? brand,
    List<String>? availableSizes,
    double? pricePerUnit,
    UnitType? unitType,
    double? currentStock,
    bool? isActive,
    SupplierDetails? supplier,
    BillingDetails? billingDetails,
    double? gstPercentage,
    double? totalAmount,
    double? paidAmount,
    double? pendingAmount,
    String? partyId,
    String? paymentMode,
    DateTime? purchaseDate,
    List<CustomDimension>? customDimensions,
    List<MaterialHistoryLog>? history,
    DateTime? updatedAt,
  }) {
    return ConstructionMaterial(
      id: id,
      masterMaterialId: masterMaterialId ?? this.masterMaterialId,
      siteId: siteId ?? this.siteId,
      name: name ?? this.name,
      category: category ?? this.category,
      subType: subType ?? this.subType,
      photoUrl: photoUrl ?? this.photoUrl,
      brand: brand ?? this.brand,
      availableSizes: availableSizes ?? this.availableSizes,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      unitType: unitType ?? this.unitType,
      currentStock: currentStock ?? this.currentStock,
      isActive: isActive ?? this.isActive,
      supplier: supplier ?? this.supplier,
      billingDetails: billingDetails ?? this.billingDetails,
      gstPercentage: gstPercentage ?? this.gstPercentage,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      pendingAmount: pendingAmount ?? this.pendingAmount,
      partyId: partyId ?? this.partyId,
      paymentMode: paymentMode ?? this.paymentMode,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      customDimensions: customDimensions ?? this.customDimensions,
      history: history ?? this.history,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
