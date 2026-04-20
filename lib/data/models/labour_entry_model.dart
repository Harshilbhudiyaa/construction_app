import 'package:construction_app/core/utils/date_parser.dart';

enum LabourWorkType {
  fixedContract,
  perSqFt,
  perDay,
  perUnit,
}

extension LabourWorkTypeExtension on LabourWorkType {
  String get displayName {
    switch (this) {
      case LabourWorkType.fixedContract:
        return 'Fixed Contract';
      case LabourWorkType.perSqFt:
        return 'Per Sq.Ft';
      case LabourWorkType.perDay:
        return 'Per Day';
      case LabourWorkType.perUnit:
        return 'Per Unit';
    }
  }

  String get unitLabel {
    switch (this) {
      case LabourWorkType.fixedContract:
        return 'Lump Sum';
      case LabourWorkType.perSqFt:
        return 'Sq.Ft';
      case LabourWorkType.perDay:
        return 'Days';
      case LabourWorkType.perUnit:
        return 'Units';
    }
  }
}

enum LabourStatus {
  ongoing,
  completed,
  settled,
}

extension LabourStatusExtension on LabourStatus {
  String get displayName {
    switch (this) {
      case LabourStatus.ongoing:
        return 'Ongoing';
      case LabourStatus.completed:
        return 'Completed';
      case LabourStatus.settled:
        return 'Settled';
    }
  }
}

/// A single advance payment record for a labour entry.
class LabourAdvancePayment {
  final String id;
  final double amount;
  final DateTime date;
  final String? remarks;
  final String paidBy;

  LabourAdvancePayment({
    required this.id,
    required this.amount,
    required this.date,
    this.remarks,
    required this.paidBy,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'date': date.toIso8601String(),
        'remarks': remarks,
        'paidBy': paidBy,
      };

  factory LabourAdvancePayment.fromJson(Map<String, dynamic> json) =>
      LabourAdvancePayment(
        id: json['id'] as String,
        amount: (json['amount'] as num).toDouble(),
        date: DateParser.parse(json['date']),
        remarks: json['remarks'] as String?,
        paidBy: json['paidBy'] as String? ?? 'Unknown',
      );
}

class LabourEntryModel {
  final String id;

  // Party Info
  final String partyId;
  final String partyName;
  final String? partyContact;

  // Site Info
  final String siteId;
  final String siteName;

  // Work Details
  final LabourWorkType workType;
  final String workDescription;

  /// For perSqFt / perDay / perUnit types — the measurable quantity
  final double? workQuantity;

  /// Rate per unit (per sqft / per day / per unit / or total for fixed)
  final double ratePerUnit;

  /// Total contract amount (computed = workQuantity * ratePerUnit, or manually entered for fixed)
  final double totalContractAmount;

  // Payment Tracking
  final List<LabourAdvancePayment> advancePayments;

  /// Final settlement amount (agreed final amt after deductions, if any)
  final double? finalSettlementAmount;

  final LabourStatus status;

  // Timeline
  final DateTime startDate;
  final DateTime? completionDate;
  final DateTime? settledDate;

  // Meta
  final String createdBy;
  final DateTime createdAt;
  final String? notes;

  LabourEntryModel({
    required this.id,
    required this.partyId,
    required this.partyName,
    this.partyContact,
    required this.siteId,
    required this.siteName,
    required this.workType,
    required this.workDescription,
    this.workQuantity,
    required this.ratePerUnit,
    required this.totalContractAmount,
    this.advancePayments = const [],
    this.finalSettlementAmount,
    this.status = LabourStatus.ongoing,
    required this.startDate,
    this.completionDate,
    this.settledDate,
    required this.createdBy,
    required this.createdAt,
    this.notes,
  });

  // ── Derived Getters ────────────────────────────────────────────────────────

  /// Sum of all advance payments
  double get totalAdvancePaid =>
      advancePayments.fold(0.0, (sum, p) => sum + p.amount);

  /// Remaining amount after advance and final settlement
  double get pendingAmount {
    final settled = finalSettlementAmount ?? 0.0;
    return totalContractAmount - totalAdvancePaid - settled;
  }

