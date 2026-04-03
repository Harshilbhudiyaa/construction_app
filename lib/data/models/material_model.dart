import 'package:flutter/material.dart';

enum MaterialCategory {
  civilStructural('Civil/Structural', Icons.architecture_rounded);

  final String displayName;
  final IconData icon;
  const MaterialCategory(this.displayName, this.icon);

  List<MaterialPreset> get presets => MaterialPreset.getPresetsForCategory(this);
}

enum UnitType {
  none('None'),
  nos('NOS'),
  pcs('PCS'),
  kgs('KGS'),
  bag('BAG'),
  wks('WKS'),
  mon('MON'),
  yrs('YRS'),
  bal('BAL'),
  bou('BOU'),
  btl('BTL'),
  box('BOX'),
  bkl('BKL'),
  bun('BUN'),
  bdl('BDL'),
  can('CAN'),
  cms('CMS'),
  ctn('CTN'),
  dzn('DZN'),
  gms('GMS'),
  grs('GRS'),
  klt('KLT'),
  kms('KMS'),
  ltr('LTR'),
  mgm('MGM'),
  mlt('MLT'),
  mtr('MTR'),
  prs('PRS'),
  qtl('QTL'),
  rll('RLL'),
  sqf('SQF'),
  sqm('SQM'),
  tne('TNE'),
  unit('Unit'),
  cft('CFT'),
  ton('Ton');

  final String label;
  const UnitType(this.label);
}

class MaterialPreset {
  final String name;
  final UnitType defaultUnit;
  final bool hasSizeGrade;
  final List<String>? suggestedSizes;

  const MaterialPreset({
    required this.name,
    required this.defaultUnit,
    this.hasSizeGrade = false,
    this.suggestedSizes,
  });

  static List<MaterialPreset> getPresetsForCategory(MaterialCategory category) {
    switch (category) {
      case MaterialCategory.civilStructural:
        return [
          const MaterialPreset(name: 'Cement', defaultUnit: UnitType.bag, hasSizeGrade: true, suggestedSizes: ['43 Grade', '53 Grade', 'PPC', 'OPC']),
          const MaterialPreset(name: 'Steel / Rebar', defaultUnit: UnitType.ton, hasSizeGrade: true, suggestedSizes: ['8mm', '10mm', '12mm', '16mm', '20mm', '25mm']),
          const MaterialPreset(name: 'Sand', defaultUnit: UnitType.cft),
          const MaterialPreset(name: 'Aggregate (Kapachi)', defaultUnit: UnitType.cft, hasSizeGrade: true, suggestedSizes: ['10mm', '20mm']),
          const MaterialPreset(name: 'Bricks', defaultUnit: UnitType.nos),
          const MaterialPreset(name: 'Blocks (AAC)', defaultUnit: UnitType.nos, hasSizeGrade: true, suggestedSizes: ['4"', '6"', '9"']),
          const MaterialPreset(name: 'Plaster', defaultUnit: UnitType.sqf),
          const MaterialPreset(name: 'Tiles (Floor)', defaultUnit: UnitType.sqf, hasSizeGrade: true, suggestedSizes: ['2x2', '2x4', '1x1']),
          const MaterialPreset(name: 'Tiles (Wall)', defaultUnit: UnitType.sqf),
        ];
    }
  }
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

class PricePoint {
  final DateTime timestamp;
  final double price;
  final String? referenceId; // e.g., Inward Log ID

  PricePoint({
    required this.timestamp,
    required this.price,
    this.referenceId,
  });

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'price': price,
    'referenceId': referenceId,
  };

  factory PricePoint.fromJson(Map<String, dynamic> json) => PricePoint(
    timestamp: DateTime.parse(json['timestamp']),
    price: (json['price'] as num).toDouble(),
    referenceId: json['referenceId'],
  );
}

class ConstructionMaterial {
  final String id;
  final String name; 
  final MaterialCategory category;
  final String subType;
  final String? photoUrl;
  final String? brand;
  final List<String> availableSizes;
  final double pricePerUnit; // Conceptual Purchase Price (legacy)
  final double purchasePrice; // Modern cost price
  final double salePrice; // Modern selling price
  final bool taxIncluded;
  final String? hsnCode;
  final UnitType unitType; // Primary Unit
  final UnitType? secondaryUnit;
  final double? conversionFactor;
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

  // Stock Management Fields
  final double minimumStockLimit;
  final String storageLocation;

  bool get isLowStock => currentStock <= minimumStockLimit;

  final String siteId;
  final List<MaterialHistoryLog> history;
  final List<PricePoint> rateHistory;
  final DateTime createdAt;
  final DateTime updatedAt;

