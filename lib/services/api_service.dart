import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // For Android Emulator: use 'http://10.0.2.2:3000'
  // For Physical Device: use your computer's IP (e.g., 'http://192.168.0.238:3000')
  // Find your IP with: ipconfig (Windows) or ifconfig (Linux/Mac)
  static const String baseUrl = 'http://192.168.0.238:3000'; // Change to your computer's IP for physical device

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, String>> _getHeaders({bool requireAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    
    if (requireAuth) {
      final token = await _getToken();
      
      // Debug: Print token status (don't print full token in production)
      if (token != null) {
        print('Token found: ${token.substring(0, 20)}...');
        headers['Authorization'] = 'Bearer $token';
      } else {
        print('WARNING: No token found in storage!');
      }
    }
    
    return headers;
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data, {bool requireAuth = true}) async {
    try {
      final headers = await _getHeaders(requireAuth: requireAuth);
      
      // Only check for auth if required (login/register don't need it)
      if (requireAuth && !headers.containsKey('Authorization')) {
        print('ERROR: Authorization header missing for protected endpoint!');
        throw Exception('Authentication required. Please login again.');
      }
      
      print('POST $endpoint');
      if (requireAuth) {
        print('Headers: ${headers.keys.toList()}');
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 10));

      print('POST $endpoint - Status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 401) {
        print('Unauthorized! Token might be expired or invalid.');
        print('Response body: ${response.body}');
        throw Exception('Authentication failed. Please login again.');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseBody = response.body;
        if (responseBody.isEmpty) {
          return {};
        }
        return jsonDecode(responseBody) as Map<String, dynamic>;
      } else {
        final errorBody = response.body;
        try {
          final errorJson = jsonDecode(errorBody) as Map<String, dynamic>;
          final message = errorJson['message'] ?? errorBody;
          throw Exception('Request failed: $message');
        } catch (_) {
          throw Exception('Request failed with status: ${response.statusCode} - $errorBody');
        }
      }
    } catch (e) {
      print('API Error (POST $endpoint): $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> get(String endpoint, {bool requireAuth = true}) async {
    try {
      final headers = await _getHeaders(requireAuth: requireAuth);
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      print('GET $endpoint - Status: ${response.statusCode}');

      if (response.statusCode == 401) {
        print('Unauthorized! Token might be expired or invalid.');
        throw Exception('Authentication failed. Please login again.');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseBody = response.body;
        if (responseBody.isEmpty) {
          return {};
        }
        return jsonDecode(responseBody) as Map<String, dynamic>;
      } else {
        final errorBody = response.body;
        try {
          final errorJson = jsonDecode(errorBody) as Map<String, dynamic>;
          final message = errorJson['message'] ?? errorBody;
          throw Exception('Request failed: $message');
        } catch (_) {
          throw Exception('Request failed with status: ${response.statusCode} - $errorBody');
        }
      }
    } catch (e) {
      print('API Error (GET $endpoint): $e');
      rethrow;
    }
  }

  Future<List<dynamic>> getList(String endpoint, {bool requireAuth = true}) async {
    try {
      final headers = await _getHeaders(requireAuth: requireAuth);
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      print('GET $endpoint - Status: ${response.statusCode}');

      if (response.statusCode == 401) {
        print('Unauthorized! Token might be expired or invalid.');
        throw Exception('Authentication failed. Please login again.');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseBody = response.body;
        if (responseBody.isEmpty) {
          return [];
        }
        return jsonDecode(responseBody) as List;
      } else {
        final errorBody = response.body;
        try {
          final errorJson = jsonDecode(errorBody) as Map<String, dynamic>;
          final message = errorJson['message'] ?? errorBody;
          throw Exception('Request failed: $message');
        } catch (_) {
          throw Exception('Request failed with status: ${response.statusCode} - $errorBody');
        }
      }
    } catch (e) {
      print('API Error (GET LIST $endpoint): $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic>? data, {bool requireAuth = true}) async {
    try {
      final headers = await _getHeaders(requireAuth: requireAuth);
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: data != null ? jsonEncode(data) : null,
      ).timeout(const Duration(seconds: 10));

      print('PUT $endpoint - Status: ${response.statusCode}');

      if (response.statusCode == 401) {
        print('Unauthorized! Token might be expired or invalid.');
        throw Exception('Authentication failed. Please login again.');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseBody = response.body;
        if (responseBody.isEmpty) {
          return {};
        }
        return jsonDecode(responseBody) as Map<String, dynamic>;
      } else {
        final errorBody = response.body;
        try {
          final errorJson = jsonDecode(errorBody) as Map<String, dynamic>;
          final message = errorJson['message'] ?? errorBody;
          throw Exception('Request failed: $message');
        } catch (_) {
          throw Exception('Request failed with status: ${response.statusCode} - $errorBody');
        }
      }
    } catch (e) {
      print('API Error (PUT $endpoint): $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> delete(String endpoint, {bool requireAuth = true}) async {
    try {
      final headers = await _getHeaders(requireAuth: requireAuth);
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      print('DELETE $endpoint - Status: ${response.statusCode}');

      if (response.statusCode == 401) {
        print('Unauthorized! Token might be expired or invalid.');
        throw Exception('Authentication failed. Please login again.');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseBody = response.body;
        if (responseBody.isEmpty) {
          return {};
        }
        return jsonDecode(responseBody) as Map<String, dynamic>;
      } else {
        final errorBody = response.body;
        try {
          final errorJson = jsonDecode(errorBody) as Map<String, dynamic>;
          final message = errorJson['message'] ?? errorBody;
          throw Exception('Request failed: $message');
        } catch (_) {
          throw Exception('Request failed with status: ${response.statusCode} - $errorBody');
        }
      }
    } catch (e) {
      print('API Error (DELETE $endpoint): $e');
      rethrow;
    }
  }
}