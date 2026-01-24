import 'package:get/get.dart';
import '../models/vehicle.dart';
import '../services/vehicle_service.dart';
import '../services/auth_service.dart';
import '../services/socket_service.dart';
import '../config/app_config.dart';

class VehicleController extends GetxController {
  final VehicleService _vehicleService = VehicleService();
  late SocketService _socketService;

  final RxList<Vehicle> vehicles = <Vehicle>[].obs;
  final RxList<Vehicle> myVehicles = <Vehicle>[].obs;
  final RxList<Vehicle> filteredVehicles = <Vehicle>[].obs;
  final RxBool isLoading = false.obs;
  final Rx<Vehicle?> selectedVehicle = Rx<Vehicle?>(null);
  final RxString currentFilter = 'all'.obs; // 'all', 'car', 'bike'
  
  // Search and filter functionality
  final RxString searchQuery = ''.obs;
  final Rx<double?> minPriceFilter = Rx<double?>(null);
  final Rx<double?> maxPriceFilter = Rx<double?>(null);
  final RxBool isSearchActive = false.obs;
  
  // Real-time connection status
  final RxBool isConnectedToRealtime = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initSocketService();
  }

  /// Initialize socket service for real-time updates
  void _initSocketService() {
    try {
      _socketService = Get.find<SocketService>();
      _setupSocketListeners();
      print('✅ VehicleController: Socket service initialized');
    } catch (e) {
      print('⚠️ VehicleController: Socket service not available yet: $e');
    }
  }

  /// Setup listeners for real-time vehicle events
  void _setupSocketListeners() {
    // Listen for vehicle approvals - add to home page list
    _socketService.onVehicleApproved = (Vehicle vehicle) {
      print('🚗 Real-time: Vehicle approved - ${vehicle.title}');
      _addApprovedVehicle(vehicle);
    };

    // Listen for vehicle rejections - remove from lists
    _socketService.onVehicleRejected = (int vehicleId) {
      print('❌ Real-time: Vehicle rejected - $vehicleId');
      _removeVehicle(vehicleId);
    };

    // Listen for vehicle sold events - update in lists
    _socketService.onVehicleSold = (Vehicle vehicle) {
      print('💰 Real-time: Vehicle sold - ${vehicle.title}');
      _updateVehicleInList(vehicle);
    };

    // Listen for vehicle deletions
    _socketService.onVehicleDeleted = (int vehicleId) {
      print('🗑️ Real-time: Vehicle deleted - $vehicleId');
      _removeVehicle(vehicleId);
    };

    // Track connection status
    ever(_socketService.isConnected, (bool connected) {
      isConnectedToRealtime.value = connected;
      if (connected) {
        print('🔌 VehicleController: Real-time updates enabled');
      } else {
        print('🔌 VehicleController: Real-time updates disabled');
      }
    });
  }

  /// Add an approved vehicle to the list (real-time update)
  void _addApprovedVehicle(Vehicle vehicle) {
    // Check if vehicle already exists to avoid duplicates
    final existingIndex = vehicles.indexWhere((v) => v.id == vehicle.id);
    if (existingIndex == -1) {
      // Add to the beginning of the list (newest first)
      vehicles.insert(0, vehicle);
      _applyFilter();
      
      // Show notification
      Get.snackbar(
        '🚗 New Vehicle Available!',
        '${vehicle.title} has been added',
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.TOP,
      );
    } else {
      // Update existing vehicle
      vehicles[existingIndex] = vehicle;
      _applyFilter();
    }
  }

  /// Remove a vehicle from lists (rejected or deleted)
  void _removeVehicle(int vehicleId) {
    vehicles.removeWhere((v) => v.id == vehicleId);
    filteredVehicles.removeWhere((v) => v.id == vehicleId);
    myVehicles.removeWhere((v) => v.id == vehicleId);
  }

  /// Update a vehicle in the list
  void _updateVehicleInList(Vehicle updatedVehicle) {
    // If vehicle is sold, remove it from the marketplace (home page)
    if (updatedVehicle.status.toLowerCase() == 'sold') {
      vehicles.removeWhere((v) => v.id == updatedVehicle.id);
      filteredVehicles.removeWhere((v) => v.id == updatedVehicle.id);
      print('💰 Real-time: Vehicle removed from marketplace because it was sold');
    } else {
      final index = vehicles.indexWhere((v) => v.id == updatedVehicle.id);
      if (index != -1) {
        vehicles[index] = updatedVehicle;
        _applyFilter();
      }
    }

    // Always update in my vehicles list so the seller sees the status change
    final myIndex = myVehicles.indexWhere((v) => v.id == updatedVehicle.id);
    if (myIndex != -1) {
      myVehicles[myIndex] = updatedVehicle;
    }
  }

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

  Future<Vehicle?> createVehicle(Vehicle vehicle) async {
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
        return null;
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
        return null;
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
      
      // Return the created vehicle - caller will handle navigation to checkout
      return createdVehicle;
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
        return null;
      }

      _handleError('Failed to post vehicle', e);
      return null;
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

  // Search functionality
  void updateSearchQuery(String query) {
    searchQuery.value = query;
    _applyFilter();
  }

  void toggleSearch() {
    isSearchActive.value = !isSearchActive.value;
    if (!isSearchActive.value) {
      // Clear search when closing
      searchQuery.value = '';
      _applyFilter();
    }
  }

  void clearSearch() {
    searchQuery.value = '';
    _applyFilter();
  }

  // Price range filter
  void setPriceRange(double? minPrice, double? maxPrice) {
    minPriceFilter.value = minPrice;
    maxPriceFilter.value = maxPrice;
    _applyFilter();
  }

  void clearPriceFilter() {
    minPriceFilter.value = null;
    maxPriceFilter.value = null;
    _applyFilter();
  }

  // Get price range from all vehicles
  double get minVehiclePrice {
    if (vehicles.isEmpty) return 0;
    return vehicles.map((v) => v.price).reduce((a, b) => a < b ? a : b);
  }

  double get maxVehiclePrice {
    if (vehicles.isEmpty) return 1000000;
    return vehicles.map((v) => v.price).reduce((a, b) => a > b ? a : b);
  }

  void _applyFilter() {
    List<Vehicle> result = vehicles.toList();
    
    // Apply type filter
    switch (currentFilter.value) {
      case 'car':
        result = result.where((vehicle) =>
            vehicle.type.toLowerCase() == 'car').toList();
        break;
      case 'bike':
        result = result.where((vehicle) =>
            vehicle.type.toLowerCase() == 'bike' ||
            vehicle.type.toLowerCase() == 'motorcycle').toList();
        break;
    }
    
    // Apply search query filter
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      result = result.where((vehicle) =>
          vehicle.title.toLowerCase().contains(query) ||
          vehicle.brand.toLowerCase().contains(query) ||
          vehicle.description.toLowerCase().contains(query)).toList();
    }
    
    // Apply price range filter
    if (minPriceFilter.value != null) {
      result = result.where((vehicle) =>
          vehicle.price >= minPriceFilter.value!).toList();
    }
    if (maxPriceFilter.value != null) {
      result = result.where((vehicle) =>
          vehicle.price <= maxPriceFilter.value!).toList();
    }
    
    filteredVehicles.value = result;
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