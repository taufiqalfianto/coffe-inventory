// lib/screens/stock_opname_screen.dart

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/product_model.dart';
import '../service/product_service.dart'; // Untuk format tanggal, meskipun tidak dikirim ke API, tetap ada di UI

class StockOpnameScreen extends StatefulWidget {
  const StockOpnameScreen({super.key});

  @override
  State<StockOpnameScreen> createState() => _StockOpnameScreenState();
}

class _StockOpnameScreenState extends State<StockOpnameScreen> {
  final ApiService _apiService = ApiService();

  Product? _selectedProduct;
  List<Product> _products = [];
  bool _isLoadingProducts = true;
  String? _productsErrorMessage;

  final TextEditingController _physicalStockController =
      TextEditingController();
  final TextEditingController _keteranganController = TextEditingController();
  final TextEditingController _dateController =
      TextEditingController(); // Untuk UI tanggal saja
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _physicalStockController.dispose();
    _keteranganController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    if (mounted) {
      setState(() {
        _isLoadingProducts = true;
        _productsErrorMessage = null;
      });
    }

    try {
      final fetchedProducts = await _apiService.getProducts();
      if (mounted) {
        setState(() {
          _products = fetchedProducts;
          if (_products.isNotEmpty) {
            _selectedProduct =
                _products.first; // Pilih produk pertama sebagai default
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _productsErrorMessage = e.toString();
        });
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat daftar produk: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingProducts = false;
        });
      }
    }
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
    Function(DateTime) onDateSelected,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.brown,
              onPrimary: Colors.white,
              onSurface: Colors.brown,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.brown),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      if (mounted) {
        setState(() {
          controller.text = DateFormat('dd/MM/yyyy').format(picked);
          onDateSelected(picked);
        });
      }
    }
  }

  Future<void> _performStockOpname() async {
    if (_selectedProduct == null) {
      const snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: 00),
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Gagal',
          message: 'Pilih Produk Terlebih Dahulu.',
          contentType: ContentType.failure,
        ),
      );

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
      return;
    }
    if (_physicalStockController.text.isEmpty ||
        int.tryParse(_physicalStockController.text) == null) {
      const snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: 650),
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Gagal',
          message: 'Masukkan Stok Fisik Yang Valid.',
          contentType: ContentType.failure,
        ),
      );

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
      return;
    }

    int physicalStock = int.parse(_physicalStockController.text);
    String keterangan = _keteranganController.text.isNotEmpty
        ? _keteranganController.text
        : '-';

    const snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(bottom: 650),
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: 'Loading',
        message: 'Proses Stok Opname.',
        contentType: ContentType.help,
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);

    try {
      await _apiService.stockOpname(
        _selectedProduct!.id!,
        physicalStock,
        keterangan,
      );
      if (mounted) {
        const snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 650),
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Berhasil',
            message: 'Stok Opname Berhasil Ditambahkan.',
            contentType: ContentType.success,
          ),
        );

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
        _physicalStockController.clear();
        _keteranganController.clear();
      }
    } catch (e) {
      if (mounted) {
        const snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 650),
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Gagal',
            message: 'Stok Opname Gagal Ditambahkan.',
            contentType: ContentType.failure,
          ),
        );

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,

        title: const Text(
          'Stock Opname',
          style: TextStyle(color: Colors.brown),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.brown),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Nama Produk (Dropdown)
            _isLoadingProducts
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.brown),
                  )
                : _productsErrorMessage != null
                ? Text(
                    'Error memuat produk: $_productsErrorMessage',
                    style: const TextStyle(color: Colors.red),
                  )
                : _products.isEmpty
                ? const Text('Tidak ada produk tersedia.')
                : DropdownButtonFormField<Product>(
                    value: _selectedProduct,
                    decoration: InputDecoration(
                      labelText: 'Nama Produk',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: _products.map((product) {
                      return DropdownMenuItem<Product>(
                        value: product,
                        child: Text(product.nama),
                      );
                    }).toList(),
                    onChanged: (Product? newValue) {
                      if (mounted) {
                        setState(() {
                          _selectedProduct = newValue;
                        });
                      }
                    },
                    isExpanded: true,
                  ),
            const SizedBox(height: 16.0),
            // Stok Fisik
            TextField(
              controller: _physicalStockController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Stok Fisik',
                hintText: 'Masukkan jumlah stok fisik',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16.0),
            // Keterangan
            TextField(
              controller: _keteranganController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: 'Keterangan',
                hintText: 'Opsional: masukkan keterangan',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16.0),
            // Tanggal (hanya untuk UI, tidak dikirim ke API opname)
            TextField(
              controller: _dateController,
              readOnly: true,
              onTap: () => _selectDate(
                context,
                _dateController,
                (date) => _selectedDate = date,
              ),
              decoration: InputDecoration(
                labelText: 'Tanggal',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: const Icon(Icons.calendar_today),
              ),
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: _performStockOpname,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Simpan', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
