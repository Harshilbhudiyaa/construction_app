import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:construction_app/data/models/site_model.dart';

class SiteRepository extends ChangeNotifier {
  static const String _sitesKey = 'app_sites_v1';
  static const String _selectedSiteKey = 'app_selected_site_v1';
  List<SiteModel> _sites = [];
  String? _selectedSiteId;
  bool _isLoading = true;

  List<SiteModel> get sites => _sites;
  String? get selectedSiteId => _selectedSiteId;
  bool get isLoading => _isLoading;

  SiteModel? get selectedSite {
    if (_selectedSiteId == null && _sites.isNotEmpty) return _sites.first;
    return _sites.where((s) => s.id == _selectedSiteId).firstOrNull ?? (_sites.isNotEmpty ? _sites.first : null);
  }

  SiteRepository() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString(_sitesKey);
      if (data != null) {
        final List<dynamic> decoded = jsonDecode(data);
        _sites = decoded.map((item) => SiteModel.fromJson(Map<String, dynamic>.from(item))).toList();
      } else {
        _sites = [];
        await _saveToPrefs();
      }
      
      _selectedSiteId = prefs.getString(_selectedSiteKey);
      if (_selectedSiteId == null && _sites.isNotEmpty) {
        _selectedSiteId = _sites.first.id;
      }
    } catch (e) {
      debugPrint('Error loading sites: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(_sites.map((s) => s.toJson()).toList());
      await prefs.setString(_sitesKey, encoded);
    } catch (e) {
      debugPrint('Error saving sites: $e');
    }
  }

  Future<void> addSite(SiteModel site) async {
    _sites.insert(0, site);
    notifyListeners();
    await _saveToPrefs();
  }

  Future<void> updateSite(SiteModel site) async {
    final index = _sites.indexWhere((s) => s.id == site.id);
    if (index != -1) {
      _sites[index] = site;
      notifyListeners();
      await _saveToPrefs();
    }
  }

  Future<void> deleteSite(String siteId) async {
    _sites.removeWhere((s) => s.id == siteId);
    if (_selectedSiteId == siteId) {
      _selectedSiteId = _sites.isNotEmpty ? _sites.first.id : null;
    }
    notifyListeners();
    await _saveToPrefs();
  }

  Future<void> selectSite(String siteId) async {
    _selectedSiteId = siteId;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedSiteKey, siteId);
  }


  List<SiteModel> _getDemoSites() {
    return [];
  }
  String getSiteName(String siteId) {
    return _sites.firstWhere((s) => s.id == siteId, orElse: () => _sites.first).name;
  }

  SiteModel? getSiteById(String id) {
    try {
      return _sites.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}
