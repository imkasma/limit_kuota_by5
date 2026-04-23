import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:limit_kuota_by5/src/core/data/database_helper.dart';
import 'package:limit_kuota_by5/src/core/services/intent_helper.dart';
import 'package:limit_kuota_by5/src/core/services/notification_service.dart';
import 'package:limit_kuota_by5/src/features/monitoring/history_page.dart';
import 'package:limit_kuota_by5/src/features/statistics/statistics_page.dart';

class Network extends StatefulWidget {
  const Network({super.key});

  @override
  State<Network> createState() => _NetworkState();
}

class _NetworkState extends State<Network> {
  static const platform = MethodChannel('limit_kuota/channel');

  String wifiUsage = "0.00 MB";
  String mobileUsage = "0.00 MB";

  double wifiPercent = 0.0;
  double mobilePercent = 0.0;

  double totalQuotaGB = 10;
  double remainingQuotaGB = 0;

  bool isLoading = false;
  bool isDarkMode = false;

  int get dailyLimitBytes => (totalQuotaGB * 1024 * 1024 * 1024).toInt();

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  // ================= INIT APP =================
  Future<void> initializeData() async {
    await loadTheme();
    await loadQuota();
    await checkMonthlyReset();
    await fetchUsage();
    await loadRemainingQuota();
  }

  // ================= LOAD THEME =================
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;
    setState(() {
      isDarkMode = prefs.getBool('darkMode') ?? false;
    });
  }

  // ================= TOGGLE THEME =================
  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      isDarkMode = !isDarkMode;
    });

    await prefs.setBool('darkMode', isDarkMode);
  }

  // ================= LOAD QUOTA =================
  Future<void> loadQuota() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;
    setState(() {
      totalQuotaGB = prefs.getDouble('totalQuotaGB') ?? 10;
    });
  }

  // ================= SAVE QUOTA =================
  Future<void> saveQuota(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('totalQuotaGB', value);

    if (!mounted) return;
    setState(() {
      totalQuotaGB = value;
    });

    await loadRemainingQuota();
  }

  // ================= LOAD SISA KUOTA =================
  Future<void> loadRemainingQuota() async {
    double remaining =
        await DatabaseHelper.instance.getRemainingQuota(totalQuotaGB);

    if (!mounted) return;
    setState(() {
      remainingQuotaGB = remaining;
    });
  }

  // ================= RESET BULANAN =================
  Future<void> checkMonthlyReset() async {
    final prefs = await SharedPreferences.getInstance();

    final currentMonth = DateTime.now().month;
    final savedMonth = prefs.getInt('savedMonth') ?? currentMonth;

    if (currentMonth != savedMonth) {
      await DatabaseHelper.instance.clearAllData();
      await prefs.setInt('savedMonth', currentMonth);
    }
  }

  // ================= SET QUOTA =================
  void showSetQuotaDialog() {
    final controller = TextEditingController(
      text: totalQuotaGB.toStringAsFixed(0),
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Set Total Kuota"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: "Masukkan total kuota (GB)",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              final value = double.tryParse(controller.text);

              if (value != null && value > 0) {
                await saveQuota(value);
                Navigator.pop(context);
                await fetchUsage();
              }
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  // ================= FETCH USAGE =================
  Future<void> fetchUsage() async {
    if (!mounted) return;

    setState(() => isLoading = true);

    try {
      final result = await platform.invokeMethod('getTodayUsage');

      String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      int wifiBytes = result['wifi'] ?? 0;
      int mobileBytes = result['mobile'] ?? 0;

      await DatabaseHelper.instance.insertOrUpdate(
        todayDate,
        wifiBytes,
        mobileBytes,
      );

      if (!mounted) return;

      setState(() {
        wifiUsage = formatBytes(wifiBytes);
        mobileUsage = formatBytes(mobileBytes);
        wifiPercent = wifiBytes / dailyLimitBytes;
        mobilePercent = mobileBytes / dailyLimitBytes;
        isLoading = false;
      });

      await checkLimitAndWarn(mobileBytes);
      await loadRemainingQuota();
    } on PlatformException catch (e) {
      if (!mounted) return;

      setState(() => isLoading = false);

      if (e.code == "PERMISSION_DENIED") {
        showPermissionDialog();
      }
    }
  }

  // ================= FORMAT BYTES =================
  String formatBytes(int bytes) {
    if (bytes <= 0) return "0.00 MB";

    double mb = bytes / (1024 * 1024);

    if (mb >= 1024) {
      return "${(mb / 1024).toStringAsFixed(2)} GB";
    }

    return "${mb.toStringAsFixed(2)} MB";
  }

  // ================= WARNING =================
  Future<void> checkLimitAndWarn(int currentUsage) async {
    if (currentUsage >= dailyLimitBytes) {
      await NotificationService.showNotification(
        id: 2,
        title: "🚫 Batas Kuota Tercapai",
        body: "Penggunaan data Anda sudah mencapai limit.",
      );
    } else if (currentUsage >= dailyLimitBytes * 0.8) {
      await NotificationService.showNotification(
        id: 1,
        title: "⚠ Kuota Hampir Habis",
        body: "Penggunaan data sudah mencapai 80% dari limit.",
      );
    }
  }

  // ================= CARD =================
  Widget usageCard(String title, String value, IconData icon, double percent) {
    Color progressColor =
        percent >= 0.8 ? Colors.red : percent >= 0.5 ? Colors.orange : Colors.green;

    return Card(
      color: isDarkMode ? Colors.grey[850] : Colors.white,
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Padding(
        padding: const EdgeInsets.all(20),
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
                      Text(title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black,
                          )),
                      Text(value,
                          style: const TextStyle(
                            fontSize: 22,
                            color: Colors.blueAccent,
                          )),
                    ],
                  ),
                ),
                Text("${(percent * 100).toStringAsFixed(0)}%"),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: percent.clamp(0, 1),
              minHeight: 10,
              valueColor: AlwaysStoppedAnimation(progressColor),
            ),
          ],
        ),
      ),
    );
  }

  // ================= PERMISSION =================
  void showPermissionDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Izin Diperlukan"),
        content: const Text("Silakan aktifkan izin akses penggunaan."),
        actions: [
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

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    double usedPercent = ((totalQuotaGB - remainingQuotaGB) / totalQuotaGB)
        .clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.grey[100],
      appBar: AppBar(
        title: const Text("Monitoring Data"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: showSetQuotaDialog,
          ),
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: toggleTheme,
          ),
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          usageCard("WiFi Today", wifiUsage, Icons.wifi, wifiPercent),
          const SizedBox(height: 20),
          usageCard("Mobile Today", mobileUsage, Icons.signal_cellular_alt, mobilePercent),
          const SizedBox(height: 20),

          Text(
            "Total Kuota: ${totalQuotaGB.toStringAsFixed(0)} GB",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            "Sisa Kuota Bulan Ini: ${remainingQuotaGB.toStringAsFixed(2)} GB",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: remainingQuotaGB <= 1 ? Colors.red : Colors.green,
            ),
          ),

          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: LinearProgressIndicator(
              value: usedPercent,
              minHeight: 12,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation(
                usedPercent >= 0.8 ? Colors.red : Colors.blue,
              ),
            ),
          ),

          const SizedBox(height: 30),

          ElevatedButton.icon(
            onPressed: isLoading ? null : fetchUsage,
            icon: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            label: Text(isLoading ? "Memuat..." : "Refresh Data"),
          ),
        ],
      ),
    );
  }
}