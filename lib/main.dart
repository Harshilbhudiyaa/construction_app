import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
<<<<<<< Updated upstream
=======
import 'package:firebase_auth/firebase_auth.dart';
>>>>>>> Stashed changes
import 'package:firebase_database/firebase_database.dart';

import 'firebase_options.dart';

<<<<<<< Updated upstream
void main() async {
=======
Future<void> main() async {
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
    return const MaterialApp(
      home: FirebaseStatusPage(),
=======
    return MaterialApp(
      title: 'Construction App - Login',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const AuthGate(),
>>>>>>> Stashed changes
    );
  }
}

<<<<<<< Updated upstream
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
=======
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = snap.data;
        if (user == null) return const LoginPage();
        return HomePage(uid: user.uid, email: user.email ?? '');
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _name = TextEditingController();

  bool _isLogin = true;
  bool _loading = false;
  String? _err;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _err = null;
    });

    try {
      final email = _email.text.trim();
      final pass = _pass.text;
      final name = _name.text.trim();

      if (email.isEmpty || pass.isEmpty) {
        throw 'Email and password are required.';
      }
      if (!_isLogin && name.isEmpty) {
        throw 'Name is required for signup.';
      }

      UserCredential cred;

      if (_isLogin) {
        cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: pass,
        );
      } else {
        cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: pass,
        );
      }

      final uid = cred.user!.uid;

      // ✅ Write/Update user record in RTDB
      final userRef = FirebaseDatabase.instance.ref('users/$uid');

      final now = ServerValue.timestamp;

      if (_isLogin) {
        await userRef.update({
          'uid': uid,
          'email': email,
          'lastLoginAt': now,
        });
      } else {
        await userRef.set({
          'uid': uid,
          'email': email,
          'name': name,
          'createdAt': now,
          'lastLoginAt': now,
        });
      }
    } catch (e) {
      setState(() => _err = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Login' : 'Create Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (!_isLogin) ...[
              TextField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pass,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            if (_err != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color.fromARGB(255, 209, 86, 77).withOpacity(0.12),
                ),
                child: Text(_err!),
              ),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _loading ? null : _submit,
                child: Text(_loading
                    ? 'Please wait...'
                    : (_isLogin ? 'Login' : 'Sign Up')),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _loading
                  ? null
                  : () => setState(() {
                        _isLogin = !_isLogin;
                        _err = null;
                      }),
              child: Text(_isLogin
                  ? "Don't have an account? Sign up"
                  : "Already have an account? Login"),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final String uid;
  final String email;

  const HomePage({super.key, required this.uid, required this.email});

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final userRef = FirebaseDatabase.instance.ref('users/$uid');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Logged in: $email'),
            const SizedBox(height: 12),
            const Text('Realtime Database user data:'),
            const SizedBox(height: 8),
            StreamBuilder<DatabaseEvent>(
              stream: userRef.onValue,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snap.hasError) {
                  return Text('Error: ${snap.error}');
                }
                final v = snap.data?.snapshot.value;
                if (v == null) return const Text('No user data found in DB.');
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.black.withOpacity(0.06),
                  ),
                  child: Text(v.toString()),
                );
              },
            ),
          ],
        ),
      ),
>>>>>>> Stashed changes
    );
  }
}
