import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/equity.dart';

class EquityForm extends StatefulWidget {
  final Equity? equity;

  const EquityForm({super.key, this.equity});

  @override
  State<EquityForm> createState() => _EquityFormState();
}

class _EquityFormState extends State<EquityForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tickerController;
  late TextEditingController _companyNameController;
  late TextEditingController _quantityController;
  late TextEditingController _buyPriceController;
  late TextEditingController _sellPriceController;
  
  late DateTime _purchaseDate;
  DateTime? _saleDate;

  @override
  void initState() {
    super.initState();
    final equity = widget.equity;
    _tickerController = TextEditingController(text: equity?.ticker ?? '');
    _companyNameController = TextEditingController(text: equity?.companyName ?? '');
    _quantityController = TextEditingController(text: equity?.quantity.toString() ?? '');
    _buyPriceController = TextEditingController(text: equity?.buyPrice.toString() ?? '');
    _sellPriceController = TextEditingController(text: equity?.sellPrice?.toString() ?? '');
    _purchaseDate = equity?.purchaseDate ?? DateTime.now();
    _saleDate = equity?.saleDate;
  }

  Future<void> _selectDate(BuildContext context, bool isPurchaseDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isPurchaseDate ? _purchaseDate : (_saleDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isPurchaseDate) {
          _purchaseDate = picked;
        } else {
          _saleDate = picked;
        }
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final newEquity = Equity(
        id: widget.equity?.id ?? const Uuid().v4(),
        ticker: _tickerController.text.toUpperCase(),
        companyName: _companyNameController.text,
        quantity: int.parse(_quantityController.text),
        buyPrice: double.parse(_buyPriceController.text),
        purchaseDate: _purchaseDate,
        sellPrice: _sellPriceController.text.isNotEmpty ? double.parse(_sellPriceController.text) : null,
        saleDate: _saleDate,
      );

      final box = Hive.box<Equity>('equities');
      await box.put(newEquity.id, newEquity);

      if (mounted) Navigator.of(context).pop();
    }
  }

  void _deleteEquity() {
    if (widget.equity != null) {
      widget.equity!.delete();
      Navigator.of(context).pop();
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
              Text(widget.equity == null ? 'Add Equity Holding' : 'Edit Equity Holding', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              TextFormField(controller: _tickerController, decoration: const InputDecoration(labelText: 'Stock Ticker (e.g., RELIANCE)'), validator: (v) => v!.isEmpty ? 'Required' : null),
              TextFormField(controller: _companyNameController, decoration: const InputDecoration(labelText: 'Company Name'), validator: (v) => v!.isEmpty ? 'Required' : null),
              TextFormField(controller: _quantityController, decoration: const InputDecoration(labelText: 'Quantity'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Required' : null),
              TextFormField(controller: _buyPriceController, decoration: const InputDecoration(labelText: 'Buy Price', prefixText: '₹'), keyboardType: const TextInputType.numberWithOptions(decimal: true), validator: (v) => v!.isEmpty ? 'Required' : null),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Purchase Date: ${DateFormat.yMMMd().format(_purchaseDate)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, true),
              ),
              const Divider(height: 24),
              Text('Sale Details (Optional)', style: Theme.of(context).textTheme.titleMedium),
              TextFormField(controller: _sellPriceController, decoration: const InputDecoration(labelText: 'Sell Price', prefixText: '₹'), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Sale Date: ${_saleDate == null ? "Not set" : DateFormat.yMMMd().format(_saleDate!)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, false),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                   if (widget.equity != null)
                    TextButton.icon(
                      onPressed: _deleteEquity,
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      label: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  const Spacer(),
                  TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
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