import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/goal.dart';

class GoalForm extends StatefulWidget {
  final Goal? goal;
  const GoalForm({super.key, this.goal});

  @override
  State<GoalForm> createState() => _GoalFormState();
}

class _GoalFormState extends State<GoalForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _targetAmountController;
  late TextEditingController _currentAmountController;
  late DateTime _targetDate;

  @override
  void initState() {
    super.initState();
    final goal = widget.goal;
    _nameController = TextEditingController(text: goal?.name ?? '');
    _targetAmountController = TextEditingController(text: goal?.targetAmount.toString() ?? '');
    _currentAmountController = TextEditingController(text: goal?.currentAmount.toString() ?? '0');
    _targetDate = goal?.targetDate ?? DateTime.now().add(const Duration(days: 365));
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _targetDate) {
      setState(() => _targetDate = picked);
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final newGoal = Goal(
        id: widget.goal?.id ?? const Uuid().v4(),
        name: _nameController.text,
        targetAmount: double.parse(_targetAmountController.text),
        currentAmount: double.parse(_currentAmountController.text),
        targetDate: _targetDate,
      );

      final box = Hive.box<Goal>('goals');
      await box.put(newGoal.id, newGoal);

      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 16, left: 16, right: 16),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.goal == null ? 'New Financial Goal' : 'Edit Goal', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Goal Name (e.g., New Car)'), validator: (v) => v!.isEmpty ? 'Required' : null),
              TextFormField(controller: _targetAmountController, decoration: const InputDecoration(labelText: 'Target Amount', prefixText: '₹'), keyboardType: const TextInputType.numberWithOptions(decimal: true), validator: (v) => v!.isEmpty ? 'Required' : null),
              TextFormField(controller: _currentAmountController, decoration: const InputDecoration(labelText: 'Current Amount Saved', prefixText: '₹'), keyboardType: const TextInputType.numberWithOptions(decimal: true), validator: (v) => v!.isEmpty ? 'Required' : null),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Target Date: ${DateFormat.yMMMd().format(_targetDate)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                child: const Text('Save Goal'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}