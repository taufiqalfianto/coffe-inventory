import 'package:coffe_inventory/menu_widget.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100.0),
        child: AppBar(
          title: Text('Home', style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFF313131),
          automaticallyImplyLeading: false,
        ),
      ),
      backgroundColor: Colors.brown[50],

      body: ListView(
        children: [
          SizedBox(height: 75),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              MenuWidget(
                title: 'Stock In/Out',
                onPressed: () {
                  // Navigate to Stock In/Out screen
                },
              ),
              MenuWidget(
                title: 'Sales Report',
                onPressed: () {
                  // Navigate to Sales Report screen
                },
              ),
              MenuWidget(
                title: 'Stock Opname',
                onPressed: () {
                  // Navigate to Inventory Management screen
                },
              ),
              MenuWidget(
                title: 'Laporan',
                onPressed: () {
                  // Navigate to Settings screen
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 56,
                  horizontal: 16,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFC67C4E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {},
                    child: Text(
                      'Tambah Produk',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
