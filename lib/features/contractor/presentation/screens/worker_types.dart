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

String statusLabel(WorkerStatus s) => s == WorkerStatus.active ? 'Active' : 'Inactive';

class Worker {
  final String id;
  final String name;
  final String phone;
  final String skill; // Mason / Helper / Electrician etc
  final WorkerShift shift;
  final PayRateType rateType;
  final num rateAmount;
  final WorkerStatus status;
  final List<String> assignedWorkTypes; // work type list

  const Worker({
    required this.id,
    required this.name,
    required this.phone,
    required this.skill,
    required this.shift,
    required this.rateType,
    required this.rateAmount,
    required this.status,
    required this.assignedWorkTypes,
  });

  Worker copyWith({
    String? id,
    String? name,
    String? phone,
    String? skill,
    WorkerShift? shift,
    PayRateType? rateType,
    num? rateAmount,
    WorkerStatus? status,
    List<String>? assignedWorkTypes,
  }) {
    return Worker(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      skill: skill ?? this.skill,
      shift: shift ?? this.shift,
      rateType: rateType ?? this.rateType,
      rateAmount: rateAmount ?? this.rateAmount,
      status: status ?? this.status,
      assignedWorkTypes: assignedWorkTypes ?? this.assignedWorkTypes,
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
