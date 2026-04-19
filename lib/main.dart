// main.dart
import 'package:flutter/material.dart';
import 'package:limit_kuota_by5/src/core/data/services/notification_service.dart';
import 'package:limit_kuota_by5/src/features/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();

  runApp(const MyApp());
}

// ✅ tambahkan const constructor
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
