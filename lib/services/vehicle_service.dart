import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vehicle.dart';
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
    final response = await _apiService.getList('/vehicles/my-vehicles');
    return response.map((json) => Vehicle.fromJson(json)).toList();
  }

  Future<Vehicle> createVehicle(Vehicle vehicle) async {
    try {
      print('Creating vehicle with data: ${vehicle.toJson()}');
      final response = await _apiService.post('/vehicles', vehicle.toJson(), requireAuth: true);
      print('Vehicle created successfully: $response');
      return Vehicle.fromJson(response);
    } catch (e) {
      print('Error creating vehicle: $e');
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
      
      if (token == null) {
        throw Exception('No authentication token found. Please login again.');
      }

      print('Uploading ${imageFiles.length} images...');
      
      final formData = FormData();
      for (var file in imageFiles) {
        // Check if file exists
        if (!await file.exists()) {
          throw Exception('File does not exist: ${file.path}');
        }
        
        formData.files.add(
          MapEntry(
            'images',
            await MultipartFile.fromFile(
              file.path,
              filename: file.path.split('/').last,
            ),
          ),
        );
      }

      print('Uploading to: ${ApiService.baseUrl}/vehicles/upload');

      final response = await _dio.post(
        '${ApiService.baseUrl}/vehicles/upload',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      print('Upload response status: ${response.statusCode}');
      print('Upload response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data['images'] != null) {
          final imageUrls = (response.data['images'] as List)
              .map((url) => '${ApiService.baseUrl}$url')
              .toList();
          
          print('Uploaded image URLs: $imageUrls');
          return imageUrls;
        } else {
          throw Exception('No images returned from server');
        }
      } else {
        throw Exception('Upload failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Image upload error: $e');
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout) {
          throw Exception('Connection timeout. Check your network connection.');
        } else if (e.type == DioExceptionType.receiveTimeout) {
          throw Exception('Upload timeout. Images may be too large.');
        } else if (e.response != null) {
          final statusCode = e.response?.statusCode;
          final errorData = e.response?.data;
          if (statusCode == 401) {
            throw Exception('Authentication failed. Please login again.');
          }
          throw Exception('Upload failed: $statusCode - $errorData');
        } else {
          throw Exception('Network error: ${e.message}');
        }
      }
      rethrow;
    }
  }
}

