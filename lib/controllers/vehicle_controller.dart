import 'package:get/get.dart';
import '../models/vehicle.dart';
import '../services/vehicle_service.dart';
import '../services/auth_service.dart';
import '../config/app_config.dart';

class VehicleController extends GetxController {
  final VehicleService _vehicleService = VehicleService();

  final RxList<Vehicle> vehicles = <Vehicle>[].obs;
  final RxList<Vehicle> myVehicles = <Vehicle>[].obs;
  final RxList<Vehicle> filteredVehicles = <Vehicle>[].obs;
  final RxBool isLoading = false.obs;
  final Rx<Vehicle?> selectedVehicle = Rx<Vehicle?>(null);
  final RxString currentFilter = 'all'.obs; // 'all', 'car', 'bike'

  Future<void> loadVehicles({String? status}) async {
    try {
      isLoading.value = true;
      final loadedVehicles = await _vehicleService.getVehicles(status: status);
      vehicles.value = loadedVehicles;
      _applyFilter(); // Apply current filter to new data
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      _handleError('Failed to load vehicles', e);
    }
  }

  Future<void> loadMyVehicles() async {
    try {
      print('🔄 VehicleController: Loading my vehicles...');
      isLoading.value = true;
      final loadedVehicles = await _vehicleService.getMyVehicles();
      print('✅ VehicleController: Loaded ${loadedVehicles.length} vehicles');
      myVehicles.value = loadedVehicles;
      isLoading.value = false;
      print('✅ VehicleController: My vehicles updated in observable');
    } catch (e) {
      print('❌ VehicleController: Error loading my vehicles: $e');
      isLoading.value = false;
      _handleError('Failed to load your vehicles', e);
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
      _handleError('Failed to load vehicle', e);
    }
  }

  Future<bool> createVehicle(Vehicle vehicle) async {
    try {
      // CRITICAL FIX: Check authentication BEFORE attempting to create
      final authService = AuthService();
      final isLoggedIn = await authService.isLoggedIn();

      if (!isLoggedIn) {
        if (AppConfig.isDebugMode) {
          print('❌ User not logged in');
        }
        Get.snackbar('Error', 'Please login again');
        Get.offAllNamed('/login');
        return false;
      }

      // CRITICAL FIX: Validate token is still valid
      final isValid = await authService.isTokenValid();
      if (!isValid) {
        if (AppConfig.isDebugMode) {
          print('❌ Token expired');
        }
        Get.snackbar('Error', 'Session expired. Please login again');
        await authService.logout();
        Get.offAllNamed('/login');
        return false;
      }

      isLoading.value = true;

      if (AppConfig.isDebugMode) {
        print('=================================');
        print('🚗 Creating vehicle: ${vehicle.title}');
        print('Vehicle JSON: ${vehicle.toJson()}');
        print('=================================');
      }

      final createdVehicle = await _vehicleService.createVehicle(vehicle);

      if (AppConfig.isDebugMode) {
        print('✅ Vehicle created successfully with ID: ${createdVehicle.id}');
      }

      isLoading.value = false;
      Get.snackbar(
        'Success',
        'Vehicle posted successfully! Waiting for admin approval.',
        duration: const Duration(seconds: 3),
      );
      return true;
    } catch (e) {
      isLoading.value = false;

      if (AppConfig.isDebugMode) {
        print('❌ Create vehicle error: $e');
        print('Error type: ${e.runtimeType}');
      }

      // CRITICAL FIX: Handle UNAUTHORIZED specifically
      if (e.toString().contains('UNAUTHORIZED')) {
        Get.snackbar('Error', 'Session expired. Please login again.');
        final authService = AuthService();
        await authService.logout();
        Get.offAllNamed('/login');
        return false;
      }

      _handleError('Failed to post vehicle', e);
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
      _handleError('Failed to mark as sold', e);
    }
  }

  // Filter methods
  void filterByType(String type) {
    currentFilter.value = type;
    _applyFilter();
  }

  void showAllVehicles() {
    currentFilter.value = 'all';
    _applyFilter();
  }

  void _applyFilter() {
    switch (currentFilter.value) {
      case 'car':
        filteredVehicles.value = vehicles.where((vehicle) =>
            vehicle.type.toLowerCase() == 'car').toList();
        break;
      case 'bike':
        filteredVehicles.value = vehicles.where((vehicle) =>
            vehicle.type.toLowerCase() == 'bike' ||
            vehicle.type.toLowerCase() == 'motorcycle').toList();
        break;
      default:
        filteredVehicles.value = vehicles.toList();
        break;
    }
  }

  // CRITICAL FIX: Centralized error handling
  void _handleError(String baseMessage, dynamic error) {
    if (AppConfig.isDebugMode) {
      print('❌ Error: $baseMessage - $error');
    }

    String errorMessage = baseMessage;
    final errorStr = error.toString();

    // Check for auth errors first
    if (errorStr.contains('UNAUTHORIZED') ||
        errorStr.contains('401') ||
        errorStr.contains('Authentication failed')) {
      errorMessage = 'Session expired. Please login again.';
      final authService = AuthService();
      authService.logout().then((_) {
        Get.offAllNamed('/login');
      });
    }
    // Network errors
    else if (errorStr.contains('Network') ||
        errorStr.contains('Connection') ||
        errorStr.contains('timeout')) {
      errorMessage = '$baseMessage: Network error. Please check your connection.';
    }
    // Validation errors
    else if (errorStr.contains('Validation') ||
        errorStr.contains('Invalid')) {
      errorMessage = '$baseMessage: Invalid data. Please check all fields.';
    }
    // Extract meaningful error message
    else {
      if (errorStr.contains('Exception: ')) {
        errorMessage = '$baseMessage: ${errorStr.split('Exception: ').last}';
      } else if (errorStr.contains('Error: ')) {
        errorMessage = '$baseMessage: ${errorStr.split('Error: ').last}';
      } else {
        errorMessage = '$baseMessage: $errorStr';
      }
    }

    Get.snackbar(
      'Error',
      errorMessage,
      duration: const Duration(seconds: 5),
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}