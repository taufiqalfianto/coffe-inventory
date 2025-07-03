import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Singleton instance
  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  static const String _baseUrl =
      'https://backend-inventory.izzalutfi.com/api';
  static const String _tokenKey =
      'auth_token';

  String? _currentAuthToken; 

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _currentAuthToken = prefs.getString(_tokenKey);
    print(
      'AuthService initialized. Token loaded: ${_currentAuthToken != null ? "Yes" : "No"}',
    );
  }

  String? get authToken => _currentAuthToken;

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/user/login');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: {'email': email, 'password': password},
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        final String? token =
            responseData['token'] ?? responseData['access_token'];

        if (token != null) {
          await _saveToken(token);
          _currentAuthToken = token;
          print('Login successful. Token saved and set.');
          return {
            'success': true,
            'message': 'Login Successful',
            'token': token,
          };
        } else {
          print('Login failed: Token not found in response.');
          throw Exception('Login failed: Token not found in response');
        }
      } else {
        print(
          'Login failed. Status: ${response.statusCode}, Body: ${response.body}',
        );
        throw Exception(
          'Login failed: ${responseData['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      print('Error during login: $e');
      rethrow;
    }
  }

  // --- Metode untuk Logout ---
  Future<void> logout() async {
    await _deleteToken();
    _currentAuthToken = null;
    print('User logged out. Token cleared.');
  }

  // --- Metode Private untuk Manajemen Token di SharedPreferences ---
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> _deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
