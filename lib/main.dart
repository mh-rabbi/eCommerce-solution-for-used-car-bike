import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'config/app_config.dart';
import 'controllers/auth_controller.dart';
import 'controllers/vehicle_controller.dart';
import 'controllers/favorite_controller.dart';
import 'controllers/payment_controller.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_routes.dart';
import 'views/login/login_view.dart';
import 'views/home/home_view.dart';

void main() {
  // CRITICAL FIX: Print configuration on startup
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.printConfig();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controllers
    Get.put(AuthController());
    Get.put(VehicleController());
    Get.put(FavoriteController());
    Get.put(PaymentController());

    return GetMaterialApp(
      title: 'Vehicle Marketplace',
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      getPages: AppRoutes.routes,
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Obx(() {
      if (authController.currentUser.value != null) {
        return const HomeView();
      }
      return const LoginView();
    });
  }
}