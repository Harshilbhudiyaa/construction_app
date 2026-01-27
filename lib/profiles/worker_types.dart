import 'package:flutter/material.dart';

enum WorkerShift { day, night }

enum PayRateType { perDay, perHour, perBlock }

enum WorkerStatus { active, inactive }

String shiftLabel(WorkerShift s) => s == WorkerShift.day ? 'Day' : 'Night';
String rateTypeLabel(PayRateType t) {
  switch (t) {
    case PayRateType.perDay:
      return 'Per Day';
    case PayRateType.perHour:
      return 'Per Hour';
    case PayRateType.perBlock:
      return 'Per Block';
  }
}

String statusLabel(WorkerStatus s) =>
    s == WorkerStatus.active ? 'Active' : 'Inactive';

class WorkerPermissionSet {
  final bool workSessionLogging;
  final bool historyViewing;
  final bool earningsViewing;
  final bool profileEditing;

  const WorkerPermissionSet({
    this.workSessionLogging = true,
    this.historyViewing = true,
    this.earningsViewing = true,
    this.profileEditing = true,
  });

  WorkerPermissionSet copyWith({
    bool? workSessionLogging,
    bool? historyViewing,
    bool? earningsViewing,
    bool? profileEditing,
  }) {
    return WorkerPermissionSet(
      workSessionLogging: workSessionLogging ?? this.workSessionLogging,
      historyViewing: historyViewing ?? this.historyViewing,
      earningsViewing: earningsViewing ?? this.earningsViewing,
      profileEditing: profileEditing ?? this.profileEditing,
    );
  }

  Map<String, dynamic> toJson() => {
        'workSessionLogging': workSessionLogging,
        'historyViewing': historyViewing,
        'earningsViewing': earningsViewing,
        'profileEditing': profileEditing,
      };

  factory WorkerPermissionSet.fromJson(Map<String, dynamic> json) =>
      WorkerPermissionSet(
        workSessionLogging: json['workSessionLogging'] ?? true,
        historyViewing: json['historyViewing'] ?? true,
        earningsViewing: json['earningsViewing'] ?? true,
        profileEditing: json['profileEditing'] ?? true,
      );

  bool get hasAnyPermission =>
      workSessionLogging || historyViewing || earningsViewing || profileEditing;
}

class Worker {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String skill; // Mason / Helper / Electrician etc
  final WorkerShift shift;
  final PayRateType rateType;
  final num rateAmount;
  final WorkerStatus status;
  final String? photoUrl;
  final List<String> assignedWorkTypes; // work type list
  final String? assignedSite;
  final String? siteId;
  final bool isActive;
  final WorkerPermissionSet permissions;

  const Worker({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.skill,
    required this.shift,
    required this.rateType,
    required this.rateAmount,
    required this.status,
    this.photoUrl,
    required this.assignedWorkTypes,
    this.assignedSite,
    this.siteId,
    this.isActive = true,
    this.permissions = const WorkerPermissionSet(),
  });

  Worker copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? skill,
    WorkerShift? shift,
    PayRateType? rateType,
    num? rateAmount,
    WorkerStatus? status,
    String? photoUrl,
    List<String>? assignedWorkTypes,
    String? assignedSite,
    String? siteId,
    bool? isActive,
    WorkerPermissionSet? permissions,
  }) {
    return Worker(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      skill: skill ?? this.skill,
      shift: shift ?? this.shift,
      rateType: rateType ?? this.rateType,
      rateAmount: rateAmount ?? this.rateAmount,
      status: status ?? this.status,
      photoUrl: photoUrl ?? this.photoUrl,
      assignedWorkTypes: assignedWorkTypes ?? this.assignedWorkTypes,
      assignedSite: assignedSite ?? this.assignedSite,
      siteId: siteId ?? this.siteId,
      isActive: isActive ?? this.isActive,
      permissions: permissions ?? this.permissions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'skill': skill,
      'shift': shift.name,
      'rateType': rateType.name,
      'rateAmount': rateAmount,
      'status': status.name,
      'photoUrl': photoUrl,
      'assignedWorkTypes': assignedWorkTypes,
      'assignedSite': assignedSite,
      'siteId': siteId,
      'isActive': isActive,
      'permissions': permissions.toJson(),
    };
  }

  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      skill: json['skill'],
      shift: WorkerShift.values.byName(json['shift']),
      rateType: PayRateType.values.byName(json['rateType']),
      rateAmount: json['rateAmount'],
      status: WorkerStatus.values.byName(json['status']),
      photoUrl: json['photoUrl'],
      assignedWorkTypes: List<String>.from(json['assignedWorkTypes'] ?? []),
      assignedSite: json['assignedSite'],
      siteId: json['siteId'],
      isActive: json['isActive'] ?? true,
      permissions: WorkerPermissionSet.fromJson(json['permissions']),
    );
  }
}

// Demo data (UI-only)
const kWorkTypes = <String>[
  'Brick / Block Work',
  'Concrete Work',
  'Electrical',
  'Plumbing',
  'Carpentry',
  'Painting',
  'Excavation',
  'General Labor',
];

const kSkills = <String>[
  'Mason',
  'Helper',
  'Electrician',
  'Plumber',
  'Carpenter',
  'Painter',
  'Operator',
];

Color statusColor(BuildContext context, WorkerStatus s) {
  final cs = Theme.of(context).colorScheme;
  return s == WorkerStatus.active ? cs.primary : cs.onSurfaceVariant;
}
