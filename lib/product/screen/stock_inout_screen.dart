// ignore_for_file: unused_field

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:coffe_inventory/product/model/product_model.dart';
import 'package:coffe_inventory/product/service/product_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StockInOutScreen extends StatefulWidget {
  const StockInOutScreen({super.key});

  @override
  State<StockInOutScreen> createState() => _StockInOutScreenState();
}

class _StockInOutScreenState extends State<StockInOutScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();

  // Controllers for Stock In tab
  Product? _selectedProductIn; // Ubah nama variabel untuk kejelasan
  final TextEditingController _quantityInController = TextEditingController();
  final TextEditingController _keteranganInController = TextEditingController();
  final TextEditingController _dateInController = TextEditingController();
  DateTime? _selectedDateIn;

  // Controllers for Stock Out tab
  Product? _selectedProductOut; // Tambahkan variabel untuk produk out
  final TextEditingController _quantityOutController = TextEditingController();
  final TextEditingController _keteranganOutController =
      TextEditingController();
  final TextEditingController _dateOutController = TextEditingController();
  DateTime? _selectedDateOut;

  List<Product> _products = [];
  bool _isLoadingProducts = true;
  String? _productsErrorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProducts(); // Muat daftar produk untuk dropdown di kedua tab

    _dateInController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    _selectedDateIn = DateTime.now();

    _dateOutController.text = DateFormat(
      'dd/MM/yyyy',
    ).format(DateTime.now()); // Set default untuk Out
    _selectedDateOut = DateTime.now();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _quantityInController.dispose();
    _keteranganInController.dispose();
    _dateInController.dispose();
    _quantityOutController.dispose();
    _keteranganOutController.dispose();
    _dateOutController.dispose();
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
            _selectedProductIn = _products.first; // Set default untuk Stock In
            _selectedProductOut =
                _products.first; // Set default untuk Stock Out
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _productsErrorMessage = e.toString();
        });
      }
      final snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 600),
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Gagal',
          message: 'Gagal Memuat Produk.',
          contentType: ContentType.failure,
        ),
      );

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
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

  Future<void> _performStockIn() async {
    if (_selectedProductIn == null) {
      const snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: 700),
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Gagal',
          message: 'Pilih nama produk terlebih dahulu.',
          contentType: ContentType.failure,
        ),
      );

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
      return;
    }
    if (_quantityInController.text.isEmpty ||
        int.tryParse(_quantityInController.text) == null ||
        int.parse(_quantityInController.text) <= 0) {
      const snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: 700),
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Gagal',
          message: 'Masukkan jumlah yang valid (lebih dari 0).',
          contentType: ContentType.failure,
        ),
      );

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
      return;
    }

    int quantity = int.parse(_quantityInController.text);
    String keterangan = _keteranganInController.text.isNotEmpty
        ? _keteranganInController.text
        : '-';

    const snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(bottom: 700),
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: 'Loading',
        message: 'Proses Stock in.',
        contentType: ContentType.help,
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);

    try {
      await _apiService.stockIn(_selectedProductIn!.id!, quantity, keterangan);
      if (mounted) {
        const snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 700),
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'erhasil',
            message: 'Proses Stock In Berhasil.',
            contentType: ContentType.success,
          ),
        );

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
        // Clear form
        _quantityInController.clear();
        _keteranganInController.clear();
      }
    } catch (e) {
      if (mounted) {
        final snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 700),
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Gagal',
            message: 'Proses Stock In Gagal $e .',
            contentType: ContentType.failure,
          ),
        );

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
      }
    }
  }

  // --- Fungsi untuk Melakukan Stock Out ---
  Future<void> _performStockOut() async {
    if (_selectedProductOut == null) {
      const snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'On Snap!',
          message: 'Pilih nama produk terlebih dahulu.',

          contentType: ContentType.failure,
        ),
      );

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);

      return;
    }
    if (_quantityOutController.text.isEmpty ||
        int.tryParse(_quantityOutController.text) == null ||
        int.parse(_quantityOutController.text) <= 0) {
      const snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: 700),
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Gagal',
          message: 'Masukkan jumlah yang valid (lebih dari 0).',
          contentType: ContentType.failure,
        ),
      );

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);

      return;
    }

    int quantity = int.parse(_quantityOutController.text);
    String keterangan = _keteranganOutController.text.isNotEmpty
        ? _keteranganOutController.text
        : '-';

    const snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(bottom: 700),
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: 'Loading',
        message: 'Melakukan Stock Out...',
        contentType: ContentType.help,
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);

    try {
      await _apiService.stockOut(
        _selectedProductOut!.id!,
        quantity,
        keterangan,
      );
      if (mounted) {
        const snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 700),
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Berhasil',
            message: 'Proses Stock Out Berhasil.',
            contentType: ContentType.success,
          ),
        );

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);

        _quantityOutController.clear();
        _keteranganOutController.clear();
      }
    } catch (e) {
      if (mounted) {
        final snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 700),
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Gagal',
            message: 'Proses Stock Out $e .',
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
          'Stock In/Out',
          style: TextStyle(color: Colors.brown),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.brown),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ), // Margin untuk TabBar
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor:
                  Colors.brown, // Warna teks untuk tab tidak terpilih
              indicatorSize: TabBarIndicatorSize
                  .tab, // Membuat indicator mengisi seluruh tab
              indicator: BoxDecoration(
                color: Colors
                    .brown[800], // Warna background untuk tab yang terpilih
                borderRadius: BorderRadius.circular(
                  20.0,
                ), // Sudut membulat untuk tab yang terpilih
              ),
              tabs: const [
                Tab(text: 'In'),
                Tab(text: 'Out'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildStockInForm(), _buildStockOutForm()],
      ),
    );
  }

  Widget _buildStockInForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 16.0),
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
              ? const Text(
                  'Tidak ada produk tersedia.',
                  style: TextStyle(color: Colors.grey),
                )
              : DropdownButtonFormField<Product>(
                  value: _selectedProductIn,
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
                        _selectedProductIn = newValue;
                      });
                    }
                  },
                  isExpanded: true,
                ),
          const SizedBox(height: 16.0),
          // Quantity
          TextField(
            controller: _quantityInController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Quantity',
              hintText: 'Masukkan jumlah',
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
            controller: _keteranganInController,
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
          // Tanggal
          TextField(
            controller: _dateInController,
            readOnly: true,
            onTap: () => _selectDate(
              context,
              _dateInController,
              (date) => _selectedDateIn = date,
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
            onPressed: _performStockIn,
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
    );
  }

  Widget _buildStockOutForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
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
              ? const Text(
                  'Tidak ada produk tersedia.',
                  style: TextStyle(color: Colors.grey),
                )
              : DropdownButtonFormField<Product>(
                  value: _selectedProductOut, // Menggunakan selectedProductOut
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
                        _selectedProductOut = newValue;
                      });
                    }
                  },
                  isExpanded: true,
                ),
          const SizedBox(height: 16.0),
          // Quantity
          TextField(
            controller: _quantityOutController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Quantity',
              hintText: 'Masukkan jumlah',
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
            controller: _keteranganOutController,
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
          // Tanggal
          TextField(
            controller: _dateOutController,
            readOnly: true,
            onTap: () => _selectDate(
              context,
              _dateOutController,
              (date) => _selectedDateOut = date,
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
            onPressed: _performStockOut,
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
    );
  }
}
