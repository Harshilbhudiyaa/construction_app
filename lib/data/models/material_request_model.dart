
enum RequestStatus {
  pending,
  approved,
  rejected,
  fulfilled;

  String get label => name[0].toUpperCase() + name.substring(1);
}

class MaterialRequestModel {
  final String id;
  final String materialId;
  final String materialName;
  final double quantity;
  final String unit;
  final String priority;
  final String siteId;
  final String purpose;
  final String? remarks;
  final RequestStatus status;
  final String requestedBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? approvedBy;

  MaterialRequestModel({
    required this.id,
    required this.materialId,
    required this.materialName,
    required this.quantity,
    required this.unit,
    required this.priority,
    required this.siteId,
    required this.purpose,
    this.remarks,
    this.status = RequestStatus.pending,
    required this.requestedBy,
    required this.createdAt,
    this.updatedAt,
    this.approvedBy,
  });

  MaterialRequestModel copyWith({
    String? id,
    String? materialId,
    String? materialName,
    double? quantity,
    String? unit,
    String? priority,
    String? siteId,
    String? purpose,
    String? remarks,
    RequestStatus? status,
    String? requestedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? approvedBy,
  }) {
    return MaterialRequestModel(
      id: id ?? this.id,
      materialId: materialId ?? this.materialId,
      materialName: materialName ?? this.materialName,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      priority: priority ?? this.priority,
      siteId: siteId ?? this.siteId,
      purpose: purpose ?? this.purpose,
      remarks: remarks ?? this.remarks,
      status: status ?? this.status,
      requestedBy: requestedBy ?? this.requestedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      approvedBy: approvedBy ?? this.approvedBy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'materialId': materialId,
      'materialName': materialName,
      'quantity': quantity,
      'unit': unit,
      'priority': priority,
      'siteId': siteId,
      'purpose': purpose,
      'remarks': remarks,
      'status': status.name,
      'requestedBy': requestedBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'approvedBy': approvedBy,
    };
  }

  factory MaterialRequestModel.fromJson(Map<String, dynamic> json) {
    return MaterialRequestModel(
      id: json['id'],
      materialId: json['materialId'],
      materialName: json['materialName'],
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'],
      priority: json['priority'],
      siteId: json['siteId'],
      purpose: json['purpose'],
      remarks: json['remarks'],
      status: RequestStatus.values.firstWhere((e) => e.name == json['status'], orElse: () => RequestStatus.pending),
      requestedBy: json['requestedBy'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      approvedBy: json['approvedBy'],
    );
  }
}

