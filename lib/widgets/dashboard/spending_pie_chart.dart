import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SpendingPieChart extends StatelessWidget {
  final Map<String, double> expenseData;
  const SpendingPieChart({super.key, required this.expenseData});

  // Helper to generate a list of colors
  List<Color> get pieColors => [
    Colors.blue.shade400,
    Colors.purple.shade400,
    Colors.green.shade400,
    Colors.orange.shade400,
    Colors.red.shade400,
    Colors.teal.shade400,
  ];

  @override
  Widget build(BuildContext context) {
    if (expenseData.isEmpty) {
      return const Center(child: Text("No expense data available."));
    }
    
    final totalExpense = expenseData.values.fold(0.0, (sum, item) => sum + item);
    final sortedExpenses = expenseData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: PieChart(
            PieChartData(
              sectionsSpace: 4,
              centerSpaceRadius: 40,
              sections: List.generate(sortedExpenses.length, (index) {
                final entry = sortedExpenses[index];
                final percentage = (entry.value / totalExpense * 100).toStringAsFixed(1);
                return PieChartSectionData(
                  color: pieColors[index % pieColors.length],
                  value: entry.value,
                  title: '$percentage%',
                  radius: 50,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: ListView.builder(
            itemCount: sortedExpenses.length,
            itemBuilder: (context, index) {
              final entry = sortedExpenses[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      color: pieColors[index % pieColors.length],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      entry.key,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}