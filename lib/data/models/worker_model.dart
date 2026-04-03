enum WorkerOccupation {
  helper,
  mason,
  carpenter,
  electrician,
  engineer,
  supervisor,
  plumber,
  painter,
  other;

  String get displayName {
    switch (this) {
      case WorkerOccupation.helper:      return 'Helper';
      case WorkerOccupation.mason:       return 'Mason';
      case WorkerOccupation.carpenter:   return 'Carpenter';
      case WorkerOccupation.electrician: return 'Electrician';
      case WorkerOccupation.engineer:    return 'Engineer';
      case WorkerOccupation.supervisor:  return 'Supervisor';
      case WorkerOccupation.plumber:     return 'Plumber';
      case WorkerOccupation.painter:     return 'Painter';
      case WorkerOccupation.other:       return 'Other';
    }
  }
}

enum SalaryType {
  daily,
  monthly;

  String get displayName {
    switch (this) {
      case SalaryType.daily:   return 'Daily Rate';
      case SalaryType.monthly: return 'Monthly';
    }
  }
}

enum AttendanceStatus {
  present,
  absent,
  halfDay;

  String get displayName {
    switch (this) {
      case AttendanceStatus.present:  return 'Present';
      case AttendanceStatus.absent:   return 'Absent';
      case AttendanceStatus.halfDay:  return 'Half Day';
    }
  }

  /// Effective days for salary calculation
  double get salaryFactor {
    switch (this) {
      case AttendanceStatus.present:  return 1.0;
      case AttendanceStatus.absent:   return 0.0;
      case AttendanceStatus.halfDay:  return 0.5;
    }
  }
}

class AttendanceRecord {
  final String id;
  final String workerId;
  final DateTime date;
  final AttendanceStatus status;
  final String? remarks;

  AttendanceRecord({
    required this.id,
    required this.workerId,
    required this.date,
    required this.status,
    this.remarks,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'workerId': workerId,
    'date': date.toIso8601String(),
    'status': status.name,
    'remarks': remarks,
  };

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) =>
      AttendanceRecord(
        id: json['id'],
        workerId: json['workerId'],
        date: DateTime.parse(json['date']),
        status: AttendanceStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => AttendanceStatus.present,
        ),
        remarks: json['remarks'],
      );
}

class WorkerAdvance {
  final String id;
  final String workerId;
  final double amount;
  final DateTime date;
  final String? remarks;
  final String paidBy;

  WorkerAdvance({
    required this.id,
    required this.workerId,
    required this.amount,
    required this.date,
    this.remarks,
    required this.paidBy,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'workerId': workerId,
    'amount': amount,
    'date': date.toIso8601String(),
    'remarks': remarks,
    'paidBy': paidBy,
  };

  factory WorkerAdvance.fromJson(Map<String, dynamic> json) => WorkerAdvance(
    id: json['id'],
    workerId: json['workerId'],
    amount: (json['amount'] as num).toDouble(),
    date: DateTime.parse(json['date']),
    remarks: json['remarks'],
    paidBy: json['paidBy'] ?? 'Admin',
  );
}

class WorkerModel {
  final String id;
  final String siteId;
  final String name;
  final String? phone;
  final WorkerOccupation occupation;
  final SalaryType salaryType;
  final double salaryAmount; // daily rate OR monthly salary
  final String? customOccupation;
  final bool isActive;
  final DateTime createdAt;

  WorkerModel({
    required this.id,
    required this.siteId,
    required this.name,
    this.phone,
    required this.occupation,
    required this.salaryType,
    required this.salaryAmount,
    this.customOccupation,
    this.isActive = true,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'siteId': siteId,
    'name': name,
    'phone': phone,
    'occupation': occupation.name,
    'salaryType': salaryType.name,
    'salaryAmount': salaryAmount,
    'customOccupation': customOccupation,
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
  };

  factory WorkerModel.fromJson(Map<String, dynamic> json) {
    WorkerOccupation occ;
    try {
      occ = WorkerOccupation.values.byName(json['occupation'] ?? 'other');
    } catch (_) {
      occ = WorkerOccupation.other;
    }
    SalaryType st;
    try {
      st = SalaryType.values.byName(json['salaryType'] ?? 'daily');
    } catch (_) {
      st = SalaryType.daily;
    }
    return WorkerModel(
      id: json['id'],
      siteId: json['siteId'] ?? '',
      name: json['name'],
      phone: json['phone'],
      occupation: occ,
      salaryType: st,
      salaryAmount: (json['salaryAmount'] as num).toDouble(),
      customOccupation: json['customOccupation'],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  WorkerModel copyWith({
    String? name,
    String? phone,
    WorkerOccupation? occupation,
    SalaryType? salaryType,
    double? salaryAmount,
    String? customOccupation,
    bool? isActive,
  }) => WorkerModel(
    id: id,
    siteId: siteId,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    occupation: occupation ?? this.occupation,
    salaryType: salaryType ?? this.salaryType,
    salaryAmount: salaryAmount ?? this.salaryAmount,
    customOccupation: customOccupation ?? this.customOccupation,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt,
  );
}
