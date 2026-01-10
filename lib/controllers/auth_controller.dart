import 'dart:io';
import 'package:get/get.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  
  final RxBool isLoading = false.obs;
  final Rx<User?> currentUser = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    final isLoggedIn = await _authService.isLoggedIn();
    if (isLoggedIn) {
      currentUser.value = await _authService.getCurrentUser();
    }
  }

  Future<bool> register(String name, String email, String password) async {
    try {
      isLoading.value = true;
      print('Attempting registration for: $email');
      final response = await _authService.register(name, email, password);
      print('Registration response keys: ${response.keys}');
      
      if (response['access_token'] != null) {
        currentUser.value = User.fromJson(response['user']);
        isLoading.value = false;
        print('Registration successful!');
        return true;
      }
      isLoading.value = false;
      final errorMsg = response['message'] ?? 'Registration failed: No token received';
      Get.snackbar('Error', errorMsg);
      return false;
    } catch (e) {
      isLoading.value = false;
      print('Registration error: $e');
      String errorMessage = 'Registration failed';
      if (e.toString().contains('Email already exists')) {
        errorMessage = 'Email already registered. Please login instead.';
      } else if (e.toString().contains('Network') || e.toString().contains('Connection')) {
        errorMessage = 'Network error. Please check your connection.';
      } else {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      }
      Get.snackbar('Error', errorMessage);
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      isLoading.value = true;
      print('Attempting login for: $email');
      final response = await _authService.login(email, password);
      print('Login response keys: ${response.keys}');
      
      if (response['access_token'] != null) {
        currentUser.value = User.fromJson(response['user']);
        isLoading.value = false;
        print('Login successful! Token saved.');
        
        // Verify token was saved
        final token = await _authService.isLoggedIn();
        print('Token saved check: $token');
        
        return true;
      }
      isLoading.value = false;
      final errorMsg = response['message'] ?? 'Login failed: No token received';
      Get.snackbar('Error', errorMsg);
      return false;
    } catch (e) {
      isLoading.value = false;
      print('Login error: $e');
      String errorMessage = 'Login failed';
      if (e.toString().contains('Invalid credentials')) {
        errorMessage = 'Invalid email or password. Please try again.';
      } else if (e.toString().contains('Network') || e.toString().contains('Connection')) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
        errorMessage = 'Invalid email or password.';
      } else {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      }
      Get.snackbar('Error', errorMessage);
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    currentUser.value = null;
    Get.offAllNamed('/login');
  }

  /// Refresh user profile from server
  Future<void> refreshUserProfile() async {
    try {
      final user = await _userService.getProfile();
      currentUser.value = user;
      // Also update local storage
      await _authService.updateLocalUser(user);
    } catch (e) {
      print('Error refreshing user profile: $e');
      if (e.toString().contains('UNAUTHORIZED')) {
        await logout();
      }
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? name,
    String? email,
    String? address,
    String? streetNo,
    String? postalCode,
    String? phone,
  }) async {
    try {
      isLoading.value = true;
      final updatedUser = await _userService.updateProfile(
        name: name,
        email: email,
        address: address,
        streetNo: streetNo,
        postalCode: postalCode,
        phone: phone,
      );
      currentUser.value = updatedUser;
      await _authService.updateLocalUser(updatedUser);
      isLoading.value = false;
      Get.snackbar('Success', 'Profile updated successfully',
          snackPosition: SnackPosition.BOTTOM);
      return true;
    } catch (e) {
      isLoading.value = false;
      print('Error updating profile: $e');
      String errorMessage = 'Failed to update profile';
      if (e.toString().contains('UNAUTHORIZED')) {
        await logout();
        errorMessage = 'Session expired. Please login again.';
      } else {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      }
      Get.snackbar('Error', errorMessage, snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }

  /// Upload profile image
  Future<bool> uploadProfileImage(File imageFile) async {
    try {
      isLoading.value = true;
      final updatedUser = await _userService.uploadProfileImage(imageFile);
      currentUser.value = updatedUser;
      await _authService.updateLocalUser(updatedUser);
      isLoading.value = false;
      Get.snackbar('Success', 'Profile image updated',
          snackPosition: SnackPosition.BOTTOM);
      return true;
    } catch (e) {
      isLoading.value = false;
      print('Error uploading profile image: $e');
      String errorMessage = 'Failed to upload image';
      if (e.toString().contains('UNAUTHORIZED')) {
        await logout();
        errorMessage = 'Session expired. Please login again.';
      } else {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      }
      Get.snackbar('Error', errorMessage, snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }

  /// Get full profile image URL
  String getProfileImageUrl() {
    final imagePath = currentUser.value?.profileImage;
    return _userService.getProfileImageUrl(imagePath);
  }
}

