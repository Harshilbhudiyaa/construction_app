import 'package:construction_app/core/utils/date_parser.dart';

enum PaymentStatus {
  success,
  pending,
  failed
}

enum PaymentType {
  given,    // e.g., to Suppliers
  received  // e.g., from Customers
}

class PaymentModel {
  final String id;
  final String partyId;
  final String partyName;
  final String siteId;
  final String siteName;
  final double amount;
  final PaymentStatus status;
  final PaymentType type;
  final String? billImageUrl;
  final String? remarks;
  final DateTime timestamp;

  PaymentModel({
    required this.id,
    required this.partyId,
    required this.partyName,
    required this.siteId,
    required this.siteName,
    required this.amount,
    required this.status,
    required this.type,
    this.billImageUrl,
    this.remarks,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'partyId': partyId,
      'partyName': partyName,
      'siteId': siteId,
      'siteName': siteName,
      'amount': amount,
      'status': status.name,
      'type': type.name,
      'billImageUrl': billImageUrl,
      'remarks': remarks,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'],
      partyId: json['partyId'],
      partyName: json['partyName'],
      siteId: json['siteId'],
      siteName: json['siteName'],
      amount: (json['amount'] as num).toDouble(),
      status: PaymentStatus.values.firstWhere((e) => e.name == json['status'], orElse: () => PaymentStatus.pending),
      type: PaymentType.values.firstWhere((e) => e.name == json['type'], orElse: () => PaymentType.given),
      billImageUrl: json['billImageUrl'],
      remarks: json['remarks'],
      timestamp: DateParser.parse(json['timestamp']),
    );
  }
}
