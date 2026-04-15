// main.dart
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp()); // sudah pakai constf
}

// ✅ tambahkan const constructor
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

// ✅ tambahkan const constructor
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // DATA KUOTA
  double kuotaUtama = 2000;
  double kuotaTerpakai = 0;

  double kuotaDarurat = 0;
  double hutangKuota = 0;

  bool sudahPakaiDarurat = false;

  double get sisaKuota {
    return (kuotaUtama - kuotaTerpakai) + kuotaDarurat;
  }

  void aktifkanKuotaDarurat() {
    setState(() {
      kuotaDarurat = 1000;
      hutangKuota = 1000;
      sudahPakaiDarurat = true;
    });
  }

  void pakaiKuota() {
    setState(() {
      kuotaTerpakai += 500;
    });
  }

  void resetKuota() {
    setState(() {
      kuotaTerpakai = 0;
      kuotaDarurat = 0;
      hutangKuota = 0;
      sudahPakaiDarurat = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double sisaUtama = kuotaUtama - kuotaTerpakai;

    return Scaffold(
      appBar: AppBar(title: const Text("Kuota Darurat")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Kuota Utama: $sisaUtama MB"),
            Text("Kuota Darurat: $kuotaDarurat MB"),
            Text("Hutang: $hutangKuota MB"),

            const SizedBox(height: 10),

            Text(
              "Total Sisa: $sisaKuota MB",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            if (kuotaDarurat > 0)
              const Text(
                "Mode Darurat Aktif ⚠️",
                style: TextStyle(color: Colors.red),
              ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: pakaiKuota,
              child: const Text("Gunakan 500MB"),
            ),

            if (sisaUtama <= 0 && !sudahPakaiDarurat)
              ElevatedButton(
                onPressed: aktifkanKuotaDarurat,
                child: const Text("Aktifkan Kuota Darurat"),
              ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: resetKuota,
              child: const Text("Reset Kuota"),
            ),
          ],
        ),
      ),
    );
  }
}
