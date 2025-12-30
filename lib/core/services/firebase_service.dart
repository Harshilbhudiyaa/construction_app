import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  Future<void> initialize() async {
    // Already handled in main.dart but can put checks here
    await Firebase.initializeApp();
  }
}
