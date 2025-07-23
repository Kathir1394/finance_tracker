import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:shimmer/shimmer.dart';
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
        // FIX: Moved equities definition here to be in the correct scope
        final equities = Hive.box<Equity>('equities').values.toList();
        double totalIncome = transactions.where((t) => t.type == TransactionType.income).fold(0, (sum, item) => sum + item.amount);
        double totalExpense = transactions.where((t) => t.type == TransactionType.expense).fold(0, (sum, item) => sum + item.amount);
        double netFlow = totalIncome - totalExpense;
        double investmentValue = equities.fold(0, (sum, item) => sum + (item.quantity * item.buyPrice));

        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    _buildSummaryGrid(totalIncome, totalExpense, netFlow, investmentValue),
                    const SizedBox(height: 24),
                    _buildAnalyticsSection(transactions),
                    const SizedBox(height: 24),
                    const Text("Recent Activity", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            _buildRecentActivitySliverList(),
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        );
      },
    );
  }

  Widget _buildSummaryGrid(double income, double expense, double netFlow, double investment) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 280, // FIX: Added required height
      borderRadius: 20,
      blur: 20,
      alignment: Alignment.center,
      border: 1.5,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.blue.withAlpha(20),
          Colors.blue.withAlpha(30),
        ],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white.withAlpha(100), Colors.white.withAlpha(30)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Wrap(
          spacing: 16.0,
          runSpacing: 16.0,
          alignment: WrapAlignment.center,
          children: [
            _SummaryTile(title: 'Total Income', amount: income),
            _SummaryTile(title: 'Total Expense', amount: expense),
            _SummaryTile(title: 'Net Cash Flow', amount: netFlow),
            _SummaryTile(title: 'Investment Value', amount: investment),
          ],
        ),
      ),
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

  Widget _buildRecentActivitySliverList() {
    final activities = _getRecentActivities();
    if (activities.isEmpty) {
      return const SliverToBoxAdapter(
        child: SizedBox(height: 100, child: Center(child: Text("No recent activity yet.")))
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
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
          childCount: activities.length,
        ),
      ),
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

  const _SummaryTile({required this.title, required this.amount});

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final screenWidth = MediaQuery.of(context).size.width;
    final tileWidth = (screenWidth / 2) - 40;

    final positiveGradient = LinearGradient(
      colors: [Colors.lightGreenAccent.shade100, Colors.greenAccent.shade700],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    final negativeGradient = LinearGradient(
      colors: [Colors.red.shade200, Colors.red.shade700],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    Gradient textGradient;
    if (title == 'Total Expense' || (title == 'Net Cash Flow' && amount < 0)) {
      textGradient = negativeGradient;
    } else {
      textGradient = positiveGradient;
    }

    return SizedBox(
      width: tileWidth,
      height: 120,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned.fill(
              child: Shimmer.fromColors(
                baseColor: Colors.black.withAlpha(220),
                highlightColor: Colors.grey[900]!,
                period: const Duration(seconds: 5),
                child: Container(color: Colors.black),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withAlpha(230),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (bounds) => textGradient.createShader(
                          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                        ),
                        child: Text(
                          format.format(amount),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}