import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../models/transaction.dart';
import '../models/equity.dart';
import '../models/derivative.dart';
import '../models/goal.dart';
import '../models/recent_activity.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        Hive.box<Transaction>('transactions').listenable(),
        Hive.box<Equity>('equities').listenable(),
        Hive.box<DerivativeTrade>('derivatives').listenable(),
        Hive.box<Goal>('goals').listenable(),
      ]),
      builder: (context, _) {
        final transactions = Hive.box<Transaction>('transactions').values.toList();
        double totalIncome = transactions.where((t) => t.type == TransactionType.income).fold(0, (sum, item) => sum + item.amount);
        double totalExpense = transactions.where((t) => t.type == TransactionType.expense).fold(0, (sum, item) => sum + item.amount);
        double netFlow = totalIncome - totalExpense;
        double investmentValue = 320000; // Mock data

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryGrid(totalIncome, totalExpense, netFlow, investmentValue),
              const SizedBox(height: 24),
              _buildAnalyticsSection(transactions),
              const SizedBox(height: 24),
              _buildRecentActivitySection(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryGrid(double income, double expense, double netFlow, double investment) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.6,
      children: [
        _SummaryTile(title: 'Total Income', amount: income, color: Colors.green),
        _SummaryTile(title: 'Total Expense', amount: expense, color: Colors.red),
        _SummaryTile(title: 'Net Cash Flow', amount: netFlow, color: netFlow >= 0 ? Colors.green : Colors.red),
        _SummaryTile(title: 'Investment Value', amount: investment, color: Colors.purple),
      ],
    );
  }

  Widget _buildAnalyticsSection(List<Transaction> transactions) {
    final expenseTransactions = transactions.where((t) => t.type == TransactionType.expense).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Spending Analytics", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        GlassmorphicContainer(
          width: double.infinity,
          height: 250,
          borderRadius: 20,
          blur: 15,
          alignment: Alignment.center,
          border: 2,
          linearGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.surface.withAlpha(25),
                Theme.of(context).colorScheme.surface.withAlpha(45),
              ],
              stops: const [0.1, 1]),
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white.withAlpha(76), Colors.white.withAlpha(25)],
          ),
          child: expenseTransactions.isEmpty
            ? const Center(child: Text("No expense data to display."))
            : Row(
                children: [
                  Expanded(flex: 3, child: _buildPieChart(expenseTransactions)),
                  Expanded(flex: 2, child: _buildLegend(expenseTransactions)),
                ],
              ),
        ),
      ],
    );
  }

  Widget _buildRecentActivitySection() {
    final activities = _getRecentActivities();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Recent Activity", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        activities.isEmpty
            ? const Center(child: Text("No recent activity yet."))
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activities.length,
                itemBuilder: (context, index) {
                  final activity = activities[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: activity.iconColor.withAlpha(50),
                        child: Icon(activity.icon, color: activity.iconColor),
                      ),
                      title: Text(activity.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(activity.subtitle),
                      trailing: activity.amount != null
                          ? Text(
                              '₹${activity.amount!.toStringAsFixed(0)}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: activity.iconColor),
                            )
                          : null,
                    ),
                  );
                },
              ),
      ],
    );
  }

  Widget _buildPieChart(List<Transaction> expenseTransactions) {
    Map<String, double> categoryTotals = {};
    for (var tx in expenseTransactions) {
      categoryTotals.update(tx.category, (value) => value + tx.amount, ifAbsent: () => tx.amount);
    }

    return PieChart(
      PieChartData(
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            setState(() {
              if (!event.isInterestedForInteractions || pieTouchResponse == null || pieTouchResponse.touchedSection == null) {
                _touchedIndex = -1;
                return;
              }
              _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
            });
          },
        ),
        borderData: FlBorderData(show: false),
        sectionsSpace: 2,
        centerSpaceRadius: 0,
        sections: List.generate(categoryTotals.length, (i) {
          final isTouched = i == _touchedIndex;
          final entry = categoryTotals.entries.elementAt(i);
          return PieChartSectionData(
            color: AppTheme.chartColors[i % AppTheme.chartColors.length],
            value: entry.value,
            title: '',
            radius: isTouched ? 90.0 : 80.0,
          );
        }),
      ),
    );
  }

  Widget _buildLegend(List<Transaction> expenseTransactions) {
    Map<String, double> categoryTotals = {};
    double totalExpense = 0;
    for (var tx in expenseTransactions) {
      totalExpense += tx.amount;
      categoryTotals.update(tx.category, (value) => value + tx.amount, ifAbsent: () => tx.amount);
    }

    return ListView.builder(
      itemCount: categoryTotals.length,
      itemBuilder: (context, i) {
        final entry = categoryTotals.entries.elementAt(i);
        final percentage = (entry.value / totalExpense * 100).toStringAsFixed(1);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Container(width: 12, height: 12, color: AppTheme.chartColors[i % AppTheme.chartColors.length]),
              const SizedBox(width: 8),
              Expanded(child: Text('${entry.key} ($percentage%)', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
            ],
          ),
        );
      },
    );
  }

  List<RecentActivity> _getRecentActivities() {
    List<RecentActivity> activities = [];

    final transactions = Hive.box<Transaction>('transactions').values;
    activities.addAll(transactions.map((t) => RecentActivity(
      id: t.id, title: t.description, subtitle: t.category, amount: t.amount, date: t.date, type: ActivityType.transaction,
      icon: t.type == TransactionType.income ? Icons.arrow_upward : Icons.arrow_downward,
      iconColor: t.type == TransactionType.income ? Colors.green : Colors.red,
    )));

    final equities = Hive.box<Equity>('equities').values;
    activities.addAll(equities.map((e) => RecentActivity(
      id: e.id, title: 'Bought ${e.ticker}', subtitle: 'Investment', amount: e.buyPrice * e.quantity, date: e.purchaseDate, type: ActivityType.investment,
      icon: Icons.show_chart, iconColor: Colors.purple,
    )));

    final goals = Hive.box<Goal>('goals').values;
     activities.addAll(goals.map((g) => RecentActivity(
      id: g.id, title: 'New Goal: ${g.name}', subtitle: 'Planning', amount: g.targetAmount, date: g.targetDate, type: ActivityType.goal,
      icon: Icons.flag, iconColor: Colors.blue,
    )));

    activities.sort((a, b) => b.date.compareTo(a.date));
    return activities.take(10).toList();
  }
}

class _SummaryTile extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;

  const _SummaryTile({required this.title, required this.amount, required this.color});

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    return GlassmorphicContainer(
      width: 180,
      height: 120,
      borderRadius: 20,
      blur: 10,
      alignment: Alignment.center,
      border: 2,
      linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withAlpha(76), color.withAlpha(153)],
          stops: const [0.1, 1]),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white.withAlpha(128), Colors.white.withAlpha(51)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(format.format(amount), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}