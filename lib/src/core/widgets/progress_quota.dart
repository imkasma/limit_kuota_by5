import 'package:flutter/material.dart';

class ProgressQuota extends StatelessWidget {
  final double used;
  final double limit;

  const ProgressQuota({super.key, required this.used, required this.limit});

  @override
  Widget build(BuildContext context) {
    double percent = (used / limit).clamp(0, 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("${(percent * 100).toStringAsFixed(0)}%"),
        const SizedBox(height: 8),
        Container(
          height: 10,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(10),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percent,
            child: Container(
              decoration: BoxDecoration(
                color: percent < 0.5
                    ? Colors.green
                    : percent < 0.8
                    ? Colors.orange
                    : Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text("Dipakai: $used / $limit"),
      ],
    );
  }
}
