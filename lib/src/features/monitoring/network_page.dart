import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
<<<<<<< HEAD
import 'package:limit_kuota_by5/src/core/data/database_helper.dart';
import 'package:limit_kuota_by5/src/core/services/intent_helper.dart';
import 'package:limit_kuota_by5/src/features/monitoring/history_page.dart';
=======
import 'package:shared_preferences/shared_preferences.dart';
<<<<<<< HEAD

import 'package:limit_kuota/src/core/data/database_helper.dart';
import 'package:limit_kuota/src/core/services/intent_helper.dart';
import 'package:limit_kuota/src/features/monitoring/history_page.dart';
import 'package:limit_kuota/src/features/statistics/statistics_page.dart';
=======
import 'package:limit_kuota_by5/src/core/data/database_helper.dart';
import 'package:limit_kuota_by5/src/core/services/intent_helper.dart';
import 'package:limit_kuota_by5/src/features/monitoring/history_page.dart';
import 'package:limit_kuota_by5/src/core/widgets/progress_quota.dart';
>>>>>>> 77350aaff14d31b6727c7c305831e61dd5d0c20e
>>>>>>> 42317128855e803f07e4a0192c9476636286e4b8

class Network extends StatefulWidget {
  const Network({super.key});

  @override
  State<Network> createState() => _NetworkState();
}

class _NetworkState extends State<Network> {
  static const platform = MethodChannel('limit_kuota/channel');

  String wifiUsage = "0.00 MB";
  String mobileUsage = "0.00 MB";

<<<<<<< HEAD
  double wifiPercent = 0.0;
  double mobilePercent = 0.0;
=======
<<<<<<< HEAD
  double totalKuotaGB = 30;

