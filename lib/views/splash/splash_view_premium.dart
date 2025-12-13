import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme/app_theme.dart';

class SplashViewPremium extends StatefulWidget {
  const SplashViewPremium({super.key});

  @override
  State<SplashViewPremium> createState() => _SplashViewPremiumState();
}

class _SplashViewPremiumState extends State<SplashViewPremium>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _controller.forward();

    // Navigate after animation
    Future.delayed(const Duration(milliseconds: 2500), () async {
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Logo
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: AppTheme.shadow3,
                  ),
                  child: const Icon(
                    Icons.directions_car_rounded,
                    size: 80,
                    color: AppTheme.primary,
                  ),
                )
                    .animate()
                    .scale(
                      delay: 200.ms,
                      duration: 600.ms,
                      curve: Curves.easeOutBack,
                    )
                    .fadeIn(duration: 400.ms),
                
                const SizedBox(height: 32),
                
                // App Name
                const Text(
                  'Vehicle Marketplace',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 600.ms)
                    .slideY(begin: 0.2, end: 0, duration: 600.ms),
                
                const SizedBox(height: 12),
                
                // Tagline
                Text(
                  'Find your perfect ride',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w400,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 600.ms, duration: 600.ms)
                    .slideY(begin: 0.2, end: 0, duration: 600.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

