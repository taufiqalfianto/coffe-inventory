// lib/services/auth_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  static const String _baseUrl = 'https://backend-inventory.izzalutfi.com/api';
  static const String _tokenKey = 'auth_token';
  static const String _userNameKey = 'name';

  String? _currentAuthToken;
  String? _currentUserName;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _currentAuthToken = prefs.getString(_tokenKey);
    _currentUserName = prefs.getString(_userNameKey);
    print(
      'AuthService initialized. Token loaded: ${_currentAuthToken != null ? "Yes" : "No"}, User Name: ${_currentUserName ?? "N/A"}',
    );
  }

  String? get authToken => _currentAuthToken;
  String? get userName => _currentUserName;

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
        final String? userName =
            responseData['data']['name'] ?? responseData['user_name'];

        if (token != null) {
          await _saveToken(token);
          _currentAuthToken = token;

          if (userName != null) {
            await _saveUserName(userName);
            _currentUserName = userName;
          } else {
            _currentUserName = null;
            await _deleteUserName();
          }

          print(
            'Login successful. Token saved, User Name: ${_currentUserName ?? "N/A"}.',
          );
          return {
            'success': true,
            'message': 'Login Successful',
            'token': token,
            'user_name': _currentUserName,
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

  Future<void> logout() async {
    await _deleteToken();
    await _deleteUserName();
    _currentAuthToken = null;
    _currentUserName = null;
    print('User logged out. Token and User Name cleared.');
  }

  Future<bool> checkAuthStatus() async {
    await init();

    if (_currentAuthToken == null) {
      print('No auth token found.');
      return false;
    }

    final url = Uri.parse('$_baseUrl/products');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_currentAuthToken',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('Auth token is valid.');
        // Opsional: Perbarui nama pengguna jika API produk mengembalikan data pengguna
        // (Tapi lebih baik bergantung pada data login awal)
        return true;
      } else if (response.statusCode == 401) {
        print('Auth token is expired or invalid (401). Clearing token.');
        await logout();
        return false;
      } else {
        print(
          'Auth token check resulted in status ${response.statusCode}. Assuming invalid for now.',
        );
        await logout();
        return false;
      }
    } catch (e) {
      print('Error during auth token validation: $e. Clearing token.');
      await logout();
      return false;
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> _deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<void> _saveUserName(String userName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, userName);
  }

  Future<void> _deleteUserName() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userNameKey);
  }
}
