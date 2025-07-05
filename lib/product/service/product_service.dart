import 'dart:convert';
import 'dart:developer';
import 'package:coffe_inventory/auth/auth_service.dart';
import 'package:coffe_inventory/product/model/product_model.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../model/report_model.dart';

class ApiService {
  // Singleton instance
  static final ApiService _instance = ApiService._internal();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal();

  static const String _baseUrl = 'https://backend-inventory.izzalutfi.com/api';
  final AuthService _authService = AuthService();

  Future<Product?> addProduct(Product product) async {
    final String? token = _authService.authToken;

    if (token == null) {
      log('Authentication token is missing for addProduct.');
      throw Exception('Authentication required. Please log in again.');
    }

    final url = Uri.parse('$_baseUrl/barangs');

    try {
      var request = http.MultipartRequest('POST', url);

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      request.fields['kode'] = product.kode;
      request.fields['nama'] = product.nama;
      request.fields['kategori'] = product.kategori!;
      request.fields['satuan'] = product.satuan!;
      request.fields['stok'] = product.stok.toString();
      request.fields['harga_beli'] = product.harga_beli.toString();
      request.fields['harga_jual'] = product.harga_jual.toString();

      if (product.gambar != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'gambar',
            product.gambar!.path,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        // 201 Created
        final responseBody = await response.stream.bytesToString();
        final Map<String, dynamic> responseData = json.decode(responseBody);
        log('Product added successfully: $responseData');
        return Product.fromMap(responseData);
      } else {
        final errorBody = await response.stream.bytesToString();
        log('Failed to add product. Status code: ${response.statusCode}');
        log('Error response: $errorBody');

        if (response.statusCode == 401) {
          await _authService.logout();
          throw Exception(
            'Unauthorized: Your session has expired. Please log in again.',
          );
        }
        throw Exception(
          'Failed to add product: ${response.statusCode} - $errorBody',
        );
      }
    } catch (e) {
      log('Error adding product: $e');
      rethrow;
    }
  }

