// lib/screens/stock_report_screen.dart

import 'package:flutter/material.dart';

import '../model/report_model.dart';
import '../service/product_service.dart';

class StockReportScreen extends StatefulWidget {
  const StockReportScreen({super.key});

  @override
  State<StockReportScreen> createState() => _StockReportScreenState();
}

class _StockReportScreenState extends State<StockReportScreen> {
  List<StockReportItem> _reportItems = [];
  final ApiService _apiService = ApiService();
  bool _isLoadingReport = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadStockReport(); // Muat laporan saat screen pertama kali dibuat
  }

  Future<void> _loadStockReport() async {
    if (mounted) {
      setState(() {
        _isLoadingReport = true;
        _errorMessage = null; // Reset error message
      });
    }

    try {
      final fetchedReport = await _apiService.getStockReport();
      if (mounted) {
        setState(() {
          _reportItems = fetchedReport;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingReport = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Laporan', style: TextStyle(color: Colors.brown)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.brown),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: _isLoadingReport
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
                      onPressed: _loadStockReport,
                      child: Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            )
          : _reportItems.isEmpty
          ? const Center(
              child: Text(
                'Tidak ada data laporan stok.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: _reportItems.length,
              itemBuilder: (context, index) {
                final item = _reportItems[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  elevation: 3,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.brown,
                      child: Text(
                        item.stok.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      item.nama,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Kode: ${item.kode}'),
                    trailing: Text(
                      'Stok: ${item.stok}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
