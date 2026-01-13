/// Engineer & Workforce Model
class EngineerModel {
  final String id;
  final String name;
  final EngineerRole role;
  final PermissionSet permissions;
  final bool isActive;
  final String? email;
  final String? phone;
  final String? assignedSite;
  final DateTime createdAt;
  final DateTime? lastLogin;

  const EngineerModel({
    required this.id,
    required this.name,
    required this.role,
    required this.permissions,
    this.isActive = true,
    this.email,
    this.phone,
    this.assignedSite,
    required this.createdAt,
    this.lastLogin,
  });

  EngineerModel copyWith({
    String? id,
    String? name,
    EngineerRole? role,
    PermissionSet? permissions,
    bool? isActive,
    String? email,
    String? phone,
    String? assignedSite,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return EngineerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
      isActive: isActive ?? this.isActive,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      assignedSite: assignedSite ?? this.assignedSite,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role.displayName,
      'permissions': permissions.toJson(),
      'isActive': isActive,
      'email': email,
      'phone': phone,
      'assignedSite': assignedSite,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }

  factory EngineerModel.fromJson(Map<String, dynamic> json) {
    return EngineerModel(
      id: json['id'],
      name: json['name'],
      role: EngineerRole.values.firstWhere(
        (e) => e.displayName == json['role'],
        orElse: () => EngineerRole.siteEngineer,
      ),
      permissions: PermissionSet.fromJson(json['permissions']),
      isActive: json['isActive'] ?? true,
      email: json['email'],
      phone: json['phone'],
      assignedSite: json['assignedSite'],
      createdAt: DateTime.parse(json['createdAt']),
      lastLogin: json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
    );
  }
}

/// Engineer Roles
enum EngineerRole {
  siteEngineer('Site Engineer'),
  supervisor('Supervisor'),
  worker('Worker'),
  machineOperator('Machine Operator'),
  storeKeeper('Store Keeper'),
  other('Other Construction Roles');

  final String displayName;
  const EngineerRole(this.displayName);
}

/// Permission Set for Role-Based Access Control
class PermissionSet {
  final bool siteManagement;
  final bool workerManagement;
  final bool inventoryManagement;
  final bool toolMachineManagement;
  final bool reportViewing;
  final bool approvalVerification;
  final bool createSite;
  final bool editSite;

  const PermissionSet({
    this.siteManagement = false,
    this.workerManagement = false,
    this.inventoryManagement = false,
    this.toolMachineManagement = false,
    this.reportViewing = false,
    this.approvalVerification = false,
    this.createSite = false,
    this.editSite = false,
  });

  PermissionSet copyWith({
    bool? siteManagement,
    bool? workerManagement,
    bool? inventoryManagement,
    bool? toolMachineManagement,
    bool? reportViewing,
    bool? approvalVerification,
    bool? createSite,
    bool? editSite,
  }) {
    return PermissionSet(
      siteManagement: siteManagement ?? this.siteManagement,
      workerManagement: workerManagement ?? this.workerManagement,
      inventoryManagement: inventoryManagement ?? this.inventoryManagement,
      toolMachineManagement: toolMachineManagement ?? this.toolMachineManagement,
      reportViewing: reportViewing ?? this.reportViewing,
      approvalVerification: approvalVerification ?? this.approvalVerification,
      createSite: createSite ?? this.createSite,
      editSite: editSite ?? this.editSite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'siteManagement': siteManagement,
      'workerManagement': workerManagement,
      'inventoryManagement': inventoryManagement,
      'toolMachineManagement': toolMachineManagement,
      'reportViewing': reportViewing,
      'approvalVerification': approvalVerification,
      'createSite': createSite,
      'editSite': editSite,
    };
  }

  factory PermissionSet.fromJson(Map<String, dynamic> json) {
    return PermissionSet(
      siteManagement: json['siteManagement'] ?? false,
      workerManagement: json['workerManagement'] ?? false,
      inventoryManagement: json['inventoryManagement'] ?? false,
      toolMachineManagement: json['toolMachineManagement'] ?? false,
      reportViewing: json['reportViewing'] ?? false,
      approvalVerification: json['approvalVerification'] ?? false,
      createSite: json['createSite'] ?? false,
      editSite: json['editSite'] ?? false,
    );
  }

  bool get hasAnyPermission =>
      siteManagement ||
      workerManagement ||
      inventoryManagement ||
      toolMachineManagement ||
      reportViewing ||
      approvalVerification ||
      createSite ||
      editSite;
}
