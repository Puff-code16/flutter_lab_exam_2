import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ExpenseChart extends StatelessWidget {
  final double total;

  const ExpenseChart({super.key, required this.total});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              value: total,
              color: Colors.blue,
              title: "${total.toStringAsFixed(0)} THB",
              radius: 80,
            ),
          ],
        ),
      ),
    );
  }
}
