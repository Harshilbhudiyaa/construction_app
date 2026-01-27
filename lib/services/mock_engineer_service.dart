import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:construction_app/profiles/engineer_model.dart';

class MockEngineerService extends ChangeNotifier {
  static final MockEngineerService _instance = MockEngineerService._internal();
  factory MockEngineerService() => _instance;

  MockEngineerService._internal() {
    _loadEngineers();
  }

  final List<EngineerModel> _engineers = [];
  bool _initialized = false;

  List<EngineerModel> get engineers => List.unmodifiable(_engineers);

  Future<void> _loadEngineers() async {
    if (_initialized) return;
    
    final prefs = await SharedPreferences.getInstance();
    final String? engineersJson = prefs.getString('engineers_data');
    
    if (engineersJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(engineersJson);
        _engineers.clear();
        _engineers.addAll(decoded.map((e) => EngineerModel.fromJson(e)).toList());
      } catch (e) {
        debugPrint('Error loading engineers: $e');
      }
    } else {
      // First run: Initialize with demo data
      initDemoData();
      await _saveEngineers();
    }
    
    _initialized = true;
    notifyListeners();
  }

  Future<void> _saveEngineers() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_engineers.map((e) => e.toJson()).toList());
    await prefs.setString('engineers_data', encoded);
  }

  Future<void> addEngineer(EngineerModel engineer) async {
    final index = _engineers.indexWhere((e) => e.id == engineer.id);
    if (index >= 0) {
      _engineers[index] = engineer; // Update
    } else {
      _engineers.add(engineer);
    }
    notifyListeners();
    await _saveEngineers();
  }

  Future<void> deleteEngineer(String id) async {
    _engineers.removeWhere((e) => e.id == id);
    notifyListeners();
    await _saveEngineers();
  }

  EngineerModel? findByPhone(String phone) {
    try {
      return _engineers.firstWhere(
        (e) => e.phone?.replaceAll(' ', '') == phone.replaceAll(' ', ''),
      );
    } catch (_) {
      return null;
    }
  }

  // Pre-populate with some data for demo
  void initDemoData() {
    if (_engineers.isEmpty) {
      _engineers.addAll([
        EngineerModel(
          id: 'e1',
          name: 'Amit Patel',
          role: EngineerRole.siteEngineer,
          permissions: const PermissionSet(siteManagement: true, createSite: true),
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          phone: "9876543210",
        ),
        EngineerModel(
          id: 'e2',
          name: 'Rahul Sharma',
          role: EngineerRole.supervisor,
          permissions: const PermissionSet(workerManagement: true),
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
          phone: "9876543211",
        ),
        EngineerModel(
          id: 'e3',
          name: 'Priya Verma',
          role: EngineerRole.siteEngineer,
          permissions: const PermissionSet(siteManagement: true, reportViewing: true),
          createdAt: DateTime.now().subtract(const Duration(days: 15)),
          phone: "9876543212",
        ),
        EngineerModel(
          id: 'e4',
          name: 'Suresh Raina',
          role: EngineerRole.storeKeeper,
          permissions: const PermissionSet(inventoryManagement: true),
          createdAt: DateTime.now().subtract(const Duration(days: 45)),
          phone: "9876543213",
        ),
        EngineerModel(
          id: 'e5',
          name: 'Anjali Gupta',
          role: EngineerRole.siteEngineer, // Using siteEngineer as project manager equivalent
          permissions: const PermissionSet(siteManagement: true, createSite: true, workerManagement: true),
          createdAt: DateTime.now().subtract(const Duration(days: 60)),
          phone: "9876543214",
        ),
        EngineerModel(
          id: 'e6',
          name: 'Vikram Singh',
          role: EngineerRole.machineOperator,
          permissions: const PermissionSet(toolMachineManagement: true),
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          phone: "9876543215",
        ),
      ]);
    }
  }
}
