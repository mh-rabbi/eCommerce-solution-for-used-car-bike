import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/vehicle_controller.dart';
import '../vehicle_list/vehicle_list_view.dart';
import '../post_vehicle/post_vehicle_view.dart';
import '../favorites/favorites_view.dart';
import '../profile/profile_view.dart';
import '../sell_history/sell_history_view.dart';

class HomeViewV2 extends StatelessWidget {
  const HomeViewV2({super.key});

  @override
  Widget build(BuildContext context) {
    final vehicleController = Get.find<VehicleController>();
    final authController = Get.find<AuthController>();
    vehicleController.loadVehicles();

    return Scaffold(
      drawer: _buildDrawer(context, authController),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFD4EBFF),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Header Section
              _buildTopHeader(context, authController),
              // Vehicle List
              Expanded(
                child: const VehicleListView(),
              ),
              // Bottom Grid Navigation
              _buildBottomGrid(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context, AuthController authController) {
    return Container(
      height: 170,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF3976B3),
            Color(0xFF06A4B4),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 25,
            left: 10,
            child: Obx(() => Text(
                  'Hello, ${authController.currentUser.value?.name ?? "User"}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                )),
          ),
          Positioned(
            top: 60,
            left: 15,
            child: const Text(
              'Buy Your Perfect Vehicle from here..',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ),
          // Logo circle overlay
          Positioned(
            right: 40,
            top: 50,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.directions_car,
                size: 50,
                color: Color(0xFF06A4B4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomGrid(BuildContext context) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      child: GridView.count(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 15,
        children: [
          _buildGridCard(
            icon: Icons.add_circle,
            label: 'Sell',
            color: const Color(0xFFE6E6FA),
            onTap: () => Get.toNamed('/post-vehicle'),
          ),
          _buildGridCard(
            icon: Icons.directions_car,
            label: 'Car',
            color: Colors.white,
            onTap: () {
              Get.find<VehicleController>().loadVehicles(status: 'approved');
              // Filter by car type
            },
          ),
          _buildGridCard(
            icon: Icons.two_wheeler,
            label: 'Bike',
            color: Colors.white,
            onTap: () {
              Get.find<VehicleController>().loadVehicles(status: 'approved');
              // Filter by bike type
            },
          ),
          _buildGridCard(
            icon: Icons.local_taxi,
            label: 'Rent',
            color: Colors.white,
            onTap: () {
              // Navigate to rent page
            },
          ),
          _buildGridCard(
            icon: Icons.favorite,
            label: 'Favorite',
            color: Colors.white,
            onTap: () => Get.toNamed('/favorites'),
          ),
          _buildGridCard(
            icon: Icons.history,
            label: 'History',
            color: Colors.white,
            onTap: () => Get.toNamed('/sell-history'),
          ),
          _buildGridCard(
            icon: Icons.support_agent,
            label: 'Support',
            color: Colors.white,
            onTap: () {
              // Navigate to support
            },
          ),
          _buildGridCard(
            icon: Icons.settings,
            label: 'Setting',
            color: Colors.white,
            onTap: () => Get.toNamed('/profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildGridCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        color: color,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 44,
              color: const Color(0xFF06A4B4),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, AuthController authController) {
    return Drawer(
      child: Column(
        children: [
          // Drawer Header
          Container(
            height: 176,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF3976B3),
                  Color(0xFF06A4B4),
                ],
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40),
                ),
                const SizedBox(height: 10),
                Obx(() => Text(
                      authController.currentUser.value?.name ?? 'Profile Name',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
                const SizedBox(height: 5),
                Obx(() => Text(
                      authController.currentUser.value?.email ??
                          'contact@gmail.com',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    )),
              ],
            ),
          ),
          // Drawer Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Home'),
                  onTap: () {
                    Get.back();
                    Get.offAllNamed('/home');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Profile'),
                  onTap: () {
                    Get.back();
                    Get.toNamed('/profile');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.favorite),
                  title: const Text('Favorites'),
                  onTap: () {
                    Get.back();
                    Get.toNamed('/favorites');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('Sell History'),
                  onTap: () {
                    Get.back();
                    Get.toNamed('/sell-history');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () {
                    Get.back();
                    Get.toNamed('/profile');
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Logout', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Get.back();
                    authController.logout();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

