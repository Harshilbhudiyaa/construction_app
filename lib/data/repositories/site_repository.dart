import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:construction_app/data/models/site_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SiteRepository extends ChangeNotifier {
  static const String _selectedSiteKey = 'app_selected_site_v1';
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<SiteModel> _sites = [];
  String? _selectedSiteId;
  bool _isLoading = true;

  List<SiteModel> get sites => _sites;
  String? get selectedSiteId => _selectedSiteId;
  bool get isLoading => _isLoading;

  SiteModel? get selectedSite {
    if (_selectedSiteId == null && _sites.isNotEmpty) return _sites.first;
    return _sites.where((s) => s.id == _selectedSiteId).firstOrNull ??
        (_sites.isNotEmpty ? _sites.first : null);
  }

  StreamSubscription? _sub;

  SiteRepository() {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedSiteId = prefs.getString(_selectedSiteKey);

    _sub = _db
        .collection('sites')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snap) {
      _sites = snap.docs
          .map((d) => SiteModel.fromJson({...d.data(), 'id': d.id}))
          .toList();
      _isLoading = false;
      if (_selectedSiteId == null && _sites.isNotEmpty) {
        _selectedSiteId = _sites.first.id;
      }
      notifyListeners();
    }, onError: (e) {
      debugPrint('SiteRepository stream error: $e');
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addSite(SiteModel site) async {
    final data = site.toJson();
    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _db.collection('sites').doc(site.id).set(data);
  }

  Future<void> updateSite(SiteModel site) async {
    final data = site.toJson();
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _db.collection('sites').doc(site.id).update(data);
  }

  Future<void> deleteSite(String siteId) async {
    await _db.collection('sites').doc(siteId).delete();
    if (_selectedSiteId == siteId) {
      _selectedSiteId = _sites.isNotEmpty ? _sites.first.id : null;
      notifyListeners();
    }
  }

  Future<void> selectSite(String siteId) async {
    _selectedSiteId = siteId;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedSiteKey, siteId);
  }

  String getSiteName(String siteId) {
    try {
      return _sites.firstWhere((s) => s.id == siteId).name;
    } catch (_) {
      return _sites.isNotEmpty ? _sites.first.name : 'Unknown Site';
    }
  }

  SiteModel? getSiteById(String id) {
    try {
      return _sites.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
