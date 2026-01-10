import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      final response = await _apiService.post('/auth/register', {
        'name': name,
        'email': email,
        'password': password,
      }, requireAuth: false);
      
      if (response['access_token'] != null) {
        await _saveToken(response['access_token']);
        await _saveUser(response['user']);
        print('Registration successful - token saved');
      } else {
        print('Warning: No access_token in response');
      }
      
      return response;
    } catch (e) {
      print('Registration error in auth_service: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiService.post('/auth/login', {
        'email': email,
        'password': password,
      }, requireAuth: false);
      
      if (response['access_token'] != null) {
        await _saveToken(response['access_token']);
        await _saveUser(response['user']);
        print('Login successful - token saved');
      } else {
        print('Warning: No access_token in response');
      }
      
      return response;
    } catch (e) {
      print('Login error in auth_service: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('token');
  }

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      return User.fromJson(Map<String, dynamic>.from(
        jsonDecode(userJson) as Map,
      ));
    }
    return null;
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    // CRITICAL FIX: Trim token before saving to prevent whitespace issues
    final cleanToken = token.trim();
    await prefs.setString('token', cleanToken);
    print('Token saved successfully (length: ${cleanToken.length})');
  }

  Future<void> _saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user));
  }

  Future<bool> isTokenValid() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    if (token == null || token.trim().isEmpty) {
      print('No token found');
      return false;
    }
    
    try {
      // CRITICAL FIX: Trim token before processing
      final cleanToken = token.trim();
      
      // Decode JWT to check expiration (simple check, not full validation)
      final parts = cleanToken.split('.');
      if (parts.length != 3) {
        print('Invalid token format - expected 3 parts, got ${parts.length}');
        return false;
      }
      
      // Decode payload - handle base64 padding
      String payload = parts[1];
      // Add padding if needed
      switch (payload.length % 4) {
        case 1:
          payload += '===';
          break;
        case 2:
          payload += '==';
          break;
        case 3:
          payload += '=';
          break;
      }
      
      final decoded = utf8.decode(base64.decode(payload));
      final payloadMap = jsonDecode(decoded) as Map<String, dynamic>;
      
      // Check expiration
      final exp = payloadMap['exp'] as int?;
      if (exp != null) {
        final expirationDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
        final now = DateTime.now();
        
        print('Token expires at: $expirationDate');
        print('Current time: $now');
        final isExpired = now.isAfter(expirationDate);
        print('Token is expired: $isExpired');
        
        return !isExpired;
      }
      
      // If no expiration, assume valid
      print('Token has no expiration, assuming valid');
      return true;
    } catch (e) {
      print('Error checking token validity: $e');
      return false;
    }
  }
  
  // CRITICAL FIX: Add method to check and refresh token if needed
  Future<bool> checkAuthStatus() async {
    final isLoggedIn = await this.isLoggedIn();
    if (!isLoggedIn) {
      return false;
    }
    
    final isValid = await this.isTokenValid();
    if (!isValid) {
      // Token expired, clear it
      await logout();
      return false;
    }
    
    return true;
  }

  /// Update local user data in storage
  Future<void> updateLocalUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user.toJson()));
    print('Local user data updated');
  }
}

