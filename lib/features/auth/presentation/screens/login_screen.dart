import 'package:flutter/material.dart';
import '../../../../app/routes.dart';
import '../../../../app/theme/professional_theme.dart';
import '../../../../core/widgets/app_textfield.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/enums/app_enums.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _idCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  
  late AnimationController _fadeController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    _passCtrl.dispose();
    _fadeController.dispose();
    _slideController.dispose();
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

  IconData _roleIcon(AppRole r) {
    switch (r) {
      case AppRole.worker:
        return Icons.engineering_rounded;
      case AppRole.engineer:
        return Icons.architecture_rounded;
      case AppRole.contractor:
        return Icons.business_center_rounded;
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

  Future<void> _handleLogin(AppRole role) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() => _loading = false);
      _goHome(role);
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = (ModalRoute.of(context)?.settings.arguments as AppRole?) ?? AppRole.worker;

    return Scaffold(
      body: ProfessionalBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FadeTransition(
                opacity: _fadeController,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Company Logo Section
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, -0.5),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _slideController,
                        curve: Curves.easeOutCubic,
                      )),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Icon(
                              _roleIcon(role),
                              size: 56,
                              color: AppColors.deepBlue1,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Smart Construction',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Management System',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 48),
                    
                    // Login Card
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.3),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _slideController,
                        curve: Curves.easeOutCubic,
                      )),
                      child: ProfessionalCard(
                        margin: EdgeInsets.zero,
                        padding: const EdgeInsets.all(32),
                        width: 440,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Role Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.deepBlue1.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _roleIcon(role),
                                      size: 18,
                                      color: AppColors.deepBlue1,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _roleLabel(role),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.deepBlue1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              const SizedBox(height: 24),
                              
                              const Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.deepBlue1,
                                ),
                              ),
                              
                              const SizedBox(height: 8),
                              
                              Text(
                                'Enter your credentials to continue',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              
                              const SizedBox(height: 32),
                              
                              // ID Field
                              AppTextField(
                                label: 'Employee ID',
                                hint: 'Enter your employee ID',
                                controller: _idCtrl,
                                prefixIcon: Icons.badge_outlined,
                                validator: (v) => AppValidators.validateRequired(v, 'ID'),
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Password Field
                              AppTextField(
                                label: 'Password',
                                hint: 'Enter your password',
                                controller: _passCtrl,
                                isPassword: _obscure,
                                prefixIcon: Icons.lock_outline,
                                suffixIcon: IconButton(
                                  onPressed: () => setState(() => _obscure = !_obscure),
                                  icon: Icon(
                                    _obscure
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                validator: AppValidators.validatePassword,
                              ),
                              
                              const SizedBox(height: 32),
                              
                              // Login Button
                              SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: ElevatedButton(
                                  onPressed: _loading ? null : () => _handleLogin(role),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.deepBlue1,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: _loading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                          ),
                                        )
                                      : const Text(
                                          'Sign In',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                ),
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // Change Role Button
                              Center(
                                child: TextButton.icon(
                                  onPressed: () => Navigator.pushReplacementNamed(
                                    context,
                                    AppRoutes.role,
                                  ),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.deepBlue1,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                  icon: const Icon(Icons.swap_horiz_rounded, size: 20),
                                  label: const Text(
                                    'Switch Role',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 48),
                    
                    // Footer
                    Text(
                      '© 2025 Smart Construction Systems',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}