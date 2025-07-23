import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/goal.dart';
import '../models/transaction.dart';
import '../widgets/transaction_list_item.dart';

class PlanningScreen extends StatelessWidget {
  final TabController tabController;
  const PlanningScreen({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: tabController,
          tabs: const [
            Tab(text: 'Financial Goals'),
            Tab(text: 'Recurring'),
          ],
          indicatorColor: Theme.of(context).colorScheme.primary,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.grey,
        ),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: const [
              _GoalsView(),
              _RecurringView(),
            ],
          ),
        ),
      ],
    );
  }
}

class _GoalsView extends StatelessWidget {
  const _GoalsView();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<Goal>('goals').listenable(),
      builder: (context, Box<Goal> box, _) {
        if (box.values.isEmpty) {
          return const Center(child: Text("No financial goals set yet."));
        }
        final goals = box.values.toList();
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          itemCount: goals.length,
          itemBuilder: (context, index) {
            final goal = goals[index];
            final progress = (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0);
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(goal.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 12,
                      borderRadius: BorderRadius.circular(6),
                      backgroundColor: Theme.of(context).colorScheme.surface.withAlpha(50),
                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                    ),
                    const SizedBox(height: 8),
                    Text('₹${goal.currentAmount.toStringAsFixed(0)} / ₹${goal.targetAmount.toStringAsFixed(0)}'),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _RecurringView extends StatelessWidget {
  const _RecurringView();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<Transaction>('transactions').listenable(),
      builder: (context, Box<Transaction> box, _) {
        final recurring = box.values.where((tx) => tx.isRecurring).toList();
        if (recurring.isEmpty) {
          return const Center(child: Text("No recurring transactions set."));
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          itemCount: recurring.length,
          itemBuilder: (context, index) {
            return TransactionListItem(transaction: recurring[index]);
          },
        );
      },
    );
  }
}