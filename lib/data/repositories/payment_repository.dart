import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:construction_app/data/models/payment_model.dart';

class PaymentRepository extends ChangeNotifier {
  static const String _paymentsKey = 'app_payments_v1';
  List<PaymentModel> _payments = [];
  bool _isLoading = true;

  List<PaymentModel> get payments => _payments;
  bool get isLoading => _isLoading;

  PaymentRepository() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString(_paymentsKey);
      if (data != null) {
        final List<dynamic> decoded = jsonDecode(data);
        _payments = decoded.map((item) => PaymentModel.fromJson(Map<String, dynamic>.from(item))).toList();
      }
    } catch (e) {
      debugPrint('Error loading payments: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(_payments.map((p) => p.toJson()).toList());
      await prefs.setString(_paymentsKey, encoded);
    } catch (e) {
      debugPrint('Error saving payments: $e');
    }
  }

  Future<void> addPayment(PaymentModel payment) async {
    _payments.insert(0, payment);
    notifyListeners();
    await _saveToPrefs();
  }

  Future<void> updatePayment(PaymentModel payment) async {
    final index = _payments.indexWhere((p) => p.id == payment.id);
    if (index != -1) {
      _payments[index] = payment;
      notifyListeners();
      await _saveToPrefs();
    }
  }

  Future<void> deletePayment(String paymentId) async {
    _payments.removeWhere((p) => p.id == paymentId);
    notifyListeners();
    await _saveToPrefs();
  }


  double getTotalSuccess({String? siteId}) {
    return _payments
        .where((p) => p.status == PaymentStatus.success && (siteId == null || p.siteId == siteId))
        .fold(0, (sum, p) => sum + p.amount);
  }

  double getTotalPending({String? siteId}) {
    return _payments
        .where((p) => p.status == PaymentStatus.pending && (siteId == null || p.siteId == siteId))
        .fold(0, (sum, p) => sum + p.amount);
  }
}
