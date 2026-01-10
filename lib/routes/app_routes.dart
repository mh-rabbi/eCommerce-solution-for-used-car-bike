import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../views/login/login_view.dart';
import '../views/login/login_view_v2.dart';
import '../views/home/home_view.dart';
import '../views/home/home_view_v2.dart';
import '../views/splash/splash_view.dart';
import '../views/splash/splash_view_premium.dart';
import '../views/onboarding/onboarding_view.dart';
import '../views/onboarding/onboarding_view_premium.dart';
import '../views/login/login_view_premium.dart';
import '../views/home/home_view_premium.dart';
import '../views/vehicle_list/vehicle_list_view.dart';
import '../views/post_vehicle/post_vehicle_view.dart';
import '../views/post_vehicle/post_vehicle_view_premium.dart';
import '../views/favorites/favorites_view.dart';
import '../views/profile/profile_view.dart';
import '../views/profile/profile_view_v2.dart';
import '../views/profile/profile_view_premium.dart';
import '../views/profile/edit_profile_view.dart';
import '../views/sell_history/sell_history_view.dart';
import '../views/payment/payment_view.dart';
import '../views/vehicle_detail/vehicle_detail_view.dart';

class AppRoutes {
  static final routes = [
    GetPage(name: '/', page: () => const SplashViewPremium()),
    GetPage(name: '/splash', page: () => const SplashViewPremium()),
    // GetPage(name: '/splash-old', page: () => const SplashView()),
    GetPage(name: '/onboarding', page: () => const OnboardingViewPremium()),
    // GetPage(name: '/onboarding-old', page: () => const OnboardingView()),
    GetPage(name: '/login', page: () => const LoginViewPremium()),
    // GetPage(name: '/login-v2', page: () => const LoginViewV2()),
    // GetPage(name: '/login-old', page: () => const LoginView()),
    GetPage(name: '/home', page: () => const HomeViewPremium()),
    // GetPage(name: '/home-v2', page: () => const HomeViewV2()),
    // GetPage(name: '/home-old', page: () => const HomeView()),
    GetPage(name: '/vehicles', page: () => const VehicleListView()),
    GetPage(name: '/post-vehicle', page: () => const PostVehicleViewPremium()),
    // GetPage(name: '/post-vehicle-old', page: () => const PostVehicleView()),
    GetPage(name: '/favorites', page: () => const FavoritesView()),
    GetPage(name: '/profile', page: () => const ProfileViewPremium()),
    // GetPage(name: '/profile-v2', page: () => const ProfileViewV2()),
    // GetPage(name: '/profile-old', page: () => const ProfileView()),
    GetPage(name: '/edit-profile', page: () => const EditProfileView()),
    GetPage(name: '/sell-history', page: () => const SellHistoryView()),
    GetPage(name: '/payment/:vehicleId', page: () => const PaymentView()),
    GetPage(name: '/vehicle-detail', page: () => const VehicleDetailView()),
  ];
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

