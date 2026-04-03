import 'package:flutter_test/flutter_test.dart';
import 'package:construction_app/core/services/workflow_service.dart';
import 'package:construction_app/data/repositories/inventory_repository.dart';
import 'package:construction_app/data/repositories/auth_repository.dart';
import 'package:construction_app/data/repositories/ledger_repository.dart';
import 'package:construction_app/data/repositories/payment_repository.dart';
import 'package:construction_app/data/repositories/site_repository.dart';
import 'package:construction_app/data/repositories/party_repository.dart';
import 'package:construction_app/data/models/inward_movement_model.dart';
import 'package:construction_app/data/models/material_model.dart';
import 'package:construction_app/data/models/user_model.dart';
import 'package:construction_app/data/models/site_model.dart';
import 'package:construction_app/data/models/party_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('WorkflowService Integration Test', () {
    late InventoryRepository inventoryRepo;
    late LedgerRepository ledgerRepo;
    late PaymentRepository paymentRepo;
    late SiteRepository siteRepo;
    late PartyRepository partyRepo;
    late WorkflowService workflowService;

    setUp(() async {
      final auth = AuthRepository();
      await auth.initialization;
      await auth.login(
        userId: 'admin_001',
        userName: 'Nimesh Patel',
        role: UserRole.admin,
      );

      inventoryRepo = InventoryRepository()..initDemoData();
      ledgerRepo = LedgerRepository();
      paymentRepo = PaymentRepository();
      siteRepo = SiteRepository();
      partyRepo = PartyRepository();

      // Manually add data to avoid async race conditions in tests
      await siteRepo.addSite(SiteModel(
        id: 'S-001',
        name: 'Hillview Apartment',
        address: 'Sector 5',
        createdAt: DateTime.now(),
      ));

      await partyRepo.addParty(PartyModel(
        id: 'P-001',
        name: 'Express Logistic',
        category: PartyCategory.supplier,
        contactNumber: '000',
        address: 'Addr',
        createdAt: DateTime.now(),
      ));
      
      workflowService = WorkflowService(
        inventoryRepo: inventoryRepo,
        ledgerRepo: ledgerRepo,
        paymentRepo: paymentRepo,
        siteRepo: siteRepo,
        partyRepo: partyRepo,
      );
    });

    test('WorkflowService initializes and approves inward entry with ledger creation', () async {
      try {
        final log = InwardMovementModel(
          id: 'WF-TEST-001',
          vehicleType: 'Truck',
          vehicleNumber: 'IND-01',
          vehicleCapacity: '10T',
          transporterName: 'Express Logistic',
          siteId: 'S-001',
          driverName: 'Test Driver',
          driverMobile: '0000',
          driverLicense: 'DL-00',
          materialId: 'MAT-001',
          materialName: 'Cement',
          category: MaterialCategory.civilStructural,
          quantity: 100,
          unit: 'Bag',
          photoProofs: [],
          ratePerUnit: 400,
          transportCharges: 0,
          taxPercentage: 18,
          totalAmount: 47200,
          createdAt: DateTime.now(),
        );

        // Save to repo first
        await inventoryRepo.saveInwardLog(log, recordedBy: 'Tester');
        expect(inventoryRepo.logs.any((l) => l.id == 'WF-TEST-001'), isTrue);

        // Approve via WorkflowService
        await workflowService.approveInwardEntry(log, performedBy: 'Nimesh Patel');

        // Verify Approval
        expect(inventoryRepo.logs.first.status, InwardStatus.approved);
        expect(inventoryRepo.logs.first.approvedBy, 'Nimesh Patel');

        // Verify Ledger Entry
        expect(ledgerRepo.entries.any((e) => e.partyName == 'Express Logistic' && e.amount == 47200), isTrue);
        // Now resolves correctly to P-001 instead of MAT-001
        final entry = ledgerRepo.entries.firstWhere((e) => e.partyName == 'Express Logistic');
        expect(entry.partyId, 'P-001');
        expect(entry.description, contains('Inward: Cement'));
      } catch (e) {
        print('TEST ERROR: $e');
        rethrow;
      }
    });
  });
}
