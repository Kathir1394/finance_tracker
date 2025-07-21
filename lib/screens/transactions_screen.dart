import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction.dart';
import '../widgets/transaction_form.dart';
import '../widgets/transaction_list_item.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Transaction>('transactions').listenable(),
        builder: (context, Box<Transaction> box, _) {
          if (box.values.isEmpty) {
            return const Center(
              child: Text("No transactions yet. Add one!"),
            );
          }
          // Display transactions in a list, sorted by date
          var transactions = box.values.toList();
          transactions.sort((a, b) => b.date.compareTo(a.date));

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return TransactionListItem(transaction: transaction);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show the form to add a new transaction
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => const TransactionForm(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}