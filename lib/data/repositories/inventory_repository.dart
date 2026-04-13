import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'package:construction_app/data/models/material_request_model.dart';
import 'package:construction_app/data/models/inward_movement_model.dart';
import 'package:construction_app/data/models/material_model.dart';
import 'package:construction_app/data/models/inventory_transaction.dart';
import 'package:construction_app/data/repositories/auth_repository.dart';
import 'package:construction_app/core/errors/exceptions.dart';

class DashboardAnalytics {
  final int totalMaterials;
  final int totalInwardEntries;
  final int totalApprovedMaterials;
  final double totalStockValue;
  final double totalStockQuantity;
  final int lowStockItems;
  final int pendingApprovals;
  final List<StockMovementPoint> movementTrend;
  final Map<String, int> approvalStats; // Status -> Count

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

class InventoryRepository extends ChangeNotifier {
  static const String _materialsKey = 'mock_materials_data_v3';
  static const String _logsKey = 'mock_inward_logs_data_v3';
  static const String _transactionsKey = 'inventory_transactions_v2';
  static const String _requestsKey = 'material_requests_v1';
  
  List<ConstructionMaterial> _materials = [];
  List<InwardMovementModel> _logs= [];
  List<InventoryTransaction> _transactions = [];
  List<MaterialRequestModel> _requests = [];
  bool _isLoading = true;

  List<ConstructionMaterial> get materials => _materials;
  List<InwardMovementModel> get logs => _logs;
  List<InventoryTransaction> get transactions => _transactions;
  List<MaterialRequestModel> get requests => _requests;
  bool get isLoading => _isLoading;

  // StreamControllers to mimic Firebase behavior
  final _materialsController = StreamController<List<ConstructionMaterial>>.broadcast();
  final _logsController = StreamController<List<InwardMovementModel>>.broadcast();
  final _transactionsController = StreamController<List<InventoryTransaction>>.broadcast();
  final _requestsController = StreamController<List<MaterialRequestModel>>.broadcast();

  InventoryRepository() {
    _init();
  }

  Future<void> _init() async {
    await _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load Materials
      final String? materialsData = prefs.getString(_materialsKey);
      if (materialsData != null) {
        final List<dynamic> decoded = jsonDecode(materialsData);
        _materials = decoded.map((item) => ConstructionMaterial.fromJson(Map<String, dynamic>.from(item))).toList();
      } else {
        _materials = _getInitialMaterialsData();
        await _saveMaterialsToPrefs();
      }

      // Load Logs
      final String? logsData = prefs.getString(_logsKey);
      if (logsData != null) {
        final List<dynamic> decoded = jsonDecode(logsData);
        _logs = decoded.map((item) => InwardMovementModel.fromJson(Map<String, dynamic>.from(item))).toList();
      } else {
        _logs = _getInitialLogsData();
        await _saveLogsToPrefs();
      }

      // Load Transactions
      final String? transactionsData = prefs.getString(_transactionsKey);
      if (transactionsData != null) {
        final List<dynamic> decoded = jsonDecode(transactionsData);
        _transactions = decoded.map((item) => InventoryTransaction.fromJson(Map<String, dynamic>.from(item))).toList();
      }

      // Load Requests
      final String? requestsData = prefs.getString(_requestsKey);
      if (requestsData != null) {
        final List<dynamic> decoded = jsonDecode(requestsData);
        _requests = decoded.map((item) => MaterialRequestModel.fromJson(Map<String, dynamic>.from(item))).toList();
      }

      // Seed if empty (First run or explicitly cleared)
      if (_materials.isEmpty) {
        _materials = _getInitialMaterialsData();
        await _saveMaterialsToPrefs();
      }
      if (_logs.isEmpty) {
        _logs = _getInitialLogsData();
        await _saveLogsToPrefs();
      }
      if (_transactions.isEmpty) {
        _transactions = _getInitialTransactionsData();
        await _saveTransactionsToPrefs();
      }
    } catch (e) {
      debugPrint('Error loading mock inventory: $e');
      _materials = _getInitialMaterialsData();
      _logs = _getInitialLogsData();
    } finally {
      _isLoading = false;
      _notifyAll();
    }
  }

  void _notifyAll() {
    notifyListeners();
    _materialsController.add(List.unmodifiable(_materials));
    _logsController.add(List.unmodifiable(_logs));
    _transactionsController.add(List.unmodifiable(_transactions));
    _requestsController.add(List.unmodifiable(_requests));
  }

