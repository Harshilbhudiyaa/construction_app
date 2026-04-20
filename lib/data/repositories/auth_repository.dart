import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:construction_app/data/models/user_model.dart';

/// Firebase-backed authentication repository.
/// Wraps [FirebaseAuth] and exposes role-based permission checks.
class AuthRepository extends ChangeNotifier {
  static final AuthRepository _instance = AuthRepository._internal();
  factory AuthRepository() => _instance;

  AuthRepository._internal() {
    _initFuture = _init();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  // ── Permission Checks ────────────────────────────────────────────────────────
  bool get isAdmin => _userRole == UserRole.admin;
  bool get canApprove => _userRole == UserRole.admin;
  bool get canEdit => _userRole == UserRole.admin || _userRole == UserRole.manager;
  bool get isSiteEngineer => _userRole == UserRole.siteEngineer;
  bool get canDelete => _userRole == UserRole.admin;
  bool get canCreateEntry => _isLoggedIn;
  bool get canManageLabour => _userRole == UserRole.admin || _userRole == UserRole.manager;
  bool get canViewReports => _userRole == UserRole.admin || _userRole == UserRole.manager;
  bool get canSettleLabour => _userRole == UserRole.admin;

  // ── Initialization ─────────────────────────────────────────────────────────

  Future<void> _init() async {
    if (_initialized) return;

    // Restore app mode preference
    final prefs = await SharedPreferences.getInstance();
    final modeStr = prefs.getString('app_mode');
    _appMode = AppMode.fromString(modeStr);

    // Listen to Firebase Auth state
    _auth.authStateChanges().listen((user) async {
      if (user != null) {
        await _loadUserProfile(user.uid);
      } else {
        _clearLocalState();
      }
      notifyListeners();
    });

    // Check if already signed in
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      await _loadUserProfile(currentUser.uid);
    }

    _initialized = true;
    notifyListeners();
  }

  Future<void> _loadUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        _userId = uid;
        _userName = data['name'] as String? ?? _auth.currentUser?.email ?? 'User';
        final roleStr = data['role'] as String?;
        _userRole = roleStr != null ? UserRole.fromString(roleStr) : UserRole.admin;
        _isLoggedIn = true;
      } else {
        // Fallback: user exists in Auth but not in Firestore — treat as admin
        _userId = uid;
        _userName = _auth.currentUser?.email ?? 'User';
        _userRole = UserRole.admin;
        _isLoggedIn = true;
        // Create the missing profile
        await _firestore.collection('users').doc(uid).set({
          'name': _userName,
          'email': _auth.currentUser?.email ?? '',
          'role': UserRole.admin.name,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('AuthRepository._loadUserProfile error: $e');
      // Still mark as logged in if Firebase Auth has the user
      if (_auth.currentUser != null) {
        _userId = _auth.currentUser!.uid;
        _userName = _auth.currentUser!.email ?? 'User';
        _userRole = UserRole.admin;
        _isLoggedIn = true;
      }
    }
  }

  void _clearLocalState() {
    _userId = null;
    _userName = null;
    _userRole = null;
    _isLoggedIn = false;
  }

  // ── App Mode ──────────────────────────────────────────────────────────────────

  Future<void> toggleAppMode() async {
    _appMode = _appMode == AppMode.simple ? AppMode.advanced : AppMode.simple;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_mode', _appMode.name);
    notifyListeners();
  }

  // ── Sign In ───────────────────────────────────────────────────────────────────

  /// Signs in with email and password.
  /// Returns null on success, or an error message string on failure.
  Future<String?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await _loadUserProfile(credential.user!.uid);
      notifyListeners();
      return null; // success
    } on FirebaseAuthException catch (e) {
      return _friendlyError(e.code);
    } catch (e) {
      return 'Sign in failed. Please try again.';
    }
  }

  // ── Register ──────────────────────────────────────────────────────────────────

  /// Creates a new Firebase Auth user and saves profile to Firestore.
  /// Returns null on success, or an error message string on failure.
  Future<String?> registerWithEmail({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Update display name
      await credential.user!.updateDisplayName(name);

      // Save to Firestore
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'name': name,
        'email': email.trim(),
        'role': role.name,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _loadUserProfile(credential.user!.uid);
      notifyListeners();
      return null; // success
    } on FirebaseAuthException catch (e) {
      return _friendlyError(e.code);
    } catch (e) {
      return 'Registration failed. Please try again.';
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    await _auth.signOut();
    _clearLocalState();
    notifyListeners();
  }

  /// Alias kept for backward compatibility
  Future<void> clearSession() => logout();

  // ── Ensure Initialized ────────────────────────────────────────────────────────

  Future<void> ensureInitialized() async {
    if (!_initialized) {
      await _initFuture;
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────

  String _friendlyError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      default:
        return 'Authentication error ($code). Please try again.';
    }
  }
}
