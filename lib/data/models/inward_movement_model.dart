import 'package:construction_app/data/models/material_model.dart';

enum InwardStatus { pendingApproval, approved, rejected }

class InwardMovementModel {
  final String id;
  final String vehicleType;
  final String vehicleNumber;
  final String vehicleCapacity;
  final String transporterName;
  final String siteId;
  
  final String driverName;
  final String driverMobile;
  final String driverLicense;
  
  final String? materialId; // Specific ConstructionMaterial ID
  final String materialName;
  final double quantity;
  final String unit;
  
  final List<InwardPhotoProof> photoProofs;
  
  final double ratePerUnit;
  final double transportCharges;
  final double taxPercentage;
  final double totalAmount;
  
  final InwardStatus status;
  final DateTime createdAt;
  final String? approvedBy;
  final DateTime? approvedAt;
  final List<String> availableSizes;

  const InwardMovementModel({
    required this.id,
    required this.vehicleType,
    required this.vehicleNumber,
    required this.vehicleCapacity,
    required this.transporterName,
    required this.siteId,
    required this.driverName,
    required this.driverMobile,
    required this.driverLicense,
    this.materialId,
    required this.materialName,
    required this.quantity,
    required this.unit,
    required this.photoProofs,
    required this.ratePerUnit,
    required this.transportCharges,
    required this.taxPercentage,
    required this.totalAmount,
    this.status = InwardStatus.pendingApproval,
    required this.createdAt,
    this.approvedBy,
    this.approvedAt,
    this.availableSizes = const [],
  });

  double get subtotal => quantity * ratePerUnit;
  double get taxAmount => (subtotal + transportCharges) * (taxPercentage / 100);

  InwardMovementModel copyWith({
    InwardStatus? status,
    String? siteId,
    String? approvedBy,
    DateTime? approvedAt,
    List<String>? availableSizes,
    String? materialId,
  }) {
    return InwardMovementModel(
      id: id,
      vehicleType: vehicleType,
      vehicleNumber: vehicleNumber,
      vehicleCapacity: vehicleCapacity,
      transporterName: transporterName,
      siteId: siteId ?? this.siteId,
      driverName: driverName,
      driverMobile: driverMobile,
      driverLicense: driverLicense,
      materialId: materialId ?? this.materialId,
      materialName: materialName,
      quantity: quantity,
      unit: unit,
      photoProofs: photoProofs,
      ratePerUnit: ratePerUnit,
      transportCharges: transportCharges,
      taxPercentage: taxPercentage,
      totalAmount: totalAmount,
      status: status ?? this.status,
      createdAt: createdAt,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      availableSizes: availableSizes ?? this.availableSizes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleType': vehicleType,
      'vehicleNumber': vehicleNumber,
      'vehicleCapacity': vehicleCapacity,
      'transporterName': transporterName,
      'siteId': siteId,
      'driverName': driverName,
      'driverMobile': driverMobile,
      'driverLicense': driverLicense,
      'materialId': materialId,
      'materialName': materialName,
      'quantity': quantity,
      'unit': unit,
      'photoProofs': photoProofs.map((e) => e.toJson()).toList(),
      'ratePerUnit': ratePerUnit,
      'transportCharges': transportCharges,
      'taxPercentage': taxPercentage,
      'totalAmount': totalAmount,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'approvedBy': approvedBy,
      'approvedAt': approvedAt?.toIso8601String(),
      'availableSizes': availableSizes,
    };
  }

  factory InwardMovementModel.fromJson(Map<String, dynamic> json) {
    return InwardMovementModel(
      id: json['id'] ?? '',
      vehicleType: json['vehicleType'] ?? '',
      vehicleNumber: json['vehicleNumber'] ?? '',
      vehicleCapacity: json['vehicleCapacity'] ?? '',
      transporterName: json['transporterName'] ?? '',
      siteId: json['siteId'] ?? 'S-001',
      driverName: json['driverName'] ?? '',
      driverMobile: json['driverMobile'] ?? '',
      driverLicense: json['driverLicense'] ?? '',
      materialId: json['materialId'], // Can be null for old logs
      materialName: json['materialName'] ?? 'Unknown Material',
      quantity: (json['quantity'] as num? ?? 0).toDouble(),
      unit: json['unit'] ?? 'unit',
      photoProofs: (json['photoProofs'] as List? ?? [])
          .map((e) => InwardPhotoProof.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      ratePerUnit: (json['ratePerUnit'] as num? ?? 0).toDouble(),
      transportCharges: (json['transportCharges'] as num? ?? 0).toDouble(),
      taxPercentage: (json['taxPercentage'] as num? ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] as num? ?? 0).toDouble(),
      status: InwardStatus.values.byName(json['status'] ?? 'pendingApproval'),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      approvedBy: json['approvedBy'],
      approvedAt: json['approvedAt'] != null ? DateTime.parse(json['approvedAt']) : null,
      availableSizes: List<String>.from(json['availableSizes'] ?? []),
    );
  }
}

class InwardPhotoProof {
  final String photoUrl;
  final String stage; // Departure, Arrival, Bill
  final DateTime capturedAt;
  final String locationTag;

  const InwardPhotoProof({
    required this.photoUrl,
    required this.stage,
    required this.capturedAt,
    required this.locationTag,
  });

  Map<String, dynamic> toJson() {
    return {
      'photoUrl': photoUrl,
      'stage': stage,
      'capturedAt': capturedAt.toIso8601String(),
      'locationTag': locationTag,
    };
  }

  factory InwardPhotoProof.fromJson(Map<String, dynamic> json) {
    return InwardPhotoProof(
      photoUrl: json['photoUrl'],
      stage: json['stage'],
      capturedAt: DateTime.parse(json['capturedAt']),
      locationTag: json['locationTag'],
    );
  }
}

