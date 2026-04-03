import 'package:flutter/material.dart';

enum AppMode {
  simple('Simple Mode', Icons.flash_on_rounded),
  advanced('Advanced Mode', Icons.settings_suggest_rounded);

  final String label;
  final IconData icon;
  const AppMode(this.label, this.icon);

  static AppMode fromString(String? mode) {
    if (mode?.toLowerCase() == 'advanced') return AppMode.advanced;
    return AppMode.simple;
  }
}

enum UserRole {
  admin('Admin', Icons.admin_panel_settings_rounded),
  manager('Manager', Icons.manage_accounts_rounded),
  siteEngineer('Site Engineer', Icons.engineering_rounded),
  storekeeper('Storekeeper', Icons.inventory_rounded),
  contractor('Contractor', Icons.handyman_rounded);

  final String label;
  final IconData icon;
  const UserRole(this.label, this.icon);

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'manager':
        return UserRole.manager;
      case 'siteengineer':
      case 'site engineer':
        return UserRole.siteEngineer;
      case 'storekeeper':
        return UserRole.storekeeper;
      case 'contractor':
        return UserRole.contractor;
      default:
        return UserRole.storekeeper;
    }
  }
}


class UserModel {
  final String id;
  final String name;
  final UserRole role;
  final String? email;
  final DateTime? lastLogin;

  const UserModel({
    required this.id,
    required this.name,
    required this.role,
    this.email,
    this.lastLogin,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role.name,
      'email': email,
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      role: UserRole.fromString(json['role']),
      email: json['email'],
      lastLogin: json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
    );
  }
}
