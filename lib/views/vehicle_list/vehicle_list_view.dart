import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../controllers/vehicle_controller.dart';
import '../../controllers/favorite_controller.dart';
import '../../models/vehicle.dart';

class VehicleListView extends StatelessWidget {
  const VehicleListView({super.key});

  @override
  Widget build(BuildContext context) {
    final vehicleController = Get.find<VehicleController>();
    final favoriteController = Get.find<FavoriteController>();

    return Obx(() {
      if (vehicleController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (vehicleController.vehicles.isEmpty) {
        return const Center(child: Text('No vehicles available'));
      }

      return ListView.builder(
        itemCount: vehicleController.vehicles.length,
        itemBuilder: (context, index) {
          final vehicle = vehicleController.vehicles[index];
          return VehicleCard(vehicle: vehicle);
        },
      );
    });
  }
}

class VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final FavoriteController favoriteController = Get.find<FavoriteController>();

  VehicleCard({super.key, required this.vehicle}) {
    favoriteController.checkFavoriteStatus(vehicle.id);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: InkWell(
        onTap: () {
          Get.toNamed('/vehicle-detail', arguments: vehicle);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (vehicle.images.isNotEmpty)
              Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: vehicle.images.first,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Obx(() => IconButton(
                      icon: Icon(
                        favoriteController.favoriteStatus[vehicle.id] == true
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        favoriteController.toggleFavorite(vehicle.id);
                      },
                    )),
                  ),
                ],
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('${vehicle.brand} • ${vehicle.type}'),
                  const SizedBox(height: 8),
                  Text(
                    '\$${vehicle.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

