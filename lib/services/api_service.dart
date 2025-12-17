import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class ApiService {
  // CRITICAL FIX: Use baseUrl from AppConfig
  static String get baseUrl => AppConfig.baseUrl;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.trim().isEmpty) {
      if (AppConfig.isDebugMode) {
        print('⚠️ WARNING: Token is null or empty');
      }
      return null;
    }

    // CRITICAL FIX: Trim token to remove any whitespace
    final cleanToken = token.trim();
    
    if (AppConfig.isDebugMode) {
      print('🔑 Token retrieved: ${cleanToken.substring(0, 20)}...');
      print('🔑 Token length: ${cleanToken.length}');
    }

    return cleanToken;
  }

  Future<Map<String, String>> _getHeaders({bool requireAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requireAuth) {
      final token = await _getToken();

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
        if (AppConfig.isDebugMode) {
          print('✅ Authorization header added');
        }
      } else {
        if (AppConfig.isDebugMode) {
          print('⚠️ WARNING: No token found in storage!');
        }
      }
    }

    return headers;
  }

  Future<Map<String, dynamic>> post(
      String endpoint,
      Map<String, dynamic> data,
      {bool requireAuth = true}
      ) async {
    try {
      final headers = await _getHeaders(requireAuth: requireAuth);

      // CRITICAL FIX: Only check auth if required
      if (requireAuth && !headers.containsKey('Authorization')) {
        if (AppConfig.isDebugMode) {
          print('❌ ERROR: Authorization header missing for protected endpoint!');
        }
        throw Exception('Authentication required. Please login again.');
      }

      final url = Uri.parse('$baseUrl$endpoint');

      if (AppConfig.isDebugMode) {
        print('=================================');
        print('📤 POST Request');
        print('URL: $url');
        print('Headers: ${headers.keys.toList()}');
        print('Body: ${jsonEncode(data)}');
        print('=================================');
      }

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(data),
      ).timeout(AppConfig.requestTimeout);

      if (AppConfig.isDebugMode) {
        print('📥 Response Status: ${response.statusCode}');
        print('📥 Response Body: ${response.body}');
      }

      // CRITICAL FIX: Handle 401 specifically
      if (response.statusCode == 401) {
        if (AppConfig.isDebugMode) {
          print('❌ Unauthorized! Token expired or invalid.');
        }
        throw Exception('UNAUTHORIZED'); // Special marker for auth errors
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
        } catch (e) {
          throw Exception('Request failed with status: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (AppConfig.isDebugMode) {
        print('❌ API Error (POST $endpoint): $e');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> get(String endpoint, {bool requireAuth = true}) async {
    try {
      final headers = await _getHeaders(requireAuth: requireAuth);
      final url = Uri.parse('$baseUrl$endpoint');

      if (AppConfig.isDebugMode) {
        print('=================================');
        print('📤 GET Request');
        print('URL: $url');
        print('=================================');
      }

      final response = await http.get(
        url,
        headers: headers,
      ).timeout(AppConfig.requestTimeout);

      if (AppConfig.isDebugMode) {
        print('📥 Response Status: ${response.statusCode}');
      }

      if (response.statusCode == 401) {
        throw Exception('UNAUTHORIZED');
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
          throw Exception('Request failed with status: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (AppConfig.isDebugMode) {
        print('❌ API Error (GET $endpoint): $e');
      }
      rethrow;
    }
  }

  Future<List<dynamic>> getList(String endpoint, {bool requireAuth = true}) async {
    try {
      final headers = await _getHeaders(requireAuth: requireAuth);
      final url = Uri.parse('$baseUrl$endpoint');

      final response = await http.get(
        url,
        headers: headers,
      ).timeout(AppConfig.requestTimeout);

      if (response.statusCode == 401) {
        throw Exception('UNAUTHORIZED');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseBody = response.body;
        if (responseBody.isEmpty) {
          return [];
        }
        return jsonDecode(responseBody) as List;
      } else {
        throw Exception('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      if (AppConfig.isDebugMode) {
        print('❌ API Error (GET LIST $endpoint): $e');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> put(
      String endpoint,
      Map<String, dynamic>? data,
      {bool requireAuth = true}
      ) async {
    try {
      final headers = await _getHeaders(requireAuth: requireAuth);
      final url = Uri.parse('$baseUrl$endpoint');

      final response = await http.put(
        url,
        headers: headers,
        body: data != null ? jsonEncode(data) : null,
      ).timeout(AppConfig.requestTimeout);

      if (response.statusCode == 401) {
        throw Exception('UNAUTHORIZED');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseBody = response.body;
        if (responseBody.isEmpty) {
          return {};
        }
        return jsonDecode(responseBody) as Map<String, dynamic>;
      } else {
        throw Exception('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      if (AppConfig.isDebugMode) {
        print('❌ API Error (PUT $endpoint): $e');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> delete(String endpoint, {bool requireAuth = true}) async {
    try {
      final headers = await _getHeaders(requireAuth: requireAuth);
      final url = Uri.parse('$baseUrl$endpoint');

      final response = await http.delete(
        url,
        headers: headers,
      ).timeout(AppConfig.requestTimeout);

      if (response.statusCode == 401) {
        throw Exception('UNAUTHORIZED');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseBody = response.body;
        if (responseBody.isEmpty) {
          return {};
        }
        return jsonDecode(responseBody) as Map<String, dynamic>;
      } else {
        throw Exception('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      if (AppConfig.isDebugMode) {
        print('❌ API Error (DELETE $endpoint): $e');
      }
      rethrow;
    }
  }
}