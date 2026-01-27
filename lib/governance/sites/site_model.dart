import 'package:construction_app/profiles/engineer_model.dart';

/// Represents a construction site with specific modular permissions per role.
class SiteModel {
  final String id;
  final String name;
  final String location;
  
  /// Maps each role to its specific permissions on THIS site.
  /// Admin can toggle modules like 'Inventory', 'Financials' etc. per site.
  final Map<EngineerRole, PermissionSet> rolePermissions;
  
  /// List of Engineer IDs assigned to this site.
  final List<String> assignedEngineerIds;

  const SiteModel({
    required this.id,
    required this.name,
    required this.location,
    required this.rolePermissions,
    this.assignedEngineerIds = const [],
  });

  SiteModel copyWith({
    String? id,
    String? name,
    String? location,
    Map<EngineerRole, PermissionSet>? rolePermissions,
    List<String>? assignedEngineerIds,
  }) {
    return SiteModel(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      rolePermissions: rolePermissions ?? this.rolePermissions,
      assignedEngineerIds: assignedEngineerIds ?? this.assignedEngineerIds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'rolePermissions': rolePermissions.map((key, value) => MapEntry(key.name, value.toJson())),
      'assignedEngineerIds': assignedEngineerIds,
    };
  }

  factory SiteModel.fromJson(Map<String, dynamic> json) {
    final rolePerms = (json['rolePermissions'] as Map<String, dynamic>).map(
      (key, value) => MapEntry(
        EngineerRole.values.byName(key),
        PermissionSet.fromJson(value as Map<String, dynamic>),
      ),
    );

    return SiteModel(
      id: json['id'],
      name: json['name'],
      location: json['location'],
      rolePermissions: rolePerms,
      assignedEngineerIds: List<String>.from(json['assignedEngineerIds'] ?? []),
    );
  }
}
