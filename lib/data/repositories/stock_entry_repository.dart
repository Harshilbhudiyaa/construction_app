import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:construction_app/data/models/stock_entry_model.dart';
import 'package:construction_app/data/models/party_model.dart';
import 'package:construction_app/data/models/material_model.dart';

/// Repository managing simplified stock purchase records and supplier bills.
/// Works alongside InventoryRepository:
///   - StockEntryRepository handles the financial/purchase side
///   - InventoryRepository handles the physical stock quantity side
class StockEntryRepository extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<StockEntryModel> _entries = [];
  List<SupplierBill> _bills = [];
  bool _isLoading = true;

  List<StockEntryModel> get entries => _entries;
  List<SupplierBill> get bills => _bills;
  bool get isLoading => _isLoading;

  StreamSubscription? _entriesSub;
  StreamSubscription? _billsSub;

  StockEntryRepository() {
    _init();
  }

  void _init() {
    _entriesSub = _db
        .collection('stock_entries')
        .orderBy('entryDate', descending: true)
        .snapshots()
        .listen((snap) {
      try {
        _entries = snap.docs
            .map((d) => StockEntryModel.fromJson({...d.data(), 'id': d.id}))
            .toList();
      } catch (e) {
        debugPrint('StockEntryRepository: Error parsing entries: $e');
      }
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      debugPrint('StockEntryRepository entries stream error: $e');
      _isLoading = false;
      notifyListeners();
    });

    _billsSub = _db
        .collection('supplier_bills')
        .orderBy('billDate', descending: true)
        .snapshots()
        .listen((snap) {
      try {
        _bills = snap.docs
            .map((d) => SupplierBill.fromJson({...d.data(), 'id': d.id}))
            .toList();
      } catch (e) {
        debugPrint('StockEntryRepository: Error parsing bills: $e');
      }
      notifyListeners();
    }, onError: (e) => debugPrint('StockEntryRepository bills stream error: $e'));
  }

  // ── Direct Stock Entry ─────────────────────────────────────────────────────────

  Future<void> addEntry(StockEntryModel entry) async {
    final data = entry.toJson();
    data['createdAt'] = FieldValue.serverTimestamp();
    await _db.collection('stock_entries').doc(entry.id).set(data);
  }

  Future<void> updateEntryPayment(String entryId, double newPaidAmount) async {
    await _db.collection('stock_entries').doc(entryId).update({
      'paidAmount': newPaidAmount,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteEntry(String entryId) async {
    await _db.collection('stock_entries').doc(entryId).delete();
  }

  // ── Supplier Bill (multi-item) ─────────────────────────────────────────────────

  Future<void> addBill(SupplierBill bill) async {
    final billData = bill.toJson();
    billData['createdAt'] = FieldValue.serverTimestamp();
    await _db.collection('supplier_bills').doc(bill.id).set(billData);

    // Also save individual entries
    final batch = _db.batch();
    for (final item in bill.items) {
      final itemData = item.toJson();
      itemData['createdAt'] = FieldValue.serverTimestamp();
      batch.set(_db.collection('stock_entries').doc(item.id), itemData);
    }
    await batch.commit();
  }

  Future<void> updateBillPayment(String billId, double newPaidAmount) async {
    await _db.collection('supplier_bills').doc(billId).update({
      'paidAmount': newPaidAmount,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Queries ────────────────────────────────────────────────────────────────────

  List<StockEntryModel> getEntriesForSite(String siteId) =>
      _entries
          .where((e) => e.siteId == siteId)
          .toList()
        ..sort((a, b) => b.entryDate.compareTo(a.entryDate));

  List<StockEntryModel> getEntriesForMaterial(String materialId) =>
      _entries
          .where((e) => e.materialId == materialId && e.isInventoryItem)
          .toList()
        ..sort((a, b) => b.entryDate.compareTo(a.entryDate));

  List<StockEntryModel> getEntriesForSupplier(String supplierId) =>
      _entries
          .where((e) => e.supplierId == supplierId)
          .toList()
        ..sort((a, b) => b.entryDate.compareTo(a.entryDate));

  List<SupplierBill> getBillsForSupplier(String supplierId) =>
      _bills
          .where((b) => b.supplierId == supplierId)
          .toList()
        ..sort((a, b) => b.billDate.compareTo(a.billDate));

  List<StockEntryModel> getMiscExpensesForSite(String siteId) =>
      _entries
          .where((e) => e.siteId == siteId && !e.isInventoryItem)
          .toList()
        ..sort((a, b) => b.entryDate.compareTo(a.entryDate));

  // ── Aggregates ─────────────────────────────────────────────────────────────────

  double getTotalQuantityForMaterial(String materialId) => _entries
      .where((e) => e.materialId == materialId && e.isInventoryItem)
      .fold(0.0, (s, e) => s + e.quantity);

  double getAvgPriceForMaterial(String materialId) {
    final matEntries = _entries
        .where((e) => e.materialId == materialId && e.isInventoryItem)
        .toList();
    if (matEntries.isEmpty) return 0;
    final totalCost = matEntries.fold(0.0, (s, e) => s + e.totalAmount);
    final totalQty = matEntries.fold(0.0, (s, e) => s + e.quantity);
    return totalQty > 0 ? totalCost / totalQty : 0;
  }

  double getTotalPurchaseFromSupplier(String supplierId) => _entries
      .where((e) => e.supplierId == supplierId)
      .fold(0.0, (s, e) => s + e.totalAmount);

  double getTotalPaidToSupplier(String supplierId) => _entries
      .where((e) => e.supplierId == supplierId)
      .fold(0.0, (s, e) => s + e.paidAmount);

  double getPendingForSupplier(String supplierId) =>
      getTotalPurchaseFromSupplier(supplierId) -
      getTotalPaidToSupplier(supplierId);

  double getTotalMaterialValueForSite(String siteId) => _entries
      .where((e) => e.siteId == siteId && e.isInventoryItem)
      .fold(0.0, (s, e) => s + e.totalAmount);

  double getTotalPendingForSite(String siteId) => _entries
      .where((e) => e.siteId == siteId)
      .fold(0.0, (s, e) => s + e.pendingAmount);

  double get totalPendingAllSites =>
      _entries.fold(0.0, (s, e) => s + e.pendingAmount);

  Future<void> recordPaymentForSupplier({
    required String supplierId,
    required double amount,
  }) async {
    final pendingEntries = _entries
        .where((e) => e.supplierId == supplierId && e.pendingAmount > 0)
        .toList()
      ..sort((a, b) => a.entryDate.compareTo(b.entryDate)); // FIFO

    double remaining = amount;
    final batch = _db.batch();
    for (final e in pendingEntries) {
      if (remaining <= 0) break;
      final pay = remaining < e.pendingAmount ? remaining : e.pendingAmount;
      batch.update(_db.collection('stock_entries').doc(e.id), {
        'paidAmount': e.paidAmount + pay,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      remaining -= pay;
    }
    await batch.commit();
  }

  Map<String, Map<String, double>> getSupplierSummaries(
      List<PartyModel> suppliers) {
    final Map<String, Map<String, double>> result = {};
    return result;
  }

  double getStockValueForSupplier(
      String supplierId, List<ConstructionMaterial> materials) {
    final supplierMatIds = _entries
        .where((e) => e.supplierId == supplierId && e.materialId.isNotEmpty)
        .map((e) => e.materialId)
        .toSet();
    if (supplierMatIds.isEmpty) return 0;
    return materials
        .where((m) => supplierMatIds.contains(m.id))
        .fold(0.0, (sum, m) => sum + (m.currentStock * m.purchasePrice));
  }

  @override
  void dispose() {
    _entriesSub?.cancel();
    _billsSub?.cancel();
    super.dispose();
  }
}
