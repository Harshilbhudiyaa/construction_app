import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:construction_app/modules/resources/tool_model.dart';

class MockToolService extends ChangeNotifier {
  static const String _storageKey = 'construction_tools_data';
  List<ToolModel> _tools = [];
  bool _isLoading = true;

  List<ToolModel> get tools => _tools;
  bool get isLoading => _isLoading;

  MockToolService() {
    _init();
  }

  Future<void> _init() async {
    await _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString(_storageKey);
      
      if (data != null) {
        final List<dynamic> decoded = jsonDecode(data);
        _tools = decoded.map((item) => _fromJson(item)).toList();
      } else {
        _tools = _getInitialDemoData();
        await _saveToPrefs();
      }
    } catch (e) {
      debugPrint('Error loading tools: $e');
      _tools = _getInitialDemoData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(_tools.map((t) => _toJson(t)).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (e) {
      debugPrint('Error saving tools: $e');
    }
  }

  void addTool(ToolModel tool) {
    _tools.insert(0, tool);
    notifyListeners();
    _saveToPrefs();
  }

  void updateTool(ToolModel tool) {
    final index = _tools.indexWhere((t) => t.id == tool.id);
    if (index != -1) {
      _tools[index] = tool;
      notifyListeners();
      _saveToPrefs();
    }
  }

  void deleteTool(String id) {
    _tools.removeWhere((t) => t.id == id);
    notifyListeners();
    _saveToPrefs();
  }

  List<ToolModel> _getInitialDemoData() {
    return [
      ToolModel(
        id: '1',
        name: 'Electric Drill Set',
        type: ToolType.powerTool,
        usagePurpose: 'Drilling holes in concrete and wood',
        assignedSiteId: 'site1',
        assignedSiteName: 'Metropolis Heights',
        assignedEngineerId: 'eng1',
        assignedEngineerName: 'Rajesh Kumar',
        quantity: 5,
        availableQuantity: 2,
        condition: ToolCondition.good,
        lastInspectionDate: DateTime.now().subtract(const Duration(days: 15)),
      ),
      ToolModel(
        id: '2',
        name: 'Safety Helmets',
        type: ToolType.safetyEquipment,
        usagePurpose: 'Worker head protection',
        quantity: 50,
        availableQuantity: 18,
        condition: ToolCondition.excellent,
        lastInspectionDate: DateTime.now().subtract(const Duration(days: 10)),
      ),
      ToolModel(
        id: '3',
        name: 'Measuring Tape (50m)',
        type: ToolType.measuringTool,
        usagePurpose: 'Site measurements and layout',
        assignedSiteId: 'site2',
        assignedSiteName: 'Skyline Plaza',
        quantity: 10,
        availableQuantity: 7,
        condition: ToolCondition.good,
        lastInspectionDate: DateTime.now().subtract(const Duration(days: 30)),
      ),
      ToolModel(
        id: '4',
        name: 'Welding Machine',
        type: ToolType.weldingEquipment,
        usagePurpose: 'Steel fabrication and welding',
        assignedSiteId: 'site1',
        assignedSiteName: 'Metropolis Heights',
        quantity: 3,
        availableQuantity: 1,
        condition: ToolCondition.fair,
        lastInspectionDate: DateTime.now().subtract(const Duration(days: 35)),
      ),
      ToolModel(
        id: '5',
        name: 'Ladder (Extension)',
        type: ToolType.ladderScaffold,
        usagePurpose: 'Height access for construction',
        quantity: 8,
        availableQuantity: 3,
        condition: ToolCondition.good,
        lastInspectionDate: DateTime.now().subtract(const Duration(days: 20)),
      ),
    ];
  }

  // Helper mappers since the model doesn't have them in the specific format I want for storage
  Map<String, dynamic> _toJson(ToolModel tool) {
    return {
      'id': tool.id,
      'name': tool.name,
      'type': tool.type.name,
      'usagePurpose': tool.usagePurpose,
      'assignedEngineerId': tool.assignedEngineerId,
      'assignedEngineerName': tool.assignedEngineerName,
      'assignedSiteId': tool.assignedSiteId,
      'assignedSiteName': tool.assignedSiteName,
      'quantity': tool.quantity,
      'availableQuantity': tool.availableQuantity,
      'condition': tool.condition.name,
      'lastInspectionDate': tool.lastInspectionDate.toIso8601String(),
    };
  }

  ToolModel _fromJson(Map<String, dynamic> json) {
    return ToolModel(
      id: json['id'],
      name: json['name'],
      type: ToolType.values.firstWhere((e) => e.name == json['type']),
      usagePurpose: json['usagePurpose'],
      assignedEngineerId: json['assignedEngineerId'],
      assignedEngineerName: json['assignedEngineerName'],
      assignedSiteId: json['assignedSiteId'],
      assignedSiteName: json['assignedSiteName'],
      quantity: json['quantity'],
      availableQuantity: json['availableQuantity'],
      condition: ToolCondition.values.firstWhere((e) => e.name == json['condition']),
      lastInspectionDate: DateTime.parse(json['lastInspectionDate']),
    );
  }
}
