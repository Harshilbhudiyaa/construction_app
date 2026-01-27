import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:construction_app/notifications/models/notification_model.dart';

class MockNotificationService extends ChangeNotifier {
  static final MockNotificationService _instance = MockNotificationService._internal();
  factory MockNotificationService() => _instance;

  MockNotificationService._internal() {
    _loadNotifications();
  }

  final List<NotificationModel> _notifications = [];
  bool _initialized = false;

  List<NotificationModel> get notifications => List.unmodifiable(_notifications);
  List<NotificationModel> get unreadNotifications => _notifications.where((n) => !n.isRead).toList();
  int get unreadCount => unreadNotifications.length;

  Future<void> _loadNotifications() async {
    if (_initialized) return;
    
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('notifications_data');
    
    if (data != null) {
      try {
        final List<dynamic> decoded = jsonDecode(data);
        _notifications.clear();
        _notifications.addAll(decoded.map((e) => NotificationModel.fromJson(e)).toList());
      } catch (e) {
        debugPrint('Error loading notifications: $e');
      }
    } else {
      _initDemoData();
      await _saveNotifications();
    }
    
    _initialized = true;
    notifyListeners();
  }

  Future<void> _saveNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_notifications.map((e) => e.toJson()).toList());
    await prefs.setString('notifications_data', encoded);
  }

  Future<void> addNotification(NotificationModel notification) async {
    _notifications.insert(0, notification);
    notifyListeners();
    await _saveNotifications();
  }

  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
      await _saveNotifications();
    }
  }

  Future<void> markAllAsRead() async {
    bool changed = false;
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
        changed = true;
      }
    }
    if (changed) {
      notifyListeners();
      await _saveNotifications();
    }
  }

  Future<void> deleteNotification(String id) async {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
    await _saveNotifications();
  }

  Future<void> clearAll() async {
    _notifications.clear();
    notifyListeners();
    await _saveNotifications();
  }

  void _initDemoData() {
    _notifications.addAll([
      NotificationModel(
        id: '1',
        type: NotificationType.alert,
        title: 'Emergency: Stock Depleted',
        message: 'Main cement silos empty at Metropolis Heights. Automated reorder triggered.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        isRead: false,
        priority: NotificationPriority.high,
      ),
      NotificationModel(
        id: '2',
        type: NotificationType.payment,
        title: 'Payroll Verified',
        message: 'Verification complete for Jan Week 3. Ready for release (₹5.42L).',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        isRead: false,
        priority: NotificationPriority.medium,
      ),
      NotificationModel(
        id: '5',
        type: NotificationType.system,
        title: 'Equipment Alert',
        message: 'JCB Excavator #448 requires immediate hydraulic maintenance.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
        priority: NotificationPriority.high,
      ),
      NotificationModel(
        id: '6',
        type: NotificationType.approval,
        title: 'Approval Required',
        message: 'Material procurement request for Steel Rebar (Site B) awaiting sign-off.',
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        isRead: false,
        priority: NotificationPriority.normal,
      ),
      NotificationModel(
        id: '3',
        type: NotificationType.truck,
        title: 'Dispatch Intelligent Alert',
        message: 'Vehicle GJ01AB-9920 rerouted via Expressway due to NH8 backlog.',
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
        isRead: true,
        priority: NotificationPriority.normal,
      ),
      NotificationModel(
        id: '4',
        type: NotificationType.workSession,
        title: 'Activity Commenced',
        message: 'Engineer Harshil started a site survey at Skyline Plaza.',
        timestamp: DateTime.now().subtract(const Duration(hours: 8)),
        isRead: true,
        priority: NotificationPriority.normal,
      ),
    ]);
  }
}
