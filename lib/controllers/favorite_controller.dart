import 'package:get/get.dart';
import '../models/vehicle.dart';
import '../services/favorite_service.dart';

class FavoriteController extends GetxController {
  final FavoriteService _favoriteService = FavoriteService();
  
  final RxList<Vehicle> favorites = <Vehicle>[].obs;
  final RxBool isLoading = false.obs;
  final RxMap<int, bool> favoriteStatus = <int, bool>{}.obs;

  Future<void> loadFavorites() async {
    try {
      isLoading.value = true;
      final loadedFavorites = await _favoriteService.getFavorites();
      favorites.value = loadedFavorites;
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to load favorites: ${e.toString()}');
    }
  }

  Future<void> toggleFavorite(int vehicleId) async {
    try {
      final isFavorite = favoriteStatus[vehicleId] ?? false;
      if (isFavorite) {
        await _favoriteService.removeFromFavorites(vehicleId);
        favorites.removeWhere((v) => v.id == vehicleId);
        favoriteStatus[vehicleId] = false;
        Get.snackbar('Success', 'Removed from favorites');
      } else {
        await _favoriteService.addToFavorites(vehicleId);
        favoriteStatus[vehicleId] = true;
        Get.snackbar('Success', 'Added to favorites');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update favorite: ${e.toString()}');
    }
  }

  Future<void> checkFavoriteStatus(int vehicleId) async {
    try {
      final isFavorite = await _favoriteService.isFavorite(vehicleId);
      favoriteStatus[vehicleId] = isFavorite;
    } catch (e) {
      favoriteStatus[vehicleId] = false;
    }
  }
}

