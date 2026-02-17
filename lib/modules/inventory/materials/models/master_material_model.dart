import 'material_model.dart';

class MasterMaterial {
  final String id;
  final String name;
  final MaterialCategory category;
  final UnitType defaultUnit;
  final String subType;
  final String? customCategoryName;
  final String? photoUrl;
  final DateTime createdAt;

  MasterMaterial({
    required this.id,
    required this.name,
    required this.category,
    required this.defaultUnit,
    this.subType = 'General',
    this.customCategoryName,
    this.photoUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category.name,
      'defaultUnit': defaultUnit.name,
      'subType': subType,
      'customCategoryName': customCategoryName,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MasterMaterial.fromJson(Map<String, dynamic> json) {
    return MasterMaterial(
      id: json['id'],
      name: json['name'],
      category: MaterialCategory.values.byName(json['category']),
      defaultUnit: UnitType.values.byName(json['defaultUnit']),
      subType: json['subType'] ?? 'General',
      customCategoryName: json['customCategoryName'],
      photoUrl: json['photoUrl'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  static UnitType getAutoUnit(MaterialCategory category) {
    switch (category) {
      case MaterialCategory.sand:
        return UnitType.ton;
      case MaterialCategory.cement:
        return UnitType.bag;
      case MaterialCategory.steel:
        return UnitType.kg;
      case MaterialCategory.bricks:
        return UnitType.piece;
      case MaterialCategory.electrical:
      case MaterialCategory.plumbing:
        return UnitType.unit;
      case MaterialCategory.paint:
        return UnitType.liter;
      case MaterialCategory.tools:
        return UnitType.piece;
      default:
        return UnitType.unit;
    }
  }
}
