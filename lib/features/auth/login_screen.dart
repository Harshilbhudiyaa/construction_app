import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../contractor/contractor_shell.dart';
import '../../../app/theme/professional_theme.dart';

/// OTP-based Login Screen
/// Users enter phone number and receive OTP for authentication
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
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    setState(() => _loading = true);
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() => _loading = false);
      
      // Navigate to Contractor Dashboard
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const ContractorShell()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                            child: const Icon(
                              Icons.construction_rounded,
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
                              const Text(
                                'Welcome Back',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.deepBlue1,
                                ),
                              ),
                              
                              const SizedBox(height: 8),
                              
                              Text(
                                'Sign in with your phone number',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
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
                                  prefixIcon: const Icon(Icons.phone_outlined),
                                  prefixText: '+91 ',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: AppColors.deepBlue1, width: 2),
                                  ),
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
                                    color: Colors.grey[700],
                                  ),
                                ),
                                
                                const SizedBox(height: 16),
                                
                                // OTP Input Fields
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: List.generate(6, (index) {
                                    return SizedBox(
                                      width: 50,
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
                                          counterText: '',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(color: Colors.grey[300]!),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                              color: AppColors.deepBlue1,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                        onChanged: (value) {
                                          if (value.isNotEmpty && index < 5) {
                                            _otpFocusNodes[index + 1].requestFocus();
                                          } else if (value.isEmpty && index > 0) {
                                            _otpFocusNodes[index - 1].requestFocus();
                                          }
                                        },
                                      ),
                                    );
                                  }),
                                ),
                                
                                const SizedBox(height: 16),
                                
                                // Resend OTP Timer
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (_resendTimer > 0) ...[
                                      Text(
                                        'Resend OTP in $_resendTimer seconds',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ] else ...[
                                      TextButton(
                                        onPressed: _sendOTP,
                                        child: const Text(
                                          'Resend OTP',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                              
                              const SizedBox(height: 32),
                              
                              // Action Button
                              SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: ElevatedButton(
                                  onPressed: _loading
                                      ? null
                                      : (_showOTPField ? _verifyOTP : _sendOTP),
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
                              
                              const SizedBox(height: 24),
                              
                              // Register Link
                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Don't have an account? ",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pushNamed(context, '/register');
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors.deepBlue1,
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                      ),
                                      child: const Text(
                                        'Register',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
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
                      '© 2026 Smart Construction Systems',
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