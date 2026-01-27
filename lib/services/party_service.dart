import 'package:firebase_database/firebase_database.dart';
import '../modules/inventory/models/party_model.dart';

class PartyService {
  final _db = FirebaseDatabase.instance.ref();

  Stream<List<PartyModel>> getPartiesStream() {
    return _db.child('parties').onValue.map<List<PartyModel>>((event) {
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
          .map((e) {
        final map = Map<String, dynamic>.from(e.value as Map);
        return PartyModel.fromJson(map);
      }).toList()..sort((a, b) => a.name.compareTo(b.name));
    }).asBroadcastStream();
  }

  Future<void> addParty(PartyModel party) async {
    await _db.child('parties').child(party.id).set(party.toJson());
  }

  Future<void> updateParty(PartyModel party) async {
    await _db.child('parties').child(party.id).update(party.toJson());
  }

  Future<void> deleteParty(String partyId) async {
    await _db.child('parties').child(partyId).remove();
  }
}
