import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:construction_app/data/models/payment_model.dart';

class PaymentRepository extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<PaymentModel> _payments = [];
  bool _isLoading = true;

  List<PaymentModel> get payments => _payments;
  bool get isLoading => _isLoading;

  StreamSubscription? _sub;

  PaymentRepository() {
    _init();
  }

  void _init() {
    _sub = _db
        .collection('payments')
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snap) {
      _payments = snap.docs
          .map((d) => PaymentModel.fromJson({...d.data(), 'id': d.id}))
          .toList();
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      debugPrint('PaymentRepository stream error: $e');
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addPayment(PaymentModel payment) async {
    final data = payment.toJson();
    data['createdAt'] = FieldValue.serverTimestamp();
    await _db.collection('payments').doc(payment.id).set(data);
  }

  Future<void> updatePayment(PaymentModel payment) async {
    final data = payment.toJson();
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _db.collection('payments').doc(payment.id).update(data);
  }

  Future<void> deletePayment(String paymentId) async {
    await _db.collection('payments').doc(paymentId).delete();
  }

  double getTotalSuccess({String? siteId}) {
    return _payments
        .where((p) =>
            p.status == PaymentStatus.success &&
            (siteId == null || p.siteId == siteId))
        .fold(0, (sum, p) => sum + p.amount);
  }

  double getTotalPending({String? siteId}) {
    return _payments
        .where((p) =>
            p.status == PaymentStatus.pending &&
            (siteId == null || p.siteId == siteId))
        .fold(0, (sum, p) => sum + p.amount);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
