import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:construction_app/data/models/ledger_entry_model.dart';

class LedgerRepository extends ChangeNotifier {
  static const String _key = 'ledger_entries_v1';
  List<LedgerEntryModel> _entries = [];
  bool _isLoading = true;

  List<LedgerEntryModel> get entries => _entries;
  bool get isLoading => _isLoading;

  LedgerRepository() {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_key);
      if (data != null) {
        final list = jsonDecode(data) as List<dynamic>;
        _entries = list
            .map((e) => LedgerEntryModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      } else {
        _entries = _getDemoEntries();
        await _save();
      }
    } catch (e) {
      debugPrint('LedgerRepository load error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _key, jsonEncode(_entries.map((e) => e.toJson()).toList()));
    } catch (e) {
      debugPrint('LedgerRepository save error: $e');
    }
  }

  Future<void> addEntry(LedgerEntryModel entry) async {
    _entries.insert(0, entry);
    notifyListeners();
    await _save();
  }

  Future<void> updateEntry(LedgerEntryModel entry) async {
    final idx = _entries.indexWhere((e) => e.id == entry.id);
    if (idx != -1) {
      _entries[idx] = entry;
      notifyListeners();
      await _save();
    }
  }

  Future<void> deleteEntry(String id) async {
    _entries.removeWhere((e) => e.id == id);
    notifyListeners();
    await _save();
  }

  // ── Queries ──────────────────────────────────────────────────────────────

  List<LedgerEntryModel> getEntriesForParty(String partyId) {
    final list = _entries.where((e) => e.partyId == partyId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return list;
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
    for (final e in _entries.where((e) => siteId == null || e.siteId == siteId)) {
      map[e.partyId] = (map[e.partyId] ?? 0) + (e.isCredit ? e.amount : -e.amount);
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

  List<LedgerEntryModel> _getDemoEntries() {
    final now = DateTime.now();
    return [
      LedgerEntryModel(
        id: 'L-001',
        partyId: 'P-003',
        partyName: 'Amit Shah',
        siteId: 'S-001',
        siteName: 'Hillview Apartment',
        amount: 2500000,
        type: LedgerEntryType.credit,
        description: 'Booking Advance - Flat 302',
        date: now.subtract(const Duration(days: 15)),
      ),
      LedgerEntryModel(
        id: 'L-002',
        partyId: 'P-001',
        partyName: 'JSW Steel Ltd',
        siteId: 'S-001',
        siteName: 'Hillview Apartment',
        amount: 850000,
        type: LedgerEntryType.debit,
        description: 'Steel reinforcement for foundation',
        date: now.subtract(const Duration(days: 10)),
      ),
      LedgerEntryModel(
        id: 'L-003',
        partyId: 'P-004', // Generic party
        partyName: 'Nimesh Patel',
        siteId: 'S-002',
        siteName: 'The Villa',
        amount: 4000000,
        type: LedgerEntryType.credit,
        description: 'Second Installment - Ground Floor Slab',
        date: now.subtract(const Duration(days: 20)),
      ),
      LedgerEntryModel(
        id: 'L-004',
        partyId: 'P-002',
        partyName: 'Ultratech Solutions',
        siteId: 'S-002',
        siteName: 'The Villa',
        amount: 1200000,
        type: LedgerEntryType.debit,
        description: 'Cement and sand delivery',
        date: now.subtract(const Duration(days: 5)),
      ),
    ];
  }
}
