import 'package:flutter/material.dart';
import 'package:limit_kuota_by5/src/features/monitoring/network_page.dart';
import 'package:limit_kuota_by5/src/core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Limit Kuota',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Network(),
    );
  }
}