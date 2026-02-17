import 'dart:async';
import '../modules/inventory/parties/models/party_model.dart';

class PartyService {
  static final PartyService _instance = PartyService._internal();
  factory PartyService() => _instance;
  PartyService._internal();

  // In-memory storage
  final List<PartyModel> _parties = [];
  final StreamController<List<PartyModel>> _partiesController = 
      StreamController<List<PartyModel>>.broadcast();

  Stream<List<PartyModel>> getPartiesStream() {
    // Emit current state immediately when someone subscribes
    Future.microtask(() => _emitUpdate());
    return _partiesController.stream;
  }

  void _emitUpdate() {
    final sortedParties = List<PartyModel>.from(_parties)
      ..sort((a, b) => a.name.compareTo(b.name));
    _partiesController.add(sortedParties);
  }

  Future<void> addParty(PartyModel party) async {
    _parties.add(party);
    _emitUpdate();
  }

  Future<void> updateParty(PartyModel party) async {
    final index = _parties.indexWhere((p) => p.id == party.id);
    if (index != -1) {
      _parties[index] = party;
      _emitUpdate();
    }
  }

  Future<void> deleteParty(String partyId) async {
    _parties.removeWhere((p) => p.id == partyId);
    _emitUpdate();
  }

  void dispose() {
    _partiesController.close();
  }
}
