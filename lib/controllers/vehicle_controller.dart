import 'package:get/get.dart';
import '../models/vehicle.dart';
import '../services/vehicle_service.dart';
import '../services/auth_service.dart';

class VehicleController extends GetxController {
  final VehicleService _vehicleService = VehicleService();

  final RxList<Vehicle> vehicles = <Vehicle>[].obs;
  final RxList<Vehicle> myVehicles = <Vehicle>[].obs;
  final RxBool isLoading = false.obs;
  final Rx<Vehicle?> selectedVehicle = Rx<Vehicle?>(null);

  Future<void> loadVehicles({String? status}) async {
    try {
      isLoading.value = true;
      final loadedVehicles = await _vehicleService.getVehicles(status: status);
      vehicles.value = loadedVehicles;
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to load vehicles: ${e.toString()}');
    }
  }

  Future<void> loadMyVehicles() async {
    try {
      isLoading.value = true;
      final loadedVehicles = await _vehicleService.getMyVehicles();
      myVehicles.value = loadedVehicles;
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to load your vehicles: ${e.toString()}');
    }
  }

  Future<void> loadVehicle(int id) async {
    try {
      isLoading.value = true;
      final vehicle = await _vehicleService.getVehicle(id);
      selectedVehicle.value = vehicle;
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to load vehicle: ${e.toString()}');
    }
  }

  Future<bool> createVehicle(Vehicle vehicle) async {
    try {
      // Check if user is still logged in
      final authService = AuthService();
      final isLoggedIn = await authService.isLoggedIn();
      
      if (!isLoggedIn) {
        Get.snackbar('Error', 'Please login again');
        Get.offAllNamed('/login');
        return false;
      }
      
      // Check token validity
      final isValid = await authService.isTokenValid();
      if (!isValid) {
        Get.snackbar('Error', 'Session expired. Please login again');
        await authService.logout();
        Get.offAllNamed('/login');
        return false;
      }
      
      isLoading.value = true;
      print('Creating vehicle: ${vehicle.title}');
      print('Vehicle JSON: ${vehicle.toJson()}');
      
      final createdVehicle = await _vehicleService.createVehicle(vehicle);
      print('Vehicle created successfully with ID: ${createdVehicle.id}');
      
      isLoading.value = false;
      Get.snackbar('Success', 'Vehicle posted successfully! Waiting for admin approval.');
      return true;
    } catch (e) {
      isLoading.value = false;
      print('Create vehicle error: $e');
      print('Error type: ${e.runtimeType}');
      print('Error toString: ${e.toString()}');
      
      String errorMessage = 'Failed to post vehicle';
      
      // Check if it's an auth error
      if (e.toString().contains('401') || 
          e.toString().contains('Unauthorized') ||
          e.toString().contains('Authentication failed')) {
        errorMessage = 'Session expired. Please login again.';
        final authService = AuthService();
        await authService.logout();
        Get.offAllNamed('/login');
      } else if (e.toString().contains('Network') || 
                 e.toString().contains('Connection') ||
                 e.toString().contains('timeout')) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (e.toString().contains('Validation')) {
        errorMessage = 'Invalid data. Please check all fields.';
      } else {
        // Extract meaningful error message
        final errorStr = e.toString();
        if (errorStr.contains('Exception: ')) {
          errorMessage = errorStr.split('Exception: ').last;
        } else if (errorStr.contains('Error: ')) {
          errorMessage = errorStr.split('Error: ').last;
        } else {
          errorMessage = errorStr;
        }
      }
      
      Get.snackbar('Error', errorMessage, duration: const Duration(seconds: 5));
      return false;
    }
  }

  Future<void> markAsSold(int vehicleId) async {
    try {
      isLoading.value = true;
      await _vehicleService.markAsSold(vehicleId);
      await loadMyVehicles();
      isLoading.value = false;
      Get.snackbar('Success', 'Vehicle marked as sold!');
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to mark as sold: ${e.toString()}');
    }
  }
}

