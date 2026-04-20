import 'package:construction_app/core/utils/date_parser.dart';

enum LedgerEntryType { credit, debit }

class LedgerEntryModel {
  final String id;
  final String partyId;
  final String partyName;
  final String? siteId;
  final String? siteName;
  final double amount;
  final LedgerEntryType type;
  final String description;
  final DateTime date;

  LedgerEntryModel({
    required this.id,
    required this.partyId,
    required this.partyName,
    this.siteId,
    this.siteName,
    required this.amount,
    required this.type,
    required this.description,
    required this.date,
  });

  bool get isCredit => type == LedgerEntryType.credit;

  Map<String, dynamic> toJson() => {
        'id': id,
        'partyId': partyId,
        'partyName': partyName,
        'siteId': siteId,
        'siteName': siteName,
        'amount': amount,
        'type': type.name,
        'description': description,
        'date': date.toIso8601String(),
      };

  factory LedgerEntryModel.fromJson(Map<String, dynamic> json) =>
      LedgerEntryModel(
        id: json['id'] as String,
        partyId: json['partyId'] as String,
        partyName: json['partyName'] as String,
        siteId: json['siteId'] as String?,
        siteName: json['siteName'] as String?,
        amount: (json['amount'] as num).toDouble(),
        type: LedgerEntryType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => LedgerEntryType.debit,
        ),
        description: json['description'] as String,
        date: DateParser.parse(json['date']),
      );

  LedgerEntryModel copyWith({
    String? description,
    double? amount,
    LedgerEntryType? type,
    DateTime? date,
    String? siteId,
    String? siteName,
  }) {
    return LedgerEntryModel(
      id: id,
      partyId: partyId,
      partyName: partyName,
      siteId: siteId ?? this.siteId,
      siteName: siteName ?? this.siteName,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      description: description ?? this.description,
      date: date ?? this.date,
    );
  }
}
