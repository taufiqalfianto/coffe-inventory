import 'dart:io';

class Product {
  int? id; // ID produk, bisa jadi required jika API mengembalikan ID
  String kode;
  String nama;
  String? kategori; // Jadikan nullable
  String? satuan; // Jadikan nullable
  int stok;
  double harga_beli;
  double harga_jual;
  File? gambar; // Sudah nullable untuk input UI

  // Jika API mengembalikan URL gambar, Anda mungkin ingin menambahkan field ini:
  String? imageUrl;

  Product({
    this.id, // ID produk opsional, bisa diisi saat update
    required this.kode,
    required this.nama,
    this.kategori, // Tidak lagi required
    this.satuan, // Tidak lagi required
    required this.stok,
    required this.harga_beli,
    required this.harga_jual,
    this.gambar, // Untuk input dari UI
    this.imageUrl, // Untuk URL gambar dari API
  });

  // Untuk mengonversi Product object ke Map (untuk kirim ke API)
  Map<String, dynamic> toMap() {
    return {
      'id': id, // ID opsional, bisa null saat membuat produk baru
      'kode': kode,
      'nama': nama,
      'kategori': kategori,
      'satuan': satuan,
      'stok': stok,
      'harga_beli': harga_beli,
      'harga_jual': harga_jual,
      // 'gambar' (File) tidak disertakan di sini karena akan di-handle Multipart
      // 'imageUrl' juga tidak dikirim, hanya untuk tampilan
    };
  }

  // Untuk membuat Product object dari Map (saat terima dari API)
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] is int ? map['id'] as int : null, // ID bisa null
      kode:
          map['kode']?.toString() ?? '', // Pastikan String, berikan default ''
      nama: map['nama']?.toString() ?? '',
      kategori: map['kategori']
          ?.toString(), // Biarkan null jika API mengirim null
      satuan: map['satuan']?.toString(), // Biarkan null jika API mengirim null
      stok: (map['stok'] is int)
          ? map['stok'] as int
          : (int.tryParse(map['stok']?.toString() ?? '0') ??
                0), // Handle int dari berbagai tipe
      harga_beli: (map['harga_beli'] is double)
          ? map['harga_beli'] as double
          : (double.tryParse(map['harga_beli']?.toString() ?? '0.0') ??
                0.0), // Handle double
      harga_jual: (map['harga_jual'] is double)
          ? map['harga_jual'] as double
          : (double.tryParse(map['harga_jual']?.toString() ?? '0.0') ??
                0.0), // Handle double
      // Jika API mengembalikan URL gambar di key 'gambar' atau 'image_url'
      imageUrl: map['gambar']?.toString() ?? map['image_url']?.toString(),
      // 'gambar' (File) tidak akan diisi dari API respons, hanya untuk UI input
    );
  }
}
