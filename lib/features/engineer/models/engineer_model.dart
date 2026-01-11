/// Engineer & Workforce Model
class EngineerModel {
  final String id;
  final String name;
  final EngineerRole role;
  final PermissionSet permissions;
  final bool isActive;
  final String? email;
  final String? phone;
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
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
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
