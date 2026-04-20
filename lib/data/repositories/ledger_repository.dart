import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:construction_app/data/models/ledger_entry_model.dart';

class LedgerRepository extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<LedgerEntryModel> _entries = [];
  bool _isLoading = true;

  List<LedgerEntryModel> get entries => _entries;
  bool get isLoading => _isLoading;

  StreamSubscription? _sub;

  LedgerRepository() {
    _init();
  }

  void _init() {
    _sub = _db
        .collection('ledger_entries')
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snap) {
      try {
        _entries = snap.docs
            .map((d) => LedgerEntryModel.fromJson({...d.data(), 'id': d.id}))
            .toList();
      } catch (e) {
        debugPrint('LedgerRepository: Error parsing ledger entries: $e');
      }
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      debugPrint('LedgerRepository stream error: $e');
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addEntry(LedgerEntryModel entry) async {
    final data = entry.toJson();
    data['createdAt'] = FieldValue.serverTimestamp();
    await _db.collection('ledger_entries').doc(entry.id).set(data);
  }

  Future<void> updateEntry(LedgerEntryModel entry) async {
    final data = entry.toJson();
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _db.collection('ledger_entries').doc(entry.id).update(data);
  }

  Future<void> deleteEntry(String id) async {
    await _db.collection('ledger_entries').doc(id).delete();
  }

  // ── Queries ────────────────────────────────────────────────────────────────────

  List<LedgerEntryModel> getEntriesForParty(String partyId) {
    return _entries
        .where((e) => e.partyId == partyId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Positive = net credit (we receive), Negative = net debit (we pay)
  double getBalanceForParty(String partyId) {
    double balance = 0;
    for (final e in _entries.where((e) => e.partyId == partyId)) {
      balance += e.isCredit ? e.amount : -e.amount;
    }
    return balance;
  }

  /// Map of partyId → net balance
  Map<String, double> getAllPartyBalances({String? siteId}) {
    final Map<String, double> map = {};
    for (final e in _entries.where(
        (e) => siteId == null || e.siteId == siteId)) {
      map[e.partyId] =
          (map[e.partyId] ?? 0) + (e.isCredit ? e.amount : -e.amount);
    }
    return map;
  }

  double getTotalReceivable({String? siteId}) {
    double total = 0;
    final balances = getAllPartyBalances(siteId: siteId);
    for (final b in balances.values) {
      if (b > 0) total += b;
    }
    return total;
  }

  double getTotalPayable({String? siteId}) {
    double total = 0;
    final balances = getAllPartyBalances(siteId: siteId);
    for (final b in balances.values) {
      if (b < 0) total += b.abs();
    }
    return total;
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
