// lib/screens/product_detail_screen.dart

import 'dart:io';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../model/product_model.dart';
import '../service/product_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product; // Produk yang akan ditampilkan/diedit

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  // Controllers untuk setiap field yang bisa diedit
  late TextEditingController _namaController;
  late TextEditingController _kategoriController;
  late TextEditingController _satuanController;
  late TextEditingController _stokController;
  late TextEditingController _hargaBeliController;
  late TextEditingController _hargaJualController;

  File? _newImageFile; // Menyimpan gambar baru yang dipilih
  bool _isEditing = false; // State untuk mengaktifkan/menonaktifkan mode edit
  bool _isLoading = false; // State untuk loading saat simpan/hapus

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.product.nama);
    _kategoriController = TextEditingController(text: widget.product.kategori);
    _satuanController = TextEditingController(text: widget.product.satuan);
    _stokController = TextEditingController(
      text: widget.product.stok.toString(),
    );
    _hargaBeliController = TextEditingController(
      text: widget.product.harga_beli.toString(),
    );
    _hargaJualController = TextEditingController(
      text: widget.product.harga_jual.toString(),
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _kategoriController.dispose();
    _satuanController.dispose();
    _stokController.dispose();
    _hargaBeliController.dispose();
    _hargaJualController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (mounted) {
        setState(() {
          _newImageFile = File(image.path);
        });
      }
    }
  }

  Future<void> _updateProduct() async {
    if (_formKey.currentState!.validate()) {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      try {
        final updatedProduct = Product(
          id: widget.product.id,
          kode: widget.product.kode, // Kode tidak diubah
          nama: _namaController.text,
          kategori: _kategoriController.text.isNotEmpty
              ? _kategoriController.text
              : null,
          satuan: _satuanController.text.isNotEmpty
              ? _satuanController.text
              : null,
          stok: int.parse(_stokController.text),
          harga_beli: double.parse(_hargaBeliController.text),
          harga_jual: double.parse(_hargaJualController.text),
          gambar: _newImageFile, // Gambar baru jika ada
          imageUrl: widget
              .product
              .imageUrl, // Pertahankan imageUrl lama jika tidak ada gambar baru
        );

        final result = await _apiService.updateProduct(updatedProduct);
        if (mounted) {
          final snackBar = SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 650),
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Berhasil',
              message: 'Produk ${result.nama} berhasil diperbarui.',
              contentType: ContentType.success,
            ),
          );

          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(snackBar);
          Navigator.pop(context, result);
        }
      } catch (e) {
        if (mounted) {
          final snackBar = SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 650),
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Vagal',
              message: 'Gagal Memperbarui Produk $e.',
              contentType: ContentType.failure,
            ),
          );

          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(snackBar);
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

  Future<void> _deleteProduct() async {
    // Tampilkan dialog konfirmasi
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text(
          'Apakah Anda yakin ingin menghapus produk "${widget.product.nama}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }
      try {
        await _apiService.deleteProduct(widget.product.id!);
        if (mounted) {
          final snackBar = SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 650),
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Berhasil',
              message: 'Produk ${widget.product.nama} berhasil dihapus.',
              contentType: ContentType.success,
            ),
          );

          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(snackBar);
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          final snackBar = SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 650),
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Gagal',
              message: 'Gagal Menghapus Produk. $e',
              contentType: ContentType.failure,
            ),
          );

          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(snackBar);
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
        title: Text(_isEditing ? 'Edit Produk' : 'Detail Produk'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF111111), Color(0xFF313131)],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ),
        actions: [
          if (!_isEditing) // Tampilkan tombol edit hanya jika tidak dalam mode edit
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                if (mounted) {
                  setState(() {
                    _isEditing = true;
                  });
                }
              },
              tooltip: 'Edit Produk',
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteProduct,
              tooltip: 'Hapus Produk',
              color: Colors.redAccent,
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _isLoading ? null : _updateProduct,
              tooltip: 'Simpan Perubahan',
            ),
        ],
      ),
      backgroundColor: Color(0xFF111111),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.brown))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          _newImageFile != null
                              ? CircleAvatar(
                                  radius: 70,
                                  backgroundImage: FileImage(_newImageFile!),
                                )
                              : (widget.product.imageUrl != null &&
                                        widget.product.imageUrl!.isNotEmpty
                                    ? CircleAvatar(
                                        radius: 70,
                                        backgroundImage: NetworkImage(
                                          widget.product.imageUrl!,
                                        ),
                                      )
                                    : CircleAvatar(
                                        radius: 70,
                                        backgroundColor: Colors.brown[200],
                                        child: Icon(
                                          Icons.broken_image,
                                          size: 50,
                                          color: Colors.brown[650],
                                        ),
                                      )),
                          if (_isEditing)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _pickImage,
                                child: CircleAvatar(
                                  backgroundColor: Colors.brown,
                                  radius: 20,
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    _buildTextField(
                      controller: TextEditingController(
                        text: widget.product.kode,
                      ), // Kode tidak bisa diedit
                      labelText: 'Kode Produk',
                      enabled: false, // Kode tidak bisa diedit
                      validator: null, // No validation for disabled field
                    ),
                    const SizedBox(height: 16.0),
                    _buildTextField(
                      controller: _namaController,
                      labelText: 'Nama Produk',
                      enabled: _isEditing,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama produk tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    _buildTextField(
                      controller: _kategoriController,
                      labelText: 'Kategori',
                      enabled: _isEditing,
                    ),
                    const SizedBox(height: 16.0),
                    _buildTextField(
                      controller: _satuanController,
                      labelText: 'Satuan',
                      enabled: _isEditing,
                    ),
                    const SizedBox(height: 16.0),
                    _buildTextField(
                      controller: _stokController,
                      labelText: 'Stok',
                      keyboardType: TextInputType.number,
                      enabled: _isEditing,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null) {
                          return 'Masukkan stok yang valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    _buildTextField(
                      controller: _hargaBeliController,
                      labelText: 'Harga Beli',
                      keyboardType: TextInputType.number,
                      enabled: _isEditing,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            double.tryParse(value) == null) {
                          return 'Masukkan harga beli yang valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    _buildTextField(
                      controller: _hargaJualController,
                      labelText: 'Harga Jual',
                      keyboardType: TextInputType.number,
                      enabled: _isEditing,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            double.tryParse(value) == null) {
                          return 'Masukkan harga jual yang valid';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: enabled,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.white),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white54),
        ),
        filled: true,
        fillColor: Colors.transparent,
        suffixIcon: enabled
            ? const Icon(Icons.edit, color: Colors.white)
            : null,
      ),
      validator: validator,
    );
  }
}
