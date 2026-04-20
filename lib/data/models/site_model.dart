import 'package:construction_app/core/utils/date_parser.dart';

enum SiteStatus {
  active,
  onHold,
  completed;

  String get displayName {
    switch (this) {
      case SiteStatus.active:    return 'Active';
      case SiteStatus.onHold:   return 'On Hold';
      case SiteStatus.completed: return 'Completed';
    }
  }
}

class SiteModel {
  final String id;
  final String name;
  final String? address;
  final String? clientName;
  final DateTime? startDate;
  final DateTime? expectedEndDate;
  final SiteStatus status;
  final bool hasBudget;
  final double? budgetAmount;
  final DateTime createdAt;

  SiteModel({
    required this.id,
    required this.name,
    this.address,
    this.clientName,
    this.startDate,
    this.expectedEndDate,
    this.status = SiteStatus.active,
    this.hasBudget = false,
    this.budgetAmount,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'clientName': clientName,
      'startDate': startDate?.toIso8601String(),
      'expectedEndDate': expectedEndDate?.toIso8601String(),
      'status': status.name,
      'hasBudget': hasBudget,
      'budgetAmount': budgetAmount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SiteModel.fromJson(Map<String, dynamic> json) {
    SiteStatus status;
    try {
      status = SiteStatus.values.byName(json['status'] ?? 'active');
    } catch (_) {
      status = SiteStatus.active;
    }
    return SiteModel(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      clientName: json['clientName'],
      startDate: DateParser.parseNullable(json['startDate']),
      expectedEndDate: DateParser.parseNullable(json['expectedEndDate']),
      status: status,
      hasBudget: json['hasBudget'] ?? false,
      budgetAmount: (json['budgetAmount'] as num?)?.toDouble(),
      createdAt: DateParser.parse(json['createdAt']),
    );
  }

  SiteModel copyWith({
    String? name,
    String? address,
    String? clientName,
    DateTime? startDate,
    DateTime? expectedEndDate,
    SiteStatus? status,
    bool? hasBudget,
    double? budgetAmount,
  }) {
    return SiteModel(
      id: id,
      name: name ?? this.name,
      address: address ?? this.address,
      clientName: clientName ?? this.clientName,
      startDate: startDate ?? this.startDate,
      expectedEndDate: expectedEndDate ?? this.expectedEndDate,
      status: status ?? this.status,
      hasBudget: hasBudget ?? this.hasBudget,
      budgetAmount: budgetAmount ?? this.budgetAmount,
      createdAt: createdAt,
    );
  }
}
