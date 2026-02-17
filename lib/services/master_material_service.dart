import 'dart:async';
import '../modules/inventory/materials/models/master_material_model.dart';

class MasterMaterialService {
  static final MasterMaterialService _instance = MasterMaterialService._internal();
  factory MasterMaterialService() => _instance;
  MasterMaterialService._internal();

  // In-memory storage
  final List<MasterMaterial> _masterMaterials = [];
  final StreamController<List<MasterMaterial>> _materialsController = 
      StreamController<List<MasterMaterial>>.broadcast();

  Stream<List<MasterMaterial>> getMasterMaterialsStream() {
    // Emit current state immediately when someone subscribes
    Future.microtask(() => _emitUpdate());
    return _materialsController.stream;
  }

  void _emitUpdate() {
    final sortedMaterials = List<MasterMaterial>.from(_masterMaterials)
      ..sort((a, b) => a.name.compareTo(b.name));
    _materialsController.add(sortedMaterials);
  }

  Future<void> addMasterMaterial(MasterMaterial material) async {
    _masterMaterials.add(material);
    _emitUpdate();
  }

  Future<void> updateMasterMaterial(MasterMaterial material) async {
    final index = _masterMaterials.indexWhere((m) => m.id == material.id);
    if (index != -1) {
      _masterMaterials[index] = material;
      _emitUpdate();
    }
  }

  Future<void> deleteMasterMaterial(String id) async {
    _masterMaterials.removeWhere((m) => m.id == id);
    _emitUpdate();
  }

  void dispose() {
    _materialsController.close();
  }
}
