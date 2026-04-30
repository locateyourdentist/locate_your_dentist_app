import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:locate_your_dentist/model/income_model.dart';

class IncomeBarChart extends StatelessWidget {
  final IncomeDashboardModel data;

  const IncomeBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        barGroups: [
          _bar(0, data.posterIncome.toDouble(), Colors.blue),
          _bar(1, data.basePlanIncome.toDouble(), Colors.green),
          _bar(2, data.addOnsIncome.toDouble(), Colors.orange),
          _bar(3, data.jobIncome.toDouble(), Colors.purple),
          _bar(4, data.webinarIncome.toDouble(), Colors.red),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                switch (value.toInt()) {
                  case 0: return const Text("Poster");
                  case 1: return const Text("Base");
                  case 2: return const Text("AddOns");
                  case 3: return const Text("Job");
                  case 4: return const Text("Webinar");
                }
                return const Text('');
              },
            ),
          ),
        ),
      ),
    );
  }

  BarChartGroupData _bar(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 18,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}