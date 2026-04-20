import 'package:construction_app/core/utils/date_parser.dart';
import 'package:uuid/uuid.dart';

class CalculationHistory {
  final String id;
  final String title;
  final String category;
  final DateTime timestamp;
  final Map<String, String> data;
  final double totalCost;

  CalculationHistory({
    String? id,
    required this.title,
    required this.category,
    required this.timestamp,
    required this.data,
    required this.totalCost,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'timestamp': timestamp.toIso8601String(),
        'data': data,
        'totalCost': totalCost,
      };

  factory CalculationHistory.fromJson(Map<String, dynamic> json) => CalculationHistory(
        id: json['id'],
        title: json['title'],
        category: json['category'],
        timestamp: DateParser.parse(json['timestamp']),
        data: Map<String, String>.from(json['data']),
        totalCost: (json['totalCost'] as num).toDouble(),
      );
}
