import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/animated_button.dart';

class LoginViewPremium extends StatefulWidget {
  const LoginViewPremium({super.key});

  @override
  State<LoginViewPremium> createState() => _LoginViewPremiumState();
}

class _LoginViewPremiumState extends State<LoginViewPremium>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthController _authController = Get.find<AuthController>();
  late TabController _tabController;
  bool _isLogin = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _isLogin = _tabController.index == 0;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      bool success = false;
      if (_isLogin) {
        success = await _authController.login(
          _emailController.text,
          _passwordController.text,
        );
      } else {
        if (_passwordController.text != _confirmPasswordController.text) {
          Get.snackbar('Error', 'Passwords do not match');
          return;
        }
        success = await _authController.register(
          _nameController.text,
          _emailController.text,
          _passwordController.text,
        );
      }
      if (success) {
        Get.offAllNamed('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.subtleGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingXL),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    
                    // Logo
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: AppTheme.shadow2,
                      ),
                      child: const Icon(
                        Icons.directions_car_rounded,
                        size: 50,
                        color: Colors.white,
                      ),
                    )
                        .animate()
                        .scale(delay: 100.ms, duration: 600.ms, curve: Curves.easeOutBack)
                        .fadeIn(duration: 400.ms),
                    
                    const SizedBox(height: 32),
                    
                    // Title
                    const Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    )
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 600.ms)
                        .slideY(begin: 0.2, end: 0, duration: 600.ms),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      _isLogin
                          ? 'Sign in to continue'
                          : 'Create your account',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    )
                        .animate()
                        .fadeIn(delay: 300.ms, duration: 600.ms),
                    
                    const SizedBox(height: 40),
                    
                    // Tab Bar
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.grey[600],
                        labelStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        dividerColor: Colors.transparent,
                        tabs: const [
                          Tab(text: 'Login'),
                          Tab(text: 'Sign Up'),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 400.ms, duration: 600.ms)
                        .slideY(begin: 0.2, end: 0, duration: 600.ms),
                    
                    const SizedBox(height: 32),
                    
                    // Form Fields
                    if (!_isLogin) ...[
                      _buildTextField(
                        controller: _nameController,
                        hint: 'Full Name',
                        icon: Icons.person_outline_rounded,
                        delay: 500,
                      ),
                      const SizedBox(height: 16),
                    ],
                    _buildTextField(
                      controller: _emailController,
                      hint: 'Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      delay: _isLogin ? 500 : 600,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _passwordController,
                      hint: 'Password',
                      icon: Icons.lock_outline_rounded,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      delay: _isLogin ? 600 : 700,
                    ),
                    if (!_isLogin) ...[
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _confirmPasswordController,
                        hint: 'Confirm Password',
                        icon: Icons.lock_outline_rounded,
                        obscureText: _obscureConfirmPassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                        delay: 800,
                      ),
                    ],
                    const SizedBox(height: 32),
                    
                    // Submit Button
                    Obx(
                      () => AnimatedButton(
                        text: _isLogin ? 'Sign In' : 'Create Account',
                        icon: Icons.arrow_forward_rounded,
                        onPressed: _handleSubmit,
                        isLoading: _authController.isLoading.value,
                        width: double.infinity,
                      )
                          .animate()
                          .fadeIn(delay: (_isLogin ? 700 : 900).ms, duration: 600.ms)
                          .slideY(begin: 0.3, end: 0, duration: 600.ms),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int delay = 0,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.primary),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppTheme.surface,
      ),
      validator: (value) =>
          value?.isEmpty ?? true ? 'Please enter $hint' : null,
    )
        .animate()
        .fadeIn(delay: delay.ms, duration: 400.ms)
        .slideX(begin: -0.2, end: 0, duration: 400.ms);
  }
}

