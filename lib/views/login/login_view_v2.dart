import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class LoginViewV2 extends StatefulWidget {
  const LoginViewV2({super.key});

  @override
  State<LoginViewV2> createState() => _LoginViewV2State();
}

class _LoginViewV2State extends State<LoginViewV2>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthController _authController = Get.find<AuthController>();
  late TabController _tabController;
  bool _isLogin = true;

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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 70),
              // Logo
              Container(
                width: 120,
                height: 80,
                decoration: BoxDecoration(
                  color: _isLogin
                      ? const Color(0xFF3976B3).withOpacity(0.1)
                      : const Color(0xFFDE7010).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _isLogin ? Icons.two_wheeler : Icons.directions_car,
                  size: 60,
                  color: _isLogin
                      ? const Color(0xFF3976B3)
                      : const Color(0xFFDE7010),
                ),
              ),
              const SizedBox(height: 20),
              // Tab Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: _isLogin
                        ? const Color(0xFF3976B3)
                        : const Color(0xFFDE7010),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black,
                  labelStyle: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                  tabs: const [
                    Tab(text: 'LogIn'),
                    Tab(text: 'SignUp'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Form
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      if (!_isLogin) ...[
                        _buildTextField(
                          controller: _nameController,
                          hint: 'Name',
                          icon: Icons.person,
                        ),
                        const SizedBox(height: 10),
                      ],
                      _buildTextField(
                        controller: _emailController,
                        hint: 'Email',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _passwordController,
                        hint: 'Password',
                        icon: Icons.lock,
                        obscureText: true,
                      ),
                      if (!_isLogin) ...[
                        const SizedBox(height: 10),
                        _buildTextField(
                          controller: _confirmPasswordController,
                          hint: 'Confirm Password',
                          icon: Icons.lock_outline,
                          obscureText: true,
                        ),
                      ],
                      const SizedBox(height: 20),
                      SizedBox(
                        width: 280,
                        height: 50,
                        child: Obx(
                          () => _authController.isLoading.value
                              ? const Center(child: CircularProgressIndicator())
                              : ElevatedButton(
                                  onPressed: _handleSubmit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _isLogin
                                        ? const Color(0xFF3976B3)
                                        : const Color(0xFFDE7010),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    _isLogin ? 'LOGIN' : 'SIGNUP',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      if (_isLogin) ...[
                        const SizedBox(height: 10),
                        const Text(
                          "I don't have any account",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildSocialButton(Icons.facebook, () {}),
                            const SizedBox(width: 20),
                            _buildSocialButton(Icons.g_mobiledata, () {}),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return Container(
      width: 280,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.grey[600]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(8),
        ),
        validator: (value) =>
            value?.isEmpty ?? true ? 'Please enter $hint' : null,
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(5),
        ),
        child: Icon(icon, color: Colors.blue),
      ),
    );
  }
}

