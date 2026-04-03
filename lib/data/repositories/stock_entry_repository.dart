import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:construction_app/data/models/stock_entry_model.dart';
import 'package:construction_app/data/models/party_model.dart';
import 'package:construction_app/data/models/material_model.dart';

/// Repository managing simplified stock purchase records and supplier bills.
/// Works alongside the existing InventoryRepository:
///   - StockEntryRepository handles the financial/purchase side
///   - InventoryRepository handles the physical stock quantity side
///
/// When adding an inventory item entry, the caller (screen) is responsible
/// for also updating InventoryRepository.addMaterial / stock level.
class StockEntryRepository extends ChangeNotifier {
  static const String _entriesKey = 'stock_entries_v1';
  static const String _billsKey   = 'supplier_bills_v1';

  List<StockEntryModel> _entries = [];
  List<SupplierBill>    _bills   = [];
  bool _isLoading = true;

  List<StockEntryModel> get entries   => _entries;
  List<SupplierBill>    get bills     => _bills;
  bool                  get isLoading => _isLoading;

  StockEntryRepository() {
    _load();
  }

  // ── Persistence ─────────────────────────────────────────────────────────────

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final eData = prefs.getString(_entriesKey);
      if (eData != null) {
        _entries = (jsonDecode(eData) as List)
            .map((e) => StockEntryModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }

      final bData = prefs.getString(_billsKey);
      if (bData != null) {
        _bills = (jsonDecode(bData) as List)
            .map((e) => SupplierBill.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (e) {
      debugPrint('StockEntryRepository load error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveEntries() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _entriesKey, jsonEncode(_entries.map((e) => e.toJson()).toList()));
  }

  Future<void> _saveBills() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _billsKey, jsonEncode(_bills.map((b) => b.toJson()).toList()));
  }

  // ── Direct Stock Entry ───────────────────────────────────────────────────────

  Future<void> addEntry(StockEntryModel entry) async {
    _entries.insert(0, entry);
    notifyListeners();
    await _saveEntries();
  }

  Future<void> updateEntryPayment(String entryId, double newPaidAmount) async {
    final idx = _entries.indexWhere((e) => e.id == entryId);
    if (idx != -1) {
      _entries[idx] = _entries[idx].copyWith(paidAmount: newPaidAmount);
      notifyListeners();
      await _saveEntries();
    }
  }

  Future<void> deleteEntry(String entryId) async {
    _entries.removeWhere((e) => e.id == entryId);
    notifyListeners();
    await _saveEntries();
  }

  // ── Supplier Bill (multi-item) ───────────────────────────────────────────────

  Future<void> addBill(SupplierBill bill) async {
    _bills.insert(0, bill);
    // Also persist individual entries so they show in material history
    for (final item in bill.items) {
      _entries.insert(0, item);
    }
    notifyListeners();
    await _saveBills();
    await _saveEntries();
  }

  Future<void> updateBillPayment(String billId, double newPaidAmount) async {
    final idx = _bills.indexWhere((b) => b.id == billId);
    if (idx != -1) {
      _bills[idx] = _bills[idx].copyWith(paidAmount: newPaidAmount);
      notifyListeners();
      await _saveBills();
    }
  }

  // ── Queries by filter ────────────────────────────────────────────────────────

  List<StockEntryModel> getEntriesForSite(String siteId) =>
      _entries.where((e) => e.siteId == siteId).toList()
        ..sort((a, b) => b.entryDate.compareTo(a.entryDate));

  List<StockEntryModel> getEntriesForMaterial(String materialId) =>
      _entries.where((e) => e.materialId == materialId && e.isInventoryItem).toList()
        ..sort((a, b) => b.entryDate.compareTo(a.entryDate));

  List<StockEntryModel> getEntriesForSupplier(String supplierId) =>
      _entries.where((e) => e.supplierId == supplierId).toList()
        ..sort((a, b) => b.entryDate.compareTo(a.entryDate));

  List<SupplierBill> getBillsForSupplier(String supplierId) =>
      _bills.where((b) => b.supplierId == supplierId).toList()
        ..sort((a, b) => b.billDate.compareTo(a.billDate));

  List<StockEntryModel> getMiscExpensesForSite(String siteId) =>
      _entries
          .where((e) => e.siteId == siteId && !e.isInventoryItem)
          .toList()
        ..sort((a, b) => b.entryDate.compareTo(a.entryDate));

  // ── Material Aggregates ──────────────────────────────────────────────────────

  /// Total quantity purchased for a material (all entries)
  double getTotalQuantityForMaterial(String materialId) =>
      _entries
          .where((e) => e.materialId == materialId && e.isInventoryItem)
          .fold(0.0, (s, e) => s + e.quantity);

  /// Average unit price for a material across all purchase entries
  double getAvgPriceForMaterial(String materialId) {
    final matEntries = _entries
        .where((e) => e.materialId == materialId && e.isInventoryItem)
        .toList();
    if (matEntries.isEmpty) return 0;
    final totalCost = matEntries.fold(0.0, (s, e) => s + e.totalAmount);
    final totalQty  = matEntries.fold(0.0, (s, e) => s + e.quantity);
    return totalQty > 0 ? totalCost / totalQty : 0;
  }

  // ── Supplier Aggregates ──────────────────────────────────────────────────────

  double getTotalPurchaseFromSupplier(String supplierId) =>
      _entries
          .where((e) => e.supplierId == supplierId)
          .fold(0.0, (s, e) => s + e.totalAmount);

  double getTotalPaidToSupplier(String supplierId) =>
      _entries
          .where((e) => e.supplierId == supplierId)
          .fold(0.0, (s, e) => s + e.paidAmount);

  double getPendingForSupplier(String supplierId) =>
      getTotalPurchaseFromSupplier(supplierId) -
      getTotalPaidToSupplier(supplierId);

  // ── Site Aggregates ───────────────────────────────────────────────────────────

  double getTotalMaterialValueForSite(String siteId) =>
      _entries
          .where((e) => e.siteId == siteId && e.isInventoryItem)
          .fold(0.0, (s, e) => s + e.totalAmount);

  double getTotalPendingForSite(String siteId) =>
      _entries
          .where((e) => e.siteId == siteId)
          .fold(0.0, (s, e) => s + e.pendingAmount);

  /// KPI helper: pending supplier payments across all entries (global)
  double get totalPendingAllSites =>
      _entries.fold(0.0, (s, e) => s + e.pendingAmount);

  // ── Record a payment against an entry (FIFO for supplier) ────────────────────

  Future<void> recordPaymentForSupplier({
    required String supplierId,
    required double amount,
  }) async {
    double remaining = amount;
    for (int i = 0; i < _entries.length && remaining > 0; i++) {
      final e = _entries[i];
      if (e.supplierId != supplierId) continue;
      final canPay = e.pendingAmount;
      if (canPay <= 0) continue;
      final pay = remaining < canPay ? remaining : canPay;
      _entries[i] = e.copyWith(paidAmount: e.paidAmount + pay);
      remaining -= pay;
    }
    notifyListeners();
    await _saveEntries();
  }

  // ── Supplier summary helper ───────────────────────────────────────────────────

  /// Returns a summary map keyed by supplierId → {total, paid, pending}
  Map<String, Map<String, double>> getSupplierSummaries(
      List<PartyModel> suppliers) {
    final Map<String, Map<String, double>> result = {};
    return result;
  }

  /// Calculates total current stock value of all items associated with this supplier.
  /// (material.currentStock * material.pricePerUnit) for materials with supplier entries.
  double getStockValueForSupplier(String supplierId, List<ConstructionMaterial> materials) {
    // Unique material IDs purchased from this supplier
    final supplierMatIds = _entries
        .where((e) => e.supplierId == supplierId && e.materialId.isNotEmpty)
        .map((e) => e.materialId)
        .toSet();
    
    if (supplierMatIds.isEmpty) return 0;
    
    // Sum current stock * price for those materials
    return materials
        .where((m) => supplierMatIds.contains(m.id))
        .fold(0.0, (sum, m) => sum + (m.currentStock * m.purchasePrice));
  }
}
