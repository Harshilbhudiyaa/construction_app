import 'package:construction_app/modules/inventory/materials/models/material_model.dart';

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
  
  final String materialName;
  final MaterialCategory category;
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
    required this.materialName,
    required this.category,
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
      materialName: materialName,
      category: category,
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
      'materialName': materialName,
      'category': category.name,
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
      id: json['id'],
      vehicleType: json['vehicleType'],
      vehicleNumber: json['vehicleNumber'],
      vehicleCapacity: json['vehicleCapacity'],
      transporterName: json['transporterName'],
      siteId: json['siteId'] ?? 'S-001',
      driverName: json['driverName'],
      driverMobile: json['driverMobile'],
      driverLicense: json['driverLicense'],
      materialName: json['materialName'],
      category: MaterialCategory.values.byName(json['category']),
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'],
      photoProofs: (json['photoProofs'] as List? ?? [])
          .map((e) => InwardPhotoProof.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      ratePerUnit: (json['ratePerUnit'] as num).toDouble(),
      transportCharges: (json['transportCharges'] as num).toDouble(),
      taxPercentage: (json['taxPercentage'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: InwardStatus.values.byName(json['status']),
      createdAt: DateTime.parse(json['createdAt']),
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
