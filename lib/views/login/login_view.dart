import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final AuthController _authController = Get.find<AuthController>();
  bool _isLogin = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
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
      appBar: AppBar(title: const Text('Vehicle Marketplace')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _isLogin ? 'Login' : 'Register',
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                if (!_isLogin)
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Please enter your name' : null,
                  ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter your email' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter your password' : null,
                ),
                const SizedBox(height: 24),
                Obx(() => _authController.isLoading.value
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 48,
                            vertical: 16,
                          ),
                        ),
                        child: Text(_isLogin ? 'Login' : 'Register'),
                      )),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = !_isLogin;
                    });
                  },
                  child: Text(_isLogin
                      ? 'Don\'t have an account? Register'
                      : 'Already have an account? Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

