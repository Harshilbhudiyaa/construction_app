import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:construction_app/data/models/user_model.dart';

/// Authentication service for managing user sessions
/// Handles login persistence across app restarts
class AuthRepository extends ChangeNotifier {
  static final AuthRepository _instance = AuthRepository._internal();
  factory AuthRepository() => _instance;

  AuthRepository._internal() {
    _initFuture = _loadSession();
  }

  String? _userId;
  String? _userName;
  UserRole? _userRole;
  AppMode _appMode = AppMode.simple;
  bool _isLoggedIn = false;
  bool _initialized = false;
  late final Future<void> _initFuture;

  Future<void> get initialization => _initFuture;

  String? get userId => _userId;
  String? get userName => _userName;
  UserRole? get userRole => _userRole;
  AppMode get appMode => _appMode;
  bool get isAdvancedMode => _appMode == AppMode.advanced;
  bool get isLoggedIn => _isLoggedIn;
  bool get initialized => _initialized;

  Future<void> toggleAppMode() async {
    _appMode = _appMode == AppMode.simple ? AppMode.advanced : AppMode.simple;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_mode', _appMode.name);
    notifyListeners();
  }


  // Permission Checks
  bool get isAdmin => _userRole == UserRole.admin;
  bool get canApprove => _userRole == UserRole.admin;
  bool get canEdit => _userRole == UserRole.admin || _userRole == UserRole.manager;
  bool get canDelete => _userRole == UserRole.admin;
  bool get canCreateEntry => _isLoggedIn; // Admin, Manager, Storekeeper, Engineer
  bool get canManageLabour => _userRole == UserRole.admin || _userRole == UserRole.manager;
  bool get canViewReports  => _userRole == UserRole.admin || _userRole == UserRole.manager;
  bool get canSettleLabour => _userRole == UserRole.admin;

  Future<void> _loadSession() async {
    if (_initialized) return;

    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('user_id');
    _userName = prefs.getString('user_name');
    final roleStr = prefs.getString('user_role');
    _userRole = roleStr != null ? UserRole.fromString(roleStr) : null;
    final modeStr = prefs.getString('app_mode');
    _appMode = AppMode.fromString(modeStr);
    _isLoggedIn = _userId != null && _userRole != null;

    
    _initialized = true;
    notifyListeners();
  }

  Future<void> login({
    required String userId,
    required String userName,
    required UserRole role,
    bool persist = true,
  }) async {
    _userId = userId;
    _userName = userName;
    _userRole = role;
    _isLoggedIn = true;

    if (persist) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', userId);
      await prefs.setString('user_name', userName);
      await prefs.setString('user_role', role.name);
      await prefs.setInt('login_timestamp', DateTime.now().millisecondsSinceEpoch);
    }
    
    notifyListeners();
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('user_role');
    await prefs.remove('login_timestamp');
    
    _userId = null;
    _userName = null;
    _userRole = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  // Alias for clearSession to match common naming
  Future<void> logout() => clearSession();

  Future<void> ensureInitialized() async {
    if (!_initialized) {
      await _loadSession();
    }
  }
}
