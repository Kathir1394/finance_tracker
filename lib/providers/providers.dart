import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Import your data models
import '../models/transaction.dart';
import '../models/equity.dart';
import '../models/goal.dart';

// A simple model for the unified activity list
class Activity {
  final String title;
  final String subtitle;
  final IconData icon;
  final DateTime date;
  final String amount;

  Activity({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.date,
    required this.amount,
  });
}

// -- REACTIVE DATA PROVIDERS --

// ✅ FIX: These StreamProviders watch the Hive boxes for any changes.
final _transactionStream = StreamProvider.autoDispose((ref) => Hive.box<Transaction>('transactions').watch());
final _equityStream = StreamProvider.autoDispose((ref) => Hive.box<Equity>('equities').watch());
final _goalStream = StreamProvider.autoDispose((ref) => Hive.box<Goal>('goals').watch());

// ✅ FIX: These providers now listen to the streams. When the database changes,
// these providers will automatically re-run, supplying fresh data to the UI.

final transactionListProvider = Provider<List<Transaction>>((ref) {
  // By watching the stream, this provider re-runs on any database event.
  ref.watch(_transactionStream);
  return Hive.box<Transaction>('transactions').values.toList();
});

final equityListProvider = Provider<List<Equity>>((ref) {
  ref.watch(_equityStream);
  return Hive.box<Equity>('equities').values.toList();
});

final goalListProvider = Provider<List<Goal>>((ref) {
  ref.watch(_goalStream);
  return Hive.box<Goal>('goals').values.toList();
});


// -- CALCULATION PROVIDERS (These will now be reactive automatically) --
// Because these providers depend on the reactive lists above, they will
// also update whenever the data changes.

final totalIncomeProvider = Provider<double>((ref) {
  final transactions = ref.watch(transactionListProvider);
  return transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, item) => sum + item.amount);
});

final totalExpenseProvider = Provider<double>((ref) {
  final transactions = ref.watch(transactionListProvider);
  return transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, item) => sum + item.amount);
});

final netCashFlowProvider = Provider<double>((ref) {
  return ref.watch(totalIncomeProvider) - ref.watch(totalExpenseProvider);
});

final investmentValueProvider = Provider<double>((ref) {
  final equities = ref.watch(equityListProvider);
  return equities.fold(0.0, (sum, e) => sum + (e.quantity * e.buyPrice));
});

final expenseByCategoryProvider = Provider<Map<String, double>>((ref) {
  final transactions = ref.watch(transactionListProvider);
  final expenseTransactions = transactions.where((t) => t.type == TransactionType.expense);

  final Map<String, double> data = {};
  for (var t in expenseTransactions) {
    data.update(t.category, (value) => value + t.amount, ifAbsent: () => t.amount);
  }
  return data;
});

final recentActivityProvider = Provider<List<Activity>>((ref) {
  final transactions = ref.watch(transactionListProvider);
  final equities = ref.watch(equityListProvider);
  final goals = ref.watch(goalListProvider);

  final List<Activity> allActivities = [];

  allActivities.addAll(transactions.map((t) => Activity(
    title: t.description,
    subtitle: t.category,
    icon: t.type == TransactionType.income ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
    date: t.date,
    amount: '${t.type == TransactionType.income ? '+' : '-'} ₹${t.amount.toStringAsFixed(0)}',
  )));

  allActivities.addAll(equities.map((e) => Activity(
    title: 'Bought ${e.ticker}',
    subtitle: '${e.quantity} shares',
    icon: Icons.show_chart_rounded,
    date: e.purchaseDate,
    amount: '- ₹${(e.quantity * e.buyPrice).toStringAsFixed(0)}',
  )));

  allActivities.addAll(goals.map((g) => Activity(
    title: 'New Goal: ${g.name}',
    subtitle: 'Target: ₹${g.targetAmount.toStringAsFixed(0)}',
    icon: Icons.flag_rounded,
    date: g.creationDate,
    amount: '',
  )));

  // Sort all activities by date and take the last 10
  allActivities.sort((a, b) => b.date.compareTo(a.date));
  return allActivities.take(10).toList();
});