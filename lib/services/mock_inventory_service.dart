import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'package:construction_app/modules/inventory/inward/models/inward_movement_model.dart';
import 'package:construction_app/modules/inventory/materials/models/material_model.dart';

class MockInventoryService extends ChangeNotifier {
  static const String _materialsKey = 'mock_materials_data_v2';
  static const String _logsKey = 'mock_inward_logs_data_v2';
  
  List<ConstructionMaterial> _materials = [];
  List<InwardMovementModel> _logs = [];
  bool _isLoading = true;

  List<ConstructionMaterial> get materials => _materials;
  List<InwardMovementModel> get logs => _logs;
  bool get isLoading => _isLoading;

  // StreamControllers to mimic Firebase behavior
  final _materialsController = StreamController<List<ConstructionMaterial>>.broadcast();
  final _logsController = StreamController<List<InwardMovementModel>>.broadcast();

  MockInventoryService() {
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

  // --- Inward Logs ---

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

  Future<void> saveInwardLog(InwardMovementModel log) async {
    _logs.insert(0, log);
    _notifyAll();
    await _saveLogsToPrefs();
  }

  Future<void> approveInwardLog(String logId, String approvedBy) async {
    final index = _logs.indexWhere((l) => l.id == logId);
    if (index != -1) {
      final log = _logs[index];
      _logs[index] = log.copyWith(
        status: InwardStatus.approved,
        approvedBy: approvedBy,
        approvedAt: DateTime.now(),
      );
      
      // Update Material Stock
      await _updateMaterialStock(log.materialName, log.quantity);
      
      _notifyAll();
      await _saveLogsToPrefs();
    }
  }

  Future<void> _updateMaterialStock(String materialName, double additionalQty) async {
    final index = _materials.indexWhere((m) => m.name == materialName);
    if (index != -1) {
      final material = _materials[index];
      final updatedStock = material.currentStock + additionalQty;
      _materials[index] = material.copyWith(currentStock: updatedStock);
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
    final index = _materials.indexWhere((m) => m.id == material.id);
    if (index != -1) {
      _materials[index] = material;
      _notifyAll();
      await _saveMaterialsToPrefs();
    }
  }

  Future<void> deleteMaterial(String materialId) async {
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

  void initDemoData() {
    _materials = _getInitialMaterialsData();
    _logs = _getInitialLogsData();
    _notifyAll();
    _saveMaterialsToPrefs();
    _saveLogsToPrefs();
  }

  List<ConstructionMaterial> _getInitialMaterialsData() {
    return [];
  }

  List<InwardMovementModel> _getInitialLogsData() {
    return [];
  }

  /// Clears all stored inventory data from SharedPreferences
  Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_materialsKey);
      await prefs.remove(_logsKey);
      _materials = [];
      _logs = [];
      _notifyAll();
      debugPrint('All inventory data cleared successfully');
    } catch (e) {
      debugPrint('Error clearing inventory data: $e');
    }
  }


  @override
  void dispose() {
    _materialsController.close();
    _logsController.close();
    super.dispose();
  }
}
