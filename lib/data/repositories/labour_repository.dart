import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:construction_app/data/models/labour_entry_model.dart';

class LabourRepository extends ChangeNotifier {
  static const String _key = 'labour_entries_v1';

  List<LabourEntryModel> _entries = [];
  bool _isLoading = true;

  List<LabourEntryModel> get entries => _entries;
  bool get isLoading => _isLoading;

  LabourRepository() {
    _load();
  }

  // ── Persistence ────────────────────────────────────────────────────────────

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_key);
      if (data != null) {
        final list = jsonDecode(data) as List<dynamic>;
        _entries = list
            .map((e) =>
                LabourEntryModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      } else {
        _entries = _getDemoEntries();
        await _save();
      }
    } catch (e) {
      debugPrint('LabourRepository load error: $e');
      _entries = _getDemoEntries();
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
      debugPrint('LabourRepository save error: $e');
    }
  }

  // ── CRUD ───────────────────────────────────────────────────────────────────

  Future<void> addEntry(LabourEntryModel entry) async {
    _entries.insert(0, entry);
    notifyListeners();
    await _save();
  }

  Future<void> updateEntry(LabourEntryModel updated) async {
    final idx = _entries.indexWhere((e) => e.id == updated.id);
    if (idx != -1) {
      _entries[idx] = updated;
      notifyListeners();
      await _save();
    }
  }

  Future<void> deleteEntry(String id) async {
    _entries.removeWhere((e) => e.id == id);
    notifyListeners();
    await _save();
  }

  // ── Advance Payments ───────────────────────────────────────────────────────

  /// Add an advance payment to an existing labour entry.
  Future<void> addAdvancePayment(
      String entryId, LabourAdvancePayment payment) async {
    final idx = _entries.indexWhere((e) => e.id == entryId);
    if (idx == -1) return;

    final existing = _entries[idx];
    final updatedPayments = [...existing.advancePayments, payment];
    _entries[idx] = existing.copyWith(advancePayments: updatedPayments);
    notifyListeners();
    await _save();
  }

  // ── Settlement ─────────────────────────────────────────────────────────────

  /// Mark a labour entry as completed (work done, pending settlement).
  Future<void> markCompleted(String entryId, DateTime completionDate) async {
    final idx = _entries.indexWhere((e) => e.id == entryId);
    if (idx == -1) return;

    _entries[idx] = _entries[idx].copyWith(
      status: LabourStatus.completed,
      completionDate: completionDate,
    );
    notifyListeners();
    await _save();
  }

  /// Record final settlement for a labour entry. Sets status → settled.
  Future<void> recordSettlement({
    required String entryId,
    required double settlementAmount,
    required DateTime settledDate,
  }) async {
    final idx = _entries.indexWhere((e) => e.id == entryId);
    if (idx == -1) return;

    _entries[idx] = _entries[idx].copyWith(
      finalSettlementAmount: settlementAmount,
      status: LabourStatus.settled,
      settledDate: settledDate,
    );
    notifyListeners();
    await _save();
  }

  // ── Queries ─────────────────────────────────────────────────────────────────

  List<LabourEntryModel> getEntriesForSite(String siteId) {
    return _entries.where((e) => e.siteId == siteId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<LabourEntryModel> getEntriesForParty(String partyId) {
    return _entries.where((e) => e.partyId == partyId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<LabourEntryModel> getNeedingSettlement({String? siteId}) {
    return _entries
        .where((e) =>
            e.needsSettlement && (siteId == null || e.siteId == siteId))
        .toList();
  }

  // ── Analytics ──────────────────────────────────────────────────────────────

  double getTotalContractValue({String? siteId}) {
    return _filtered(siteId).fold(0.0, (s, e) => s + e.totalContractAmount);
  }

  double getTotalAdvancePaid({String? siteId}) {
    return _filtered(siteId).fold(0.0, (s, e) => s + e.totalAdvancePaid);
  }

  double getTotalFinalSettled({String? siteId}) {
    return _filtered(siteId)
        .fold(0.0, (s, e) => s + (e.finalSettlementAmount ?? 0));
  }

  double getTotalPending({String? siteId}) {
    return _filtered(siteId)
        .where((e) => !e.isFullySettled)
        .fold(0.0, (s, e) => s + e.pendingAmount);
  }

  int getSettlementPendingCount({String? siteId}) {
    return _filtered(siteId).where((e) => e.needsSettlement).length;
  }

  List<LabourEntryModel> _filtered(String? siteId) {
    if (siteId == null) return _entries;
    return _entries.where((e) => e.siteId == siteId).toList();
  }

  // ── Demo Data ───────────────────────────────────────────────────────────────

  List<LabourEntryModel> _getDemoEntries() {
    final now = DateTime.now();
    return [
      LabourEntryModel(
        id: 'LAB-001',
        partyId: 'P-LABOUR-001',
        partyName: 'Ramesh Mistri & Team',
        partyContact: '9876501234',
        siteId: 'S-001',
        siteName: 'Hillview Apartment',
        workType: LabourWorkType.perSqFt,
        workDescription: 'RCC Slab work — Ground Floor',
        workQuantity: 3200,
        ratePerUnit: 45,
        totalContractAmount: 144000,
        advancePayments: [
          LabourAdvancePayment(
            id: 'ADV-001',
            amount: 50000,
            date: now.subtract(const Duration(days: 10)),
            remarks: 'Mobilisation advance',
            paidBy: 'Admin',
          ),
        ],
        status: LabourStatus.ongoing,
        startDate: now.subtract(const Duration(days: 12)),
        createdBy: 'Admin',
        createdAt: now.subtract(const Duration(days: 12)),
        notes: 'Includes formwork and concrete pouring.',
      ),
      LabourEntryModel(
        id: 'LAB-002',
        partyId: 'P-LABOUR-002',
        partyName: 'Suresh Painter Works',
        partyContact: '9823456780',
        siteId: 'S-001',
        siteName: 'Hillview Apartment',
        workType: LabourWorkType.fixedContract,
        workDescription: 'Interior painting — all 4 floors',
        workQuantity: null,
        ratePerUnit: 85000,
        totalContractAmount: 85000,
        advancePayments: [
          LabourAdvancePayment(
            id: 'ADV-002',
            amount: 30000,
            date: now.subtract(const Duration(days: 20)),
            remarks: 'Initial advance',
            paidBy: 'Admin',
          ),
          LabourAdvancePayment(
            id: 'ADV-003',
            amount: 25000,
            date: now.subtract(const Duration(days: 8)),
            remarks: 'Mid-work advance',
            paidBy: 'Admin',
          ),
        ],
        status: LabourStatus.completed,
        startDate: now.subtract(const Duration(days: 22)),
        completionDate: now.subtract(const Duration(days: 2)),
        createdBy: 'Admin',
        createdAt: now.subtract(const Duration(days: 22)),
      ),
    ];
  }
}
