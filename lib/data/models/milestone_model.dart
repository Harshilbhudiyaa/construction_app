enum MilestoneStatus { upcoming, dueSoon, overdue, paid }

class MilestoneModel {
  final String id;
  final String siteId;
  final String siteName;
  final String title;
  final String? description;
  final DateTime dueDate;
  final double amount;
  final bool isPaid;
  final DateTime? paidOn;

  MilestoneModel({
    required this.id,
    required this.siteId,
    required this.siteName,
    required this.title,
    this.description,
    required this.dueDate,
    required this.amount,
    this.isPaid = false,
    this.paidOn,
  });

  MilestoneStatus get status {
    if (isPaid) return MilestoneStatus.paid;
    final now = DateTime.now();
    final diff = dueDate.difference(now).inDays;
    if (diff < 0) return MilestoneStatus.overdue;
    if (diff <= 7) return MilestoneStatus.dueSoon;
    return MilestoneStatus.upcoming;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'siteId': siteId,
        'siteName': siteName,
        'title': title,
        'description': description,
        'dueDate': dueDate.toIso8601String(),
        'amount': amount,
        'isPaid': isPaid,
        'paidOn': paidOn?.toIso8601String(),
      };

  factory MilestoneModel.fromJson(Map<String, dynamic> json) => MilestoneModel(
        id: json['id'] as String,
        siteId: json['siteId'] as String,
        siteName: json['siteName'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        dueDate: DateTime.parse(json['dueDate'] as String),
        amount: (json['amount'] as num).toDouble(),
        isPaid: json['isPaid'] as bool? ?? false,
        paidOn: json['paidOn'] != null
            ? DateTime.parse(json['paidOn'] as String)
            : null,
      );

  MilestoneModel copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    double? amount,
    bool? isPaid,
    DateTime? paidOn,
  }) {
    return MilestoneModel(
      id: id,
      siteId: siteId,
      siteName: siteName,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      amount: amount ?? this.amount,
      isPaid: isPaid ?? this.isPaid,
      paidOn: paidOn ?? this.paidOn,
    );
  }
}
