import 'package:coffe_inventory/auth/auth_service.dart';
import 'package:coffe_inventory/menu_widget.dart';
import 'package:coffe_inventory/product/screen/list_product_screen.dart';
import 'package:coffe_inventory/product/screen/add_product_screen.dart';
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
  String? _userName;
  final AuthService _authService = AuthService();
  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  void _loadUserName() async {
    // Pastikan AuthService sudah diinisialisasi untuk mengambil nama dari SharedPreferences
    await _authService.init();
    if (mounted) {
      setState(() {
        _userName = _authService
            .userName; // Assuming userName is a String property in AuthService
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(90.0),
        child: AppBar(
          title: Text(
            'Selamat Datang, ${_userName ?? 'User'}!',
            style: TextStyle(color: Colors.white),
          ),
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF111111), Color(0xFF313131)],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Image.asset(
            'assets/image_onboarding.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          ListView(
            children: [
              SizedBox(height: 75),
              Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: [
                  MenuWidget(
                    image: 'assets/stock_in.png',
                    title: 'Stock In/Out',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StockInOutScreen(),
                        ),
                      );
                    },
                  ),
                  MenuWidget(
                    image: 'assets/product_list.png',
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
                    image: 'assets/stock_opname.png',
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
                    image: 'assets/report.png',
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
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(
                  //     vertical: 56,
                  //     horizontal: 16,
                  //   ),
                  //   child: SizedBox(
                  //     width: double.infinity,
                  //     height: 56,
                  //     child: ElevatedButton(
                  //       style: ElevatedButton.styleFrom(
                  //         backgroundColor: Color(0xFFC67C4E),
                  //         shape: RoundedRectangleBorder(
                  //           borderRadius: BorderRadius.circular(12),
                  //         ),
                  //       ),
                  //       onPressed: () {
                  //         Navigator.push(
                  //           context,
                  //           MaterialPageRoute(
                  //             builder: (context) => AddProductScreen(),
                  //           ),
                  //         );
                  //       },
                  //       child: Text(
                  //         'Tambah Produk',
                  //         style: TextStyle(
                  //           color: Colors.white,
                  //           fontWeight: FontWeight.bold,
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
