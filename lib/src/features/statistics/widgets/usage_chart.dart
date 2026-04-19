import 'package:flutter/material.dart';
import '../model/usage_model.dart';

class UsageChart extends StatelessWidget {
  final List<UsageModel> data;

  const UsageChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final totalTerpakai = data.fold<double>(
      0,
      (sum, item) => sum + item.terpakai,
    );

    final totalSisa = data.fold<double>(0, (sum, item) => sum + item.sisa);

    final total = totalTerpakai + totalSisa;

    final hasData = data.isNotEmpty && total > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Ringkasan Pemakaian",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 15),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: hasData
              ? Column(
                  children: [
                    _bar("Terpakai", totalTerpakai, total, Colors.red),
                    const SizedBox(height: 12),
                    _bar("Sisa", totalSisa, total, Colors.green),
                  ],
                )
              : const Center(
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Text("Data belum tersedia"),
                  ),
                ),
        ),

        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _legend(Colors.red, "Terpakai"),
            const SizedBox(width: 20),
            _legend(Colors.green, "Sisa"),
          ],
        ),
      ],
    );
  }

  Widget _bar(String label, double value, double total, Color color) {
    final percent = total == 0 ? 0.0 : value / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label: ${value.toStringAsFixed(0)}",
          style: const TextStyle(fontSize: 13),
        ),

        const SizedBox(height: 6),

        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percent.clamp(0.0, 1.0),
            backgroundColor: Colors.grey.shade300,
            color: color,
            minHeight: 10,
          ),
        ),
      ],
    );
  }

  Widget _legend(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(text),
      ],
    );
  }
}
