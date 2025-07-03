// lib/models/stock_report_item.dart

class StockReportItem {
  final String kode;
  final String nama;
  final int stok;

  StockReportItem({
    required this.kode,
    required this.nama,
    required this.stok,
  });

  factory StockReportItem.fromMap(Map<String, dynamic> map) {
    return StockReportItem(
      kode: map['kode']?.toString() ?? '',
      nama: map['nama']?.toString() ?? '',
      stok: (map['stok'] is int)
          ? map['stok'] as int
          : (int.tryParse(map['stok']?.toString() ?? '0') ?? 0),
    );
  }
}