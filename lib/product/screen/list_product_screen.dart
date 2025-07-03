import 'package:coffe_inventory/auth/auth_service.dart';
import 'package:coffe_inventory/auth/login.dart';
import 'package:coffe_inventory/product/model/product_model.dart';
import 'package:coffe_inventory/product/screen/product_screen.dart';
import 'package:coffe_inventory/product/service/product_service.dart';
import 'package:flutter/material.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Product> _products = [];
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  bool _isLoadingProducts = true; // State untuk loading produk
  String? _errorMessage; // State untuk pesan error

  @override
  void initState() {
    super.initState();
    _loadProducts(); // Muat produk saat screen pertama kali dibuat
  }

  Future<void> _loadProducts() async {
    if (mounted) {
      setState(() {
        _isLoadingProducts = true;
        _errorMessage = null; // Reset error message
      });
    }

    try {
      final fetchedProducts = await _apiService.getProducts();
      if (mounted) {
        setState(() {
          _products = fetchedProducts;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString(); // Simpan pesan error
          // Jika error adalah Unauthorized, mungkin perlu redirect ke login
          if (e.toString().contains('Unauthorized')) {
            _logoutAndNavigateToLogin(); // Panggil logout jika token tidak valid
          }
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingProducts = false;
        });
      }
    }
  }

  void _logoutAndNavigateToLogin() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        // Gunakan pushAndRemoveUntil untuk membersihkan stack
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (Route<dynamic> route) => false, // Hapus semua route sebelumnya
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Produk'),
        backgroundColor: Colors.brown[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProducts, // Tombol refresh
            tooltip: 'Refresh Produk',
          ),
        ],
      ),
      body: _isLoadingProducts
          ? const Center(child: CircularProgressIndicator(color: Colors.brown))
          : _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 50),
                    SizedBox(height: 10),
                    Text(
                      'Error: $_errorMessage',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _loadProducts,
                      child: Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            )
          : _products.isEmpty
          ? const Center(
              child: Text(
                'Belum ada produk. Tambahkan produk baru!',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _products.map((product) {
                    return SizedBox(
                      width: MediaQuery.of(context).size.width / 2 - 24,
                      child: Card(
                        elevation: 3,
                        child: InkWell(
                          onTap: () {
                            print('Tapped on ${product.nama}');
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                product.imageUrl != null &&
                                        product.imageUrl!.isNotEmpty
                                    ? CircleAvatar(
                                        backgroundImage: NetworkImage(
                                          product.imageUrl!,
                                        ),
                                        radius: 30,
                                      )
                                    : const CircleAvatar(
                                        backgroundColor: Colors.brown,
                                        radius: 30,
                                        child: Icon(
                                          Icons.local_cafe,
                                          color: Colors.white,
                                        ),
                                      ),
                                const SizedBox(height: 8),
                                Text(
                                  product.nama,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Kode: ${product.kode}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                Text(
                                  'Kategori: ${product.kategori ?? 'N/A'}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                Text(
                                  'Satuan: ${product.satuan ?? 'N/A'}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                Text(
                                  'Stok: ${product.stok}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                Text(
                                  'Beli: \$${product.harga_beli.toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                Text(
                                  'Jual: \$${product.harga_jual.toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigasi ke AddProductScreen
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProductScreen()),
          );

          if (result != null && result is Product) {
            // Setelah menambah produk baru, muat ulang daftar produk di ProductListScreen
            await _loadProducts();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Produk "${result.nama}" berhasil ditambahkan!',
                  ),
                ),
              );
            }
          }
        },
        backgroundColor: Colors.brown,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
