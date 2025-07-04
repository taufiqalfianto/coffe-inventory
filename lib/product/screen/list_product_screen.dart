// lib/screens/product_list_screen.dart

import 'package:coffe_inventory/auth/login.dart' show LoginScreen;
import 'package:coffe_inventory/product/screen/detail_product_screen.dart';
import 'package:coffe_inventory/product/screen/product_screen.dart';
import 'package:flutter/material.dart';

import '../../auth/auth_service.dart';
import '../model/product_model.dart';
import '../service/product_service.dart'; // Impor ProductDetailScreen

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Product> _products = [];
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  bool _isLoadingProducts = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    if (mounted) {
      setState(() {
        _isLoadingProducts = true;
        _errorMessage = null;
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
          _errorMessage = e.toString();
          if (e.toString().contains('Unauthorized')) {
            _logoutAndNavigateToLogin();
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
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Produk'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
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
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 50,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Error: $_errorMessage',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _loadProducts,
                      child: const Text('Coba Lagi'),
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
                          onTap: () async {
                            // Navigasi ke ProductDetailScreen dan tunggu hasilnya
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProductDetailScreen(product: product),
                              ),
                            );

                            // Tangani hasil dari ProductDetailScreen
                            if (result != null) {
                              if (result is Product) {
                                // Jika produk diperbarui, perbarui di daftar lokal
                                final index = _products.indexWhere(
                                  (p) => p.id == result.id,
                                );
                                if (index != -1) {
                                  if (mounted) {
                                    setState(() {
                                      _products[index] = result;
                                    });
                                  }
                                }
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Produk "${result.nama}" berhasil diperbarui!',
                                      ),
                                    ),
                                  );
                                }
                              } else if (result is bool && result == true) {
                                // Jika produk dihapus, muat ulang daftar produk
                                await _loadProducts();
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Produk berhasil dihapus!'),
                                    ),
                                  );
                                }
                              }
                            }
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              product.imageUrl != null &&
                                      product.imageUrl!.isNotEmpty
                                  ? Image.network(
                                      product.imageUrl!,
                                      fit: BoxFit.fill,
                                      scale: 1,
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
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Text(
                                      product.nama,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 4),
                                    CustomRow(
                                      title: 'Kode:',
                                      product: product.kode,
                                    ),
                                    CustomRow(
                                      title: 'Kategori:',
                                      product: product.kategori ?? 'N/A',
                                    ),
                                    CustomRow(
                                      title: 'Satuan:',
                                      product: product.satuan ?? 'N/A',
                                    ),
                                    CustomRow(
                                      title: 'Stok',
                                      product: product.stok.toString(),
                                    ),
                                    CustomRow(
                                      title: 'Harga Beli',
                                      product: product.harga_beli.toString(),
                                    ),
                                    CustomRow(
                                      title: 'Harga Jual',
                                      product: product.harga_jual.toString(),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
          // Asumsi AddProductScreen ada di path ini
          // coffe_inventory/product/screen/product_screen.dart (dari import)
          // Jika tidak, ganti dengan path yang benar
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddProductScreen(),
            ), // Menggunakan AddProductScreen
          );

          if (result != null && result is Product) {
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

// Widget untuk menampilkan daftar produk
class CustomRow extends StatelessWidget {
  final String title;
  final String product;
  const CustomRow({super.key, required this.title, required this.product});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontSize: 12)),
        const Spacer(),
        Text(product, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
