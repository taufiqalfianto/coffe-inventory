import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:coffe_inventory/product/model/product_model.dart';
import 'package:coffe_inventory/product/service/product_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // Required for File

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  final TextEditingController _kodeController = TextEditingController();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _kategoriController = TextEditingController();
  final TextEditingController _satuanController = TextEditingController();
  final TextEditingController _stokController = TextEditingController();
  final TextEditingController _hargaBeliController = TextEditingController();
  final TextEditingController _hargaJualController = TextEditingController();

  File? _selectedImage;
  bool _isLoading = false; // To show loading indicator

  @override
  void dispose() {
    _kodeController.dispose();
    _namaController.dispose();
    _kategoriController.dispose();
    _satuanController.dispose();
    _stokController.dispose();
    _hargaBeliController.dispose();
    _hargaJualController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _addProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final String kode = _kodeController.text;
      final String nama = _namaController.text;
      final String kategori = _kategoriController.text;
      final String satuan = _satuanController.text;
      final int stok = int.parse(_stokController.text);
      final double hargaBeli = double.parse(_hargaBeliController.text);
      final double hargaJual = double.parse(_hargaJualController.text);

      final Product newProduct = Product(
        kode: kode,
        nama: nama,
        kategori: kategori,
        satuan: satuan,
        stok: stok,
        harga_beli: hargaBeli,
        harga_jual: hargaJual,
        gambar: _selectedImage, // Pass the selected image file
      );

      try {
        final addedProduct = await _apiService.addProduct(newProduct);

        if (mounted) {
          // Check if the widget is still mounted before showing SnackBar or popping
          if (addedProduct != null) {
            const snackBar = SnackBar(
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(bottom: 650),
              backgroundColor: Colors.transparent,
              content: AwesomeSnackbarContent(
                title: 'Berhasil',
                message: 'Produk Berhasil Ditambahkan.',
                contentType: ContentType.success,
              ),
            );

            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(snackBar);
            Navigator.pop(context, addedProduct); // Pass the added product back
          } else {
            const snackBar = SnackBar(
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(bottom: 650),
              backgroundColor: Colors.transparent,
              content: AwesomeSnackbarContent(
                title: 'gagal',
                message: 'Gagal Menambahkan Produk.',
                contentType: ContentType.failure,
              ),
            );

            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(snackBar);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Tambah Daftar Produk',
          style: TextStyle(color: Colors.brown),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.brown),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              // Kode
              TextFormField(
                controller: _kodeController,
                decoration: _inputDecoration('Kode Produk', Icons.vpn_key),
                validator: (value) => value == null || value.isEmpty
                    ? 'Mohon masukkan kode produk'
                    : null,
              ),
              const SizedBox(height: 20),
              // Nama
              TextFormField(
                controller: _namaController,
                decoration: _inputDecoration('Nama Produk', Icons.coffee),
                validator: (value) => value == null || value.isEmpty
                    ? 'Mohon masukkan nama produk'
                    : null,
              ),
              const SizedBox(height: 20),
              // Kategori
              TextFormField(
                controller: _kategoriController,
                decoration: _inputDecoration('Kategori', Icons.category),
                validator: (value) => value == null || value.isEmpty
                    ? 'Mohon masukkan kategori'
                    : null,
              ),
              const SizedBox(height: 20),
              // Satuan
              TextFormField(
                controller: _satuanController,
                decoration: _inputDecoration('Satuan', Icons.edit),
                validator: (value) => value == null || value.isEmpty
                    ? 'Mohon masukkan satuan produk'
                    : null,
              ),
              const SizedBox(height: 20),
              // Stok
              TextFormField(
                controller: _stokController,
                decoration: _inputDecoration('Stok', Icons.inventory),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Mohon masukkan stok';
                  if (int.tryParse(value) == null)
                    return 'Mohon masukkan angka valid';
                  if (int.parse(value) < 0) return 'Stok tidak boleh negatif';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Harga Beli
              TextFormField(
                controller: _hargaBeliController,
                decoration: _inputDecoration(
                  'Harga Beli',
                  Icons.monetization_on,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Mohon masukkan harga beli';
                  if (double.tryParse(value) == null)
                    return 'Mohon masukkan angka valid';
                  if (double.parse(value) <= 0)
                    return 'Harga beli harus lebih dari nol';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Harga Jual
              TextFormField(
                controller: _hargaJualController,
                decoration: _inputDecoration('Harga Jual', Icons.sell),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Mohon masukkan harga jual';
                  if (double.tryParse(value) == null)
                    return 'Mohon masukkan angka valid';
                  if (double.parse(value) <= 0)
                    return 'Harga jual harus lebih dari nol';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Gambar
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.brown[50],
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: Colors.brown.shade200),
                  ),
                  child: _selectedImage != null
                      ? Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt,
                              size: 50,
                              color: Colors.brown[300],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Pilih Gambar Produk',
                              style: TextStyle(color: Colors.brown[500]),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 30),

              // Tombol Tambah Produk
              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.brown),
                    )
                  : ElevatedButton.icon(
                      onPressed: _addProduct,
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text(
                        'Tambah Produk',
                        style: TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method for consistent InputDecoration
  InputDecoration _inputDecoration(String labelText, IconData icon) {
    return InputDecoration(
      labelText: labelText,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
      prefixIcon: Icon(icon),
    );
  }
}
