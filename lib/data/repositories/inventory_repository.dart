import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:construction_app/data/models/material_request_model.dart';
import 'package:construction_app/data/models/inward_movement_model.dart';
import 'package:construction_app/data/models/material_model.dart';
import 'package:construction_app/data/models/inventory_transaction.dart';
import 'package:construction_app/core/errors/exceptions.dart';

// ── Analytics helpers ──────────────────────────────────────────────────────────

class DashboardAnalytics {
  final int totalMaterials;
  final int totalInwardEntries;
  final int totalApprovedMaterials;
  final double totalStockValue;
  final double totalStockQuantity;
  final int lowStockItems;
  final int pendingApprovals;
  final List<StockMovementPoint> movementTrend;
  final Map<String, int> approvalStats;

  DashboardAnalytics({
    required this.totalMaterials,
    required this.totalInwardEntries,
    required this.totalApprovedMaterials,
    required this.totalStockValue,
    required this.totalStockQuantity,
    required this.lowStockItems,
    required this.pendingApprovals,
    required this.movementTrend,
    required this.approvalStats,
  });
}

class StockMovementPoint {
  final DateTime date;
  final double quantity;
  StockMovementPoint(this.date, this.quantity);
}

// ── Repository ─────────────────────────────────────────────────────────────────

class InventoryRepository extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Local cache
  List<ConstructionMaterial> _materials = [];
  List<InwardMovementModel> _logs = [];
  List<InventoryTransaction> _transactions = [];
  List<MaterialRequestModel> _requests = [];
  bool _isLoading = true;

  List<ConstructionMaterial> get materials => _materials;
  List<InwardMovementModel> get logs => _logs;
  List<InventoryTransaction> get transactions => _transactions;
  List<MaterialRequestModel> get requests => _requests;
  bool get isLoading => _isLoading;

  // Firestore collection references
  CollectionReference<Map<String, dynamic>> get _materialsCol =>
      _db.collection('materials');
  CollectionReference<Map<String, dynamic>> get _logsCol =>
      _db.collection('inward_logs');
  CollectionReference<Map<String, dynamic>> get _txnCol =>
      _db.collection('transactions');
  CollectionReference<Map<String, dynamic>> get _requestsCol =>
      _db.collection('material_requests');

  // Stream subscriptions
  StreamSubscription? _materialsSub;
  StreamSubscription? _logsSub;
  StreamSubscription? _txnSub;
  StreamSubscription? _requestsSub;

  // Internal broadcast stream controllers
  final _materialsController =
      StreamController<List<ConstructionMaterial>>.broadcast();
  final _logsController =
      StreamController<List<InwardMovementModel>>.broadcast();
  final _transactionsController =
      StreamController<List<InventoryTransaction>>.broadcast();
  final _requestsController =
      StreamController<List<MaterialRequestModel>>.broadcast();

  InventoryRepository() {
    _initStreams();
  }

  void _initStreams() {
    // Materials
    _materialsSub = _materialsCol
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .listen((snap) {
      _materials = snap.docs
          .map((d) => ConstructionMaterial.fromJson({...d.data(), 'id': d.id}))
          .toList();
      _isLoading = false;
      _materialsController.add(List.unmodifiable(_materials));
      notifyListeners();
    }, onError: (e) {
      debugPrint('InventoryRepository materials stream error: $e');
      _isLoading = false;
      notifyListeners();
    });

    // Inward Logs
    _logsSub = _logsCol
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snap) {
      _logs = snap.docs
          .map((d) => InwardMovementModel.fromJson({...d.data(), 'id': d.id}))
          .toList();
      _logsController.add(List.unmodifiable(_logs));
      notifyListeners();
    }, onError: (e) => debugPrint('Logs stream error: $e'));

    // Transactions
    _txnSub = _txnCol
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snap) {
      _transactions = snap.docs
          .map((d) => InventoryTransaction.fromJson({...d.data(), 'id': d.id}))
          .toList();
      _transactionsController.add(List.unmodifiable(_transactions));
      notifyListeners();
    }, onError: (e) => debugPrint('Transactions stream error: $e'));

    // Material Requests
    _requestsSub =
        _requestsCol.orderBy('createdAt', descending: true).snapshots().listen(
      (snap) {
        _requests = snap.docs
            .map((d) =>
                MaterialRequestModel.fromJson({...d.data(), 'id': d.id}))
            .toList();
        _requestsController.add(List.unmodifiable(_requests));
        notifyListeners();
      },
      onError: (e) => debugPrint('Requests stream error: $e'),
    );
  }

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();
    // Streams auto-update; just trigger a read
    try {
      final snap = await _materialsCol.limit(1).get();
      debugPrint('Refresh: ${snap.docs.length} material(s) confirmed live.');
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  // ── Materials ──────────────────────────────────────────────────────────────────

  Stream<List<ConstructionMaterial>> getMaterialsStream({String? siteId}) {
    return _db
        .collection('materials')
        .orderBy('name')
        .snapshots()
        .map((snap) {
      final all = snap.docs
          .map((d) => ConstructionMaterial.fromJson({...d.data(), 'id': d.id}))
          .toList();
      if (siteId != null) {
        return all.where((m) => m.siteId == siteId).toList();
      }
      return all;
    });
  }

  Stream<ConstructionMaterial?> getMaterialStream(String materialId) {
    return _materialsCol.doc(materialId).snapshots().map((snap) {
      if (!snap.exists) return null;
      return ConstructionMaterial.fromJson({...snap.data()!, 'id': snap.id});
    });
  }

  Future<void> addMaterial(ConstructionMaterial material) async {
    final data = material.toJson();
    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();
    if (material.id.isNotEmpty) {
      await _materialsCol.doc(material.id).set(data);
    } else {
      await _materialsCol.add(data);
    }
  }

  Future<void> updateMaterial(ConstructionMaterial material) async {
    final data = material.toJson();
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _materialsCol.doc(material.id).update(data);
  }

  Future<void> deleteMaterial(String materialId) async {
    await _materialsCol.doc(materialId).delete();
  }

  // ── Inward Logs ───────────────────────────────────────────────────────────────

  Stream<List<InwardMovementModel>> getInwardLogsStream({String? siteId}) {
    Query<Map<String, dynamic>> q =
        _logsCol.orderBy('createdAt', descending: true);
    if (siteId != null) q = q.where('siteId', isEqualTo: siteId);
    return q.snapshots().map((snap) => snap.docs
        .map((d) => InwardMovementModel.fromJson({...d.data(), 'id': d.id}))
        .toList());
  }

  Future<void> saveInwardLog(InwardMovementModel log,
      {required String recordedBy}) async {
    final data = log.toJson();
    data['createdAt'] = FieldValue.serverTimestamp();
    await _logsCol.doc(log.id).set(data);

    // Create transaction record
    final txn = InventoryTransaction(
      id: 'txn_${log.id}',
      type: TransactionType.inward,
      materialId: log.materialId ?? '',
      materialName: log.materialName,
      quantity: log.quantity,
      unit: log.unit,
      timestamp: log.createdAt,
      siteId: log.siteId,
      partyName: log.transporterName,
      rate: log.ratePerUnit,
      totalAmount: log.totalAmount,
      remarks: 'Inward from ${log.transporterName} via ${log.vehicleNumber}',
      createdBy: recordedBy,
      isApproved: log.status == InwardStatus.approved,
      referenceId: log.id,
    );
    final txnData = txn.toJson();
    txnData['timestamp'] = FieldValue.serverTimestamp();
    await _txnCol.doc(txn.id).set(txnData);
  }

  Future<void> updateInwardLog(InwardMovementModel updatedLog) async {
    final data = updatedLog.toJson();
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _logsCol.doc(updatedLog.id).update(data);
  }

  Future<void> deleteInwardLog(String logId) async {
    // Only allow deletion for pending logs
    final snap = await _logsCol.doc(logId).get();
    if (snap.exists) {
      final data = snap.data()!;
      if (data['status'] != InwardStatus.pendingApproval.name) {
        throw Exception('Cannot delete an approved or rejected log.');
      }
    }
    await _logsCol.doc(logId).delete();
    await _txnCol.doc('txn_$logId').delete();
  }

  Future<void> approveInwardLog(String logId, String approvedBy) async {
    final snap = await _logsCol.doc(logId).get();
    if (!snap.exists) return;
    final log =
        InwardMovementModel.fromJson({...snap.data()!, 'id': snap.id});

    await _logsCol.doc(logId).update({
      'status': InwardStatus.approved.name,
      'approvedBy': approvedBy,
      'approvedAt': FieldValue.serverTimestamp(),
    });

    // Update transaction
    await _txnCol.doc('txn_$logId').update({
      'isApproved': true,
      'approvedBy': approvedBy,
      'approvedAt': FieldValue.serverTimestamp(),
    });

    // Update material stock
    if (log.materialId != null) {
      await _adjustStock(log.materialId!, log.quantity, newRate: log.ratePerUnit);
    }
  }

  Future<void> rejectInwardLog(
      String logId, String rejectedBy, String reason) async {
    await _logsCol.doc(logId).update({
      'status': InwardStatus.rejected.name,
      'approvedBy': 'Rejected by $rejectedBy',
      'approvedAt': FieldValue.serverTimestamp(),
    });
    await _txnCol.doc('txn_$logId').update({
      'isApproved': false,
      'remarks': 'REJECTED: $reason',
      'approvedBy': rejectedBy,
      'approvedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Stock Adjustments ─────────────────────────────────────────────────────────

  Future<void> _adjustStock(String materialId, double delta,
      {double? newRate}) async {
    final ref = _materialsCol.doc(materialId);
    await _db.runTransaction((txn) async {
      final snap = await txn.get(ref);
      if (!snap.exists) return;
      final current = (snap.data()!['currentStock'] as num? ?? 0).toDouble();
      final updated = current + delta;
      final updates = <String, dynamic>{
        'currentStock': updated,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (newRate != null) {
        updates['purchasePrice'] = newRate;
      }
      txn.update(ref, updates);
    });
  }

  // ── Transactions ──────────────────────────────────────────────────────────────

  Stream<List<InventoryTransaction>> getTransactionsStream({
    String? materialId,
    TransactionType? type,
    bool? approvedOnly,
    int? limit,
  }) {
    Query<Map<String, dynamic>> q =
        _txnCol.orderBy('timestamp', descending: true);
    if (materialId != null) q = q.where('materialId', isEqualTo: materialId);
    if (type != null) q = q.where('type', isEqualTo: type.index);
    if (approvedOnly == true) q = q.where('isApproved', isEqualTo: true);
    if (limit != null) q = q.limit(limit);
    return q.snapshots().map((snap) => snap.docs
        .map((d) => InventoryTransaction.fromJson({...d.data(), 'id': d.id}))
        .toList());
  }

  Stream<List<InventoryTransaction>> getMaterialTransactions(
          String materialId) =>
      getTransactionsStream(materialId: materialId);

  // ── Site Inventory ─────────────────────────────────────────────────────────────

  Stream<Map<String, double>> getSiteInventorySummary(String siteId) {
    return getMaterialsStream(siteId: siteId).map((materials) {
      double totalValue = 0;
      double pendingAmount = 0;
      for (var m in materials) {
        totalValue += m.totalAmount;
        pendingAmount += m.pendingAmount;
      }
      return {'totalValue': totalValue, 'pendingAmount': pendingAmount};
    });
  }

  // ── Stock Out ─────────────────────────────────────────────────────────────────

  Future<void> recordStockOut({
    required String materialId,
    required double quantity,
    double? rate,
    DateTime? date,
    String? remarks,
    String? purpose,
    String? issuedTo,
    String? siteId,
    String? recordedBy,
  }) async {
    final matSnap = await _materialsCol.doc(materialId).get();
    if (!matSnap.exists) throw Exception('Material not found: $materialId');
    final material =
        ConstructionMaterial.fromJson({...matSnap.data()!, 'id': matSnap.id});

    if (material.currentStock < quantity) {
      throw Exception(
          'Insufficient stock. Available: ${material.currentStock} ${material.unitType}');
    }

    final effectiveRate = rate ?? material.salePrice;
    final txnId = 'txn_out_${DateTime.now().millisecondsSinceEpoch}';

    final txn = InventoryTransaction(
      id: txnId,
      type: TransactionType.outward,
      materialId: materialId,
      materialName: material.name,
      quantity: quantity,
      unit: material.unitType,
      timestamp: date ?? DateTime.now(),
      siteId: siteId ?? material.siteId,
      rate: effectiveRate,
      totalAmount: quantity * effectiveRate,
      remarks: remarks ??
          'Purpose: ${purpose ?? "N/A"}, Receiver: ${issuedTo ?? "N/A"}',
      createdBy: recordedBy ?? 'System',
      isApproved: true,
      approvedBy: recordedBy ?? 'System',
      approvedAt: DateTime.now(),
    );

    final txnData = txn.toJson();
    txnData['timestamp'] = FieldValue.serverTimestamp();
    txnData['approvedAt'] = FieldValue.serverTimestamp();
    await _txnCol.doc(txnId).set(txnData);
    await _adjustStock(materialId, -quantity);
  }

  // ── Stock In ──────────────────────────────────────────────────────────────────

  Future<void> recordStockIn({
    required String materialId,
    required double quantity,
    required double rate,
    DateTime? date,
    String? remarks,
    String? recordedBy,
  }) async {
    final matSnap = await _materialsCol.doc(materialId).get();
    if (!matSnap.exists) throw Exception('Material not found: $materialId');
    final material =
        ConstructionMaterial.fromJson({...matSnap.data()!, 'id': matSnap.id});

    final txnId = 'txn_in_${DateTime.now().millisecondsSinceEpoch}';
    final txn = InventoryTransaction(
      id: txnId,
      type: TransactionType.inward,
      materialId: materialId,
      materialName: material.name,
      quantity: quantity,
      unit: material.unitType,
      timestamp: date ?? DateTime.now(),
      siteId: material.siteId,
      rate: rate,
      totalAmount: quantity * rate,
      remarks: remarks ?? 'Stock In',
      createdBy: recordedBy ?? 'System',
      isApproved: true,
      approvedBy: recordedBy ?? 'System',
      approvedAt: DateTime.now(),
    );

    final txnData = txn.toJson();
    txnData['timestamp'] = FieldValue.serverTimestamp();
    txnData['approvedAt'] = FieldValue.serverTimestamp();
    await _txnCol.doc(txnId).set(txnData);
    await _adjustStock(materialId, quantity, newRate: rate);

    // Update purchase price
    await _materialsCol.doc(materialId).update({
      'purchasePrice': rate,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Stock Transfer ────────────────────────────────────────────────────────────

  Future<void> recordStockTransfer({
    required String materialId,
    required String materialName,
    required double quantity,
    required String unit,
    required String fromSiteId,
    required String toSiteId,
    String? remarks,
    required String recordedBy,
  }) async {
    final txnId = 'txn_trn_${DateTime.now().millisecondsSinceEpoch}';
    final txn = InventoryTransaction(
      id: txnId,
      type: TransactionType.transfer,
      materialId: materialId,
      materialName: materialName,
      quantity: quantity,
      unit: unit,
      timestamp: DateTime.now(),
      siteId: fromSiteId,
      remarks: remarks ?? 'Transfer: $fromSiteId -> $toSiteId',
      createdBy: recordedBy,
      isApproved: true,
      approvedBy: recordedBy,
      approvedAt: DateTime.now(),
    );
    final txnData = txn.toJson();
    txnData['timestamp'] = FieldValue.serverTimestamp();
    await _txnCol.doc(txnId).set(txnData);
    await _adjustStock(materialId, -quantity);
  }

  // ── Stock Damage ──────────────────────────────────────────────────────────────

  Future<void> recordStockDamage({
    required String materialId,
    required String materialName,
    required double quantity,
    required String unit,
    String? type,
    String? siteId,
    String? remarks,
    required String recordedBy,
  }) async {
    final txnId = 'txn_dmg_${DateTime.now().millisecondsSinceEpoch}';
    final txn = InventoryTransaction(
      id: txnId,
      type: TransactionType.damage,
      materialId: materialId,
      materialName: materialName,
      quantity: quantity,
      unit: unit,
      timestamp: DateTime.now(),
      siteId: siteId,
      remarks: '${type ?? "Damage"} - ${remarks ?? ""}',
      createdBy: recordedBy,
      isApproved: true,
      approvedBy: recordedBy,
      approvedAt: DateTime.now(),
    );
    final txnData = txn.toJson();
    txnData['timestamp'] = FieldValue.serverTimestamp();
    await _txnCol.doc(txnId).set(txnData);
    await _adjustStock(materialId, -quantity);
  }

  // ── Material Requests ─────────────────────────────────────────────────────────

  Stream<List<MaterialRequestModel>> getRequestsStream(
      {String? siteId, RequestStatus? status}) {
    Query<Map<String, dynamic>> q =
        _requestsCol.orderBy('createdAt', descending: true);
    if (siteId != null) q = q.where('siteId', isEqualTo: siteId);
    if (status != null) q = q.where('status', isEqualTo: status.name);
    return q.snapshots().map((snap) => snap.docs
        .map((d) =>
            MaterialRequestModel.fromJson({...d.data(), 'id': d.id}))
        .toList());
  }

  Future<void> createMaterialRequest(MaterialRequestModel request) async {
    final data = request.toJson();
    data['createdAt'] = FieldValue.serverTimestamp();
    await _requestsCol.doc(request.id).set(data);
  }

  Future<void> updateRequestStatus(String requestId, RequestStatus status,
      {String? approvedBy}) async {
    await _requestsCol.doc(requestId).update({
      'status': status.name,
      if (approvedBy != null) 'approvedBy': approvedBy,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Analytics ─────────────────────────────────────────────────────────────────

  DashboardAnalytics getDashboardAnalytics({String? siteId}) {
    final now = DateTime.now();
    final filteredMaterials = siteId != null
        ? _materials.where((m) => m.siteId == siteId).toList()
        : _materials;
    final filteredLogs = siteId != null
        ? _logs.where((l) => l.siteId == siteId).toList()
        : _logs;
    final filteredTransactions = siteId != null
        ? _transactions.where((t) => t.siteId == siteId).toList()
        : _transactions;

    final totalInward =
        filteredTransactions.where((t) => t.type == TransactionType.inward).length;
    final approvedMaterialsCount =
        filteredMaterials.where((m) => m.currentStock > 0).length;
    final totalValue = filteredMaterials.fold<double>(
        0, (s, m) => s + (m.currentStock * m.pricePerUnit));
    final totalQty =
        filteredMaterials.fold<double>(0, (s, m) => s + m.currentStock);
    final pending = filteredLogs
        .where((l) => l.status == InwardStatus.pendingApproval)
        .length;
    final lowStock = filteredMaterials
        .where((m) => m.currentStock <= m.minimumStockLimit)
        .length;

    final List<StockMovementPoint> trend = [];
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayDate = DateTime(date.year, date.month, date.day);
      final dayQty = filteredTransactions
          .where((t) =>
              t.isApproved &&
              t.timestamp.year == dayDate.year &&
              t.timestamp.month == dayDate.month &&
              t.timestamp.day == dayDate.day)
          .fold<double>(0, (s, t) => s + t.stockImpact.abs());
      trend.add(StockMovementPoint(dayDate, dayQty));
    }

    final Map<String, int> approvalMetrics = {
      'Approved':
          filteredLogs.where((l) => l.status == InwardStatus.approved).length,
      'Pending': filteredLogs
          .where((l) => l.status == InwardStatus.pendingApproval)
          .length,
      'Rejected':
          filteredLogs.where((l) => l.status == InwardStatus.rejected).length,
    };

    return DashboardAnalytics(
      totalMaterials: filteredMaterials.length,
      totalInwardEntries: totalInward,
      totalApprovedMaterials: approvedMaterialsCount,
      totalStockValue: totalValue,
      totalStockQuantity: totalQty,
      lowStockItems: lowStock,
      pendingApprovals: pending,
      movementTrend: trend,
      approvalStats: approvalMetrics,
    );
  }

  List<ConstructionMaterial> getLowStockMaterials({String? siteId}) {
    return _materials
        .where((m) =>
            m.currentStock <= m.minimumStockLimit &&
            (siteId == null || m.siteId == siteId))
        .toList();
  }

  Map<String, double> getWeeklyProfitData(String materialId) {
    try {
      final now = DateTime.now();
      final startOfWeek =
          DateTime(now.year, now.month, now.day).subtract(const Duration(days: 7));
      final material = _materials.firstWhere((m) => m.id == materialId);
      final weeklyTxns = _transactions.where((t) =>
          t.materialId == materialId &&
          t.isApproved &&
          t.timestamp.isAfter(startOfWeek));

      double totalProfit = 0;
      double stocksSold = 0;
      for (final txn in weeklyTxns) {
        if (txn.type == TransactionType.outward) {
          stocksSold += txn.quantity;
          totalProfit +=
              ((txn.rate ?? 0) - material.purchasePrice) * txn.quantity;
        }
      }
      return {'totalProfit': totalProfit, 'stocksSold': stocksSold};
    } catch (_) {
      return {'totalProfit': 0, 'stocksSold': 0};
    }
  }

  double getMaterialCurrentStockFromTransactions(String materialId) {
    return _transactions
        .where((t) => t.materialId == materialId && t.isApproved)
        .fold<double>(0.0, (s, txn) => s + txn.stockImpact);
  }

  @override
  void dispose() {
    _materialsSub?.cancel();
    _logsSub?.cancel();
    _txnSub?.cancel();
    _requestsSub?.cancel();
    _materialsController.close();
    _logsController.close();
    _transactionsController.close();
    _requestsController.close();
    super.dispose();
  }
}
