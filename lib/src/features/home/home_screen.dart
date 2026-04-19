import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double value = 0;

  String get status {
    if (value >= 100) return "Kuota Habis";
    if (value >= 90) return "Kritis";
    if (value >= 75) return "Hampir Habis";
    return "Aman";
  }

  Color get statusColor {
    if (value >= 100) return Colors.red;
    if (value >= 90) return Colors.orange;
    if (value >= 75) return Colors.amber;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Limit Kuota"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Text(
              "${value.toStringAsFixed(0)}%",
              style: const TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              status,
              style: TextStyle(
                fontSize: 20,
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            Slider(
              value: value,
              min: 0,
              max: 100,
              divisions: 100,
              label: "${value.toStringAsFixed(0)}%",
              onChanged: (v) {
                setState(() {
                  value = v;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}