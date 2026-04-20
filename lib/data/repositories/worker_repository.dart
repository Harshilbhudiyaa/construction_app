import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:construction_app/data/models/worker_model.dart';

/// Repository managing daily/monthly workers, attendance, and advance salary payments.
/// Now backed by Firestore for real-time sync.
class WorkerRepository extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<WorkerModel> _workers = [];
  List<AttendanceRecord> _attendance = [];
  List<WorkerAdvance> _advances = [];
  bool _isLoading = true;

  List<WorkerModel> get workers => _workers;
  List<AttendanceRecord> get attendance => _attendance;
  List<WorkerAdvance> get advances => _advances;
  bool get isLoading => _isLoading;

  StreamSubscription? _workersSub;
  StreamSubscription? _attendanceSub;
  StreamSubscription? _advancesSub;

  WorkerRepository() {
    _init();
  }

  void _init() {
    _workersSub = _db
        .collection('workers')
        .orderBy('name')
        .snapshots()
        .listen((snap) {
      _workers = snap.docs
          .map((d) => WorkerModel.fromJson({...d.data(), 'id': d.id}))
          .toList();
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      debugPrint('WorkerRepository workers stream error: $e');
      _isLoading = false;
      notifyListeners();
    });

    _attendanceSub = _db
        .collection('attendance')
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snap) {
      _attendance = snap.docs
          .map((d) => AttendanceRecord.fromJson({...d.data(), 'id': d.id}))
          .toList();
      notifyListeners();
    }, onError: (e) => debugPrint('Attendance stream error: $e'));

    _advancesSub = _db
        .collection('worker_advances')
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snap) {
      _advances = snap.docs
          .map((d) => WorkerAdvance.fromJson({...d.data(), 'id': d.id}))
          .toList();
      notifyListeners();
    }, onError: (e) => debugPrint('Advances stream error: $e'));
  }

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();
    // Firestore streams auto-update; just signal loading done
    await Future.delayed(const Duration(milliseconds: 200));
    _isLoading = false;
    notifyListeners();
  }

  // ── Worker CRUD ────────────────────────────────────────────────────────────────

  Future<void> addWorker(WorkerModel worker) async {
    final data = worker.toJson();
    data['createdAt'] = FieldValue.serverTimestamp();
    await _db.collection('workers').doc(worker.id).set(data);
  }

  Future<void> updateWorker(WorkerModel updated) async {
    final data = updated.toJson();
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _db.collection('workers').doc(updated.id).update(data);
  }

  Future<void> deleteWorker(String workerId) async {
    final batch = _db.batch();
    batch.delete(_db.collection('workers').doc(workerId));

    // Delete related attendance records
    final attSnap = await _db
        .collection('attendance')
        .where('workerId', isEqualTo: workerId)
        .get();
    for (final doc in attSnap.docs) {
      batch.delete(doc.reference);
    }

    // Delete related advances
    final advSnap = await _db
        .collection('worker_advances')
        .where('workerId', isEqualTo: workerId)
        .get();
    for (final doc in advSnap.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  // ── Attendance ─────────────────────────────────────────────────────────────────

  Future<void> markAttendance(AttendanceRecord record) async {
    final norm = _normalizeDate(record.date);
    // Use a deterministic doc ID so duplicates are overwritten
    final docId = '${record.workerId}_${norm.millisecondsSinceEpoch}';
    final data = record.toJson();
    data['createdAt'] = FieldValue.serverTimestamp();
    await _db.collection('attendance').doc(docId).set(data);
  }

  Future<void> markBulkAttendance({
    required String siteId,
    required DateTime date,
    required Map<String, AttendanceStatus> statusByWorkerId,
    String? generatedIdPrefix,
  }) async {
    final norm = _normalizeDate(date);
    final batch = _db.batch();
    for (final entry in statusByWorkerId.entries) {
      final docId = '${entry.key}_${norm.millisecondsSinceEpoch}';
      final record = AttendanceRecord(
        id: docId,
        workerId: entry.key,
        date: date,
        status: entry.value,
      );
      batch.set(_db.collection('attendance').doc(docId), {
        ...record.toJson(),
        'siteId': siteId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  AttendanceStatus getAttendanceStatus(String workerId, DateTime date) {
    final norm = _normalizeDate(date);
    try {
      return _attendance
          .firstWhere((a) =>
              a.workerId == workerId &&
              _normalizeDate(a.date) == norm)
          .status;
    } catch (_) {
      return AttendanceStatus.absent;
    }
  }

  List<AttendanceRecord> getAttendanceForWorker(String workerId) =>
      _attendance
          .where((a) => a.workerId == workerId)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  List<AttendanceRecord> getAttendanceForMonth(
          String workerId, int year, int month) =>
      _attendance
          .where((a) =>
              a.workerId == workerId &&
              a.date.year == year &&
              a.date.month == month)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  // ── Advances ───────────────────────────────────────────────────────────────────

  Future<void> addAdvance(WorkerAdvance advance) async {
    final data = advance.toJson();
    data['createdAt'] = FieldValue.serverTimestamp();
    await _db.collection('worker_advances').doc(advance.id).set(data);
  }

  List<WorkerAdvance> getAdvancesForWorker(String workerId) =>
      _advances
          .where((a) => a.workerId == workerId)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  List<WorkerAdvance> getAdvancesForMonth(
          String workerId, int year, int month) =>
      _advances
          .where((a) =>
              a.workerId == workerId &&
              a.date.year == year &&
              a.date.month == month)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  // ── Salary ─────────────────────────────────────────────────────────────────────

  double computeEarnedSalary(String workerId, int year, int month) {
    final worker = _workers.firstWhere(
      (w) => w.id == workerId,
      orElse: () => WorkerModel(
        id: '', siteId: '', name: '',
        occupation: WorkerOccupation.other,
        salaryType: SalaryType.daily,
        salaryAmount: 0,
        createdAt: DateTime.now(),
      ),
    );
    if (worker.id.isEmpty) return 0;

    final monthAttendance = _attendance
        .where((a) =>
            a.workerId == workerId &&
            a.date.year == year &&
            a.date.month == month)
        .toList();

    if (worker.salaryType == SalaryType.monthly) {
      final dim = daysInMonth(year, month);
      final presentFactor =
          monthAttendance.fold(0.0, (s, a) => s + a.status.salaryFactor);
      return (worker.salaryAmount / dim) * presentFactor;
    } else {
      return monthAttendance
          .fold(0.0, (s, a) => s + a.status.salaryFactor * worker.salaryAmount);
    }
  }

  double getTotalAdvanceForMonth(String workerId, int year, int month) =>
      getAdvancesForMonth(workerId, year, month)
          .fold(0.0, (s, a) => s + a.amount);

  double getTotalAdvancePaid(String workerId) =>
      _advances
          .where((a) => a.workerId == workerId)
          .fold(0.0, (s, a) => s + a.amount);

  double getSalaryDue(String workerId, int year, int month) {
    final earned = computeEarnedSalary(workerId, year, month);
    final advance = getTotalAdvanceForMonth(workerId, year, month);
    return earned - advance;
  }

  // ── Site Queries ───────────────────────────────────────────────────────────────

  List<WorkerModel> getWorkersForSite(String siteId) =>
      _workers.where((w) => w.siteId == siteId && w.isActive).toList();

  double getTotalSalaryDueForSite(String siteId) {
    final now = DateTime.now();
    return _workers
        .where((w) => w.siteId == siteId && w.isActive)
        .fold(0.0, (s, w) => s + getSalaryDue(w.id, now.year, now.month));
  }

  Map<String, int> getTodayStats({String? siteId}) {
    final now = DateTime.now();
    final norm = _normalizeDate(now);
    final siteWorkers = siteId != null
        ? getWorkersForSite(siteId)
        : _workers.where((w) => w.isActive).toList();

    int present = 0, absent = 0, halfDay = 0, notMarked = 0;

    for (final w in siteWorkers) {
      try {
        final record = _attendance.firstWhere(
          (a) => a.workerId == w.id && _normalizeDate(a.date) == norm,
        );
        if (record.status == AttendanceStatus.present) present++;
        else if (record.status == AttendanceStatus.absent) absent++;
        else if (record.status == AttendanceStatus.halfDay) halfDay++;
      } catch (_) {
        notMarked++;
      }
    }

    return {
      'present': present,
      'absent': absent,
      'halfDay': halfDay,
      'notMarked': notMarked,
      'total': siteWorkers.length,
    };
  }

  List<AttendanceStatus?> getRecentAttendance(String workerId, {int days = 7}) {
    final List<AttendanceStatus?> history = [];
    final now = DateTime.now();
    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final norm = _normalizeDate(date);
      try {
        final record = _attendance.firstWhere(
          (a) => a.workerId == workerId && _normalizeDate(a.date) == norm,
        );
        history.add(record.status);
      } catch (_) {
        history.add(null);
      }
    }
    return history;
  }

  // ── Helpers ────────────────────────────────────────────────────────────────────

  DateTime _normalizeDate(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  void dispose() {
    _workersSub?.cancel();
    _attendanceSub?.cancel();
    _advancesSub?.cancel();
    super.dispose();
  }
}

/// Utility: number of days in a given year/month.
int daysInMonth(int year, int month) {
  return DateTime(year, month + 1, 0).day;
}
