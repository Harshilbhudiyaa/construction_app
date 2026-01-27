import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:construction_app/modules/resources/machine_model.dart';

class MockMachineService extends ChangeNotifier {
  static final MockMachineService _instance = MockMachineService._internal();
  factory MockMachineService() => _instance;

  MockMachineService._internal() {
    _loadMachines();
  }

  final List<MachineModel> _machines = [];
  bool _initialized = false;

  List<MachineModel> get machines => List.unmodifiable(_machines);

  Future<void> _loadMachines() async {
    if (_initialized) return;
    
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('machines_data');
    
    if (data != null) {
      try {
        final List<dynamic> decoded = jsonDecode(data);
        _machines.clear();
        _machines.addAll(decoded.map((e) => MachineModel.fromJson(e)).toList());
      } catch (e) {
        debugPrint('Error loading machines: $e');
      }
    } else {
      _initDemoData();
      await _saveMachines();
    }
    
    _initialized = true;
    notifyListeners();
  }

  Future<void> _saveMachines() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_machines.map((e) => e.toJson()).toList());
    await prefs.setString('machines_data', encoded);
  }

  Future<void> addMachine(MachineModel machine) async {
    _machines.add(machine);
    notifyListeners();
    await _saveMachines();
  }

  Future<void> updateMachine(MachineModel machine) async {
    final index = _machines.indexWhere((m) => m.id == machine.id);
    if (index != -1) {
      _machines[index] = machine;
      notifyListeners();
      await _saveMachines();
    }
  }

  Future<void> deleteMachine(String id) async {
    _machines.removeWhere((m) => m.id == id);
    notifyListeners();
    await _saveMachines();
  }

  void _initDemoData() {
    _machines.addAll([
      MachineModel(
        id: 'm1',
        name: 'Excavator JCB-450',
        type: MachineType.excavator,
        assignedSiteId: 'site1',
        assignedSiteName: 'Metropolis Heights',
        natureOfWork: NatureOfWork.excavation,
        status: MachineStatus.inUse,
        lastMaintenanceDate: DateTime.now().subtract(const Duration(days: 30)),
        nextMaintenanceDate: DateTime.now().add(const Duration(days: 60)),
        operatorName: 'Ramesh Yadav',
      ),
      MachineModel(
        id: 'm2',
        name: 'Crane TC-7032',
        type: MachineType.crane,
        assignedSiteId: 'site2',
        assignedSiteName: 'Skyline Plaza',
        natureOfWork: NatureOfWork.lifting,
        status: MachineStatus.inUse,
        lastMaintenanceDate: DateTime.now().subtract(const Duration(days: 60)),
        nextMaintenanceDate: DateTime.now().add(const Duration(days: 30)),
        operatorName: 'Suresh Kumar',
      ),
      MachineModel(
        id: 'm3',
        name: 'Concrete Mixer CM-350',
        type: MachineType.mixer,
        assignedSiteId: 'site1',
        assignedSiteName: 'Metropolis Heights',
        natureOfWork: NatureOfWork.mixing,
        status: MachineStatus.available,
        lastMaintenanceDate: DateTime.now().subtract(const Duration(days: 14)),
        nextMaintenanceDate: DateTime.now().add(const Duration(days: 76)),
      ),
      MachineModel(
        id: 'm4',
        name: 'Road Roller RR-22',
        type: MachineType.roller,
        status: MachineStatus.maintenance,
        lastMaintenanceDate: DateTime.now().subtract(const Duration(days: 5)),
        nextMaintenanceDate: DateTime.now().add(const Duration(days: 2)),
      ),
    ]);
  }
}
