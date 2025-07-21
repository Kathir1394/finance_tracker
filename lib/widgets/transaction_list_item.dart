import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';

class TransactionListItem extends StatelessWidget {
  final Transaction transaction;

  const TransactionListItem({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? const Color(0xFF2A2A40) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final isExpense = transaction.type == TransactionType.expense;
    final amountColor = isExpense ? Colors.redAccent : Colors.green;
    final amountPrefix = isExpense ? '- ' : '+ ';

    return Card(
      color: cardColor,
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: amountColor.withOpacity(0.2),
          child: Icon(
            isExpense ? Icons.arrow_downward : Icons.arrow_upward,
            color: amountColor,
          ),
        ),
        title: Text(
          transaction.description,
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        subtitle: Text(
          '${transaction.category} • ${DateFormat.yMMMd().format(transaction.date)}',
          style: TextStyle(color: textColor.withOpacity(0.7)),
        ),
        trailing: Text(
          '$amountPrefix₹${transaction.amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: amountColor,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}