  ConstructionMaterial({
    required this.id,
    required this.siteId,
    required this.name,
    required this.category,
    required this.subType,
    this.photoUrl,
    this.brand,
    this.availableSizes = const [],
    this.pricePerUnit = 0,
    this.purchasePrice = 0,
    this.salePrice = 0,
    this.taxIncluded = true,
    this.hsnCode,
    required this.unitType,
    this.secondaryUnit,
    this.conversionFactor,
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
    this.minimumStockLimit = 0,
    this.storageLocation = '',
    this.history = const [],
    this.rateHistory = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'siteId': siteId,
      'name': name,
      'category': category.name,
      'subType': subType,
      'photoUrl': photoUrl,
      'brand': brand,
      'availableSizes': availableSizes,
      'pricePerUnit': pricePerUnit,
      'purchasePrice': purchasePrice,
      'salePrice': salePrice,
      'taxIncluded': taxIncluded,
      'hsnCode': hsnCode,
      'unitType': unitType.name,
      'secondaryUnit': secondaryUnit?.name,
      'conversionFactor': conversionFactor,
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
      'minimumStockLimit': minimumStockLimit,
      'storageLocation': storageLocation,
      'history': history.map((e) => e.toJson()).toList(),
      'rateHistory': rateHistory.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ConstructionMaterial.fromJson(Map<String, dynamic> json) {
    MaterialCategory category;
    try {
      category = MaterialCategory.values.byName(json['category'] ?? 'civilStructural');
    } catch (_) {
      category = MaterialCategory.civilStructural;
    }

    UnitType unitType;
    try {
      unitType = UnitType.values.byName(json['unitType'] ?? 'unit');
    } catch (_) {
      unitType = UnitType.unit;
    }

    UnitType? secondaryUnit;
    if (json['secondaryUnit'] != null) {
      try {
        secondaryUnit = UnitType.values.byName(json['secondaryUnit']);
      } catch (_) {}
    }

    return ConstructionMaterial(
      id: json['id'] ?? '',
      siteId: json['siteId'] ?? 'S-001',
      name: json['name'] ?? 'Unknown Material',
      category: category,
      subType: json['subType'] ?? '',
      photoUrl: json['photoUrl'],
      brand: json['brand'],
      availableSizes: json['availableSizes'] != null ? List<String>.from(json['availableSizes']) : [],
      pricePerUnit: (json['pricePerUnit'] as num? ?? 0).toDouble(),
      purchasePrice: (json['purchasePrice'] as num? ?? json['pricePerUnit'] as num? ?? 0).toDouble(),
      salePrice: (json['salePrice'] as num? ?? 0).toDouble(),
      taxIncluded: json['taxIncluded'] ?? true,
      hsnCode: json['hsnCode'],
      unitType: unitType,
      secondaryUnit: secondaryUnit,
      conversionFactor: (json['conversionFactor'] as num?)?.toDouble(),
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
      purchaseDate: () {
        if (json['purchaseDate'] == null) return null;
        try {
          return DateTime.parse(json['purchaseDate']);
        } catch (_) {
          return null;
        }
      }(),
      customDimensions: (json['customDimensions'] as List? ?? []).map((e) => CustomDimension.fromJson(Map<String, dynamic>.from(e))).toList(),
      minimumStockLimit: (json['minimumStockLimit'] as num? ?? 0).toDouble(),
      storageLocation: json['storageLocation'] ?? '',
      history: (json['history'] as List? ?? []).map((e) => MaterialHistoryLog.fromJson(Map<String, dynamic>.from(e))).toList(),
      rateHistory: (json['rateHistory'] as List? ?? []).map((e) => PricePoint.fromJson(Map<String, dynamic>.from(e))).toList(),
      createdAt: () {
        try {
          return json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now();
        } catch (_) {
          return DateTime.now();
        }
      }(),
      updatedAt: () {
        try {
          return json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now();
        } catch (_) {
          return DateTime.now();
        }
      }(),
    );
  }

  ConstructionMaterial copyWith({
    String? siteId,
    String? name,
    MaterialCategory? category,
    String? subType,
    String? photoUrl,
    String? brand,
    List<String>? availableSizes,
    double? pricePerUnit,
    double? purchasePrice,
    double? salePrice,
    bool? taxIncluded,
    String? hsnCode,
    UnitType? unitType,
    UnitType? secondaryUnit,
    double? conversionFactor,
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
    double? minimumStockLimit,
    String? storageLocation,
    List<MaterialHistoryLog>? history,
    List<PricePoint>? rateHistory,
    DateTime? updatedAt,
  }) {
    return ConstructionMaterial(
      id: id,
      siteId: siteId ?? this.siteId,
      name: name ?? this.name,
      category: category ?? this.category,
      subType: subType ?? this.subType,
      photoUrl: photoUrl ?? this.photoUrl,
      brand: brand ?? this.brand,
      availableSizes: availableSizes ?? this.availableSizes,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      salePrice: salePrice ?? this.salePrice,
      taxIncluded: taxIncluded ?? this.taxIncluded,
      hsnCode: hsnCode ?? this.hsnCode,
      unitType: unitType ?? this.unitType,
      secondaryUnit: secondaryUnit ?? this.secondaryUnit,
      conversionFactor: conversionFactor ?? this.conversionFactor,
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
      minimumStockLimit: minimumStockLimit ?? this.minimumStockLimit,
      storageLocation: storageLocation ?? this.storageLocation,
      history: history ?? this.history,
      rateHistory: rateHistory ?? this.rateHistory,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

