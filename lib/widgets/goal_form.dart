import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
// ✅ FIX: The 'uuid' package is not used here, so its import is removed.
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
  DateTime? _targetDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.goal?.name);
    _targetAmountController =
        TextEditingController(text: widget.goal?.targetAmount.toString());
    _currentAmountController =
        TextEditingController(text: widget.goal?.currentAmount.toString() ?? '0');
    _targetDate = widget.goal?.targetDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetAmountController.dispose();
    _currentAmountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _targetDate) {
      setState(() {
        _targetDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final newGoal = Goal(
        id: widget.goal?.id,
        name: _nameController.text,
        targetAmount: double.parse(_targetAmountController.text),
        currentAmount: double.parse(_currentAmountController.text),
        targetDate: _targetDate,
        creationDate: widget.goal?.creationDate,
      );

      final box = Hive.box<Goal>('goals');
      await box.put(newGoal.id, newGoal);
      if (mounted) Navigator.of(context).pop();
    }
  }

  void _deleteGoal() {
    if (widget.goal != null) {
      widget.goal!.delete();
      Navigator.of(context).pop();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 16,
          left: 16,
          right: 16),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.goal == null ? 'Add New Goal' : 'Edit Goal',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Goal Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _targetAmountController,
                decoration:
                    const InputDecoration(labelText: 'Target Amount', prefixText: '₹'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _currentAmountController,
                decoration: const InputDecoration(
                    labelText: 'Current Amount (Optional)', prefixText: '₹'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                    'Target Date: ${_targetDate == null ? "Not set" : DateFormat.yMMMd().format(_targetDate!)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  if (widget.goal != null)
                    TextButton.icon(
                      onPressed: _deleteGoal,
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      label:
                          const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  const Spacer(),
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel')),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: _submitForm, child: const Text('Save')),
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