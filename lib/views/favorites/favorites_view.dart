import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../controllers/favorite_controller.dart';

class FavoritesView extends StatelessWidget {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    final favoriteController = Get.find<FavoriteController>();
    favoriteController.loadFavorites();

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: Obx(() {
        if (favoriteController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (favoriteController.favorites.isEmpty) {
          return const Center(child: Text('No favorites yet'));
        }

        return ListView.builder(
          itemCount: favoriteController.favorites.length,
          itemBuilder: (context, index) {
            final vehicle = favoriteController.favorites[index];
            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                leading: vehicle.images.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: vehicle.images.first,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.image),
                title: Text(vehicle.title),
                subtitle: Text('${vehicle.brand} • BDT ${vehicle.price.toStringAsFixed(2)}'),
                trailing: IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  onPressed: () {
                    favoriteController.toggleFavorite(vehicle.id);
                  },
                ),
                onTap: () {
                  Get.toNamed('/vehicle-detail', arguments: vehicle);
                },
              ),
            );
          },
        );
      }),
    );
  }
}

