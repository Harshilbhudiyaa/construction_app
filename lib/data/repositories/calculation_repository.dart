import 'package:flutter/material.dart';
import '../models/calculation_history_model.dart';

class CalculationRepository with ChangeNotifier {
  final List<CalculationHistory> _history = [];

  List<CalculationHistory> get history => List.unmodifiable(_history.reversed);

  void saveCalculation({
    required String title,
    required String category,
    required Map<String, String> data,
    required double totalCost,
  }) {
    final newEntry = CalculationHistory(
      title: title,
      category: category,
      timestamp: DateTime.now(),
      data: data,
      totalCost: totalCost,
    );
    _history.add(newEntry);
    notifyListeners();
  }

  void deleteCalculation(String id) {
    _history.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
  }
}