  bool get isFullySettled => status == LabourStatus.settled;

  bool get needsSettlement =>
      status == LabourStatus.completed && pendingAmount > 0;

  // ── Serialization ──────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'id': id,
        'partyId': partyId,
        'partyName': partyName,
        'partyContact': partyContact,
        'siteId': siteId,
        'siteName': siteName,
        'workType': workType.name,
        'workDescription': workDescription,
        'workQuantity': workQuantity,
        'ratePerUnit': ratePerUnit,
        'totalContractAmount': totalContractAmount,
        'advancePayments':
            advancePayments.map((p) => p.toJson()).toList(),
        'finalSettlementAmount': finalSettlementAmount,
        'status': status.name,
        'startDate': startDate.toIso8601String(),
        'completionDate': completionDate?.toIso8601String(),
        'settledDate': settledDate?.toIso8601String(),
        'createdBy': createdBy,
        'createdAt': createdAt.toIso8601String(),
        'notes': notes,
      };

  factory LabourEntryModel.fromJson(Map<String, dynamic> json) {
    LabourWorkType workType;
    try {
      workType = LabourWorkType.values
          .firstWhere((e) => e.name == json['workType']);
    } catch (_) {
      workType = LabourWorkType.fixedContract;
    }

    LabourStatus status;
    try {
      status =
          LabourStatus.values.firstWhere((e) => e.name == json['status']);
    } catch (_) {
      status = LabourStatus.ongoing;
    }

    return LabourEntryModel(
      id: json['id'] as String,
      partyId: json['partyId'] as String,
      partyName: json['partyName'] as String,
      partyContact: json['partyContact'] as String?,
      siteId: json['siteId'] as String,
      siteName: json['siteName'] as String,
      workType: workType,
      workDescription: json['workDescription'] as String,
      workQuantity: (json['workQuantity'] as num?)?.toDouble(),
      ratePerUnit: (json['ratePerUnit'] as num).toDouble(),
      totalContractAmount: (json['totalContractAmount'] as num).toDouble(),
      advancePayments: (json['advancePayments'] as List? ?? [])
          .map<LabourAdvancePayment>((e) =>
              LabourAdvancePayment.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      finalSettlementAmount: (json['finalSettlementAmount'] as num?)?.toDouble(),
      status: status,
      startDate: DateParser.parse(json['startDate']),
      completionDate: DateParser.parseNullable(json['completionDate']),
      settledDate: DateParser.parseNullable(json['settledDate']),
      createdBy: json['createdBy'] as String? ?? 'Unknown',
      createdAt: DateParser.parse(json['createdAt']),
      notes: json['notes'] as String?,
    );
  }

  LabourEntryModel copyWith({
    String? partyId,
    String? partyName,
    String? partyContact,
    String? siteId,
    String? siteName,
    LabourWorkType? workType,
    String? workDescription,
    double? workQuantity,
    double? ratePerUnit,
    double? totalContractAmount,
    List<LabourAdvancePayment>? advancePayments,
    double? finalSettlementAmount,
    LabourStatus? status,
    DateTime? startDate,
    DateTime? completionDate,
    DateTime? settledDate,
    String? notes,
  }) {
    return LabourEntryModel(
      id: id,
      partyId: partyId ?? this.partyId,
      partyName: partyName ?? this.partyName,
      partyContact: partyContact ?? this.partyContact,
      siteId: siteId ?? this.siteId,
      siteName: siteName ?? this.siteName,
      workType: workType ?? this.workType,
      workDescription: workDescription ?? this.workDescription,
      workQuantity: workQuantity ?? this.workQuantity,
      ratePerUnit: ratePerUnit ?? this.ratePerUnit,
      totalContractAmount: totalContractAmount ?? this.totalContractAmount,
      advancePayments: advancePayments ?? this.advancePayments,
      finalSettlementAmount:
          finalSettlementAmount ?? this.finalSettlementAmount,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      completionDate: completionDate ?? this.completionDate,
      settledDate: settledDate ?? this.settledDate,
      createdBy: createdBy,
      createdAt: createdAt,
      notes: notes ?? this.notes,
    );
  }
}
