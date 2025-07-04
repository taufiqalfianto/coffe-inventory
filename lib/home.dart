import 'package:coffe_inventory/menu_widget.dart';
import 'package:coffe_inventory/product/screen/list_product_screen.dart';
import 'package:coffe_inventory/product/screen/product_screen.dart';
import 'package:coffe_inventory/product/screen/stock_inout_screen.dart';
import 'package:coffe_inventory/product/screen/stock_opname_screen.dart';
import 'package:flutter/material.dart';

import 'product/screen/report_screen.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100.0),
        child: AppBar(
          title: Text('Home', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.brown,
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => StockInOutScreen()),
                  );
                },
              ),
              MenuWidget(
                title: 'List Produk',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductListScreen(),
                    ),
                  );
                },
              ),
              MenuWidget(
                title: 'Stock Opname',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StockOpnameScreen(),
                    ),
                  );
                },
              ),
              MenuWidget(
                title: 'Laporan',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StockReportScreen(),
                    ),
                  );
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddProductScreen(),
                        ),
                      );
                    },
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
