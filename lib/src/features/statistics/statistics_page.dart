import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:limit_kuota/src/core/data/database_helper.dart';
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

  @override
  void initState() {
    super.initState();
    loadChartData();
  }

  Future<void> loadChartData() async {
    final data = await DatabaseHelper.instance.getWeeklyUsageData();

    if (!mounted) return;

    setState(() {
      weeklyData = List<double>.from(data);

      usageList = data.map((value) {
        return UsageModel(terpakai: value * 0.6, sisa: value * 0.4);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Statistik"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Grafik Pemakaian 7 Hari",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: true),

                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = ["S", "S", "R", "K", "J", "S", "M"];

                          if (value.toInt() < 0 ||
                              value.toInt() >= days.length) {
                            return const SizedBox();
                          }

                          return Text(
                            days[value.toInt()],
                            style: const TextStyle(fontSize: 12),
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
                          width: 14,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "Distribusi Pemakaian",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            UsageChart(data: usageList),

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
