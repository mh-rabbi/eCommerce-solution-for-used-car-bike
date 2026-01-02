import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/vehicle_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/animated_card.dart';
import '../../core/widgets/shimmer_loading.dart';
import '../../core/widgets/empty_state.dart';
import '../../models/vehicle.dart';
import '../../controllers/favorite_controller.dart';
import '../vehicle_list/vehicle_list_view.dart';
import '../post_vehicle/post_vehicle_view.dart';
import '../favorites/favorites_view.dart';
import '../profile/profile_view_v2.dart';
import '../sell_history/sell_history_view.dart';

class HomeViewPremium extends StatelessWidget {
  const HomeViewPremium({super.key});

  @override
  Widget build(BuildContext context) {
    final vehicleController = Get.find<VehicleController>();
    final authController = Get.find<AuthController>();
    vehicleController.loadVehicles();

    return Scaffold(
      drawer: _buildDrawer(context, authController),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.subtleGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Elegant Header
              _buildHeader(context, authController),
              // Vehicle List with Staggered Animation
              Expanded(
                child: _buildVehicleList(context, vehicleController),
              ),
              // Floating Quick Actions
              _buildQuickActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AuthController authController) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacingLG,
        AppTheme.spacingMD,
        AppTheme.spacingLG,
        AppTheme.spacingLG,
      ),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: AppTheme.shadow2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Menu Icon
              IconButton(
                icon: const Icon(Icons.menu_rounded, color: Colors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
              )
                  .animate()
                  .fadeIn(duration: 300.ms)
                  .scale(delay: 100.ms),
              
              // Search Icon
              IconButton(
                icon: const Icon(Icons.search_rounded, color: Colors.white),
                onPressed: () {
                  // TODO: Implement search
                },
              )
                  .animate()
                  .fadeIn(duration: 300.ms)
                  .scale(delay: 200.ms),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() => Text(
                'Hello, ${authController.currentUser.value?.name ?? "User"} 👋',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ))
              .animate()
              .fadeIn(delay: 200.ms, duration: 600.ms)
              .slideX(begin: -0.2, end: 0, duration: 600.ms),
          const SizedBox(height: 8),
          const Text(
            'Find your perfect vehicle',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          )
              .animate()
              .fadeIn(delay: 300.ms, duration: 600.ms)
              .slideX(begin: -0.2, end: 0, duration: 600.ms),
        ],
      ),
    );
  }

  Widget _buildVehicleList(
      BuildContext context, VehicleController vehicleController) {
    return Obx(() {
      if (vehicleController.isLoading.value) {
        return ListView.builder(
          padding: const EdgeInsets.all(AppTheme.spacingMD),
          itemCount: 3,
          itemBuilder: (context, index) => const ShimmerVehicleCard(),
        );
      }

      if (vehicleController.filteredVehicles.isEmpty) {
        return EmptyState(
          icon: Icons.directions_car_outlined,
          title: 'No Vehicles Yet',
          message: 'Be the first to list a vehicle!',
          actionLabel: 'Post Vehicle',
          onAction: () => Get.toNamed('/post-vehicle'),
        );
      }

      return AnimationLimiter(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Responsive grid: 2 columns on larger screens, 1 on smaller
            final crossAxisCount = constraints.maxWidth > 600 ? 2 : 2;
            return GridView.builder(
              padding: const EdgeInsets.all(AppTheme.spacingMD),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: AppTheme.spacingMD,
                mainAxisSpacing: AppTheme.spacingMD,
                childAspectRatio: 0.9,
              ),
              itemCount: vehicleController.filteredVehicles.length,
              itemBuilder: (context, index) {
                final vehicle = vehicleController.filteredVehicles[index];
                return AnimationConfiguration.staggeredGrid(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  columnCount: crossAxisCount,
                  child: ScaleAnimation(
                    child: FadeInAnimation(
                      child: _buildVehicleCard(vehicle),
                    ),
                  ),
                );
              },
            );
          },
        ),
      );
    });
  }

  Widget _buildVehicleCard(Vehicle vehicle) {
    final favoriteController = Get.find<FavoriteController>();
    favoriteController.checkFavoriteStatus(vehicle.id);

    return AnimatedCard(
      index: 0,
      onTap: () {
        Get.toNamed('/vehicle-detail', arguments: vehicle);
      },
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image - Takes up flexible space
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppTheme.radiusLarge),
                topRight: Radius.circular(AppTheme.radiusLarge),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: AppTheme.surfaceVariant,
                    child: vehicle.images.isNotEmpty
                        ? Image.network(
                            vehicle.images.first,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.image_not_supported),
                          )
                        : const Icon(Icons.directions_car, size: 40),
                  ),
                  // Favorite Button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: AppTheme.shadow1,
                      ),
                      child: Obx(() => IconButton(
                        icon: Icon(
                          favoriteController.favoriteStatus[vehicle.id] == true
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 18,
                        ),
                        onPressed: () {
                          favoriteController.toggleFavorite(vehicle.id);
                        },
                        color: Colors.red,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                      )),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content - Takes up flexible space
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingSM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  // Title - Allow flexible height
                  Flexible(
                    flex: 2,
                    child: Text(
                      vehicle.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Brand and Type - Fixed height
                  SizedBox(
                    height: 16,
                    child: Text(
                      '${vehicle.brand} • ${vehicle.type}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Price - Fixed at bottom
                  Text(
                    'BDT ${vehicle.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.success,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppTheme.spacingMD),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMD,
        vertical: AppTheme.spacingSM,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: AppTheme.shadow2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildQuickAction(Icons.add_circle, 'Sell', () {
            Get.toNamed('/post-vehicle');
          }),
          Obx(() {
            final vehicleController = Get.find<VehicleController>();
            return _buildQuickAction(
              Icons.directions_car,
              'Cars',
              () => vehicleController.filterByType('car'),
              isSelected: vehicleController.currentFilter.value == 'car',
            );
          }),
          Obx(() {
            final vehicleController = Get.find<VehicleController>();
            return _buildQuickAction(
              Icons.two_wheeler,
              'Bikes',
              () => vehicleController.filterByType('bike'),
              isSelected: vehicleController.currentFilter.value == 'bike',
            );
          }),
          _buildQuickAction(Icons.list, 'All', () {
            final vehicleController = Get.find<VehicleController>();
            vehicleController.showAllVehicles();
          }),
          _buildQuickAction(Icons.favorite, 'Favorites', () {
            Get.toNamed('/favorites');
          }),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 200.ms, duration: 400.ms)
        .slideY(begin: 0.3, end: 0, duration: 400.ms);
  }

  Widget _buildQuickAction(IconData icon, String label, VoidCallback onTap, {bool isSelected = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primary
                  : AppTheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
              border: isSelected ? Border.all(color: AppTheme.primary, width: 2) : null,
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : AppTheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isSelected ? AppTheme.primary : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, AuthController authController) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: Column(
          children: [
            // Drawer Header
            Container(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spacingLG,
                60,
                AppTheme.spacingLG,
                AppTheme.spacingLG,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 50, color: AppTheme.primary),
                  ),
                  const SizedBox(height: 16),
                  Obx(() => Text(
                        authController.currentUser.value?.name ?? 'User',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      )),
                  const SizedBox(height: 4),
                  Obx(() => Text(
                        authController.currentUser.value?.email ?? '',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      )),
                ],
              ),
            ),
            // Menu Items
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: ListView(
                  padding: const EdgeInsets.only(top: AppTheme.spacingLG),
                  children: [
                    _buildDrawerItem(
                      Icons.home_rounded,
                      'Home',
                      () {
                        Get.back();
                        Get.offAllNamed('/home');
                      },
                    ),
                    _buildDrawerItem(
                      Icons.person_rounded,
                      'Profile',
                      () {
                        Get.back();
                        Get.toNamed('/profile');
                      },
                    ),
                    _buildDrawerItem(
                      Icons.favorite_rounded,
                      'Favorites',
                      () {
                        Get.back();
                        Get.toNamed('/favorites');
                      },
                    ),
                    _buildDrawerItem(
                      Icons.history_rounded,
                      'Sell History',
                      () {
                        Get.back();
                        Get.toNamed('/sell-history');
                      },
                    ),
                    _buildDrawerItem(
                      Icons.settings_rounded,
                      'Settings',
                      () {
                        Get.back();
                        Get.toNamed('/profile');
                      },
                    ),
                    const Divider(height: 32),
                    _buildDrawerItem(
                      Icons.logout_rounded,
                      'Logout',
                      () {
                        Get.back();
                        authController.logout();
                      },
                      isDestructive: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppTheme.error : AppTheme.primary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? AppTheme.error : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
    );
  }
}

