import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/derivative.dart';

class DerivativeForm extends StatefulWidget {
  final DerivativeTrade? trade;

  const DerivativeForm({super.key, this.trade});

  @override
  State<DerivativeForm> createState() => _DerivativeFormState();
}

class _DerivativeFormState extends State<DerivativeForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _instrumentController;
  late TextEditingController _netPandLController;
  late TextEditingController _strategyController;
  late TextEditingController _learningsController;

  late TradeType _tradeType;
  late DateTime _buyDate;
  DateTime? _saleDate;

  @override
  void initState() {
    super.initState();
    final trade = widget.trade;
    _instrumentController = TextEditingController(text: trade?.instrument ?? '');
    _netPandLController = TextEditingController(text: trade?.netPandL.toString() ?? '');
    _strategyController = TextEditingController(text: trade?.strategy ?? '');
    _learningsController = TextEditingController(text: trade?.learnings ?? '');
    _tradeType = trade?.tradeType ?? TradeType.intraday;
    _buyDate = trade?.buyDate ?? DateTime.now();
    _saleDate = trade?.saleDate;
  }

  Future<void> _selectDate(BuildContext context, bool isBuyDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isBuyDate ? _buyDate : (_saleDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isBuyDate) {
          _buyDate = picked;
        } else {
          _saleDate = picked;
        }
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final newTrade = DerivativeTrade(
        id: widget.trade?.id ?? const Uuid().v4(),
        instrument: _instrumentController.text,
        tradeType: _tradeType,
        buyDate: _buyDate,
        saleDate: _tradeType == TradeType.positional ? _saleDate : null,
        netPandL: double.parse(_netPandLController.text),
        strategy: _strategyController.text,
        learnings: _learningsController.text,
      );

      final box = Hive.box<DerivativeTrade>('derivatives');
      await box.put(newTrade.id, newTrade);
      if (mounted) Navigator.of(context).pop();
    }
  }
  
  void _deleteTrade() {
    if (widget.trade != null) {
      widget.trade!.delete();
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
              Text(widget.trade == null ? 'Log New Trade' : 'Edit Trade', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              SegmentedButton<TradeType>(
                segments: const [
                  ButtonSegment(value: TradeType.intraday, label: Text('Intraday')),
                  ButtonSegment(value: TradeType.positional, label: Text('Positional')),
                ],
                selected: {_tradeType},
                onSelectionChanged: (selection) => setState(() => _tradeType = selection.first),
              ),
              const SizedBox(height: 16),
              TextFormField(controller: _instrumentController, decoration: const InputDecoration(labelText: 'Instrument (e.g., NIFTY 22500 CE)'), validator: (v) => v!.isEmpty ? 'Required' : null),
              TextFormField(controller: _netPandLController, decoration: const InputDecoration(labelText: 'Net Profit / Loss', prefixText: '₹'), keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true), validator: (v) => v!.isEmpty ? 'Required' : null),
              
              if (_tradeType == TradeType.intraday)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Date: ${DateFormat.yMMMd().format(_buyDate)}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _selectDate(context, true),
                )
              else ...[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Buy Date: ${DateFormat.yMMMd().format(_buyDate)}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _selectDate(context, true),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Sale Date: ${_saleDate == null ? "Not set" : DateFormat.yMMMd().format(_saleDate!)}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _selectDate(context, false),
                ),
              ],

              const Divider(height: 24),
              Text('Trade Analysis (Optional)', style: Theme.of(context).textTheme.titleMedium),
              TextFormField(controller: _strategyController, decoration: const InputDecoration(labelText: 'Strategy / Setup')),
              TextFormField(controller: _learningsController, decoration: const InputDecoration(labelText: 'Mistakes / Learnings'), maxLines: 3),
              const SizedBox(height: 24),
               Row(
                children: [
                  if (widget.trade != null)
                    TextButton.icon(
                      onPressed: _deleteTrade,
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