  Future<void> saveTotalKuota() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setDouble('total_kuota', totalKuotaGB);
  }

  Future<void> loadTotalKuota() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      totalKuotaGB = prefs.getDouble('total_kuota') ?? 30;
    });
  }

  void setTotalKuota() {
    TextEditingController controller = TextEditingController(
      text: totalKuotaGB.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Set Total Kuota"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: "Masukkan GB"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Batal"),
          ),

          ElevatedButton(
            onPressed: () {
              setState(() {
                totalKuotaGB = double.tryParse(controller.text) ?? 30;
              });

              saveTotalKuota();

              Navigator.pop(context);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  // ================= FETCH DATA =================
  Future<void> fetchUsage() async {
    try {
      final result = await platform.invokeMethod('getTodayUsage') as Map? ?? {};

      String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      int wifiBytes = parseToInt(result['wifi']);
      int mobileBytes = parseToInt(result['mobile']);

      // simpan ke database
=======
  double wifiBytesVal = 0;
  double mobileBytesVal = 0;
>>>>>>> 42317128855e803f07e4a0192c9476636286e4b8

  final int dailyLimitBytes = 1024 * 1024 * 1024; // 1 GB

  Future<void> fetchUsage() async {
    try {
      final Map<dynamic, dynamic> result =
          await platform.invokeMethod('getTodayUsage');

      String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      int wifiBytes = result['wifi'] ?? 0;
      int mobileBytes = result['mobile'] ?? 0;

>>>>>>> 77350aaff14d31b6727c7c305831e61dd5d0c20e
      await DatabaseHelper.instance.insertOrUpdate(
        todayDate,
        wifiBytes,
        mobileBytes,
      );
<<<<<<< HEAD

      if (!mounted) return;
=======
>>>>>>> 77350aaff14d31b6727c7c305831e61dd5d0c20e

      setState(() {
        wifiUsage = formatBytes(wifiBytes);
        mobileUsage = formatBytes(mobileBytes);
<<<<<<< HEAD
=======

<<<<<<< HEAD
        wifiPercent = wifiBytes / dailyLimitBytes;
        mobilePercent = mobileBytes / dailyLimitBytes;
=======
        wifiBytesVal = wifiBytes.toDouble();
        mobileBytesVal = mobileBytes.toDouble();
>>>>>>> 77350aaff14d31b6727c7c305831e61dd5d0c20e
>>>>>>> 42317128855e803f07e4a0192c9476636286e4b8
      });

      await checkLimitAndWarn(mobileBytes);
    } on PlatformException catch (e) {
      if (e.code == "PERMISSION_DENIED") {
        _showPermissionDialog();
      }
    }
  }

  // ================= PARSE INT AMAN =================
  int parseToInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  // ================= FORMAT =================
  String formatBytes(int bytes) {
    if (bytes <= 0) return "0.00 MB";

    double mb = bytes / (1024 * 1024);

    if (mb > 1024) {
      return "${(mb / 1024).toStringAsFixed(2)} GB";
    }

    return "${mb.toStringAsFixed(2)} MB";
  }

  // ================= LIMIT WARNING =================
  Future<void> checkLimitAndWarn(int currentUsage) async {
<<<<<<< HEAD
    if (currentUsage >= dailyLimitBytes) {
=======
<<<<<<< HEAD
    int limitInBytes = 1024 * 1024 * 1024; //1 GB

    // Warning 80%
    if (currentUsage >= (limitInBytes * 0.8) && currentUsage < limitInBytes) {
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("⚠ Kuota Hampir Habis"),
          content: const Text("Penggunaan data sudah mencapai 80% dari limit."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
    // Warning 100%
    else if (currentUsage >= limitInBytes) {
      if (!mounted) return;
=======
    int limitInBytes = 1024 * 1024 * 1024;
>>>>>>> 77350aaff14d31b6727c7c305831e61dd5d0c20e

>>>>>>> 42317128855e803f07e4a0192c9476636286e4b8
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Batas Kuota Tercapai!"),
<<<<<<< HEAD
          content: const Text("Penggunaan data Anda sudah mencapai limit."),
=======
          content: const Text(
            "Penggunaan data Anda sudah mencapai limit.\n\n"
            "Silakan aktifkan 'Set Data Limit' di pengaturan sistem.",
          ),
>>>>>>> 77350aaff14d31b6727c7c305831e61dd5d0c20e
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Nanti"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                IntentHelper.openDataLimitSettings();
              },
              child: const Text("Buka Pengaturan"),
            ),
          ],
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    fetchUsage();
=======
<<<<<<< HEAD

    loadTotalKuota();

    fetchUsage();
=======
    initApp();
  }

  Future<void> initApp() async {
    await checkMonthlyReset();
    await fetchUsage();
>>>>>>> 77350aaff14d31b6727c7c305831e61dd5d0c20e
>>>>>>> 42317128855e803f07e4a0192c9476636286e4b8
  }

  int getRemainingDays() {
    DateTime now = DateTime.now();

    DateTime nextReset = DateTime(
      now.month == 12 ? now.year + 1 : now.year,
      now.month == 12 ? 1 : now.month + 1,
      1,
    );

    return nextReset.difference(now).inDays;
  }

  double parseUsageToGB(String usage) {
    if (usage.contains("GB")) {
      return double.parse(usage.replaceAll("GB", "").trim());
    }

    if (usage.contains("MB")) {
      return double.parse(usage.replaceAll("MB", "").trim()) / 1024;
    }

    return 0;
  }

  String getHematStatus() {
    double mobileUsedGB = parseUsageToGB(mobileUsage);

    double sisaKuota = totalKuotaGB - mobileUsedGB;

    int sisaHari = getRemainingDays();

    double batasAmanPerHari = sisaKuota / sisaHari;

    if (mobileUsedGB > batasAmanPerHari) {
      return "⚠ Pemakaian hari ini boros";
    }

    return "✅ Pemakaian masih aman";
  }

  String getPrediksiKuota() {
    double mobileUsedGB = parseUsageToGB(mobileUsage);

    int hariBerjalan = DateTime.now().day;

    if (mobileUsedGB <= 0) {
      return "Prediksi belum tersedia";
    }

    double rataHarian = mobileUsedGB / hariBerjalan;

    double sisaKuota = totalKuotaGB - mobileUsedGB;

    if (rataHarian <= 0) {
      return "Prediksi belum tersedia";
    }

    int prediksiHariHabis = (sisaKuota / rataHarian).floor();

    return "📉 Kuota diperkirakan habis dalam $prediksiHariHabis hari";
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoring Data'),

        actions: [
<<<<<<< HEAD
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: setTotalKuota,
          ),

=======
>>>>>>> 77350aaff14d31b6727c7c305831e61dd5d0c20e
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
<<<<<<< HEAD
                MaterialPageRoute(
                  builder: (context) => const HistoryPage(),
                ),
=======
                MaterialPageRoute(builder: (_) => const HistoryPage()),
              );
            },
          ),

          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatisticsPage()),
>>>>>>> 42317128855e803f07e4a0192c9476636286e4b8
              );
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const StatisticsPage()),
          );
        },
        child: const Icon(Icons.bar_chart),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
