import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:construction_app/profiles/worker_types.dart';

class MockWorkerService extends ChangeNotifier {
  static const String _storageKey = 'mock_workers_data';
  final List<Worker> _workers = [];

  List<Worker> get workers => List.unmodifiable(_workers);

  MockWorkerService() {
    _loadWorkers();
  }

  Future<void> _loadWorkers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString(_storageKey);
      
      if (data != null) {
        final List<dynamic> decoded = jsonDecode(data);
        _workers.clear();
        _workers.addAll(decoded.map((json) => _workerFromJson(json)));
      } else {
        initDemoData();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading workers: $e');
      initDemoData();
    }
  }

  Future<void> _saveWorkers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(_workers.map((w) => _workerToJson(w)).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (e) {
      debugPrint('Error saving workers: $e');
    }
  }

  void initDemoData() {
    if (_workers.isEmpty) {
      _workers.addAll([
        const Worker(
          id: 'WK-1001',
          name: 'Ramesh Kumar',
          phone: '9876543210',
          skill: 'Mason',
          shift: WorkerShift.day,
          rateType: PayRateType.perDay,
          rateAmount: 900,
          status: WorkerStatus.active,
          assignedSite: 'METROPOLIS SITE A',
          isActive: true,
          permissions: WorkerPermissionSet(
            workSessionLogging: true,
            historyViewing: true,
            earningsViewing: true,
            profileEditing: true,
          ),
          photoUrl: 'https://images.unsplash.com/photo-1540560914872-8e2ec52bd488?q=80&w=200&h=200&auto=format&fit=crop',
          assignedWorkTypes: ['Concrete Work', 'Brick / Block Work'],
          siteId: 'S-001',
        ),
        const Worker(
          id: 'WK-1002',
          name: 'Suresh Patil',
          phone: '9876543211',
          skill: 'Helper',
          shift: WorkerShift.day,
          rateType: PayRateType.perDay,
          rateAmount: 600,
          status: WorkerStatus.active,
          assignedSite: 'METROPOLIS SITE A',
          isActive: true,
          permissions: WorkerPermissionSet(
            workSessionLogging: true,
            historyViewing: true,
            earningsViewing: false, // Restricted
            profileEditing: false,
          ),
          photoUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=200&h=200&auto=format&fit=crop',
          assignedWorkTypes: ['General Labor'],
          siteId: 'S-001',
        ),
        const Worker(
          id: 'WK-1003',
          name: 'Amir Khan',
          phone: '9876543212',
          skill: 'Carpenter',
          shift: WorkerShift.day,
          rateType: PayRateType.perDay,
          rateAmount: 800,
          status: WorkerStatus.active,
          photoUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=200&h=200&auto=format&fit=crop',
          assignedWorkTypes: ['Carpentry'],
          siteId: 'S-002',
        ),
        const Worker(
          id: 'WK-1004',
          name: 'Arjun Meena',
          phone: '9876500001',
          skill: 'Plumber',
          shift: WorkerShift.day,
          rateType: PayRateType.perDay,
          rateAmount: 850,
          status: WorkerStatus.active,
          photoUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=200&h=200&auto=format&fit=crop',
          assignedWorkTypes: ['Plumbing'],
        ),
        const Worker(
          id: 'WK-1005',
          name: 'Deepak Jha',
          phone: '9876500002',
          skill: 'Carpenter',
          shift: WorkerShift.night,
          rateType: PayRateType.perDay,
          rateAmount: 950,
          status: WorkerStatus.active,
          photoUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=200&h=200&auto=format&fit=crop',
          assignedWorkTypes: ['Carpentry'],
        ),
      ]);
    }
  }

  Future<void> addWorker(Worker worker) async {
    _workers.insert(0, worker);
    notifyListeners();
    await _saveWorkers();
  }

  Future<void> updateWorker(Worker worker) async {
    final index = _workers.indexWhere((w) => w.id == worker.id);
    if (index != -1) {
      _workers[index] = worker;
      notifyListeners();
      await _saveWorkers();
    }
  }

  Future<void> deleteWorker(String id) async {
    _workers.removeWhere((w) => w.id == id);
    notifyListeners();
    await _saveWorkers();
  }

  Future<void> toggleStatus(String id) async {
    final index = _workers.indexWhere((w) => w.id == id);
    if (index != -1) {
      final w = _workers[index];
      _workers[index] = w.copyWith(
        status: w.status == WorkerStatus.active ? WorkerStatus.inactive : WorkerStatus.active
      );
      notifyListeners();
      await _saveWorkers();
    }
  }

  // Serialization helpers
  Map<String, dynamic> _workerToJson(Worker w) => {
    'id': w.id,
    'name': w.name,
    'phone': w.phone,
    'email': w.email,
    'skill': w.skill,
    'shift': w.shift.index,
    'rateType': w.rateType.index,
    'rateAmount': w.rateAmount,
    'status': w.status.index,
    'photoUrl': w.photoUrl,
    'assignedWorkTypes': w.assignedWorkTypes,
    'assignedSite': w.assignedSite,
    'siteId': w.siteId,
    'isActive': w.isActive,
    'permissions': w.permissions.toJson(),
  };

  Worker _workerFromJson(Map<String, dynamic> json) => Worker(
    id: json['id'],
    name: json['name'],
    phone: json['phone'],
    email: json['email'],
    skill: json['skill'],
    shift: WorkerShift.values[json['shift']],
    rateType: PayRateType.values[json['rateType']],
    rateAmount: json['rateAmount'],
    status: WorkerStatus.values[json['status']],
    photoUrl: json['photoUrl'],
    assignedWorkTypes: List<String>.from(json['assignedWorkTypes']),
    assignedSite: json['assignedSite'],
    siteId: json['siteId'],
    isActive: json['isActive'] ?? true,
    permissions: json['permissions'] != null 
        ? WorkerPermissionSet.fromJson(json['permissions']) 
        : const WorkerPermissionSet(),
  );
}
