import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';

class TransactionForm extends StatefulWidget {
  final Transaction? transaction; // Optional transaction for editing

  const TransactionForm({super.key, this.transaction});

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  late TextEditingController _storeController;
  late TextEditingController _notesController;

  late TransactionType _selectedType;
  late String _selectedCategory;
  late String _selectedPaymentMethod;
  late DateTime _selectedDate;
  late bool _isRecurring;

  // Mock categories & payment methods - will be moved to settings
  final List<String> _incomeCategories = ['Salary', 'Gifts', 'Investments'];
  final List<String> _expenseCategories = ['Food', 'Transport', 'Shopping', 'Bills', 'Entertainment'];
  final List<String> _paymentMethods = ['Cash', 'UPI', 'Credit Card', 'Debit Card', 'Net Banking'];

  @override
  void initState() {
    super.initState();
    final transaction = widget.transaction;

    _descriptionController = TextEditingController(text: transaction?.description ?? '');
    _amountController = TextEditingController(text: transaction?.amount.toString() ?? '');
    _storeController = TextEditingController(text: transaction?.store ?? '');
    _notesController = TextEditingController(text: transaction?.notes ?? '');

    _selectedType = transaction?.type ?? TransactionType.expense;
    _selectedCategory = transaction?.category ?? (_selectedType == TransactionType.expense ? _expenseCategories.first : _incomeCategories.first);
    _selectedPaymentMethod = transaction?.paymentMethod ?? _paymentMethods.first;
    _selectedDate = transaction?.date ?? DateTime.now();
    _isRecurring = transaction?.isRecurring ?? false;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final box = Hive.box<Transaction>('transactions');
      
      final transactionData = Transaction(
        id: widget.transaction?.id ?? const Uuid().v4(),
        description: _descriptionController.text,
        amount: double.parse(_amountController.text),
        category: _selectedCategory,
        date: _selectedDate,
        type: _selectedType,
        paymentMethod: _selectedPaymentMethod,
        store: _storeController.text,
        notes: _notesController.text,
        isRecurring: _isRecurring,
      );

      if (widget.transaction != null) {
        // Update existing transaction
        await widget.transaction!.delete(); // Hive needs delete before put to update key
      }
      await box.put(transactionData.id, transactionData);

      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }
  
  void _deleteTransaction() {
    if (widget.transaction != null) {
      widget.transaction!.delete();
      Navigator.of(context).pop();
    }
  }


  @override
  Widget build(BuildContext context) {
    final categories = _selectedType == TransactionType.expense ? _expenseCategories : _incomeCategories;
    if (!categories.contains(_selectedCategory)) {
      _selectedCategory = categories.first;
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 16, left: 16, right: 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.transaction == null ? 'New Transaction' : 'Edit Transaction', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(value: TransactionType.expense, label: Text('Expense'), icon: Icon(Icons.remove)),
                  ButtonSegment(value: TransactionType.income, label: Text('Income'), icon: Icon(Icons.add)),
                ],
                selected: {_selectedType},
                onSelectionChanged: (Set<TransactionType> newSelection) {
                  setState(() {
                    _selectedType = newSelection.first;
                    _selectedCategory = (_selectedType == TransactionType.expense) ? _expenseCategories.first : _incomeCategories.first;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a description' : null,
                autocorrect: false, // Disables platform-native autocomplete
                enableSuggestions: false,
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount', prefixText: '₹'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter an amount';
                  if (double.tryParse(value) == null) return 'Please enter a valid number';
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                onChanged: (value) => setState(() => _selectedCategory = value!),
              ),
              DropdownButtonFormField<String>(
                value: _selectedPaymentMethod,
                decoration: const InputDecoration(labelText: 'Payment Method'),
                items: _paymentMethods.map((pm) => DropdownMenuItem(value: pm, child: Text(pm))).toList(),
                onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
              ),
              TextFormField(controller: _storeController, decoration: const InputDecoration(labelText: 'Store/Vendor (Optional)')),
              TextFormField(controller: _notesController, decoration: const InputDecoration(labelText: 'Notes (Optional)'), maxLines: 2),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Mark as Recurring", style: Theme.of(context).textTheme.bodyLarge),
                  Switch(value: _isRecurring, onChanged: (value) => setState(() => _isRecurring = value)),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  if (widget.transaction != null)
                    TextButton.icon(
                      onPressed: _deleteTransaction,
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      label: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  const Spacer(),
                  TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('Save'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}