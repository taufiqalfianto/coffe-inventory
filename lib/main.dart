import 'package:coffe_inventory/auth/auth_service.dart';
import 'package:coffe_inventory/onboarding.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inisialisasi AuthService dan ApiService saat aplikasi dimulai
  await AuthService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Flutter Demo', home: Onboarding());
  }
}
