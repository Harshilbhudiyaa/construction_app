import 'package:flutter/foundation.dart';
import 'package:construction_app/data/repositories/inventory_repository.dart';
import 'package:construction_app/data/repositories/ledger_repository.dart';
import 'package:construction_app/data/repositories/payment_repository.dart';
import 'package:construction_app/data/repositories/site_repository.dart';
import 'package:construction_app/data/repositories/party_repository.dart';
import 'package:construction_app/data/models/inward_movement_model.dart';
import 'package:construction_app/data/models/ledger_entry_model.dart';
import 'package:construction_app/data/models/payment_model.dart';

class WorkflowService extends ChangeNotifier {
  final InventoryRepository inventoryRepo;
  final LedgerRepository ledgerRepo;
  final PaymentRepository paymentRepo;
  final SiteRepository siteRepo;
  final PartyRepository partyRepo;

  WorkflowService({
    required this.inventoryRepo,
    required this.ledgerRepo,
    required this.paymentRepo,
    required this.siteRepo,
    required this.partyRepo,
  });

  /// Approves an inward log and automatically creates a ledger entry for the supplier
  Future<void> approveInwardEntry(InwardMovementModel entry, {required String performedBy}) async {
    // 1. Approve in inventory (updates stock)
    await inventoryRepo.approveInwardLog(entry.id, performedBy);

    // 2. Resolve Party (Search for party by name)
    final partyName = entry.transporterName;
    String? resolvedPartyId;

    try {
      final matches = partyRepo.parties.where(
        (p) => p.name.toLowerCase().trim() == partyName.toLowerCase().trim()
      ).toList();

      if (matches.isNotEmpty) {
        resolvedPartyId = matches.first.id;
      }
    } catch (_) {}

    // Fallback if not found
    final partyId = resolvedPartyId ?? 'P-GENERIC';

    // 3. Create Ledger Credit Entry (we owe the supplier)
    final siteName = siteRepo.getSiteName(entry.siteId);

    final ledgerEntry = LedgerEntryModel(
      id: 'L-INW-${DateTime.now().millisecondsSinceEpoch}',
      partyId: partyId,
      partyName: partyName,
      siteId: entry.siteId,
      siteName: siteName,
      amount: entry.totalAmount,
      type: LedgerEntryType.credit,
      description: 'Inward: ${entry.materialName} (${entry.quantity} ${entry.unit})',
      date: DateTime.now(),
    );

    await ledgerRepo.addEntry(ledgerEntry);
  }

  /// Records a payment and automatically creates a ledger debit entry
  Future<void> recordPayment(PaymentModel payment) async {
    // 1. Save payment record
    await paymentRepo.addPayment(payment);

    // 2. Create Ledger Debit Entry (we reduce our debt)
    final ledgerEntry = LedgerEntryModel(
      id: 'L-PAY-${DateTime.now().millisecondsSinceEpoch}',
      partyId: payment.partyId,
      partyName: payment.partyName,
      siteId: payment.siteId,
      siteName: payment.siteName,
      amount: payment.amount,
      type: LedgerEntryType.debit,
      description: 'Payment: ${payment.type.name.toUpperCase()} - ${payment.remarks ?? ""}',
      date: payment.timestamp,
    );

    await ledgerRepo.addEntry(ledgerEntry);
  }

  /// Strict stock consumption with validation
  Future<void> consumeStock({
    required String materialId,
    required double quantity,
    required String siteId,
    String? remark,
    required String performedBy,
  }) async {
    final material = inventoryRepo.materials.firstWhere((m) => m.id == materialId);
    
    if (material.currentStock < quantity) {
      throw Exception('Insufficient Stock! Available: ${material.currentStock} ${material.unitType}');
    }

    await inventoryRepo.recordStockOut(
      materialId: materialId,
      quantity: quantity,
      siteId: siteId,
      remarks: remark,
      recordedBy: performedBy,
    );
  }
}
