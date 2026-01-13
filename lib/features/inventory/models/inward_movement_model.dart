import 'inventory_detail_model.dart';

enum InwardStatus { pendingApproval, approved, rejected }

class InwardMovementModel {
  final String id;
  final String vehicleType;
  final String vehicleNumber;
  final String vehicleCapacity;
  final String transporterName;
  
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

  const InwardMovementModel({
    required this.id,
    required this.vehicleType,
    required this.vehicleNumber,
    required this.vehicleCapacity,
    required this.transporterName,
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
  });

  double get subtotal => quantity * ratePerUnit;
  double get taxAmount => (subtotal + transportCharges) * (taxPercentage / 100);

  InwardMovementModel copyWith({
    InwardStatus? status,
    String? approvedBy,
    DateTime? approvedAt,
  }) {
    return InwardMovementModel(
      id: id,
      vehicleType: vehicleType,
      vehicleNumber: vehicleNumber,
      vehicleCapacity: vehicleCapacity,
      transporterName: transporterName,
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
}
