import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/user.dart';

class UserService {
  static String get baseUrl => AppConfig.baseUrl;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token?.trim();
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Get the current user's profile
  Future<User> getProfile() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/users/profile'),
        headers: headers,
      ).timeout(AppConfig.requestTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('UNAUTHORIZED');
      } else {
        throw Exception('Failed to get profile: ${response.statusCode}');
      }
    } catch (e) {
      if (AppConfig.isDebugMode) {
        print('❌ Error getting profile: $e');
      }
      rethrow;
    }
  }

  /// Update user profile
  Future<User> updateProfile({
    String? name,
    String? email,
    String? address,
    String? streetNo,
    String? postalCode,
    String? phone,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = <String, dynamic>{};

      if (name != null) body['name'] = name;
      if (email != null) body['email'] = email;
      if (address != null) body['address'] = address;
      if (streetNo != null) body['streetNo'] = streetNo;
      if (postalCode != null) body['postalCode'] = postalCode;
      if (phone != null) body['phone'] = phone;

      final response = await http.put(
        Uri.parse('$baseUrl/users/profile'),
        headers: headers,
        body: jsonEncode(body),
      ).timeout(AppConfig.requestTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('UNAUTHORIZED');
      } else {
        final errorBody = response.body;
        try {
          final errorJson = jsonDecode(errorBody);
          throw Exception(errorJson['message'] ?? 'Failed to update profile');
        } catch (_) {
          throw Exception('Failed to update profile: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (AppConfig.isDebugMode) {
        print('❌ Error updating profile: $e');
      }
      rethrow;
    }
  }

  /// Upload profile image
  Future<User> uploadProfileImage(File imageFile) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      print('📤 Uploading profile image...');
      print('📄 File path: ${imageFile.path}');
      print('📄 File exists: ${imageFile.existsSync()}');
      print('📄 File size: ${imageFile.lengthSync()} bytes');

      final uri = Uri.parse('$baseUrl/users/profile/upload-image');
      print('🌐 Upload URL: $uri');

      final request = http.MultipartRequest('POST', uri);

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';
      
      // Get file extension and determine content type
      final extension = imageFile.path.split('.').last.toLowerCase();
      String contentType = 'image/jpeg';
      if (extension == 'png') {
        contentType = 'image/png';
      } else if (extension == 'gif') {
        contentType = 'image/gif';
      } else if (extension == 'webp') {
        contentType = 'image/webp';
      }
      
      print('📄 File extension: $extension, Content-Type: $contentType');

      // Add the file with proper content type
      final multipartFile = await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        contentType: MediaType.parse(contentType),
      );
      request.files.add(multipartFile);
      
      print('📤 Sending request...');

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
      );

      print('📥 Response status: ${streamedResponse.statusCode}');

      final response = await http.Response.fromStream(streamedResponse);
      
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('✅ Upload successful!');
        return User.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('UNAUTHORIZED');
      } else {
        final errorBody = response.body;
        try {
          final errorJson = jsonDecode(errorBody);
          throw Exception(errorJson['message'] ?? 'Failed to upload image');
        } catch (e) {
          if (e.toString().contains('Exception:')) {
            rethrow;
          }
          throw Exception('Failed to upload image: ${response.statusCode} - $errorBody');
        }
      }
    } catch (e) {
      print('❌ Error uploading profile image: $e');
      rethrow;
    }
  }

  /// Get full profile image URL
  String getProfileImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return '';
    }
    
    // If already a full URL, return as is
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    
    // Build full URL
    return '$baseUrl$imagePath';
  }
}