  Future<void> _saveMaterialsToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(_materials.map((m) => m.toJson()).toList());
      await prefs.setString(_materialsKey, encoded);
    } catch (e) {
      debugPrint('Error saving materials: $e');
    }
  }

  Future<void> _saveLogsToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(_logs.map((l) => l.toJson()).toList());
      await prefs.setString(_logsKey, encoded);
    } catch (e) {
      debugPrint('Error saving logs: $e');
    }
  }

  Future<void> _saveTransactionsToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(_transactions.map((t) => t.toJson()).toList());
      await prefs.setString(_transactionsKey, encoded);
    } catch (e) {
      debugPrint('Error saving transactions: $e');
    }
  }

  Future<void> _saveRequestsToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(_requests.map((r) => r.toJson()).toList());
      await prefs.setString(_requestsKey, encoded);
    } catch (e) {
      debugPrint('Error saving requests: $e');
    }
  }

  // --- Transaction Management ---

  Stream<List<InwardMovementModel>> getInwardLogsStream({String? siteId}) {
    return _getInwardLogsStreamInternal(siteId: siteId).asBroadcastStream();
  }

  Stream<List<InwardMovementModel>> _getInwardLogsStreamInternal({String? siteId}) async* {
    // Emit initial data immediately
    if (siteId != null) {
      yield _logs.where((l) => l.siteId == siteId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else {
      yield List.from(_logs)..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    
    // Then listen for updates
    await for (final logs in _logsController.stream) {
      if (siteId != null) {
        yield logs.where((l) => l.siteId == siteId).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      } else {
        yield logs.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
    }
  }

  Future<void> saveInwardLog(InwardMovementModel log, {required String recordedBy}) async {
    if (!AuthRepository().canCreateEntry) {
      throw AuthException('You do not have permission to create inward entries.');
    }
    _logs.insert(0, log);
    
    // Create transaction record (not yet approved, so no stock impact)
    final transaction = InventoryTransaction(
      id: 'txn_${log.id}',
      type: TransactionType.inward,
      materialId: log.materialId ?? '', // Use materialId from log
      materialName: log.materialName,
      quantity: log.quantity,
      unit: log.unit,
      timestamp: log.createdAt,
      siteId: log.siteId,
      siteName: null, 
      partyId: null, 
      partyName: log.transporterName,
      rate: log.ratePerUnit,
      totalAmount: log.totalAmount,
      remarks: 'Inward from ${log.transporterName} via ${log.vehicleNumber}',
      createdBy: recordedBy,
      isApproved: log.status == InwardStatus.approved,
      referenceId: log.id,
    );
    
    _transactions.insert(0, transaction);
    _notifyAll();
    await _saveLogsToPrefs();
    await _saveTransactionsToPrefs();
  }

  Future<void> updateInwardLog(InwardMovementModel updatedLog) async {
    final index = _logs.indexWhere((l) => l.id == updatedLog.id);
    if (index != -1) {
      // Only allow updates for pending logs to prevent inventory inconsistency
      if (_logs[index].status != InwardStatus.pendingApproval) {
        throw Exception('Cannot update an already approved or rejected log.');
      }
      
      _logs[index] = updatedLog;
      
      // Update associated transaction
      final txnIndex = _transactions.indexWhere((t) => t.referenceId == updatedLog.id);
      if (txnIndex != -1) {
        _transactions[txnIndex] = _transactions[txnIndex].copyWith(
          materialId: updatedLog.materialId ?? '',
          materialName: updatedLog.materialName,
          quantity: updatedLog.quantity,
          unit: updatedLog.unit,
          partyName: updatedLog.transporterName,
          rate: updatedLog.ratePerUnit,
          totalAmount: updatedLog.totalAmount,
          remarks: 'Updated: Inward from ${updatedLog.transporterName} via ${updatedLog.vehicleNumber}',
        );
      }
      
      _notifyAll();
      await _saveLogsToPrefs();
      await _saveTransactionsToPrefs();
    }
  }

  Future<void> deleteInwardLog(String logId) async {
    final index = _logs.indexWhere((l) => l.id == logId);
    if (index != -1) {
      // Only allow deletion for pending logs
      if (_logs[index].status != InwardStatus.pendingApproval) {
        throw Exception('Cannot delete an already approved or rejected log.');
      }
      
      _logs.removeAt(index);
      
      // Remove associated transaction
      _transactions.removeWhere((t) => t.referenceId == logId);
      
      _notifyAll();
      await _saveLogsToPrefs();
      await _saveTransactionsToPrefs();
    }
  }

  Future<void> approveInwardLog(String logId, String approvedBy) async {
    if (!AuthRepository().canApprove) {
      throw AuthException('Only Administrators can approve inward logs.');
    }
    final index = _logs.indexWhere((l) => l.id == logId);
    if (index != -1) {
      final log = _logs[index];
      _logs[index] = log.copyWith(
        status: InwardStatus.approved,
        approvedBy: approvedBy,
        approvedAt: DateTime.now(),
      );
      
      // Update transaction to approved status
      final txnIndex = _transactions.indexWhere((t) => t.referenceId == logId);
      if (txnIndex != -1) {
        _transactions[txnIndex] = _transactions[txnIndex].copyWith(
          isApproved: true,
          approvedBy: approvedBy,
          approvedAt: DateTime.now(),
        );
      }
      
      // Update Material Stock (automatic synchronization!)
      // Prioritize updating by ID if available, otherwise fallback to name
      if (log.materialId != null) {
        await _updateMaterialStockById(log.materialId!, log.quantity, newRate: log.ratePerUnit, referenceId: log.id); 
      } else {
        await _updateMaterialStock(log.materialName, log.quantity, newRate: log.ratePerUnit, referenceId: log.id);
      }
      
      _notifyAll(); // This triggers all UI updates everywhere!
      await _saveLogsToPrefs();
      await _saveTransactionsToPrefs();
    }
  }

  Future<void> rejectInwardLog(String logId, String rejectedBy, String reason) async {
    if (!AuthRepository().canApprove) {
      throw AuthException('Only Administrators can reject inward logs.');
    }
    final index = _logs.indexWhere((l) => l.id == logId);
    if (index != -1) {
      final log = _logs[index];
      _logs[index] = log.copyWith(
        status: InwardStatus.rejected,
        // rejectedBy: rejectedBy, // If model supports it, otherwise generic handling
        // rejectionReason: reason,
        approvedBy: 'Rejected by $rejectedBy', // Using existing field for audit
        approvedAt: DateTime.now(),
      );
      
      // Update transaction to rejected (or delete it? Standard practice: keep as rejected)
      final txnIndex = _transactions.indexWhere((t) => t.referenceId == logId);
      if (txnIndex != -1) {
        _transactions[txnIndex] = _transactions[txnIndex].copyWith(
          isApproved: false,
          remarks: 'REJECTED: $reason',
          approvedBy: rejectedBy,
          approvedAt: DateTime.now(),
        );
      }
      
      // NO STOCK UPDATE for rejection
      
      _notifyAll();
      await _saveLogsToPrefs();
      await _saveTransactionsToPrefs();
    }
  }

  Future<void> _updateMaterialStock(String materialName, double additionalQty, {double? newRate, String? referenceId}) async {
    final index = _materials.indexWhere((m) => m.name == materialName);
    if (index != -1) {
      final material = _materials[index];
      final updatedStock = material.currentStock + additionalQty;
      
      List<PricePoint> updatedHistory = List.from(material.rateHistory);
      if (newRate != null) {
        updatedHistory.add(PricePoint(timestamp: DateTime.now(), price: newRate, referenceId: referenceId));
      }

      _materials[index] = material.copyWith(
        currentStock: updatedStock,
        rateHistory: updatedHistory,
        purchasePrice: newRate ?? material.purchasePrice,
      );
      await _saveMaterialsToPrefs();
    }
  }

  Future<void> _updateMaterialStockById(String materialId, double additionalQty, {double? newRate, String? referenceId}) async {
     final index = _materials.indexWhere((m) => m.id == materialId);
    if (index != -1) {
      final material = _materials[index];
      final updatedStock = material.currentStock + additionalQty;

      List<PricePoint> updatedHistory = List.from(material.rateHistory);
      if (newRate != null) {
        updatedHistory.add(PricePoint(timestamp: DateTime.now(), price: newRate, referenceId: referenceId));
      }

      _materials[index] = material.copyWith(
        currentStock: updatedStock,
        rateHistory: updatedHistory,
        purchasePrice: newRate ?? material.purchasePrice,
      );
      await _saveMaterialsToPrefs();
    }
  }

  // --- Construction Materials ---

  Stream<List<ConstructionMaterial>> getMaterialsStream({String? siteId}) {
    return _getMaterialsStreamInternal(siteId: siteId).asBroadcastStream();
  }

  Stream<List<ConstructionMaterial>> _getMaterialsStreamInternal({String? siteId}) async* {
    // Emit initial data immediately
    if (siteId != null) {
      yield _materials.where((m) => m.siteId == siteId).toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    } else {
      yield List.from(_materials)..sort((a, b) => a.name.compareTo(b.name));
    }
    
    // Then listen for updates
    await for (final materials in _materialsController.stream) {
      if (siteId != null) {
        yield materials.where((m) => m.siteId == siteId).toList()
          ..sort((a, b) => a.name.compareTo(b.name));
      } else {
        yield materials.toList()..sort((a, b) => a.name.compareTo(b.name));
      }
    }
  }

  Stream<ConstructionMaterial?> getMaterialStream(String materialId) {
    return _getMaterialStreamInternal(materialId).asBroadcastStream();
  }

  Stream<ConstructionMaterial?> _getMaterialStreamInternal(String materialId) async* {
    // Emit initial data immediately
    try {
      yield _materials.firstWhere((m) => m.id == materialId);
    } catch (_) {
      yield null;
    }
    
    // Then listen for updates
    await for (final materials in _materialsController.stream) {
      try {
        yield materials.firstWhere((m) => m.id == materialId);
      } catch (_) {
        yield null;
      }
    }
  }

  Future<void> addMaterial(ConstructionMaterial material) async {
    _materials.insert(0, material);
    _notifyAll();
    await _saveMaterialsToPrefs();
  }

  Future<void> updateMaterial(ConstructionMaterial material) async {
    if (!AuthRepository().canEdit) {
      throw AuthException('You do not have permission to update materials.');
    }
    final index = _materials.indexWhere((m) => m.id == material.id);
    if (index != -1) {
      _materials[index] = material;
      _notifyAll();
      await _saveMaterialsToPrefs();
    }
  }

  Future<void> deleteMaterial(String materialId) async {
    if (!AuthRepository().canEdit) {
      throw AuthException('You do not have permission to delete materials.');
    }
    _materials.removeWhere((m) => m.id == materialId);
    _notifyAll();
    await _saveMaterialsToPrefs();
  }

  Stream<Map<String, double>> getSiteInventorySummary(String siteId) {
    return getMaterialsStream(siteId: siteId).map((materials) {
      double totalValue = 0;
      double pendingAmount = 0;
      for (var m in materials) {
        totalValue += m.totalAmount;
        pendingAmount += m.pendingAmount;
      }
      return {
        'totalValue': totalValue,
        'pendingAmount': pendingAmount,
      };
    });
  }

  // --- Advanced Analytics ---

  DashboardAnalytics getDashboardAnalytics({String? siteId}) {
    final now = DateTime.now();
    
    final filteredMaterials = siteId != null ? _materials.where((m) => m.siteId == siteId).toList() : _materials;
    final filteredLogs = siteId != null ? _logs.where((l) => l.siteId == siteId).toList() : _logs;
    final filteredTransactions = siteId != null ? _transactions.where((t) => t.siteId == siteId).toList() : _transactions;

    // Basic stats
    final totalInward = filteredTransactions.where((t) => t.type == TransactionType.inward).length;
    final approvedMaterialsCount = filteredMaterials.where((m) => m.currentStock > 0).length;
    final totalValue = filteredMaterials.fold<double>(0, (sum, m) => sum + (m.currentStock * m.pricePerUnit));
    final totalQty = filteredMaterials.fold<double>(0, (sum, m) => sum + m.currentStock);
    final pending = filteredLogs.where((l) => l.status == InwardStatus.pendingApproval).length;
    final lowStock = filteredMaterials.where((m) => m.currentStock <= m.minimumStockLimit).length;

    // Last 7 days movement trend
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
          .fold<double>(0, (sum, t) => sum + t.stockImpact.abs());
          
      trend.add(StockMovementPoint(dayDate, dayQty));
    }


    // Approval stats
    final Map<String, int> approvalMetrics = {
      'Approved': filteredLogs.where((l) => l.status == InwardStatus.approved).length,
      'Pending': filteredLogs.where((l) => l.status == InwardStatus.pendingApproval).length,
      'Rejected': filteredLogs.where((l) => l.status == InwardStatus.rejected).length,
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
    return _materials.where((m) => m.currentStock <= m.minimumStockLimit && (siteId == null || m.siteId == siteId)).toList();
  }

  void initDemoData() {
    _materials = _getInitialMaterialsData();
    _logs = _getInitialLogsData();
    _notifyAll();
    _saveMaterialsToPrefs();
    _saveLogsToPrefs();
  }

  List<ConstructionMaterial> _getInitialMaterialsData() {
    return [
      ConstructionMaterial(
        id: 'MAT-001',
        siteId: 'S-001',
        name: 'Ultratech Cement (Premium)',
        subType: 'OPC 53 Grade',
        brand: 'Ultratech',
        pricePerUnit: 450,
        purchasePrice: 420,
        salePrice: 480,
        unitType: 'bag',
        currentStock: 1250,
        minimumStockLimit: 100,
        storageLocation: 'Warehouse A',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
        rateHistory: [
          PricePoint(timestamp: DateTime.now().subtract(const Duration(days: 30)), price: 410),
          PricePoint(timestamp: DateTime.now().subtract(const Duration(days: 20)), price: 430),
          PricePoint(timestamp: DateTime.now().subtract(const Duration(days: 10)), price: 420),
          PricePoint(timestamp: DateTime.now().subtract(const Duration(days: 2)), price: 450),
        ],
      ),
      ConstructionMaterial(
        id: 'MAT-002',
        siteId: 'S-001',
        name: 'TMT Steel Bar 12mm',
        subType: 'TMT Bar',
        brand: 'Tata Tiscon',
        pricePerUnit: 75000,
        purchasePrice: 72000,
        salePrice: 78000,
        unitType: 'ton',
        currentStock: 45.5,
        minimumStockLimit: 5.0,
        storageLocation: 'Yard 1',
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
        updatedAt: DateTime.now(),
        rateHistory: [
          PricePoint(timestamp: DateTime.now().subtract(const Duration(days: 25)), price: 70000),
          PricePoint(timestamp: DateTime.now().subtract(const Duration(days: 15)), price: 74000),
          PricePoint(timestamp: DateTime.now().subtract(const Duration(days: 5)), price: 72000),
        ],
      ),
      ConstructionMaterial(
        id: 'MAT-003',
        siteId: 'S-001',
        name: 'High-End Vitrified Tiles',
        subType: 'Italian Polish',
        brand: 'Kajaria',
        pricePerUnit: 120,
        purchasePrice: 110,
        salePrice: 145,
        unitType: 'sqf',
        currentStock: 4200,
        minimumStockLimit: 500,
        storageLocation: 'Warehouse B',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now(),
        rateHistory: [
          PricePoint(timestamp: DateTime.now().subtract(const Duration(days: 20)), price: 105),
          PricePoint(timestamp: DateTime.now().subtract(const Duration(days: 10)), price: 115),
          PricePoint(timestamp: DateTime.now().subtract(const Duration(days: 5)), price: 110),
        ],
      ),
      ConstructionMaterial(
        id: 'MAT-004',
        siteId: 'S-002',
        name: 'Jindal Steel Sections',
        subType: 'Beams',
        brand: 'Jindal',
        pricePerUnit: 85000,
        purchasePrice: 82000,
        salePrice: 88000,
        unitType: 'ton',
        currentStock: 1.2,
        minimumStockLimit: 0.2,
        storageLocation: 'Site 2 Yard',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now(),
        rateHistory: [
          PricePoint(timestamp: DateTime.now().subtract(const Duration(days: 15)), price: 80000),
          PricePoint(timestamp: DateTime.now().subtract(const Duration(days: 1)), price: 82000),
        ],
      ),
    ];
  }

  List<InwardMovementModel> _getInitialLogsData() {
    final now = DateTime.now();
    return [
      InwardMovementModel(
        id: 'LOG-101',
        vehicleType: '12-Wheeler Truck',
        vehicleNumber: 'MH-12-AQ-8842',
        vehicleCapacity: '25 Ton',
        transporterName: 'Standard Logistics Corp',
        siteId: 'S-001',
        driverName: 'Rajesh Kumar', driverMobile: '9876543210', driverLicense: 'DL-MH12-20150042',
        materialId: 'MAT-001', materialName: 'Ultratech Cement (Premium)',
        quantity: 500, unit: 'Bags', photoProofs: [],
        ratePerUnit: 420, transportCharges: 5000, taxPercentage: 18, totalAmount: 247000,
        status: InwardStatus.approved, createdAt: now.subtract(const Duration(days: 2)),
        approvedBy: 'Admin', approvedAt: now.subtract(const Duration(days: 2, hours: 4)),
      ),
      InwardMovementModel(
        id: 'LOG-102',
        vehicleType: 'Flatbed Trailer',
        vehicleNumber: 'GJ-01-TX-4521',
        vehicleCapacity: '40 Ton',
        transporterName: 'Gujarat Freight Solutions',
        siteId: 'S-001',
        driverName: 'Suresh Patel', driverMobile: '9988776655', driverLicense: 'DL-GJ01-20184412',
        materialId: 'MAT-002', materialName: 'TMT Steel Bar 12mm',
        quantity: 10, unit: 'Ton', photoProofs: [],
        ratePerUnit: 72000, transportCharges: 12000, taxPercentage: 18, totalAmount: 852000,
        status: InwardStatus.pendingApproval, createdAt: now.subtract(const Duration(hours: 5)),
      ),
      InwardMovementModel(
        id: 'LOG-103',
        vehicleType: 'Medium Tempo',
        vehicleNumber: 'MH-43-BE-1120',
        vehicleCapacity: '5 Ton',
        transporterName: 'Arora Transporters',
        siteId: 'S-001',
        driverName: 'Amit Arora', driverMobile: '9123456780', driverLicense: 'DL-MH43-20120011',
        materialId: 'MAT-003', materialName: 'High-End Vitrified Tiles',
        quantity: 400, unit: 'SqFt', photoProofs: [],
        ratePerUnit: 110, transportCharges: 1500, taxPercentage: 12, totalAmount: 50960,
        status: InwardStatus.approved, createdAt: now.subtract(const Duration(days: 5)),
        approvedBy: 'Admin', approvedAt: now.subtract(const Duration(days: 5, hours: 2)),
      ),
      InwardMovementModel(
        id: 'LOG-104',
        vehicleType: 'Tata 407',
        vehicleNumber: 'MH-04-ER-9012',
        vehicleCapacity: '4 Ton',
        transporterName: 'Local Haulage Co',
        siteId: 'S-002',
        driverName: 'Vikram Singh', driverMobile: '9001234567', driverLicense: 'DL-MH04-20199012',
        materialId: 'MAT-004', materialName: 'Jindal Steel Sections',
        quantity: 2, unit: 'Ton', photoProofs: [],
        ratePerUnit: 82000, transportCharges: 3000, taxPercentage: 18, totalAmount: 197000,
        status: InwardStatus.pendingApproval, createdAt: now.subtract(const Duration(hours: 1)),
      ),
    ];
  }

  List<InventoryTransaction> _getInitialTransactionsData() {
    final now = DateTime.now();
    return [
      InventoryTransaction(
        id: 'TXN-001',
        type: TransactionType.inward,
        materialId: 'MAT-001',
        materialName: 'Ultratech Cement (Premium)',
        quantity: 500,
        unit: 'Bags',
        timestamp: now.subtract(const Duration(days: 2)),
        siteId: 'S-001',
        partyName: 'Standard Logistics Corp',
        rate: 420,
        totalAmount: 210000,
        isApproved: true,
        createdBy: 'Admin',
      ),
      InventoryTransaction(
        id: 'TXN-002',
        type: TransactionType.inward,
        materialId: 'MAT-002',
        materialName: 'TMT Steel Bar 12mm',
        quantity: 10,
        unit: 'Ton',
        timestamp: now.subtract(const Duration(hours: 5)),
        siteId: 'S-001',
        partyName: 'Gujarat Freight Solutions',
        rate: 72000,
        totalAmount: 720000,
        isApproved: false, // Pending
        createdBy: 'Manager',
      ),
      InventoryTransaction(
        id: 'TXN-003',
        type: TransactionType.inward,
        materialId: 'MAT-003',
        materialName: 'High-End Vitrified Tiles',
        quantity: 400,
        unit: 'SqFt',
        timestamp: now.subtract(const Duration(days: 5)),
        siteId: 'S-001',
        partyName: 'Arora Transporters',
        rate: 110,
        totalAmount: 44000,
        isApproved: true,
        createdBy: 'Admin',
      ),
    ];
  }

  // --- Transaction Streams (Real-time updates) ---

  /// Get all transactions stream with optional filters
  Stream<List<InventoryTransaction>> getTransactionsStream({
    String? materialId,
    TransactionType? type,
    bool? approvedOnly,
    int? limit,
  }) async* {
    // Emit initial data
    yield _filterTransactions(
      materialId: materialId,
      type: type,
      approvedOnly: approvedOnly,
      limit: limit,
    );
    
    // Listen for updates
    await for (final _ in _transactionsController.stream) {
      yield _filterTransactions(
        materialId: materialId,
        type: type,
        approvedOnly: approvedOnly,
        limit: limit,
      );
    }
  }

  List<InventoryTransaction> _filterTransactions({
    String? materialId,
    TransactionType? type,
    bool? approvedOnly,
    int? limit,
  }) {
    var filtered = _transactions.where((t) {
      if (materialId != null && t.materialId != materialId) return false;
      if (type != null && t.type != type) return false;
      if (approvedOnly == true && !t.isApproved) return false;
      return true;
    }).toList();
    
    // Sort by timestamp descending (newest first)
    filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    if (limit != null && filtered.length > limit) {
      return filtered.sublist(0, limit);
    }
    
    return filtered;
  }

  /// Get material's transaction history
  Stream<List<InventoryTransaction>> getMaterialTransactions(String materialId) {
    return getTransactionsStream(materialId: materialId);
  }

  /// Calculate current stock for a materialfrom transaction history
  /// This is the SINGLE SOURCE OF TRUTH for stock levels
  double getMaterialCurrentStockFromTransactions(String materialId) {
    final materialTransactions = _transactions.where(
      (t) => t.materialId == materialId && t.isApproved
    );
    
    return materialTransactions.fold<double>(
      0.0,
      (sum, txn) => sum + txn.stockImpact,
    );
  }


  /// Record Stock Transfer
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
    final transaction = InventoryTransaction(
      id: 'txn_trn_${DateTime.now().millisecondsSinceEpoch}',
      type: TransactionType.transfer,
      materialId: materialId,
      materialName: materialName,
      quantity: quantity,
      unit: unit,
      timestamp: DateTime.now(),
      siteId: fromSiteId, // Source site
      remarks: remarks ?? 'Transfer: $fromSiteId -> $toSiteId',
      createdBy: recordedBy,
      isApproved: true,
      approvedBy: recordedBy,
      approvedAt: DateTime.now(),
    );

    _transactions.insert(0, transaction);
    
    // Decrement from Source
    await _updateMaterialStockById(materialId, -quantity);
    
    // TODO: Handle destination stock (For now, we assume simple debit from source)
    
    _notifyAll();
    await _saveTransactionsToPrefs();
  }

  /// Record Stock Damage/Waste
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
    final transaction = InventoryTransaction(
      id: 'txn_dmg_${DateTime.now().millisecondsSinceEpoch}',
      type: TransactionType.damage,
      materialId: materialId,
      materialName: materialName,
      quantity: quantity,
      unit: unit,
      timestamp: DateTime.now(),
      siteId: siteId,
      remarks: '$type - ${remarks ?? ""}',
      createdBy: recordedBy,
      isApproved: true,
      approvedBy: recordedBy,
      approvedAt: DateTime.now(),
    );

    _transactions.insert(0, transaction);
    await _updateMaterialStockById(materialId, -quantity);
    
    _notifyAll();
    await _saveTransactionsToPrefs();
  }

  /// Clears all stored inventory data from SharedPreferences
  Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_materialsKey);
      await prefs.remove(_transactionsKey);
      await prefs.remove(_requestsKey);
      _materials = [];
      _logs = [];
      _transactions = [];
      _requests = [];
      _notifyAll();
      debugPrint('All inventory data cleared successfully');
    } catch (e) {
      debugPrint('Error clearing inventory data: $e');
    }
  }

  // --- Material Requests ---

  Stream<List<MaterialRequestModel>> getRequestsStream({String? siteId, RequestStatus? status}) async* {
    yield _filterRequests(siteId, status);
    await for (final _ in _requestsController.stream) {
      yield _filterRequests(siteId, status);
    }
  }

  List<MaterialRequestModel> _filterRequests(String? siteId, RequestStatus? status) {
    var filtered = _requests.where((r) {
      if (siteId != null && r.siteId != siteId) return false;
      if (status != null && r.status != status) return false;
      return true;
    }).toList();
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return filtered;
  }

  Future<void> createMaterialRequest(MaterialRequestModel request) async {
    _requests.insert(0, request);
    _notifyAll();
    await _saveRequestsToPrefs();
  }

  Future<void> updateRequestStatus(String requestId, RequestStatus status, {String? approvedBy}) async {
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      _requests[index] = _requests[index].copyWith(
        status: status,
        approvedBy: approvedBy,
        updatedAt: DateTime.now(),
      );
      _notifyAll();
      await _saveRequestsToPrefs();
    }
  }


  /// Modern Stock In (Vyapar Style)
  Future<void> recordStockIn({
    required String materialId,
    required double quantity,
    required double rate,
    DateTime? date,
    String? remarks,
    String? recordedBy,
  }) async {
    final material = _materials.firstWhere(
      (m) => m.id == materialId,
      orElse: () => throw Exception('Material not found: $materialId'),
    );
    final transaction = InventoryTransaction(
      id: 'txn_in_${DateTime.now().millisecondsSinceEpoch}',
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

    _transactions.insert(0, transaction);
    await _updateMaterialStockById(materialId, quantity);
    
    // Also update the material's purchase price to the latest rate
    final mIndex = _materials.indexWhere((m) => m.id == materialId);
    if (mIndex != -1) {
      _materials[mIndex] = _materials[mIndex].copyWith(purchasePrice: rate, updatedAt: DateTime.now());
      await _saveMaterialsToPrefs();
    }

    _notifyAll();
    await _saveTransactionsToPrefs();
  }

  /// Modern Stock Out (Vyapar Style)
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
    final material = _materials.firstWhere(
      (m) => m.id == materialId,
      orElse: () => throw Exception('Material not found: $materialId'),
    );
    if (material.currentStock < quantity) {
      throw Exception('Insufficient stock. Available: ${material.currentStock} ${material.unitType}');
    }

    final effectiveRate = rate ?? material.salePrice;

    final transaction = InventoryTransaction(
      id: 'txn_out_${DateTime.now().millisecondsSinceEpoch}',
      type: TransactionType.outward,
      materialId: materialId,
      materialName: material.name,
      quantity: quantity,
      unit: material.unitType,
      timestamp: date ?? DateTime.now(),
      siteId: siteId ?? material.siteId,
      rate: effectiveRate,
      totalAmount: quantity * effectiveRate,
      remarks: remarks ?? 'Purpose: ${purpose ?? "N/A"}, Receiver: ${issuedTo ?? "N/A"}',
      createdBy: recordedBy ?? 'System',
      isApproved: true,
      approvedBy: recordedBy ?? 'System',
      approvedAt: DateTime.now(),
    );

    _transactions.insert(0, transaction);
    await _updateMaterialStockById(materialId, -quantity);

    // Also update the material's sale price if a new rate was provided
    if (rate != null) {
      final mIndex = _materials.indexWhere((m) => m.id == materialId);
      if (mIndex != -1) {
        _materials[mIndex] = _materials[mIndex].copyWith(salePrice: rate, updatedAt: DateTime.now());
        await _saveMaterialsToPrefs();
      }
    }

    _notifyAll();
    await _saveTransactionsToPrefs();
  }

  /// Get profit for a material over the last 7 days
  Map<String, double> getWeeklyProfitData(String materialId) {
    try {
      final now = DateTime.now();
      final startOfWeek = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 7));
      
      final material = _materials.firstWhere((m) => m.id == materialId);
      final weeklyTransactions = _transactions.where((t) => 
        t.materialId == materialId && 
        t.isApproved && 
        t.timestamp.isAfter(startOfWeek)
      ).toList();

      double totalProfit = 0;
      double stocksSold = 0;

      for (var txn in weeklyTransactions) {
        if (txn.type == TransactionType.outward) {
          stocksSold += txn.quantity;
          // Simple profit = (sale rate - material purchase price) * quantity
          final profitPerUnit = (txn.rate ?? 0) - material.purchasePrice;
          totalProfit += profitPerUnit * txn.quantity;
        }
      }

      return {
        'totalProfit': totalProfit,
        'stocksSold': stocksSold,
      };
    } catch (_) {
      return {
        'totalProfit': 0,
        'stocksSold': 0,
      };
    }
  }

  @override
  void dispose() {
    _materialsController.close();
    _logsController.close();
    _transactionsController.close();
    _requestsController.close();
    super.dispose();
  }
}
