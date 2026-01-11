/// Tools & Equipment Management Model
class ToolModel {
  final String id;
  final String name;
  final String? photoUrl;
  final ToolType type;
  final String usagePurpose;
  final String? assignedEngineerId;
  final String? assignedEngineerName;
  final String? assignedSiteId;
  final String? assignedSiteName;
  final int quantity;
  final int availableQuantity;
  final ToolCondition condition;
  final DateTime lastInspectionDate;

  const ToolModel({
    required this.id,
    required this.name,
    this.photoUrl,
    required this.type,
    required this.usagePurpose,
    this.assignedEngineerId,
    this.assignedEngineerName,
    this.assignedSiteId,
    this.assignedSiteName,
    required this.quantity,
    required this.availableQuantity,
    this.condition = ToolCondition.good,
    required this.lastInspectionDate,
  });

  int get inUseQuantity => quantity - availableQuantity;

  ToolModel copyWith({
    String? id,
    String? name,
    String? photoUrl,
    ToolType? type,
    String? usagePurpose,
    String? assignedEngineerId,
    String? assignedEngineerName,
    String? assignedSiteId,
    String? assignedSiteName,
    int? quantity,
    int? availableQuantity,
    ToolCondition? condition,
    DateTime? lastInspectionDate,
  }) {
    return ToolModel(
      id: id ?? this.id,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      type: type ?? this.type,
      usagePurpose: usagePurpose ?? this.usagePurpose,
      assignedEngineerId: assignedEngineerId ?? this.assignedEngineerId,
      assignedEngineerName: assignedEngineerName ?? this.assignedEngineerName,
      assignedSiteId: assignedSiteId ?? this.assignedSiteId,
      assignedSiteName: assignedSiteName ?? this.assignedSiteName,
      quantity: quantity ?? this.quantity,
      availableQuantity: availableQuantity ?? this.availableQuantity,
      condition: condition ?? this.condition,
      lastInspectionDate: lastInspectionDate ?? this.lastInspectionDate,
    );
  }
}

enum ToolType {
  powerTool('Power Tool', '⚡'),
  handTool('Hand Tool', '🔨'),
  measuringTool('Measuring Tool', '📏'),
  safetyEquipment('Safety Equipment', '🦺'),
  ladderScaffold('Ladder & Scaffold', '🪜'),
  cuttingTool('Cutting Tool', '✂️'),
  weldingEquipment('Welding Equipment', '🔥'),
  paintingTool('Painting Tool', '🎨'),
  electricalTool('Electrical Tool', '💡'),
  plumbingTool('Plumbing Tool', '🚰'),
  other('Other', '🔧');

  final String displayName;
  final String icon;
  const ToolType(this.displayName, this.icon);
}

enum ToolCondition {
  excellent('Excellent', '⭐'),
  good('Good', '✅'),
  fair('Fair', '⚠️'),
  poor('Poor', '❌'),
  needsRepair('Needs Repair', '🔨');

  final String displayName;
  final String icon;
  const ToolCondition(this.displayName, this.icon);
}
