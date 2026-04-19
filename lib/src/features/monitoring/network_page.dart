// src/features/monitoring/network_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
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

      int wifiBytes = _parseToInt(result['wifi']);
      int mobileBytes = _parseToInt(result['mobile']);

      // simpan ke database
=======
  double wifiBytesVal = 0;
  double mobileBytesVal = 0;

  // ================= RESET BULANAN =================
  Future<void> checkMonthlyReset() async {
    final prefs = await SharedPreferences.getInstance();

    final lastResetString = prefs.getString('last_reset_date');
    final now = DateTime.now();

    if (lastResetString != null) {
      final lastReset = DateTime.parse(lastResetString);

      if (lastReset.month != now.month || lastReset.year != now.year) {
        await _resetDatabase();
        await prefs.setString('last_reset_date', now.toIso8601String());
      }
    } else {
      await prefs.setString('last_reset_date', now.toIso8601String());
    }
  }

  Future<void> _resetDatabase() async {
    final db = await DatabaseHelper.instance.database;

    await db.delete('usage');

    setState(() {
      wifiUsage = "0.00 MB";
      mobileUsage = "0.00 MB";
      wifiBytesVal = 0;
      mobileBytesVal = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Data telah direset (bulan baru)")),
    );
  }
  // =================================================

  Future<void> fetchUsage() async {
    try {
      final Map<dynamic, dynamic> result = await platform.invokeMethod(
        'getTodayUsage',
      );

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
        wifiUsage = _formatBytes(wifiBytes);
        mobileUsage = _formatBytes(mobileBytes);
<<<<<<< HEAD
=======

        wifiBytesVal = wifiBytes.toDouble();
        mobileBytesVal = mobileBytes.toDouble();
>>>>>>> 77350aaff14d31b6727c7c305831e61dd5d0c20e
      });

      await checkLimitAndWarn(mobileBytes);
    } on PlatformException catch (e) {
      if (e.code == "PERMISSION_DENIED") {
        _showPermissionDialog();
      }
    }
  }

  // ================= PARSE INT AMAN =================
  int _parseToInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  // ================= FORMAT =================
  String _formatBytes(int bytes) {
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

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Batas Kuota Tercapai!"),
<<<<<<< HEAD
          content: const Text("Penggunaan data Anda sudah mencapai limit."),
=======
          content: const Text(
            "Penggunaan data Anda sudah mencapai limit. "
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

    loadTotalKuota();

    fetchUsage();
=======
    initApp();
  }

  Future<void> initApp() async {
    await checkMonthlyReset();
    await fetchUsage();
>>>>>>> 77350aaff14d31b6727c7c305831e61dd5d0c20e
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

  double _parseUsageToGB(String usage) {
    if (usage.contains("GB")) {
      return double.parse(usage.replaceAll("GB", "").trim());
    }

    if (usage.contains("MB")) {
      return double.parse(usage.replaceAll("MB", "").trim()) / 1024;
    }

    return 0;
  }

  String getHematStatus() {
    double mobileUsedGB = _parseUsageToGB(mobileUsage);

    double sisaKuota = totalKuotaGB - mobileUsedGB;

    int sisaHari = getRemainingDays();

    double batasAmanPerHari = sisaKuota / sisaHari;

    if (mobileUsedGB > batasAmanPerHari) {
      return "⚠ Pemakaian hari ini boros";
    }

    return "✅ Pemakaian masih aman";
  }

  String getPrediksiKuota() {
    double mobileUsedGB = _parseUsageToGB(mobileUsage);

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
            _usageCard("WiFi Today", wifiUsage, Icons.wifi),
<<<<<<< HEAD
=======
            const SizedBox(height: 8),
            ProgressQuota(used: wifiBytesVal, limit: 1024 * 1024 * 1024),
>>>>>>> 77350aaff14d31b6727c7c305831e61dd5d0c20e

            const SizedBox(height: 20),

            _usageCard("Mobile Today", mobileUsage, Icons.signal_cellular_alt),
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

  // ================= CARD =================
  Widget _usageCard(String title, String value, IconData icon) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 40, color: Colors.blue),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                value,
                style: const TextStyle(fontSize: 20, color: Colors.blueAccent),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= PERMISSION =================
  void _showPermissionDialog() {
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
            "Aplikasi membutuhkan izin 'Akses Penggunaan'.\n\n"
            "Silakan aktifkan izin di pengaturan.",
>>>>>>> 77350aaff14d31b6727c7c305831e61dd5d0c20e
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
