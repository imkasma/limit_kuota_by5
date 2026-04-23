import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:limit_kuota_by5/src/core/data/database_helper.dart';
import 'model/usage_model.dart';
import 'widgets/usage_chart.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  List<double> weeklyData = List.filled(7, 0);
  List<UsageModel> usageList = [];

  bool isLoading = false;

  static const double dailyLimitMB = 1024; // 1 GB

  @override
  void initState() {
    super.initState();
    loadChartData();
  }

  // =========================
  // LOAD DATA
  // =========================
  Future<void> loadChartData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final data = await DatabaseHelper.instance.getWeeklyUsageData();

      if (!mounted) return;

      setState(() {
        weeklyData = List<double>.from(data);

        usageList = weeklyData.map((used) {
          double remaining = dailyLimitMB - used;
          if (remaining < 0) remaining = 0;

          return UsageModel(
            terpakai: used,
            sisa: remaining,
          );
        }).toList();

        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loadChartData: $e");

      setState(() {
        isLoading = false;
      });
    }
  }

  // =========================
  // BAR CHART
  // =========================
  Widget buildBarChart() {
    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          maxY: dailyLimitMB,
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 256,
                getTitlesWidget: (value, meta) {
                  return Text(
                    "${value.toInt()}",
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const days = ['S', 'S', 'R', 'K', 'J', 'S', 'M'];

                  if (value.toInt() >= days.length) {
                    return const SizedBox();
                  }

                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      days[value.toInt()],
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: List.generate(
            weeklyData.length,
            (i) => BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: weeklyData[i],
                  width: 16,
                  borderRadius: BorderRadius.circular(6),
                  color: weeklyData[i] > 800
                      ? Colors.red
                      : weeklyData[i] > 500
                          ? Colors.orange
                          : Colors.blue,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================
  // TOTAL SUMMARY
  // =========================
  Widget buildSummaryCard() {
    double totalUsed =
        usageList.fold(0, (sum, item) => sum + item.terpakai);

    double totalRemaining =
        usageList.fold(0, (sum, item) => sum + item.sisa);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Text(
              "Ringkasan Mingguan",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Text(
              "Terpakai: ${totalUsed.toStringAsFixed(1)} MB",
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              "Sisa: ${totalRemaining.toStringAsFixed(1)} MB",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Statistik"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Grafik Pemakaian 7 Hari",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: buildBarChart(),
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "Distribusi Pemakaian",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  usageList.isEmpty
                      ? const Center(
                          child: Text("Belum ada data"),
                        )
                      : Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: UsageChart(data: usageList),
                          ),
                        ),

                  const SizedBox(height: 20),

                  buildSummaryCard(),

                  const SizedBox(height: 25),

                  Center(
                    child: ElevatedButton.icon(
                      onPressed: loadChartData,
                      icon: const Icon(Icons.refresh),
                      label: const Text("Refresh Data"),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}