import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/vehicle_controller.dart';
import '../vehicle_list/vehicle_list_view.dart';
import '../post_vehicle/post_vehicle_view.dart';
import '../favorites/favorites_view.dart';
import '../profile/profile_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final vehicleController = Get.find<VehicleController>();
    vehicleController.loadVehicles();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Marketplace'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () => Get.toNamed('/favorites'),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Get.toNamed('/profile'),
          ),
        ],
      ),
      body: const VehicleListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/post-vehicle'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

