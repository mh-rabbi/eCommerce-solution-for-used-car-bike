import '../models/vehicle.dart';
import 'api_service.dart';

class FavoriteService {
  final ApiService _apiService = ApiService();

  Future<List<Vehicle>> getFavorites() async {
    final response = await _apiService.getList('/favorites');
    return response.map((json) => Vehicle.fromJson(json['vehicle'])).toList();
  }

  Future<void> addToFavorites(int vehicleId) async {
    await _apiService.post('/favorites/$vehicleId', {});
  }

  Future<void> removeFromFavorites(int vehicleId) async {
    await _apiService.delete('/favorites/$vehicleId');
  }

  Future<bool> isFavorite(int vehicleId) async {
    final response = await _apiService.get('/favorites/$vehicleId/check');
    return response['isFavorite'] ?? false;
  }
}

