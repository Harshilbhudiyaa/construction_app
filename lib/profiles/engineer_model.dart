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
  final String? customRoleName;
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
    this.customRoleName,
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
    String? customRoleName,
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
      customRoleName: customRoleName ?? this.customRoleName,
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
      'customRoleName': customRoleName,
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
      customRoleName: json['customRoleName'],
      createdAt: DateTime.parse(json['createdAt']),
      lastLogin: json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
    );
  }
}

enum EngineerRole {
  projectManager('Project Manager'),
  siteEngineer('Site Engineer'),
  supervisor('Supervisor'),
  inventoryManager('Inventory Manager'),
  worker('Worker'),
  machineOperator('Machine Operator'),
  storeKeeper('Store Keeper'),
  financeHandler('Finance Handler'),
  workerCoordinator('Worker Coordinator'),
  other('Other Construction Roles');

  final String displayName;
  const EngineerRole(this.displayName);

  PermissionSet get mandatoryPermissions {
    switch (this) {
      case EngineerRole.projectManager:
      case EngineerRole.siteEngineer:
        return const PermissionSet(siteManagement: true, reportViewing: true);
      case EngineerRole.supervisor:
        return const PermissionSet(siteManagement: true);
      case EngineerRole.inventoryManager:
      case EngineerRole.storeKeeper:
        return const PermissionSet(inventoryManagement: true);
      case EngineerRole.machineOperator:
        return const PermissionSet(toolMachineManagement: true);
      case EngineerRole.financeHandler:
        return const PermissionSet(reportViewing: true);
      case EngineerRole.workerCoordinator:
        return const PermissionSet(workerManagement: true);
      case EngineerRole.worker:
        return const PermissionSet(reportViewing: true);
      case EngineerRole.other:
        return const PermissionSet();
    }
  }

  List<String> get requiredModuleIds {
    switch (this) {
      case EngineerRole.projectManager:
        return ['Dashboard', 'Approvals', 'Workers', 'Inventory', 'Inward Logs', 'Tools', 'Machines', 'Financials'];
      case EngineerRole.siteEngineer:
        return ['Dashboard', 'Approvals', 'Workers', 'Inventory', 'Inward Logs', 'Financials'];
      case EngineerRole.supervisor:
        return ['Dashboard', 'Workers', 'Tools'];
      case EngineerRole.inventoryManager:
        return ['Dashboard', 'Inventory', 'Inward Logs', 'Tools', 'Machines'];
      case EngineerRole.storeKeeper:
        return ['Dashboard', 'Inventory', 'Inward Logs'];
      case EngineerRole.machineOperator:
        return ['Dashboard', 'Machines', 'Tools'];
      case EngineerRole.financeHandler:
        return ['Dashboard', 'Financials'];
      case EngineerRole.workerCoordinator:
        return ['Dashboard', 'Workers'];
      case EngineerRole.worker:
        return ['Dashboard'];
      case EngineerRole.other:
        return ['Dashboard'];
    }
  }
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
