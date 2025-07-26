import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/providers.dart';
import '../widgets/dashboard/futuristic_info_card.dart';
import '../widgets/dashboard/spending_pie_chart.dart';
import '../widgets/dashboard/recent_activity_list.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalIncome = ref.watch(totalIncomeProvider);
    final totalExpense = ref.watch(totalExpenseProvider);
    final netCashFlow = ref.watch(netCashFlowProvider);
    final investmentValue = ref.watch(investmentValueProvider);
    final expenseData = ref.watch(expenseByCategoryProvider);
    final recentActivities = ref.watch(recentActivityProvider);

    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Financial Overview',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1, 
                    children: [
                      FuturisticInfoCard(
                        title: 'Total Income',
                        value: currencyFormat.format(totalIncome),
                        icon: Icons.arrow_downward_rounded,
                      ),
                      FuturisticInfoCard(
                        title: 'Total Expense',
                        value: currencyFormat.format(totalExpense),
                        icon: Icons.arrow_upward_rounded,
                      ),
                      FuturisticInfoCard(
                        title: 'Net Cash Flow',
                        value: currencyFormat.format(netCashFlow),
                        icon: Icons.account_balance_wallet_outlined,
                      ),
                      FuturisticInfoCard(
                        title: 'Investment Value',
                        value: currencyFormat.format(investmentValue),
                        icon: Icons.trending_up_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Spending Analytics',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: SpendingPieChart(expenseData: expenseData),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Recent Activity',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          RecentActivityList(activities: recentActivities),

          // ✅ FIX: Adds padding at the bottom so the list can scroll above the nav bar
          const SliverToBoxAdapter(
            child: SizedBox(height: 120),
          ),
        ],
      ),
    );
  }
}