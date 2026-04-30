import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

// class ExpensePieChart extends StatelessWidget {
//   final List<Map<String, dynamic>> stateWiseExpense;
//
//   const ExpensePieChart({
//     super.key,
//     required this.stateWiseExpense,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     if (stateWiseExpense.isEmpty) {
//       return const Center(child: Text("No Data"));
//     }
//
//     return PieChart(
//       PieChartData(
//         sectionsSpace: 2,
//         centerSpaceRadius: 30,
//         sections: stateWiseExpense.map((e) {
//           final double value =
//           (e["totalExpense"] ?? 0 as num).toDouble();
//
//           final String state =
//           (e["state"] == null || e["state"].toString().trim().isEmpty)
//               ? "Others"
//               : e["state"].toString();
//
//           return PieChartSectionData(
//             value: value,
//             title: value.toStringAsFixed(0),
//             color: _getColor(state),
//             radius: 70,
//             titleStyle: const TextStyle(
//               fontSize: 12,
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }
//
//   Color _getColor(String state) {
//     switch (state) {
//       case "Kerala":
//         return Colors.green;
//       case "Andhra Pradesh":
//         return Colors.blue;
//       default:
//         return Colors.orange;
//     }
//   }
// }

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
            color: colors[index % colors.length], // 🔥 dynamic color
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