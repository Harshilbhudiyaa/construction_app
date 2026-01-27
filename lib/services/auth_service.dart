import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Authentication service for managing user sessions
/// Handles login persistence across app restarts
class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  AuthService._internal() {
    _loadSession();
  }

  String? _userId;
  String? _userRole; // 'admin', 'engineer', 'worker'
  bool _isLoggedIn = false;
  bool _initialized = false;

  String? get userId => _userId;
  String? get userRole => _userRole;
  bool get isLoggedIn => _isLoggedIn;
  bool get initialized => _initialized;

  Future<void> _loadSession() async {
    if (_initialized) return;
    
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('user_id');
    _userRole = prefs.getString('user_role');
    _isLoggedIn = _userId != null && _userRole != null;
    
    _initialized = true;
    notifyListeners();
  }

  Future<void> saveSession({
    required String userId,
    required String role,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userId);
    await prefs.setString('user_role', role);
    await prefs.setInt('login_timestamp', DateTime.now().millisecondsSinceEpoch);
    
    _userId = userId;
    _userRole = role;
    _isLoggedIn = true;
    notifyListeners();
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_role');
    await prefs.remove('login_timestamp');
    
    _userId = null;
    _userRole = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  Future<void> ensureInitialized() async {
    if (!_initialized) {
      await _loadSession();
    }
  }
}
