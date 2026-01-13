/// Machine Management Model
class MachineModel {
  final String id;
  final String name;
  final String? photoUrl;
  final MachineType type;
  final String? assignedSiteId;
  final String? assignedSiteName;
  final NatureOfWork? natureOfWork;
  final MachineStatus status;
  final DateTime lastMaintenanceDate;
  final DateTime? nextMaintenanceDate;
  final String? operatorId;
  final String? operatorName;

  const MachineModel({
    required this.id,
    required this.name,
    this.photoUrl,
    required this.type,
    this.assignedSiteId,
    this.assignedSiteName,
    this.natureOfWork,
    this.status = MachineStatus.available,
    required this.lastMaintenanceDate,
    this.nextMaintenanceDate,
    this.operatorId,
    this.operatorName,
  });

  MachineModel copyWith({
    String? id,
    String? name,
    String? photoUrl,
    MachineType? type,
    String? assignedSiteId,
    String? assignedSiteName,
    NatureOfWork? natureOfWork,
    MachineStatus? status,
    DateTime? lastMaintenanceDate,
    DateTime? nextMaintenanceDate,
    String? operatorId,
    String? operatorName,
  }) {
    return MachineModel(
      id: id ?? this.id,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      type: type ?? this.type,
      assignedSiteId: assignedSiteId ?? this.assignedSiteId,
      assignedSiteName: assignedSiteName ?? this.assignedSiteName,
      natureOfWork: natureOfWork ?? this.natureOfWork,
      status: status ?? this.status,
      lastMaintenanceDate: lastMaintenanceDate ?? this.lastMaintenanceDate,
      nextMaintenanceDate: nextMaintenanceDate ?? this.nextMaintenanceDate,
      operatorId: operatorId ?? this.operatorId,
      operatorName: operatorName ?? this.operatorName,
    );
  }
}

enum MachineType {
  excavator('Excavator', '🚜'),
  crane('Crane', '🏗️'),
  mixer('Concrete Mixer', '🔄'),
  roller('Road Roller', '🚜'),
  loader('Loader', '🏋️'),
  bulldozer('Bulldozer', '🚜'),
  grader('Grader', '⚙️'),
  compactor('Compactor', '💪'),
  pumpTruck('Pump Truck', '🚚'),
  blockMachine('Block Machine', '🧱'),
  other('Other', '🔧');


  final String displayName;
  final String icon;
  const MachineType(this.displayName, this.icon);
}

enum NatureOfWork {
  earthwork('Earthwork', '🏔️'),
  lifting('Lifting', '⬆️'),
  mixing('Mixing', '🔄'),
  finishing('Finishing', '✨'),
  excavation('Excavation', '⛏️'),
  compaction('Compaction', '💪'),
  transportation('Transportation', '🚚'),
  demolition('Demolition', '💥'),
  blockProduction('Block Production', '🧱'),
  other('Other', '🔧');


  final String displayName;
  final String icon;
  const NatureOfWork(this.displayName, this.icon);
}

enum MachineStatus {
  available('Available', '✅'),
  inUse('In Use', '🔧'),
  maintenance('Under Maintenance', '🔨'),
  breakdown('Breakdown', '⚠️'),
  reserved('Reserved', '📅');

  final String displayName;
  final String icon;
  const MachineStatus(this.displayName, this.icon);
}
