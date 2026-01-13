/// Enhanced Inventory Detail Model
class InventoryDetailModel {
  final String id;
  final String materialName;
  final MaterialCategory category;
  final double totalQuantity;
  final double consumedQuantity;
  final String unit;
  final DateTime lastUpdatedDate;
  final String? lastUpdatedBy;
  final double? reorderLevel;
  final double? costPerUnit;
  final String? supplierId;
  final String? supplierName;
  final String? storageLocation;
  final Map<String, dynamic>? metadata;

  const InventoryDetailModel({
    required this.id,
    required this.materialName,
    required this.category,
    required this.totalQuantity,
    required this.consumedQuantity,
    required this.unit,
    required this.lastUpdatedDate,
    this.lastUpdatedBy,
    this.reorderLevel,
    this.costPerUnit,
    this.supplierId,
    this.supplierName,
    this.storageLocation,
    this.metadata,
  });

  double get remainingStock => totalQuantity - consumedQuantity;
  
  double get consumptionPercentage => 
      totalQuantity > 0 ? (consumedQuantity / totalQuantity) * 100 : 0;

  bool get isLowStock => 
      reorderLevel != null && remainingStock <= reorderLevel!;

  bool get isOutOfStock => remainingStock <= 0;

  StockStatus get stockStatus {
    if (isOutOfStock) return StockStatus.outOfStock;
    if (isLowStock) return StockStatus.lowStock;
    if (consumptionPercentage < 50) return StockStatus.adequate;
    return StockStatus.warning;
  }

  InventoryDetailModel copyWith({
    String? id,
    String? materialName,
    MaterialCategory? category,
    double? totalQuantity,
    double? consumedQuantity,
    String? unit,
    DateTime? lastUpdatedDate,
    String? lastUpdatedBy,
    double? reorderLevel,
    double? costPerUnit,
    String? supplierId,
    String? supplierName,
    String? storageLocation,
    Map<String, dynamic>? metadata,
  }) {
    return InventoryDetailModel(
      id: id ?? this.id,
      materialName: materialName ?? this.materialName,
      category: category ?? this.category,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      consumedQuantity: consumedQuantity ?? this.consumedQuantity,
      unit: unit ?? this.unit,
      lastUpdatedDate: lastUpdatedDate ?? this.lastUpdatedDate,
      lastUpdatedBy: lastUpdatedBy ?? this.lastUpdatedBy,
      reorderLevel: reorderLevel ?? this.reorderLevel,
      costPerUnit: costPerUnit ?? this.costPerUnit,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      storageLocation: storageLocation ?? this.storageLocation,
      metadata: metadata ?? this.metadata,
    );
  }
}

enum MaterialCategory {
  cement('Cement', '🏗️'),
  sand('Sand', '🏖️'),
  steel('Steel', '🔩'),
  bricks('Bricks', '🧱'),
  aggregate('Aggregate', '🪨'),
  timber('Timber', '🪵'),
  paint('Paint', '🎨'),
  electrical('Electrical', '💡'),
  plumbing('Plumbing', '🚰'),
  tiles('Tiles', '⬜'),
  glass('Glass', '🪟'),
  hardware('Hardware', '🔧'),
  other('Other Materials', '📦');

  final String displayName;
  final String icon;
  const MaterialCategory(this.displayName, this.icon);
}

enum StockStatus {
  adequate('Adequate Stock', '✅'),
  warning('Warning Level', '⚠️'),
  lowStock('Low Stock', '🔴'),
  outOfStock('Out of Stock', '❌');

  final String displayName;
  final String icon;
  const StockStatus(this.displayName, this.icon);
}
