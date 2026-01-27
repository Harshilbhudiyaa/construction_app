import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:construction_app/services/mock_engineer_service.dart';
import 'package:construction_app/services/mock_worker_service.dart';
import 'package:construction_app/services/auth_service.dart';
import 'package:construction_app/services/theme_service.dart';
import 'package:construction_app/dashboard/contractor_shell.dart';
import 'package:construction_app/dashboard/engineer_shell.dart';
import 'package:construction_app/dashboard/worker_shell.dart';
import 'package:construction_app/shared/theme/app_theme.dart';
import 'package:construction_app/profiles/worker_types.dart';

/// OTP-based Login Screen with Session Persistence
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());
  
  bool _loading = false;
  bool _showOTPField = false;
  int _resendTimer = 30;
  bool _rememberMe = true;
  
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
    _phoneCtrl.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _otpFocusNodes) {
      node.dispose();
    }
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() => _resendTimer = 30);
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _resendTimer--);
      return _resendTimer > 0;
    });
  }

  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() {
        _loading = false;
        _showOTPField = true;
      });
      _startResendTimer();
      _otpFocusNodes[0].requestFocus();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Text('OTP sent to ${_phoneCtrl.text}'),
            ],
          ),
          backgroundColor: ConstructionColors.successGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _verifyOTP() async {
    final otp = _otpControllers.map((c) => c.text).join();
    
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.error_outline, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Text('Please enter complete OTP'),
            ],
          ),
          backgroundColor: ConstructionColors.warningAmber,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _loading = true);
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() => _loading = false);
      
      final authService = context.read<AuthService>();
        
      try {
        // 1. Check for Admin Login
        if (_phoneCtrl.text == '9999999999') {
          // Save session if remember me is checked
          if (_rememberMe) {
            await authService.saveSession(userId: 'admin', role: 'admin');
          }
          
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const ContractorShell()),
            (_) => false,
          );
          return;
        }

        // 2. Check for Engineer Login
        final engineerService = context.read<MockEngineerService>();
        final engineer = engineerService.findByPhone(_phoneCtrl.text);

        if (engineer != null) {
          if (!engineer.isActive) {
            _showError('Account is inactive. Contact Administrator.');
            return;
          }

          if (_rememberMe) {
            await authService.saveSession(userId: engineer.id, role: 'engineer');
          }

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => EngineerShell(engineerId: engineer.id)),
            (_) => false,
          );
          return;
        }

        // 3. Check for Worker Login
        final workerService = context.read<MockWorkerService>();
        final workerList = workerService.workers.where((w) => w.phone == _phoneCtrl.text).toList();

        if (workerList.isNotEmpty) {
          final worker = workerList.first;
          if (worker.status != WorkerStatus.active) {
            _showError('Worker account is inactive.');
            return;
          }

          if (_rememberMe) {
            await authService.saveSession(userId: worker.id, role: 'worker');
          }

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => WorkerShell(workerId: worker.id)),
            (_) => false,
          );
          return;
        }

        // 4. Not Found
        _showError('No user found. Try 9999999999 for Admin.');
      } catch (e) {
        debugPrint('Login Error: $e');
        _showError('Something went wrong. Please try again.');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ConstructionColors.errorRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: _ThemeToggle(),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark 
              ? [const Color(0xFF0F1218), const Color(0xFF1A1F2B)]
              : [
                  theme.colorScheme.primary.withOpacity(0.1),
                  theme.colorScheme.secondary.withOpacity(0.05),
                  theme.colorScheme.background,
                ],
          ),
        ),
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
                    // Logo Section
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
                              gradient: ConstructionColors.primaryGradient,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: ConstructionColors.deepOrange.withOpacity(0.3),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.construction,
                              size: 56,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Smart Construction',
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Management System',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.textTheme.bodySmall?.color,
                              letterSpacing: 1.2,
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
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child: Card(
                          elevation: 8,
                          shadowColor: ConstructionColors.deepOrange.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome Back',
                                    style: theme.textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 8),
                                  
                                  Text(
                                    'Sign in with your phone number',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: ConstructionColors.steelGray,
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 32),
                                  
                                  // Phone Number Field
                                  TextFormField(
                                    controller: _phoneCtrl,
                                    keyboardType: TextInputType.phone,
                                    enabled: !_showOTPField,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(10),
                                    ],
                                    decoration: InputDecoration(
                                      labelText: 'Phone Number',
                                      hintText: 'Enter 10-digit mobile number',
                                      prefixIcon: Icon(Icons.phone_outlined, color: ConstructionColors.deepOrange),
                                      prefixText: '+91 ',
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter phone number';
                                      }
                                      if (value.length != 10) {
                                        return 'Phone number must be 10 digits';
                                      }
                                      return null;
                                    },
                                  ),
                                  
                                  if (_showOTPField) ...[
                                    const SizedBox(height: 24),
                                    
                                    Text(
                                      'Enter 6-digit OTP',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                    
                                    const SizedBox(height: 16),
                                    
                                    // OTP Input Fields
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: List.generate(6, (index) {
                                        return Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 4),
                                            child: TextFormField(
                                              controller: _otpControllers[index],
                                              focusNode: _otpFocusNodes[index],
                                              keyboardType: TextInputType.number,
                                              textAlign: TextAlign.center,
                                              maxLength: 1,
                                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              decoration: InputDecoration(
                                                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                                counterText: '',
                                              ),
                                              onChanged: (value) {
                                                if (value.isNotEmpty && index < 5) {
                                                  _otpFocusNodes[index + 1].requestFocus();
                                                } else if (value.isEmpty && index > 0) {
                                                  _otpFocusNodes[index - 1].requestFocus();
                                                }
                                              },
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                                    
                                    const SizedBox(height: 16),
                                    
                                    // Resend OTP Timer
                                    Center(
                                      child: _resendTimer > 0
                                          ? Text(
                                              'Resend OTP in $_resendTimer seconds',
                                              style: theme.textTheme.bodySmall,
                                            )
                                          : TextButton(
                                              onPressed: _sendOTP,
                                              child: Text(
                                                'Resend OTP',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: theme.colorScheme.primary,
                                                ),
                                              ),
                                            ),
                                    ),
                                  ],
                                  
                                  const SizedBox(height: 24),
                                  
                                  // Remember Me Checkbox
                                  Row(
                                    children: [
                                      Transform.scale(
                                        scale: 1.1,
                                        child: Checkbox(
                                          value: _rememberMe,
                                          onChanged: (value) {
                                            setState(() => _rememberMe = value ?? true);
                                          },
                                          activeColor: theme.colorScheme.primary,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                      ),
                                      Text(
                                        'Remember me',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: ConstructionColors.charcoalGray,
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  const SizedBox(height: 24),
                                  
                                  // Action Button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: ElevatedButton(
                                      onPressed: _loading
                                          ? null
                                          : (_showOTPField ? _verifyOTP : _sendOTP),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: ConstructionColors.deepOrange,
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
                                          : Text(
                                              _showOTPField ? 'Verify & Sign In' : 'Send OTP',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Footer
                    Text(
                      '© 2026 Smart Construction Systems',
                      style: theme.textTheme.bodySmall,
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

class _ThemeToggle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, _) {
        final isDark = themeService.isDarkMode;
        return IconButton(
          onPressed: () => themeService.toggleTheme(),
          icon: Icon(
            isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
            color: isDark ? Colors.amberAccent : const Color(0xFF1B2B8F),
          ),
        );
      },
    );
  }
}