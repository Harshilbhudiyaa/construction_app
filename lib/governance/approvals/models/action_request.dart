enum ApprovalStatus { pending, approved, rejected }

enum ActionType { add, edit, delete }

/// Represents a data mutation request submitted by an Engineer for Admin approval.
class ActionRequest {
  final String id;
  final String siteId;
  final String requesterId;
  final String requesterName;
  
  /// The collection or feature being modified (e.g., 'inventory', 'tools', 'workers').
  final String entityType;
  final ActionType action;
  
  /// The detailed data being added or changed.
  final Map<String, dynamic> payload;
  
  final ApprovalStatus status;
  final DateTime createdAt;
  final String? adminRemark;
  final DateTime? reviewedAt;

  const ActionRequest({
    required this.id,
    required this.siteId,
    required this.requesterId,
    required this.requesterName,
    required this.entityType,
    required this.action,
    required this.payload,
    this.status = ApprovalStatus.pending,
    required this.createdAt,
    this.adminRemark,
    this.reviewedAt,
  });

  ActionRequest copyWith({
    ApprovalStatus? status,
    String? adminRemark,
    DateTime? reviewedAt,
  }) {
    return ActionRequest(
      id: id,
      siteId: siteId,
      requesterId: requesterId,
      requesterName: requesterName,
      entityType: entityType,
      action: action,
      payload: payload,
      status: status ?? this.status,
      createdAt: createdAt,
      adminRemark: adminRemark ?? this.adminRemark,
      reviewedAt: reviewedAt ?? this.reviewedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'siteId': siteId,
      'requesterId': requesterId,
      'requesterName': requesterName,
      'entityType': entityType,
      'action': action.name,
      'payload': payload,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'adminRemark': adminRemark,
      'reviewedAt': reviewedAt?.toIso8601String(),
    };
  }

  factory ActionRequest.fromJson(Map<String, dynamic> json) {
    return ActionRequest(
      id: json['id'],
      siteId: json['siteId'],
      requesterId: json['requesterId'],
      requesterName: json['requesterName'],
      entityType: json['entityType'],
      action: ActionType.values.byName(json['action']),
      payload: Map<String, dynamic>.from(json['payload']),
      status: ApprovalStatus.values.byName(json['status']),
      createdAt: DateTime.parse(json['createdAt']),
      adminRemark: json['adminRemark'],
      reviewedAt: json['reviewedAt'] != null ? DateTime.parse(json['reviewedAt']) : null,
    );
  }
}
