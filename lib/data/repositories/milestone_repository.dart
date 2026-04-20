import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:construction_app/data/models/milestone_model.dart';

class MilestoneRepository extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<MilestoneModel> _milestones = [];
  bool _isLoading = true;

  List<MilestoneModel> get milestones => _milestones;
  bool get isLoading => _isLoading;

  StreamSubscription? _sub;

  MilestoneRepository() {
    _init();
  }

  void _init() {
    _sub = _db
        .collection('milestones')
        .orderBy('dueDate')
        .snapshots()
        .listen((snap) {
      try {
        _milestones = snap.docs
            .map((d) => MilestoneModel.fromJson({...d.data(), 'id': d.id}))
            .toList();
      } catch (e) {
        debugPrint('MilestoneRepository: Error parsing milestones: $e');
      }
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      debugPrint('MilestoneRepository stream error: $e');
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addMilestone(MilestoneModel milestone) async {
    final data = milestone.toJson();
    data['createdAt'] = FieldValue.serverTimestamp();
    await _db.collection('milestones').doc(milestone.id).set(data);
  }

  Future<void> updateMilestone(MilestoneModel milestone) async {
    final data = milestone.toJson();
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _db.collection('milestones').doc(milestone.id).update(data);
  }

  Future<void> deleteMilestone(String id) async {
    await _db.collection('milestones').doc(id).delete();
  }

  Future<void> markPaid(String id) async {
    await _db.collection('milestones').doc(id).update({
      'isPaid': true,
      'paidOn': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Queries ────────────────────────────────────────────────────────────────────

  List<MilestoneModel> getMilestonesForSite(String siteId) =>
      _milestones.where((m) => m.siteId == siteId).toList()
        ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

  List<MilestoneModel> getOverdueMilestones({String? siteId}) => _milestones
      .where((m) =>
          m.status == MilestoneStatus.overdue &&
          (siteId == null || m.siteId == siteId))
      .toList()
    ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

  List<MilestoneModel> getUpcomingMilestones({String? siteId}) => _milestones
      .where((m) =>
          (m.status == MilestoneStatus.upcoming ||
              m.status == MilestoneStatus.dueSoon) &&
          (siteId == null || m.siteId == siteId))
      .toList()
    ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

  double getTotalUnpaid({String? siteId}) => _milestones
      .where((m) => !m.isPaid && (siteId == null || m.siteId == siteId))
      .fold(0.0, (sum, m) => sum + m.amount);

  int getOverdueCount({String? siteId}) =>
      getOverdueMilestones(siteId: siteId).length;

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
