// Categories and Unit types are now dynamic Strings to allow for custom user entry.
// Standard Unit presets are provided for the UI.
const List<String> standardUnits = ['nos', 'pcs', 'kgs', 'bag', 'sqft', 'sqm', 'mtr', 'ton', 'ltr', 'cft', 'brass'];

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
      id: json['id'] ?? '',
      action: json['action'] ?? '',
      description: json['description'] ?? '',
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : DateTime.now(),
      performedBy: json['performedBy'] ?? '',
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
  final String subType;
  final String variant; // e.g. "12mm", "14mm"
  final String? photoUrl;
  final String? brand;
  final double pricePerUnit; 
  final double purchasePrice; 
  final double salePrice; 
  final bool taxIncluded;
  final String? hsnCode;
  final String unitType; 
  final String? secondaryUnit;
  final double? conversionFactor;
  final double currentStock;
  final bool isActive;
  
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

  double get taxPercentage => gstPercentage;

  ConstructionMaterial({
    required this.id,
    required this.siteId,
    required this.name,
    required this.subType,
    this.variant = '',
    this.photoUrl,
    this.brand,
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
      'subType': subType,
      'variant': variant,
      'photoUrl': photoUrl,
      'brand': brand,
      'pricePerUnit': pricePerUnit,
      'purchasePrice': purchasePrice,
      'salePrice': salePrice,
      'taxIncluded': taxIncluded,
      'hsnCode': hsnCode,
      'unitType': unitType,
      'secondaryUnit': secondaryUnit,
      'conversionFactor': conversionFactor,
      'currentStock': currentStock,
      'isActive': isActive,
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
    return ConstructionMaterial(
      id: json['id'] ?? '',
      siteId: json['siteId'] ?? 'S-001',
      name: json['name'] ?? 'Unknown Material',
      subType: json['subType'] ?? '',
      variant: json['variant'] ?? '',
      photoUrl: json['photoUrl'],
      brand: json['brand'],
      pricePerUnit: (json['pricePerUnit'] as num? ?? 0).toDouble(),
      purchasePrice: (json['purchasePrice'] as num? ?? json['pricePerUnit'] as num? ?? 0).toDouble(),
      salePrice: (json['salePrice'] as num? ?? 0).toDouble(),
      taxIncluded: json['taxIncluded'] ?? true,
      hsnCode: json['hsnCode'],
      unitType: json['unitType']?.toString() ?? 'unit',
      secondaryUnit: json['secondaryUnit'],
      conversionFactor: (json['conversionFactor'] as num?)?.toDouble(),
      currentStock: (json['currentStock'] as num? ?? 0).toDouble(),
      isActive: json['isActive'] ?? true,
      gstPercentage: (json['gstPercentage'] as num? ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] as num? ?? 0).toDouble(),
      paidAmount: (json['paidAmount'] as num? ?? 0).toDouble(),
      pendingAmount: (json['pendingAmount'] as num? ?? 0).toDouble(),
      partyId: json['partyId'],
      paymentMode: json['paymentMode'],
      purchaseDate: json['purchaseDate'] != null ? DateTime.tryParse(json['purchaseDate']) : null,
      customDimensions: (json['customDimensions'] as List? ?? []).map((e) => CustomDimension.fromJson(Map<String, dynamic>.from(e))).toList(),
      minimumStockLimit: (json['minimumStockLimit'] as num? ?? 0).toDouble(),
      storageLocation: json['storageLocation'] ?? '',
      history: (json['history'] as List? ?? []).map((e) => MaterialHistoryLog.fromJson(Map<String, dynamic>.from(e))).toList(),
      rateHistory: (json['rateHistory'] as List? ?? []).map((e) => PricePoint.fromJson(Map<String, dynamic>.from(e))).toList(),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
    );
  }

  ConstructionMaterial copyWith({
    String? siteId,
    String? name,
    String? subType,
    String? variant,
    String? photoUrl,
    String? brand,
    double? pricePerUnit,
    double? purchasePrice,
    double? salePrice,
    bool? taxIncluded,
    String? hsnCode,
    String? unitType,
    String? secondaryUnit,
    double? conversionFactor,
    double? currentStock,
    bool? isActive,
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
      subType: subType ?? this.subType,
      variant: variant ?? this.variant,
      photoUrl: photoUrl ?? this.photoUrl,
      brand: brand ?? this.brand,
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

