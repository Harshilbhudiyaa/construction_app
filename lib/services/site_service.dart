import 'package:flutter/material.dart';
import 'package:construction_app/governance/sites/site_model.dart';
import 'package:construction_app/profiles/engineer_model.dart';

class SiteService with ChangeNotifier {
  List<SiteModel> _sites = [
    SiteModel(
      id: 'S-001',
      name: 'Metropolis Heights',
      location: 'Mumbai, MH',
      rolePermissions: {
        EngineerRole.siteEngineer: const PermissionSet(
          siteManagement: true,
          workerManagement: true,
          inventoryManagement: true,
          reportViewing: true,
          approvalVerification: true,
        ),
        EngineerRole.supervisor: const PermissionSet(
          siteManagement: true,
          workerManagement: true,
          reportViewing: true,
        ),
      },
      assignedEngineerIds: ['eng-001', 'eng-002'],
    ),
    SiteModel(
      id: 'S-002',
      name: 'Site B North',
      location: 'Pune, MH',
      rolePermissions: {
        EngineerRole.siteEngineer: const PermissionSet(
          siteManagement: true,
          inventoryManagement: true,
          reportViewing: true,
        ),
      },
      assignedEngineerIds: ['eng-001'],
    ),
  ];

  List<SiteModel> get sites => List.unmodifiable(_sites);

  void addSite(SiteModel site) {
    if (!_sites.any((s) => s.id == site.id)) {
      _sites.add(site);
      notifyListeners();
    }
  }

  void updateSite(SiteModel site) {
    final index = _sites.indexWhere((s) => s.id == site.id);
    if (index != -1) {
      _sites[index] = site;
      notifyListeners();
    }
  }

  void deleteSite(String siteId) {
    _sites.removeWhere((s) => s.id == siteId);
    notifyListeners();
  }

  SiteModel? getSiteById(String id) {
    try {
      return _sites.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Returns effective permissions for an engineer at a specific site.
  PermissionSet getPermissionsForEngineer(String engineerId, EngineerRole role, String siteId) {
    final site = getSiteById(siteId);
    if (site == null) return const PermissionSet();
    
    // Check if engineer is actually assigned to this site
    if (!site.assignedEngineerIds.contains(engineerId)) return const PermissionSet();

    // Return the role-specific permissions defined for this site
    return site.rolePermissions[role] ?? const PermissionSet();
  }

  /// Admin method to update permissions for a role at a site
  void updateRolePermissions(String siteId, EngineerRole role, PermissionSet newPerms) {
    final idx = _sites.indexWhere((s) => s.id == siteId);
    if (idx != -1) {
      final updatedPerms = Map<EngineerRole, PermissionSet>.from(_sites[idx].rolePermissions);
      updatedPerms[role] = newPerms;
      _sites[idx] = _sites[idx].copyWith(rolePermissions: updatedPerms);
      notifyListeners();
    }
  }

  /// Alias for updateRolePermissions for compatibility
  void updatePermissions(String siteId, EngineerRole role, PermissionSet newPerms) {
    updateRolePermissions(siteId, role, newPerms);
  }

  List<SiteModel> getSitesForEngineer(String engineerId) {
    return _sites.where((s) => s.assignedEngineerIds.contains(engineerId)).toList();
  }

  Future<void> assignEngineer(String siteId, String engineerId) async {
    final idx = _sites.indexWhere((s) => s.id == siteId);
    if (idx != -1) {
      if (!_sites[idx].assignedEngineerIds.contains(engineerId)) {
        final updatedIds = List<String>.from(_sites[idx].assignedEngineerIds)..add(engineerId);
        _sites[idx] = _sites[idx].copyWith(assignedEngineerIds: updatedIds);
        notifyListeners();
      }
    }
  }

  Future<void> unassignEngineer(String siteId, String engineerId) async {
    final idx = _sites.indexWhere((s) => s.id == siteId);
    if (idx != -1) {
      if (_sites[idx].assignedEngineerIds.contains(engineerId)) {
        final updatedIds = List<String>.from(_sites[idx].assignedEngineerIds)..remove(engineerId);
        _sites[idx] = _sites[idx].copyWith(assignedEngineerIds: updatedIds);
        notifyListeners();
      }
    }
  }

  /// Audits all assigned engineers at a site for role/permission inconsistencies.
  List<PermissionAuditResult> auditSitePermissions(String siteId, List<EngineerModel> allEngineers) {
    final site = getSiteById(siteId);
    if (site == null) return [];

    final results = <PermissionAuditResult>[];
    for (final engId in site.assignedEngineerIds) {
      final eng = allEngineers.firstWhere((e) => e.id == engId, orElse: () => throw 'Engineer not found');
      final currentPerms = site.rolePermissions[eng.role] ?? const PermissionSet();
      final mandatory = eng.role.mandatoryPermissions;

      // Check for missing mandatory perms
      final missing = <String>[];
      if (mandatory.workerManagement && !currentPerms.workerManagement) missing.add('Worker Management');
      if (mandatory.inventoryManagement && !currentPerms.inventoryManagement) missing.add('Inventory Management');
      if (mandatory.toolMachineManagement && !currentPerms.toolMachineManagement) missing.add('Asset Control');
      if (mandatory.reportViewing && !currentPerms.reportViewing) missing.add('Financial Visibility');
      if (mandatory.siteManagement && !currentPerms.siteManagement) missing.add('Site Management');

      if (missing.isNotEmpty) {
        results.add(PermissionAuditResult(
          engineerId: eng.id,
          engineerName: eng.name,
          role: eng.role,
          issue: 'Inconsistent Permissions',
          details: 'Mandatory modules for ${eng.role.displayName} are currently hidden: ${missing.join(", ")}',
          isResolved: false,
        ));
      }
    }
    return results;
  }

  /// Verifies if an engineer has access to a specific site.
  bool verifySiteAccess(String engineerId, String siteId) {
    final site = getSiteById(siteId);
    return site?.assignedEngineerIds.contains(engineerId) ?? false;
  }
}

class PermissionAuditResult {
  final String engineerId;
  final String engineerName;
  final EngineerRole role;
  final String issue;
  final String details;
  final bool isResolved;

  PermissionAuditResult({
    required this.engineerId,
    required this.engineerName,
    required this.role,
    required this.issue,
    required this.details,
    required this.isResolved,
  });
}
