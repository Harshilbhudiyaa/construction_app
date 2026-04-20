import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:construction_app/data/models/party_model.dart';

class PartyRepository extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<PartyModel> _parties = [];
  List<SupplierTransaction> _transactions = [];
  bool _isLoading = true;

  List<PartyModel> get parties => _parties;
  List<SupplierTransaction> get allTransactions => _transactions;
  bool get isLoading => _isLoading;

  List<PartyModel> get suppliers =>
      _parties.where((p) => p.category == PartyCategory.supplier).toList();

  List<PartyModel> get contractors =>
      _parties.where((p) => p.category == PartyCategory.contractor).toList();

  StreamSubscription? _partiesSub;
  StreamSubscription? _txnSub;

  PartyRepository() {
    _init();
  }

  void _init() {
    _partiesSub = _db
        .collection('parties')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snap) {
      try {
        _parties = snap.docs
            .map((d) => PartyModel.fromJson({...d.data(), 'id': d.id}))
            .toList();
      } catch (e) {
        debugPrint('PartyRepository: Error parsing parties: $e');
      }
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      debugPrint('PartyRepository parties stream error: $e');
      _isLoading = false;
      notifyListeners();
    });

    _txnSub = _db
        .collection('supplier_transactions')
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snap) {
      try {
        _transactions = snap.docs
            .map((d) =>
                SupplierTransaction.fromJson({...d.data(), 'id': d.id}))
            .toList();
      } catch (e) {
        debugPrint('PartyRepository: Error parsing supplier transactions: $e');
      }
      notifyListeners();
    }, onError: (e) => debugPrint('Supplier transactions stream error: $e'));
  }

  // ── Party CRUD ─────────────────────────────────────────────────────────────────

  Future<void> addParty(PartyModel party) async {
    final data = party.toJson();
    data['createdAt'] = FieldValue.serverTimestamp();
    await _db.collection('parties').doc(party.id).set(data);
  }

  Future<void> updateParty(PartyModel party) async {
    final data = party.toJson();
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _db.collection('parties').doc(party.id).update(data);
  }

  Future<void> deleteParty(String partyId) async {
    await _db.collection('parties').doc(partyId).delete();
  }

  // ── Supplier Transactions ──────────────────────────────────────────────────────

  Future<void> addTransaction(SupplierTransaction txn) async {
    final data = txn.toJson();
    data['createdAt'] = FieldValue.serverTimestamp();
    await _db.collection('supplier_transactions').doc(txn.id).set(data);
  }

  Future<void> recordPaymentToSupplier({
    required String supplierId,
    required String transactionId,
    required double paymentAmount,
  }) async {
    final ref =
        _db.collection('supplier_transactions').doc(transactionId);
    await _db.runTransaction((txn) async {
      final snap = await txn.get(ref);
      if (!snap.exists) return;
      final current =
          (snap.data()!['paidAmount'] as num? ?? 0).toDouble();
      txn.update(ref, {
        'paidAmount': current + paymentAmount,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> paySupplierBalance({
    required String supplierId,
    required double paymentAmount,
    String? remarks,
  }) async {
    final pendingTxns = _transactions
        .where((t) =>
            t.supplierId == supplierId && t.pendingAmount > 0)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date)); // FIFO

    double remaining = paymentAmount;
    for (final t in pendingTxns) {
      if (remaining <= 0) break;
      final toPay = remaining < t.pendingAmount ? remaining : t.pendingAmount;
      await recordPaymentToSupplier(
        supplierId: supplierId,
        transactionId: t.id,
        paymentAmount: toPay,
      );
      remaining -= toPay;
    }
  }

  // ── Queries ────────────────────────────────────────────────────────────────────

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

  double getTotalPurchaseForSupplier(String supplierId) => _transactions
      .where((t) => t.supplierId == supplierId)
      .fold(0.0, (s, t) => s + t.amount);

  double getTotalPaidForSupplier(String supplierId) => _transactions
      .where((t) => t.supplierId == supplierId)
      .fold(0.0, (s, t) => s + t.paidAmount);

  double getPendingBalanceForSupplier(String supplierId) =>
      getTotalPurchaseForSupplier(supplierId) -
      getTotalPaidForSupplier(supplierId);

  double get totalPendingSupplierBalance =>
      _transactions.fold(0.0, (s, t) => s + t.pendingAmount);

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

  @override
  void dispose() {
    _partiesSub?.cancel();
    _txnSub?.cancel();
    super.dispose();
  }
}
