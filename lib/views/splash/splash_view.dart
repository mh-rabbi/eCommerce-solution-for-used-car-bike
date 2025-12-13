import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();

    // Navigate after animation
    Future.delayed(const Duration(seconds: 3), () async {
      final authController = Get.find<AuthController>();
      await authController.checkAuthStatus();
      if (authController.currentUser.value != null) {
        Get.offAllNamed('/home');
      } else {
        Get.offAllNamed('/onboarding');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo placeholder - replace with actual logo
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: const Color(0xFF06A4B4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.directions_car,
                    size: 100,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Vehicle Marketplace',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF06A4B4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

