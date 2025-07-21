import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../widgets/transaction_list_item.dart';
import '../theme/app_theme.dart'; // Import theme

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<Transaction>('transactions').listenable(),
      builder: (context, Box<Transaction> box, _) {
        final transactions = box.values.toList();
        double totalIncome = transactions.where((t) => t.type == TransactionType.income).fold(0, (sum, item) => sum + item.amount);
        double totalExpense = transactions.where((t) => t.type == TransactionType.expense).fold(0, (sum, item) => sum + item.amount);
        double netFlow = totalIncome - totalExpense;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatCards(netFlow, totalIncome, totalExpense, 0.0),
              const SizedBox(height: 24),
              Text('Spending by category', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildSpendingChart(transactions),
              const SizedBox(height: 24),
              Text('Recent Transactions', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildRecentTransactions(transactions),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCards(double netFlow, double income, double expense, double pnl) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.8,
      children: [
        _StatCard(title: 'Net Flow', amount: netFlow, color: netFlow >= 0 ? Colors.greenAccent.shade400 : Colors.redAccent),
        _StatCard(title: 'Total Income', amount: income, color: Colors.greenAccent.shade400),
        _StatCard(title: 'Total Expense', amount: expense, color: Colors.redAccent),
        _StatCard(title: 'Investments P/L', amount: pnl, color: pnl >= 0 ? Colors.greenAccent.shade400 : Colors.redAccent),
      ],
    );
  }

  Widget _buildSpendingChart(List<Transaction> transactions) {
    final expenseTransactions = transactions.where((t) => t.type == TransactionType.expense).toList();
    if (expenseTransactions.isEmpty) {
      return Card(
        child: const SizedBox(
          height: 200,
          child: Center(child: Text("No expense data to display.")),
        ),
      );
    }

    double totalExpense = expenseTransactions.fold(0, (sum, item) => sum + item.amount);

    Map<String, double> categoryTotals = {};
    for (var tx in expenseTransactions) {
      categoryTotals.update(tx.category, (value) => value + tx.amount, ifAbsent: () => tx.amount);
    }

    List<PieChartSectionData> sections = [];
    int colorIndex = 0;
    for (var entry in categoryTotals.entries) {
      final isTouched = categoryTotals.keys.toList().indexOf(entry.key) == touchedIndex;
      final percentage = totalExpense > 0 ? (entry.value / totalExpense * 100) : 0;
      sections.add(PieChartSectionData(
        color: AppTheme.chartColors[colorIndex % AppTheme.chartColors.length],
        value: entry.value,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: isTouched ? 60.0 : 50.0,
        titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ));
      colorIndex++;
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions || pieTouchResponse == null || pieTouchResponse.touchedSection == null) {
                            touchedIndex = -1;
                            return;
                          }
                          touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: sections,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: categoryTotals.keys.map((category) {
                  int catIndex = categoryTotals.keys.toList().indexOf(category);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Indicator(color: AppTheme.chartColors[catIndex % AppTheme.chartColors.length], text: category, isSquare: false),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions(List<Transaction> transactions) {
    if (transactions.isEmpty) {
      return const Center(child: Text("No recent transactions."));
    }
    transactions.sort((a, b) => b.date.compareTo(a.date));
    final recent = transactions.take(5).toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recent.length,
      itemBuilder: (context, index) {
        return TransactionListItem(transaction: recent[index]);
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;

  const _StatCard({required this.title, required this.amount, required this.color});

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
            const SizedBox(height: 4),
            Text(
              format.format(amount),
              style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class Indicator extends StatelessWidget {
  final Color color;
  final String text;
  final bool isSquare;
  const Indicator({super.key, required this.color, required this.text, required this.isSquare});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(width: 16, height: 16, decoration: BoxDecoration(shape: isSquare ? BoxShape.rectangle : BoxShape.circle, color: color)),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)))
      ],
    );
  }
}