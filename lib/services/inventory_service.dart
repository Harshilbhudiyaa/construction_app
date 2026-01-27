import 'package:firebase_database/firebase_database.dart';
import 'package:construction_app/modules/inventory/models/inward_movement_model.dart';
import 'package:construction_app/modules/inventory/models/material_model.dart';

class InventoryService {
  final _db = FirebaseDatabase.instance.ref();

  // --- Inward Logs ---

  Stream<List<InwardMovementModel>> getInwardLogsStream({String? siteId}) {
    return _db.child('inward_logs').onValue.map<List<InwardMovementModel>>((event) {
      final value = event.snapshot.value;
      if (value == null) return [];
      
      final Map<dynamic, dynamic> data;
      if (value is Map) {
        data = value;
      } else if (value is List) {
        data = value.asMap();
      } else {
        return [];
      }

      final logs = data.entries
          .where((e) => e.value != null)
          .map((e) {
        final map = Map<String, dynamic>.from(e.value as Map);
        return InwardMovementModel.fromJson(map);
      }).toList();

      if (siteId != null) {
        return logs.where((l) => l.siteId == siteId).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }

      return logs..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }).asBroadcastStream();
  }

  Future<void> saveInwardLog(InwardMovementModel log) async {
    await _db.child('inward_logs').child(log.id).set(log.toJson());
  }

  Future<void> approveInwardLog(String logId, String approvedBy) async {
    final snapshot = await _db.child('inward_logs').child(logId).get();
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final log = InwardMovementModel.fromJson(data);
      
      final updatedLog = log.copyWith(
        status: InwardStatus.approved,
        approvedBy: approvedBy,
        approvedAt: DateTime.now(),
      );

      // 1. Update Log Status
      await _db.child('inward_logs').child(logId).set(updatedLog.toJson());

      // 2. Synchronize with Inventory
      await _updateMaterialStock(log.materialName, log.quantity);
    }
  }

  Future<void> _updateMaterialStock(String materialName, double additionalQty) async {
    final snapshot = await _db.child('inventory').child('materials').get();
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      for (final entry in data.entries) {
        final map = Map<String, dynamic>.from(entry.value);
        if (map['name'] == materialName) {
          final material = ConstructionMaterial.fromJson(map);
          final updatedStock = material.currentStock + additionalQty;
          await updateMaterial(material.copyWith(currentStock: updatedStock));
          break;
        }
      }
    }
  }

  // --- Inventory (Removed legacy methods) ---
}

// --- Construction Materials (New Module) ---

extension MaterialsExtension on InventoryService {

  Stream<List<ConstructionMaterial>> getMaterialsStream({String? siteId}) {
    return _db.child('inventory').child('materials').onValue.map<List<ConstructionMaterial>>((event) {
      final value = event.snapshot.value;
      if (value == null) return [];
  
      final Map<dynamic, dynamic> data;
      if (value is Map) {
        data = value;
      } else if (value is List) {
        data = value.asMap();
      } else {
        return [];
      }

      final materials = data.entries
          .where((e) => e.value != null)
          .map((e) {
        final map = Map<String, dynamic>.from(e.value as Map);
        return ConstructionMaterial.fromJson(map);
      }).toList();

      if (siteId != null) {
        return materials.where((m) => m.siteId == siteId).toList()
          ..sort((a, b) => a.name.compareTo(b.name));
      }

      return materials..sort((a, b) => a.name.compareTo(b.name));
    }).asBroadcastStream();
  }

  Stream<ConstructionMaterial?> getMaterialStream(String materialId) {
    return _db.child('inventory').child('materials').child(materialId).onValue.map<ConstructionMaterial?>((event) {
      final data = event.snapshot.value;
      if (data == null || data is! Map) return null;
      return ConstructionMaterial.fromJson(Map<String, dynamic>.from(data));
    }).asBroadcastStream();
  }

  Future<void> addMaterial(ConstructionMaterial material) async {
    await _db.child('inventory').child('materials').child(material.id).set(material.toJson());
  }

  Future<void> updateMaterial(ConstructionMaterial material) async {
    await _db.child('inventory').child('materials').child(material.id).update(material.toJson());
  }

  Future<void> deleteMaterial(String materialId) async {
    await _db.child('inventory').child('materials').child(materialId).remove();
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
}
