import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: FirebaseStatusPage(),
    );
  }
}

class FirebaseStatusPage extends StatelessWidget {
  const FirebaseStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Firebase RTDB connection indicator
    final ref = FirebaseDatabase.instance.ref('.info/connected');

    return Scaffold(
      appBar: AppBar(title: const Text('Firebase Connection')),
      body: Center(
        child: StreamBuilder(
          stream: ref.onValue,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Text('Checking...');
            }

            final connected = snapshot.data!.snapshot.value == true;

            return Text(
              connected ? 'Connected' : 'Not Connected',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      ),
    );
  }
}
