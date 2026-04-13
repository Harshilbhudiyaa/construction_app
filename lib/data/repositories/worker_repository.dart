import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:construction_app/data/models/worker_model.dart';

/// Repository managing daily/monthly workers, their attendance records,
/// and advance salary payments. Stored across three separate prefs keys to
/// keep per-record size manageable.
class WorkerRepository extends ChangeNotifier {
  static const String _workersKey       = 'workers_v1';
  static const String _attendanceKey    = 'attendance_records_v1';
  static const String _advancesKey      = 'worker_advances_v1';

  List<WorkerModel>      _workers    = [];
  List<AttendanceRecord> _attendance = [];
  List<WorkerAdvance>    _advances   = [];
  bool _isLoading = true;

  List<WorkerModel>      get workers    => _workers;
  List<AttendanceRecord> get attendance => _attendance;
  List<WorkerAdvance>    get advances   => _advances;
  bool                   get isLoading  => _isLoading;

  WorkerRepository() {
    _load();
  }

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();
    await _load();
  }

  // ── Load / Save ─────────────────────────────────────────────────────────────

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final wData = prefs.getString(_workersKey);
      if (wData != null) {
        _workers = (jsonDecode(wData) as List)
            .map((e) => WorkerModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } else {
        _workers = _demoWorkers();
        await _saveWorkers();
      }

      final aData = prefs.getString(_attendanceKey);
      if (aData != null) {
        _attendance = (jsonDecode(aData) as List)
            .map((e) => AttendanceRecord.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }

      final adData = prefs.getString(_advancesKey);
      if (adData != null) {
        _advances = (jsonDecode(adData) as List)
            .map((e) => WorkerAdvance.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (e) {
      debugPrint('WorkerRepository load error: $e');
      _workers = _demoWorkers();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveWorkers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _workersKey, jsonEncode(_workers.map((w) => w.toJson()).toList()));
  }

  Future<void> _saveAttendance() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _attendanceKey, jsonEncode(_attendance.map((a) => a.toJson()).toList()));
  }

  Future<void> _saveAdvances() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _advancesKey, jsonEncode(_advances.map((a) => a.toJson()).toList()));
  }

  // ── Worker CRUD ──────────────────────────────────────────────────────────────

  Future<void> addWorker(WorkerModel worker) async {
    _workers.insert(0, worker);
    notifyListeners();
    await _saveWorkers();
  }

  Future<void> updateWorker(WorkerModel updated) async {
    final idx = _workers.indexWhere((w) => w.id == updated.id);
    if (idx != -1) {
      _workers[idx] = updated;
      notifyListeners();
      await _saveWorkers();
    }
  }

  Future<void> deleteWorker(String workerId) async {
    _workers.removeWhere((w) => w.id == workerId);
    _attendance.removeWhere((a) => a.workerId == workerId);
    _advances.removeWhere((a) => a.workerId == workerId);
    notifyListeners();
    await _saveWorkers();
    await _saveAttendance();
    await _saveAdvances();
  }

  // ── Attendance ────────────────────────────────────────────────────────────────

  /// Mark / update attendance for a worker on a given date.
  Future<void> markAttendance(AttendanceRecord record) async {
    // Replace existing record for same worker+date if already present
    final norm = _normalizeDate(record.date);
    final idx = _attendance.indexWhere(
        (a) => a.workerId == record.workerId && _normalizeDate(a.date) == norm);
    if (idx != -1) {
      _attendance[idx] = record;
    } else {
      _attendance.add(record);
    }
    notifyListeners();
    await _saveAttendance();
  }

  /// Mark attendance for ALL active workers on a site for a given date.
  Future<void> markBulkAttendance({
    required String siteId,
    required DateTime date,
    required Map<String, AttendanceStatus> statusByWorkerId,
    String? generatedIdPrefix,
  }) async {
    final norm = _normalizeDate(date);
    for (final entry in statusByWorkerId.entries) {
      _attendance.removeWhere((a) =>
          a.workerId == entry.key && _normalizeDate(a.date) == norm);
      _attendance.add(AttendanceRecord(
        id: '${generatedIdPrefix ?? 'ATT'}-${entry.key}-${norm.millisecondsSinceEpoch}',
        workerId: entry.key,
        date: date,
        status: entry.value,
      ));
    }
    notifyListeners();
    await _saveAttendance();
  }

  AttendanceStatus getAttendanceStatus(String workerId, DateTime date) {
    final norm = _normalizeDate(date);
    try {
      return _attendance
          .firstWhere((a) =>
              a.workerId == workerId && _normalizeDate(a.date) == norm)
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

  List<AttendanceRecord> getAttendanceForMonth(String workerId, int year, int month) =>
      _attendance
          .where((a) => a.workerId == workerId && a.date.year == year && a.date.month == month)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  // ── Advances ─────────────────────────────────────────────────────────────────

  Future<void> addAdvance(WorkerAdvance advance) async {
    _advances.insert(0, advance);
    notifyListeners();
    await _saveAdvances();
  }

  List<WorkerAdvance> getAdvancesForWorker(String workerId) =>
      _advances
          .where((a) => a.workerId == workerId)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  List<WorkerAdvance> getAdvancesForMonth(String workerId, int year, int month) =>
      _advances
          .where((a) => a.workerId == workerId && a.date.year == year && a.date.month == month)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  double getTotalAdvanceForMonth(String workerId, int year, int month) =>
      getAdvancesForMonth(workerId, year, month).fold(0.0, (s, a) => s + a.amount);

  // ── Salary Calculations ───────────────────────────────────────────────────────

  /// Compute earned salary for a worker in a given month.
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
        .where((a) => a.workerId == workerId && a.date.year == year && a.date.month == month)
        .toList();

    if (worker.salaryType == SalaryType.monthly) {
      // Proportional for monthly workers based on attendance
      final dim = daysInMonth(year, month);
      final presentFactor = monthAttendance.fold(0.0, (s, a) => s + a.status.salaryFactor);
      return (worker.salaryAmount / dim) * presentFactor;
    } else {
      // Daily rate × present days
      return monthAttendance.fold(0.0, (s, a) => s + a.status.salaryFactor * worker.salaryAmount);
    }
  }

  double getTotalAdvancePaid(String workerId) =>
      _advances.where((a) => a.workerId == workerId).fold(0.0, (s, a) => s + a.amount);

  /// Net salary due for a specific month = earned in month − advances in month
  double getSalaryDue(String workerId, int year, int month) {
    final earned  = computeEarnedSalary(workerId, year, month);
    final advance = getTotalAdvanceForMonth(workerId, year, month);
    return (earned - advance); // Allow negative for "Advance Overpaid" if needed, but UI clamps it.
  }

  // ── Site Queries ─────────────────────────────────────────────────────────────

  List<WorkerModel> getWorkersForSite(String siteId) =>
      _workers.where((w) => w.siteId == siteId && w.isActive).toList();

  /// KPI: total salary due across all active workers for a site this month
  double getTotalSalaryDueForSite(String siteId) {
    final now = DateTime.now();
    return _workers
        .where((w) => w.siteId == siteId && w.isActive)
        .fold(0.0, (s, w) => s + getSalaryDue(w.id, now.year, now.month));
  }

  /// Get today's attendance stats for a site (Present, Absent, Not Marked).
  Map<String, int> getTodayStats({String? siteId}) {
    final now = DateTime.now();
    final norm = _normalizeDate(now);
    final siteWorkers = siteId != null 
        ? getWorkersForSite(siteId) 
        : _workers.where((w) => w.isActive).toList();
    
    int present = 0;
    int absent = 0;
    int halfDay = 0;
    int notMarked = 0;

    for (final w in siteWorkers) {
      try {
        final record = _attendance.firstWhere(
          (a) => a.workerId == w.id && _normalizeDate(a.date) == norm
        );
        if (record.status == AttendanceStatus.present) {
          present++;
        } else if (record.status == AttendanceStatus.absent) {
          absent++;
        } else if (record.status == AttendanceStatus.halfDay) {
          halfDay++;
        }
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

  /// Get attendance history for the last X days.
  List<AttendanceStatus?> getRecentAttendance(String workerId, {int days = 7}) {
    final List<AttendanceStatus?> history = [];
    final now = DateTime.now();
    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final norm = _normalizeDate(date);
      try {
        final record = _attendance.firstWhere(
          (a) => a.workerId == workerId && _normalizeDate(a.date) == norm
        );
        history.add(record.status);
      } catch (_) {
        history.add(null);
      }
    }
    return history;
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  DateTime _normalizeDate(DateTime d) => DateTime(d.year, d.month, d.day);

  List<WorkerModel> _demoWorkers() {
    return [
      WorkerModel(
        id: 'W-001',
        siteId: 'S-001',
        name: 'Suresh Kumar',
        phone: '9876501111',
        occupation: WorkerOccupation.mason,
        salaryType: SalaryType.daily,
        salaryAmount: 700,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      WorkerModel(
        id: 'W-002',
        siteId: 'S-001',
        name: 'Ramesh Patel',
        phone: '9876502222',
        occupation: WorkerOccupation.helper,
        salaryType: SalaryType.daily,
        salaryAmount: 500,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      WorkerModel(
        id: 'W-003',
        siteId: 'S-001',
        name: 'Mukesh Singh',
        phone: '9876503333',
        occupation: WorkerOccupation.electrician,
        salaryType: SalaryType.monthly,
        salaryAmount: 18000,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
    ];
  }
}

/// Utility: number of days in a given year/month.
int daysInMonth(int year, int month) {
  return DateTime(year, month + 1, 0).day;
}
