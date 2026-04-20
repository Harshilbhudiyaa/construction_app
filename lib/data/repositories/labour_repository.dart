import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:construction_app/data/models/labour_entry_model.dart';

class LabourRepository extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<LabourEntryModel> _entries = [];
  bool _isLoading = true;

  List<LabourEntryModel> get entries => _entries;
  bool get isLoading => _isLoading;

  StreamSubscription? _sub;

  LabourRepository() {
    _init();
  }

  void _init() {
    _sub = _db
        .collection('labour_entries')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snap) {
      try {
        _entries = snap.docs
            .map((d) => LabourEntryModel.fromJson({...d.data(), 'id': d.id}))
            .toList();
      } catch (e) {
        debugPrint('LabourRepository: Error parsing labour entries: $e');
      }
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      debugPrint('LabourRepository stream error: $e');
      _isLoading = false;
      notifyListeners();
    });
  }

  // ── CRUD ───────────────────────────────────────────────────────────────────────

  Future<void> addEntry(LabourEntryModel entry) async {
    final data = entry.toJson();
    data['createdAt'] = FieldValue.serverTimestamp();
    await _db.collection('labour_entries').doc(entry.id).set(data);
  }

  Future<void> updateEntry(LabourEntryModel updated) async {
    final data = updated.toJson();
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _db.collection('labour_entries').doc(updated.id).update(data);
  }

  Future<void> deleteEntry(String id) async {
    await _db.collection('labour_entries').doc(id).delete();
  }

  // ── Advance Payments ───────────────────────────────────────────────────────────

  Future<void> addAdvancePayment(
      String entryId, LabourAdvancePayment payment) async {
    final ref = _db.collection('labour_entries').doc(entryId);
    await _db.runTransaction((txn) async {
      final snap = await txn.get(ref);
      if (!snap.exists) return;
      final existing =
          LabourEntryModel.fromJson({...snap.data()!, 'id': snap.id});
      final updated = existing.copyWith(
        advancePayments: [...existing.advancePayments, payment],
      );
      txn.update(ref, {
        'advancePayments':
            updated.advancePayments.map((p) => p.toJson()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  // ── Settlement ─────────────────────────────────────────────────────────────────

  Future<void> markCompleted(String entryId, DateTime completionDate) async {
    await _db.collection('labour_entries').doc(entryId).update({
      'status': LabourStatus.completed.name,
      'completionDate': completionDate.toIso8601String(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> recordSettlement({
    required String entryId,
    required double settlementAmount,
    required DateTime settledDate,
  }) async {
    await _db.collection('labour_entries').doc(entryId).update({
      'finalSettlementAmount': settlementAmount,
      'status': LabourStatus.settled.name,
      'settledDate': settledDate.toIso8601String(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Queries ────────────────────────────────────────────────────────────────────

  List<LabourEntryModel> getEntriesForSite(String siteId) {
    return _entries
        .where((e) => e.siteId == siteId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<LabourEntryModel> getEntriesForParty(String partyId) {
    return _entries
        .where((e) => e.partyId == partyId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<LabourEntryModel> getNeedingSettlement({String? siteId}) {
    return _entries
        .where((e) =>
            e.needsSettlement &&
            (siteId == null || e.siteId == siteId))
        .toList();
  }

  // ── Analytics ──────────────────────────────────────────────────────────────────

  double getTotalContractValue({String? siteId}) =>
      _filtered(siteId).fold(0.0, (s, e) => s + e.totalContractAmount);

  double getTotalAdvancePaid({String? siteId}) =>
      _filtered(siteId).fold(0.0, (s, e) => s + e.totalAdvancePaid);

  double getTotalFinalSettled({String? siteId}) =>
      _filtered(siteId).fold(0.0, (s, e) => s + (e.finalSettlementAmount ?? 0));

  double getTotalPending({String? siteId}) => _filtered(siteId)
      .where((e) => !e.isFullySettled)
      .fold(0.0, (s, e) => s + e.pendingAmount);

  int getSettlementPendingCount({String? siteId}) =>
      _filtered(siteId).where((e) => e.needsSettlement).length;

  List<LabourEntryModel> _filtered(String? siteId) {
    if (siteId == null) return _entries;
    return _entries.where((e) => e.siteId == siteId).toList();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
