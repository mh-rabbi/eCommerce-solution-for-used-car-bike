import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vehicle.dart';
import '../config/app_config.dart';
import 'api_service.dart';

class VehicleService {
  final ApiService _apiService = ApiService();
  final Dio _dio = Dio();

  Future<List<Vehicle>> getVehicles({String? status}) async {
    final endpoint = status != null ? '/vehicles?status=$status' : '/vehicles';
    final response = await _apiService.getList(endpoint);
    return response.map((json) => Vehicle.fromJson(json)).toList();
  }

  Future<Vehicle> getVehicle(int id) async {
    final response = await _apiService.get('/vehicles/$id');
    return Vehicle.fromJson(response);
  }

  Future<List<Vehicle>> getMyVehicles() async {
    print('🚗 VehicleService: Fetching my vehicles from API...');
    final response = await _apiService.getList('/vehicles/my-vehicles');
    print('🚗 VehicleService: API returned ${response.length} vehicles');
    final vehicles = response.map((json) => Vehicle.fromJson(json)).toList();
    print('🚗 VehicleService: Parsed ${vehicles.length} vehicles successfully');
    return vehicles;
  }

  Future<Vehicle> createVehicle(Vehicle vehicle) async {
    try {
      if (AppConfig.isDebugMode) {
        print('=================================');
        print('🚗 Creating vehicle');
        print('Vehicle data: ${vehicle.toJson()}');
        print('=================================');
      }

      final response = await _apiService.post(
          '/vehicles',
          vehicle.toJson(),
          requireAuth: true
      );

      if (AppConfig.isDebugMode) {
        print('✅ Vehicle created successfully: $response');
      }

      return Vehicle.fromJson(response);
    } catch (e) {
      if (AppConfig.isDebugMode) {
        print('❌ Error creating vehicle: $e');
      }
      rethrow;
    }
  }

  Future<Vehicle> markAsSold(int vehicleId) async {
    final response = await _apiService.put('/vehicles/$vehicleId/sold', null);
    return Vehicle.fromJson(response);
  }

  Future<List<String>> uploadImages(List<File> imageFiles) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.trim().isEmpty) {
        if (AppConfig.isDebugMode) {
          print('❌ No token found in storage');
        }
        throw Exception('UNAUTHORIZED');
      }

      // CRITICAL FIX: Trim token to remove any whitespace
      final cleanToken = token.trim();
      
      if (AppConfig.isDebugMode) {
        print('🔑 Token for upload: ${cleanToken.substring(0, 20)}...');
        print('🔑 Token length: ${cleanToken.length}');
      }

      if (AppConfig.isDebugMode) {
        print('=================================');
        print('📸 Uploading ${imageFiles.length} images...');
        print('Base URL: ${AppConfig.baseUrl}');
        print('=================================');
      }

      // CRITICAL FIX: Validate files exist
      for (var file in imageFiles) {
        if (!await file.exists()) {
          throw Exception('File does not exist: ${file.path}');
        }

        // CRITICAL FIX: Check file size
        final fileSize = await file.length();
        if (fileSize > AppConfig.maxImageUploadSize) {
          throw Exception('File too large: ${file.path} (${fileSize ~/ (1024 * 1024)}MB)');
        }

        if (AppConfig.isDebugMode) {
          print('✅ File validated: ${file.path} (${fileSize ~/ 1024}KB)');
        }
      }

      // CRITICAL FIX: Create FormData properly
      final formData = FormData();
      for (var file in imageFiles) {
        formData.files.add(
          MapEntry(
            'images', // Must match backend parameter name
            await MultipartFile.fromFile(
              file.path,
              filename: file.path.split('/').last,
            ),
          ),
        );
      }

      final uploadUrl = '${AppConfig.baseUrl}/vehicles/upload';
      if (AppConfig.isDebugMode) {
        print('📤 Uploading to: $uploadUrl');
      }

      // CRITICAL FIX: Better Dio configuration
      final response = await _dio.post(
        uploadUrl,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $cleanToken', // Use cleaned token
            // Don't set Content-Type - Dio will set it automatically with boundary
          },
          receiveTimeout: AppConfig.uploadTimeout,
          sendTimeout: AppConfig.uploadTimeout,
          validateStatus: (status) {
            // CRITICAL FIX: Accept 200 and 201 as success
            return status != null && (status == 200 || status == 201);
          },
        ),
        onSendProgress: (sent, total) {
          if (AppConfig.isDebugMode) {
            final progress = (sent / total * 100).toStringAsFixed(1);
            print('📤 Upload progress: $progress% ($sent / $total bytes)');
          }
        },
      );

      if (AppConfig.isDebugMode) {
        print('📥 Upload response status: ${response.statusCode}');
        print('📥 Upload response data: ${response.data}');
      }

      // CRITICAL FIX: Handle response properly
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;

        // Handle both old and new response formats
        if (data is Map && data['images'] != null) {
          final imageUrls = (data['images'] as List)
              .map((url) {
            // CRITICAL FIX: Ensure full URL
            final urlStr = url.toString();
            if (urlStr.startsWith('http')) {
              return urlStr;
            } else {
              return '${AppConfig.baseUrl}$urlStr';
            }
          })
              .toList();

          if (AppConfig.isDebugMode) {
            print('✅ Uploaded image URLs: $imageUrls');
          }

          return imageUrls;
        } else {
          throw Exception('Invalid response format: No images field');
        }
      } else {
        throw Exception('Upload failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (AppConfig.isDebugMode) {
        print('❌ Dio Exception: ${e.type}');
        print('❌ Error message: ${e.message}');
        print('❌ Response: ${e.response?.data}');
      }

      // CRITICAL FIX: Handle specific error types
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Connection timeout. Check your network connection.');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Upload timeout. Images may be too large.');
      } else if (e.response?.statusCode == 401) {
        throw Exception('UNAUTHORIZED');
      } else if (e.response != null) {
        final statusCode = e.response?.statusCode;
        final errorData = e.response?.data;
        throw Exception('Upload failed: $statusCode - $errorData');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      if (AppConfig.isDebugMode) {
        print('❌ Unexpected error during upload: $e');
      }
      rethrow;
    }
  }
}