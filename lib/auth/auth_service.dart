// lib/services/auth_service.dart

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
      'https://backend-inventory.izzalutfi.com/api'; // Ganti dengan URL dasar API Anda
  static const String _tokenKey =
      'auth_token'; // Kunci untuk menyimpan token di SharedPreferences

  String? _currentAuthToken; // Token yang disimpan di memori

  // Inisialisasi token dari SharedPreferences saat aplikasi dimulai
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _currentAuthToken = prefs.getString(_tokenKey);
    print(
      'AuthService initialized. Token loaded: ${_currentAuthToken != null ? "Yes" : "No"}',
    );
  }

  // Getter untuk token yang bisa diakses oleh service lain (misalnya ApiService)
  String? get authToken => _currentAuthToken;

  // --- Metode untuk Login ---
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/user/login'); //

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: {
          'email': email, //
          'password': password, //
        },
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

  // --- Metode Baru: Mengecek Status Otentikasi dan Validitas Token ---
  Future<bool> checkAuthStatus() async {
    await init(); // Pastikan token sudah dimuat dari SharedPreferences

    if (_currentAuthToken == null) {
      print('No auth token found.');
      return false; // Tidak ada token, berarti tidak login
    }

    // Coba validasi token dengan memanggil API yang membutuhkan otentikasi
    // Kita akan gunakan endpoint getProducts sebagai contoh validasi token
    final url = Uri.parse(
      '$_baseUrl/products',
    ); // Menggunakan endpoint produk sebagai validasi
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_currentAuthToken',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Jika berhasil mendapatkan produk, berarti token masih valid
        print('Auth token is valid.');
        return true;
      } else if (response.statusCode == 401) {
        // Jika 401 Unauthorized, token tidak valid atau kadaluarsa
        print('Auth token is expired or invalid (401). Clearing token.');
        await logout(); // Hapus token yang tidak valid
        return false;
      } else {
        // Status code lain menunjukkan ada masalah, tapi mungkin token masih "ada"
        print(
          'Auth token check resulted in status ${response.statusCode}. Assuming invalid for now.',
        );
        await logout(); // Hapus token jika respons tidak sukses (selain 200)
        return false;
      }
    } catch (e) {
      // Ada error jaringan atau lainnya, anggap token tidak bisa divalidasi
      print('Error during auth token validation: $e. Clearing token.');
      await logout(); // Hapus token jika ada error saat validasi
      return false;
    }
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
