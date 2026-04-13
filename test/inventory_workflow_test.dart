import 'package:construction_app/data/models/inward_movement_model.dart';
import 'package:construction_app/data/models/material_model.dart';
import 'package:construction_app/data/models/user_model.dart';
import 'package:construction_app/data/repositories/auth_repository.dart';
import 'package:construction_app/data/repositories/inventory_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('Inventory Workflow Integration Test', () {
    late InventoryRepository service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final auth = AuthRepository();
      await auth.initialization; // Ensure _loadSession is done
      await auth.login(
        userId: 'admin_test',
        userName: 'Test Admin',
        role: UserRole.admin,
      );
      service = InventoryRepository();
      
      // No need to await service.isLoading as it's a bool getter
    });

    test('Full Workflow: Inward -> Approval -> Stock Update', () async {
      // 1. Create Inward Log
      final log = InwardMovementModel(
        id: 'TEST-001',
        vehicleType: 'Truck',
        vehicleNumber: 'GJ01AB1234',
        vehicleCapacity: '10T',
        transporterName: 'Test Transporter',
        siteId: 'S-001',
        driverName: 'John Doe',
        driverMobile: '1234567890',
        driverLicense: 'LIC123',
        materialId: 'MAT-001',
        materialName: 'Ultratech Cement',
        category: 'Civil/Structural',
        quantity: 100,
        unit: 'bag',
        photoProofs: [],
        ratePerUnit: 350,
        transportCharges: 0,
        taxPercentage: 18,
        totalAmount: 41300,
        createdAt: DateTime.now(),
      );

      await service.saveInwardLog(log, recordedBy: 'Admin');
      expect(service.logs.length, 1);
      expect(service.logs.first.status, InwardStatus.pendingApproval);

      // Verify Initial Stock (from demo data in service)
      final initialStock = service.materials.firstWhere((m) => m.id == 'MAT-001').currentStock;
      expect(initialStock, 1250.0);

      // 2. Approve Log
      await service.approveInwardLog('TEST-001', 'Admin');
      
      // 3. Verify Stock Update
      final updatedStock = service.materials.firstWhere((m) => m.id == 'MAT-001').currentStock;
      expect(updatedStock, initialStock + 100);
      expect(service.logs.first.status, InwardStatus.approved);
    });

    test('Edit Pending Inward Log', () async {
      final log = InwardMovementModel(
        id: 'TEST-002',
        vehicleType: 'Truck',
        vehicleNumber: 'GJ01AB1234',
        vehicleCapacity: '10T',
        transporterName: 'Test Transporter',
        siteId: 'S-001',
        driverName: 'John Doe',
        driverMobile: '1234567890',
        driverLicense: 'LIC123',
        materialId: 'MAT-001',
        materialName: 'Ultratech Cement',
        category: 'Civil/Structural',
        quantity: 50,
        unit: 'bag',
        photoProofs: [],
        ratePerUnit: 350,
        transportCharges: 0,
        taxPercentage: 18,
        totalAmount: 20650,
        createdAt: DateTime.now(),
      );

      await service.saveInwardLog(log, recordedBy: 'Admin');
      
      // Change quantity to 75
      final editedLog = InwardMovementModel(
        id: log.id,
        vehicleType: log.vehicleType,
        vehicleNumber: log.vehicleNumber,
        vehicleCapacity: log.vehicleCapacity,
        transporterName: log.transporterName,
        siteId: log.siteId,
        driverName: log.driverName,
        driverMobile: log.driverMobile,
        driverLicense: log.driverLicense,
        materialId: log.materialId,
        materialName: log.materialName,
        category: log.category,
        quantity: 75, // Edited
        unit: log.unit,
        photoProofs: [],
        ratePerUnit: 350,
        transportCharges: 0,
        taxPercentage: 18,
        totalAmount: 30975,
        createdAt: log.createdAt,
      );
    

      await service.updateInwardLog(editedLog);
      expect(service.logs.first.quantity, 75);
      expect(service.transactions.first.quantity, 75);
    });

    test('Delete Pending Inward Log', () async {
       final log = InwardMovementModel(
        id: 'TEST-003',
        vehicleType: 'Truck',
        vehicleNumber: 'GJ01AB1234',
        vehicleCapacity: '10T',
        transporterName: 'Test Transporter',
        siteId: 'S-001',
        driverName: 'John Doe',
        driverMobile: '1234567890',
        driverLicense: 'LIC123',
        materialId: 'MAT-001',
        materialName: 'Ultratech Cement',
        category: 'Civil/Structural',
        quantity: 50,
        unit: 'bag',
        photoProofs: [],
        ratePerUnit: 350,
        transportCharges: 0,
        taxPercentage: 18,
        totalAmount: 20650,
        createdAt: DateTime.now(),
      );

      await service.saveInwardLog(log, recordedBy: 'Admin');
      expect(service.logs.length, 1);
      
      await service.deleteInwardLog('TEST-003');
      expect(service.logs.length, 0);
      expect(service.transactions.length, 0);
    });

    test('Reject Inward Log', () async {
       final log = InwardMovementModel(
        id: 'TEST-004',
        vehicleType: 'Truck',
        vehicleNumber: 'GJ01AB1234',
        vehicleCapacity: '10T',
        transporterName: 'Test Transporter',
        siteId: 'S-001',
        driverName: 'John Doe',
        driverMobile: '1234567890',
        driverLicense: 'LIC123',
        materialId: 'MAT-001',
        materialName: 'Ultratech Cement',
        category: 'Civil/Structural',
        quantity: 50,
        unit: 'bag',
        photoProofs: [],
        ratePerUnit: 350,
        transportCharges: 0,
        taxPercentage: 18,
        totalAmount: 20650,
        createdAt: DateTime.now(),
      );

      await service.saveInwardLog(log, recordedBy: 'Admin');
      final initialStock = service.materials.firstWhere((m) => m.id == 'MAT-001').currentStock;

      await service.rejectInwardLog('TEST-004', 'Admin', 'Bad quality');
      
      final postRejectStock = service.materials.firstWhere((m) => m.id == 'MAT-001').currentStock;
      expect(postRejectStock, initialStock); // No stock change
      expect(service.logs.first.status, InwardStatus.rejected);
    });
  });
}

