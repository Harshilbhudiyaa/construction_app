import 'package:flutter/material.dart';
import '../../../../app/routes.dart';
import 'role_select_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _idCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  String _roleLabel(AppRole r) {
    switch (r) {
      case AppRole.worker:
        return 'Worker';
      case AppRole.engineer:
        return 'Site Engineer';
      case AppRole.contractor:
        return 'Contractor';
    }
  }

  void _goHome(AppRole role) {
    final route = switch (role) {
      AppRole.worker => AppRoutes.workerHome,
      AppRole.engineer => AppRoutes.engineerHome,
      AppRole.contractor => AppRoutes.contractorHome,
    };

    Navigator.pushNamedAndRemoveUntil(context, route, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final role =
        (ModalRoute.of(context)?.settings.arguments as AppRole?) ??
        AppRole.worker;

    return Scaffold(
      appBar: AppBar(title: Text('Login (${_roleLabel(role)})')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _idCtrl,
                        decoration: const InputDecoration(
                          labelText: 'ID',
                          hintText: 'Enter your ID',
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'ID is required'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter password',
                          suffixIcon: IconButton(
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_rounded
                                  : Icons.visibility_off_rounded,
                            ),
                          ),
                        ),
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Password is required'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () {
                            if (!_formKey.currentState!.validate()) return;
                            _goHome(
                              role,
                            ); // Demo redirect. Firebase auth later.
                          },
                          child: const Text('Continue'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () => Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.role,
                        ),
                        child: const Text('Change role'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
