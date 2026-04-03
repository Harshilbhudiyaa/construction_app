import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:construction_app/data/models/party_model.dart';

class PartyRepository extends ChangeNotifier {
  static const String _partiesKey = 'app_parties_v1';
  // New key for supplier transactions (does not clash with old data)
  static const String _transactionsKey = 'supplier_transactions_v1';

  List<PartyModel> _parties = [];
  List<SupplierTransaction> _transactions = [];
  bool _isLoading = true;

  List<PartyModel> get parties => _parties;
  List<SupplierTransaction> get allTransactions => _transactions;
  bool get isLoading => _isLoading;

  // ── Supplier-filtered getters ────────────────────────────────────────────────

  List<PartyModel> get suppliers =>
      _parties.where((p) => p.category == PartyCategory.supplier).toList();

  List<PartyModel> get contractors =>
      _parties.where((p) => p.category == PartyCategory.contractor).toList();

  PartyRepository() {
    _loadFromPrefs();
  }

  // ── Persistence ─────────────────────────────────────────────────────────────

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load parties
      final String? data = prefs.getString(_partiesKey);
      if (data != null) {
        final List<dynamic> decoded = jsonDecode(data);
        _parties = decoded
            .map((item) => PartyModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      } else {
        _parties = _getDemoParties();
        await _savePartiesToPrefs();
      }

      // Load supplier transactions (new — may be empty on first run)
      final String? txnData = prefs.getString(_transactionsKey);
      if (txnData != null) {
        final List<dynamic> decoded = jsonDecode(txnData);
        _transactions = decoded
            .map((item) =>
                SupplierTransaction.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading parties: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _savePartiesToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded =
          jsonEncode(_parties.map((p) => p.toJson()).toList());
      await prefs.setString(_partiesKey, encoded);
    } catch (e) {
      debugPrint('Error saving parties: $e');
    }
  }

  Future<void> _saveTransactionsToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded =
          jsonEncode(_transactions.map((t) => t.toJson()).toList());
      await prefs.setString(_transactionsKey, encoded);
    } catch (e) {
      debugPrint('Error saving supplier transactions: $e');
    }
  }

  // ── Party CRUD ───────────────────────────────────────────────────────────────

  Future<void> addParty(PartyModel party) async {
    _parties.insert(0, party);
    notifyListeners();
    await _savePartiesToPrefs();
  }

  Future<void> updateParty(PartyModel party) async {
    final index = _parties.indexWhere((p) => p.id == party.id);
    if (index != -1) {
      _parties[index] = party;
      notifyListeners();
      await _savePartiesToPrefs();
    }
  }

  Future<void> deleteParty(String partyId) async {
    _parties.removeWhere((p) => p.id == partyId);
    notifyListeners();
    await _savePartiesToPrefs();
  }

  // ── Supplier Transaction Management ─────────────────────────────────────────

  Future<void> addTransaction(SupplierTransaction txn) async {
    _transactions.insert(0, txn);
    notifyListeners();
    await _saveTransactionsToPrefs();
  }

  Future<void> recordPaymentToSupplier({
    required String supplierId,
    required String transactionId,
    required double paymentAmount,
  }) async {
    final idx = _transactions.indexWhere(
        (t) => t.id == transactionId && t.supplierId == supplierId);
    if (idx != -1) {
      final updated = _transactions[idx]
          .copyWith(paidAmount: _transactions[idx].paidAmount + paymentAmount);
      _transactions[idx] = updated;
      notifyListeners();
      await _saveTransactionsToPrefs();
    }
  }

  /// Pay down the oldest pending transactions for a supplier (FIFO).
  Future<void> paySupplierBalance({
    required String supplierId,
    required double paymentAmount,
    String? remarks,
  }) async {
    double remaining = paymentAmount;
    for (int i = 0; i < _transactions.length && remaining > 0; i++) {
      final t = _transactions[i];
      if (t.supplierId != supplierId) continue;
      final canPay = t.pendingAmount;
      if (canPay <= 0) continue;
      final toPay = remaining < canPay ? remaining : canPay;
      _transactions[i] = t.copyWith(
          paidAmount: t.paidAmount + toPay,
          remarks: remarks ?? t.remarks);
      remaining -= toPay;
    }
    notifyListeners();
    await _saveTransactionsToPrefs();
  }

  // ── Supplier Queries ─────────────────────────────────────────────────────────

  List<SupplierTransaction> getTransactionsForSupplier(String supplierId) =>
      _transactions
          .where((t) => t.supplierId == supplierId)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  List<SupplierTransaction> getTransactionsForSite(String siteId) =>
      _transactions
          .where((t) => t.siteId == siteId)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  double getTotalPurchaseForSupplier(String supplierId) =>
      _transactions
          .where((t) => t.supplierId == supplierId)
          .fold(0.0, (s, t) => s + t.amount);

  double getTotalPaidForSupplier(String supplierId) =>
      _transactions
          .where((t) => t.supplierId == supplierId)
          .fold(0.0, (s, t) => s + t.paidAmount);

  double getPendingBalanceForSupplier(String supplierId) =>
      getTotalPurchaseForSupplier(supplierId) -
      getTotalPaidForSupplier(supplierId);

  /// Global pending balance across all suppliers (for dashboard KPI)
  double get totalPendingSupplierBalance =>
      _transactions.fold(0.0, (s, t) => s + t.pendingAmount);

  // ── Helpers ──────────────────────────────────────────────────────────────────

  String getPartyName(String partyId) {
    try {
      return _parties.firstWhere((p) => p.id == partyId).name;
    } catch (_) {
      return 'Unknown';
    }
  }

  PartyModel? getPartyById(String id) {
    try {
      return _parties.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  // ── Demo Data ────────────────────────────────────────────────────────────────

  List<PartyModel> _getDemoParties() {
    return [
      PartyModel(
        id: 'P-001',
        name: 'JSW Steel Ltd',
        category: PartyCategory.supplier,
        contactNumber: '9988776655',
        gstNumber: '07AAAAA0000A1Z5',
        address: 'Mumbai, Maharashtra',
        paymentTerms: 'Net 30',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      PartyModel(
        id: 'P-002',
        name: 'Ultratech Cement',
        category: PartyCategory.supplier,
        contactNumber: '9876543210',
        gstNumber: '24BBBBB1111B2Z6',
        address: 'Ahmedabad, Gujarat',
        paymentTerms: 'On Delivery',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      PartyModel(
        id: 'P-003',
        name: 'Ramesh Tile Works',
        category: PartyCategory.supplier,
        contactNumber: '9900112233',
        address: 'Surat, Gujarat',
        paymentTerms: 'Credit 15 days',
        createdAt: DateTime.now().subtract(const Duration(days: 40)),
      ),
    ];
  }
}
