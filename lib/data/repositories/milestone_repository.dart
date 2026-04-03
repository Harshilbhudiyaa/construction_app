import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:construction_app/data/models/milestone_model.dart';

class MilestoneRepository extends ChangeNotifier {
  static const String _key = 'milestones_v1';
  List<MilestoneModel> _milestones = [];
  bool _isLoading = true;

  List<MilestoneModel> get milestones => _milestones;
  bool get isLoading => _isLoading;

  MilestoneRepository() {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_key);
      if (data != null) {
        final list = jsonDecode(data) as List<dynamic>;
        _milestones = list
            .map((e) => MilestoneModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      } else {
        _milestones = _getInitialMilestonesData();
        await _save();
      }
    } catch (e) {
      debugPrint('MilestoneRepository load error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _key, jsonEncode(_milestones.map((m) => m.toJson()).toList()));
    } catch (e) {
      debugPrint('MilestoneRepository save error: $e');
    }
  }

  Future<void> addMilestone(MilestoneModel milestone) async {
    _milestones.insert(0, milestone);
    notifyListeners();
    await _save();
  }

  Future<void> updateMilestone(MilestoneModel milestone) async {
    final idx = _milestones.indexWhere((m) => m.id == milestone.id);
    if (idx != -1) {
      _milestones[idx] = milestone;
      notifyListeners();
      await _save();
    }
  }

  Future<void> deleteMilestone(String id) async {
    _milestones.removeWhere((m) => m.id == id);
    notifyListeners();
    await _save();
  }

  Future<void> markPaid(String id) async {
    final idx = _milestones.indexWhere((m) => m.id == id);
    if (idx != -1) {
      _milestones[idx] = _milestones[idx].copyWith(
        isPaid: true,
        paidOn: DateTime.now(),
      );
      notifyListeners();
      await _save();
    }
  }

  // ── Queries ──────────────────────────────────────────────────────────────

  List<MilestoneModel> getMilestonesForSite(String siteId) =>
      _milestones.where((m) => m.siteId == siteId).toList()
        ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

  List<MilestoneModel> getOverdueMilestones({String? siteId}) => _milestones
      .where((m) => m.status == MilestoneStatus.overdue && (siteId == null || m.siteId == siteId))
      .toList()
    ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

  List<MilestoneModel> getUpcomingMilestones({String? siteId}) => _milestones
      .where((m) =>
          (m.status == MilestoneStatus.upcoming ||
          m.status == MilestoneStatus.dueSoon) && (siteId == null || m.siteId == siteId))
      .toList()
    ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

  double getTotalUnpaid({String? siteId}) => _milestones
      .where((m) => !m.isPaid && (siteId == null || m.siteId == siteId))
      .fold(0.0, (sum, m) => sum + m.amount);

  int getOverdueCount({String? siteId}) => getOverdueMilestones(siteId: siteId).length;

  List<MilestoneModel> _getInitialMilestonesData() {
    final now = DateTime.now();
    return [
      MilestoneModel(
        id: 'M-001',
        siteId: 'S-001',
        siteName: 'Hillview Apartment',
        title: 'Foundation Completion',
        description: 'Excavation and PCC completed',
        dueDate: now.subtract(const Duration(days: 5)),
        amount: 500000,
        isPaid: false,
      ),
      MilestoneModel(
        id: 'M-002',
        siteId: 'S-002',
        siteName: 'The Villa',
        title: 'Roof Casting',
        description: 'First floor slab casting',
        dueDate: now.add(const Duration(days: 3)),
        amount: 800000,
        isPaid: false,
      ),
      MilestoneModel(
        id: 'M-003',
        siteId: 'S-001',
        siteName: 'Hillview Apartment',
        title: 'First Floor Slab',
        description: 'Columns and slab for 1st floor',
        dueDate: now.subtract(const Duration(days: 30)),
        amount: 1000000,
        isPaid: true,
        paidOn: now.subtract(const Duration(days: 28)),
      ),
    ];
  }
}
