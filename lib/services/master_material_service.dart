import 'package:firebase_database/firebase_database.dart';
import '../modules/inventory/models/master_material_model.dart';
import '../modules/inventory/models/material_model.dart';

class MasterMaterialService {
  final _db = FirebaseDatabase.instance.ref();

  Stream<List<MasterMaterial>> getMasterMaterialsStream() {
    return _db.child('inventory').child('master_materials').onValue.map<List<MasterMaterial>>((event) {
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

      return data.entries
          .where((e) => e.value != null)
          .map((e) => MasterMaterial.fromJson(Map<String, dynamic>.from(e.value as Map)))
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    }).asBroadcastStream();
  }

  Future<void> addMasterMaterial(MasterMaterial material) async {
    await _db.child('inventory').child('master_materials').child(material.id).set(material.toJson());
  }

  Future<void> updateMasterMaterial(MasterMaterial material) async {
    await _db.child('inventory').child('master_materials').child(material.id).update(material.toJson());
  }

  Future<void> deleteMasterMaterial(String id) async {
    await _db.child('inventory').child('master_materials').child(id).remove();
  }
}