  Future<List<Product>> getProducts() async {
    final String? token = _authService.authToken;

    if (token == null) {
      print('Authentication token is missing for getProducts.');
      throw Exception('Authentication required. Please log in again.');
    }

    final url = Uri.parse('$_baseUrl/barangs');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseMap = json.decode(
          response.body,
        ); // Ubah menjadi Map

        // Ambil array produk dari key 'data'
        final List<dynamic> productJsonList =
            responseMap['data'] as List<dynamic>;

        // Konversi setiap item di array menjadi objek Product
        return productJsonList.map((json) => Product.fromMap(json)).toList();
      } else {
        print('Failed to load products. Status code: ${response.statusCode}');
        print('Error response: ${response.body}');
        if (response.statusCode == 401) {
          await _authService.logout();
          throw Exception(
            'Unauthorized: Your session has expired. Please log in again.',
          );
        }
        throw Exception(
          'Failed to load products: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error getting products: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> stockIn(
    int productId,
    int quantity,
    String keterangan,
  ) async {
    final String? token = _authService.authToken;

    if (token == null) {
      print('Authentication token is missing for stockIn.');
      throw Exception('Authentication required. Please log in again.');
    }

    final url = Uri.parse('$_baseUrl/stock/in'); // Endpoint API untuk stock in

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded', // Sesuai Postman
        },
        body: {
          'barang_id': productId.toString(),
          'jumlah': quantity.toString(),
          'keterangan': keterangan,
        },
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        // Asumsi 200 OK untuk success, sesuai Postman
        print('Stock in successful: $responseData');
        return responseData; // Mengembalikan seluruh respons data
      } else {
        print(
          'Failed to perform stock in. Status code: ${response.statusCode}',
        );
        print('Error response: ${response.body}');
        if (response.statusCode == 401) {
          await _authService.logout();
          throw Exception(
            'Unauthorized: Your session has expired. Please log in again.',
          );
        }
        throw Exception(
          'Failed to perform stock in: ${response.statusCode} - ${responseData['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      print('Error performing stock in: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> stockOut(
    int productId,
    int quantity,
    String keterangan,
  ) async {
    final String? token = _authService.authToken;

    if (token == null) {
      print('Authentication token is missing for stockOut.');
      throw Exception('Authentication required. Please log in again.');
    }

    final url = Uri.parse(
      '$_baseUrl/stock/out',
    ); // Endpoint API untuk stock out

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded', // Sesuai Postman
        },
        body: {
          'barang_id': productId.toString(), // Parameter barang_id
          'jumlah': quantity.toString(), // Parameter jumlah
          'keterangan': keterangan, // Parameter keterangan
        },
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        // Asumsi 200 OK untuk success, sesuai Postman
        print('Stock out successful: $responseData');
        return responseData; // Mengembalikan seluruh respons data
      } else {
        print(
          'Failed to perform stock out. Status code: ${response.statusCode}',
        );
        print('Error response: ${response.body}');
        if (response.statusCode == 401) {
          await _authService.logout();
          throw Exception(
            'Unauthorized: Your session has expired. Please log in again.',
          );
        }
        throw Exception(
          'Failed to perform stock out: ${response.statusCode} - ${responseData['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      print('Error performing stock out: $e');
      rethrow;
    }
  }

  Future<List<StockReportItem>> getStockReport() async {
    final String? token = _authService.authToken;

    if (token == null) {
      print('Authentication token is missing for getStockReport.');
      throw Exception('Authentication required. Please log in again.');
    }

    final url = Uri.parse(
      '$_baseUrl/laporan/stock',
    ); // Endpoint API laporan stok

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseMap = json.decode(response.body);
        final List<dynamic> reportJsonList =
            responseMap['data'] as List<dynamic>; // Ambil array dari key 'data'

        return reportJsonList
            .map((json) => StockReportItem.fromMap(json))
            .toList();
      } else {
        print(
          'Failed to load stock report. Status code: ${response.statusCode}',
        );
        print('Error response: ${response.body}');
        if (response.statusCode == 401) {
          await _authService.logout();
          throw Exception(
            'Unauthorized: Your session has expired. Please log in again.',
          );
        }
        throw Exception(
          'Failed to load stock report: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error getting stock report: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> stockOpname(
    int productId,
    int physicalStock,
    String keterangan,
  ) async {
    final String? token = _authService.authToken;

    if (token == null) {
      print('Authentication token is missing for stockOpname.');
      throw Exception('Authentication required. Please log in again.');
    }

    final url = Uri.parse(
      '$_baseUrl/stock-opname',
    ); // Endpoint API untuk stock opname

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded', // Sesuai Postman
        },
        body: {
          'barang_id': productId.toString(), // Parameter barang_id
          'stok_fisik': physicalStock.toString(), // Parameter stok_fisik
          'keterangan': keterangan, // Parameter keterangan
        },
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        // Asumsi 200 OK untuk success
        print('Stock opname successful: $responseData');
        return responseData; // Mengembalikan seluruh respons data
      } else {
        print(
          'Failed to perform stock opname. Status code: ${response.statusCode}',
        );
        print('Error response: ${response.body}');
        if (response.statusCode == 401) {
          await _authService.logout();
          throw Exception(
            'Unauthorized: Your session has expired. Please log in again.',
          );
        }
        throw Exception(
          'Failed to perform stock opname: ${response.statusCode} - ${responseData['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      print('Error performing stock opname: $e');
      rethrow;
    }
  }

  Future<Product> updateProduct(Product product) async {
    final String? token = _authService.authToken;

    if (token == null) {
      throw Exception('Authentication required. Please log in again.');
    }
    final url = Uri.parse('$_baseUrl/barangs/${product.id}');
    var request = http.MultipartRequest('POST', url);

    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    request.fields['nama'] = product.nama;
    request.fields['kategori'] = product.kategori ?? '';
    request.fields['satuan'] = product.satuan ?? '';
    request.fields['stok'] = product.stok.toString();
    request.fields['harga_beli'] = product.harga_beli.toString();
    request.fields['harga_jual'] = product.harga_jual.toString();

    if (product.gambar != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'gambar',
          product.gambar!.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }
    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        print('Update product successful: $responseData');
        return Product.fromMap(
          responseData['data'],
        ); // Asumsi 'data' berisi objek produk yang diperbarui
      } else {
        print('Failed to update product. Status code: ${response.statusCode}');
        print('Error response: ${response.body}');
        if (response.statusCode == 401) {
          await _authService.logout();
          throw Exception(
            'Unauthorized: Your session has expired. Please log in again.',
          );
        }
        throw Exception(
          'Failed to update product: ${response.statusCode} - ${responseData['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      print('Error updating product: $e');
      rethrow;
    }
  }

  Future<void> deleteProduct(int productId) async {
    final String? token = _authService.authToken;

    if (token == null) {
      throw Exception('Authentication required. Please log in again.');
    }

    final url = Uri.parse('$_baseUrl/barangs/$productId'); // Endpoint DELETE

    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        // 200 OK atau 204 No Content
        print('Product deleted successfully for ID: $productId');
      } else {
        print('Failed to delete product. Status code: ${response.statusCode}');
        print('Error response: ${response.body}');
        if (response.statusCode == 401) {
          await _authService.logout();
          throw Exception(
            'Unauthorized: Your session has expired. Please log in again.',
          );
        }
        throw Exception(
          'Failed to delete product: ${response.statusCode} - ${json.decode(response.body)['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      print('Error deleting product: $e');
      rethrow;
    }
  }
}
