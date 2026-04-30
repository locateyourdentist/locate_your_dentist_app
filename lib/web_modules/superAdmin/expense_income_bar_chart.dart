import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ExpensePieChart extends StatelessWidget {
  final List<Map<String, dynamic>> stateWiseExpense;

  const ExpensePieChart({
    super.key,
    required this.stateWiseExpense,
  });

  @override
  Widget build(BuildContext context) {
    final List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.brown,
    ];

    return PieChart(
      PieChartData(
        sections: List.generate(stateWiseExpense.length, (index) {
          final item = stateWiseExpense[index];

          final state = (item["state"] ?? "").toString().trim().isEmpty
              ? "Others"
              : item["state"].toString();

          final value = (item["totalExpense"] ?? 0).toDouble();

          return PieChartSectionData(
            value: value,
            title: state,
            color: colors[index % colors.length],
            radius: 70,
            titleStyle: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          );
        }),
      ),
    );
  }
}