import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:vehicle_marketplace/views/checkout/checkout_view.dart';
import '../controllers/auth_controller.dart';
import '../views/splash/splash_view_premium.dart';
import '../views/onboarding/onboarding_view_premium.dart';
import '../views/login/login_view_premium.dart';
import '../views/home/home_view_premium.dart';
import '../views/vehicle_list/vehicle_list_view.dart';
import '../views/post_vehicle/post_vehicle_view_premium.dart';
import '../views/favorites/favorites_view.dart';
import '../views/profile/profile_view_premium.dart';
import '../views/profile/edit_profile_view.dart';
import '../views/sell_history/sell_history_view.dart';
import '../views/my_posts/my_posts_view.dart';
import '../views/my_posts/payment_detail_view.dart';
import '../views/vehicle_detail/vehicle_detail_view.dart';
import '../views/support/support_view.dart';

class AppRoutes {
  static final routes = [
    GetPage(name: '/', page: () => const SplashViewPremium()),
    GetPage(name: '/splash', page: () => const SplashViewPremium()),
    GetPage(name: '/onboarding', page: () => const OnboardingViewPremium()),
    GetPage(name: '/login', page: () => const LoginViewPremium()),
    GetPage(name: '/home', page: () => const HomeViewPremium()),
    GetPage(name: '/vehicles', page: () => const VehicleListView()),
    GetPage(name: '/post-vehicle', page: () => const PostVehicleViewPremium()),
    GetPage(name: '/favorites', page: () => const FavoritesView()),
    GetPage(name: '/profile', page: () => const ProfileViewPremium()),
    GetPage(name: '/edit-profile', page: () => const EditProfileView()),
    GetPage(name: '/sell-history', page: () => const SellHistoryView()),
    GetPage(name: '/my-posts', page: () => const MyPostsView()),
    GetPage(name: '/vehicle-detail', page: () => const VehicleDetailView()),
    GetPage(name: '/checkout', page: () => const CheckoutView()), 
    GetPage(name: '/support', page: () => const SupportView()),
    GetPage(name: '/payment-detail', page: () => const PaymentDetailView()),
  ];
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    
    return Obx(() {
      if (authController.currentUser.value != null) {
        return const HomeViewPremium();
      }
      return const LoginViewPremium();
    });
  }
}