<<<<<<< HEAD
            usageCard("WiFi Today", wifiUsage, Icons.wifi, wifiPercent),
            const SizedBox(height: 20),
            usageCard(
              "Mobile Today",
              mobileUsage,
              Icons.signal_cellular_alt,
              mobilePercent,
            ),
=======
            usageCard("WiFi Today", wifiUsage, Icons.wifi),
<<<<<<< HEAD
=======
            const SizedBox(height: 8),
            ProgressQuota(used: wifiBytesVal, limit: 1024 * 1024 * 1024),
>>>>>>> 77350aaff14d31b6727c7c305831e61dd5d0c20e

            const SizedBox(height: 20),

            usageCard("Mobile Today", mobileUsage, Icons.signal_cellular_alt),
<<<<<<< HEAD

            const SizedBox(height: 20),

            Text(
              getHematStatus(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),

            const SizedBox(height: 10),

            const SizedBox(height: 15),

            Text(
              getPrediksiKuota(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.redAccent,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "Total Kuota: $totalKuotaGB GB",
              style: const TextStyle(fontSize: 16),
            ),
=======
            const SizedBox(height: 8),
            ProgressQuota(used: mobileBytesVal, limit: 1024 * 1024 * 1024),
>>>>>>> 77350aaff14d31b6727c7c305831e61dd5d0c20e

>>>>>>> 42317128855e803f07e4a0192c9476636286e4b8
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: fetchUsage,
              icon: const Icon(Icons.refresh),
              label: const Text("Refresh Data"),
            ),
          ],
        ),
      ),
    );
  }

<<<<<<< HEAD
  Widget usageCard(
    String title,
    String value,
    IconData icon,
    double percent,
  ) {
    Color progressColor;

    if (percent >= 0.8) {
      progressColor = Colors.red;
    } else if (percent >= 0.5) {
      progressColor = Colors.orange;
    } else {
      progressColor = Colors.green;
    }

=======
  // ================= CARD =================
  Widget _usageCard(String title, String value, IconData icon) {
>>>>>>> 42317128855e803f07e4a0192c9476636286e4b8
    return Container(
      width: 320,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, size: 40, color: Colors.blue),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 22,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "${(percent * 100).toStringAsFixed(0)}%",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: progressColor,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percent.clamp(0, 1),
              minHeight: 10,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
        ],
      ),
    );
  }

  // ================= PERMISSION =================
  void showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
<<<<<<< HEAD
      builder: (context) {
        return AlertDialog(
          title: const Text("Izin Diperlukan"),
          content: const Text(
            "Aplikasi membutuhkan izin akses penggunaan.\n\n"
            "Silakan aktifkan di pengaturan.",
=======
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Izin Diperlukan"),
          content: const Text(
<<<<<<< HEAD
            "Aplikasi membutuhkan izin akses penggunaan untuk membaca statistik data internet.",
=======
            "Aplikasi membutuhkan izin 'Akses Penggunaan'.\n\n"
            "Silakan aktifkan izin di pengaturan.",
>>>>>>> 77350aaff14d31b6727c7c305831e61dd5d0c20e
>>>>>>> 42317128855e803f07e4a0192c9476636286e4b8
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                fetchUsage();
              },
              child: const Text("Buka Pengaturan"),
            ),
          ],
        );
      },
    );
  }
}