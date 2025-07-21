import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/equity.dart';
import '../models/derivative.dart';
import '../widgets/equity_form.dart';
import '../widgets/derivative_form.dart';

class InvestmentsScreen extends StatelessWidget {
  const InvestmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        // Use a colored AppBar for this screen to contain the TabBar
        appBar: AppBar(
          flexibleSpace: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TabBar(
                tabs: const [
                  Tab(text: 'Portfolio Holdings'),
                  Tab(text: 'Trade Logbook'),
                ],
                indicatorColor: Theme.of(context).colorScheme.primary,
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor: Colors.grey,
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _PortfolioHoldingsView(),
            _TradeLogbookView(),
          ],
        ),
      ),
    );
  }
}

class _PortfolioHoldingsView extends StatelessWidget {
  const _PortfolioHoldingsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Equity>('equities').listenable(),
        builder: (context, Box<Equity> box, _) {
          if (box.values.isEmpty) {
            return const Center(child: Text("No equity holdings yet."));
          }
          final equities = box.values.toList();
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8),
            itemCount: equities.length,
            itemBuilder: (context, index) {
              final equity = equities[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text('${equity.ticker} (${equity.companyName})'),
                  subtitle: Text('${equity.quantity} shares @ ₹${equity.buyPrice.toStringAsFixed(2)}'),
                  trailing: const Icon(Icons.chevron_right),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(context: context, isScrollControlled: true, builder: (_) => const EquityForm()),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _TradeLogbookView extends StatelessWidget {
  const _TradeLogbookView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: Hive.box<DerivativeTrade>('derivatives').listenable(),
        builder: (context, Box<DerivativeTrade> box, _) {
          if (box.values.isEmpty) {
            return const Center(child: Text("No derivative trades logged yet."));
          }
          final trades = box.values.toList();
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8),
            itemCount: trades.length,
            itemBuilder: (context, index) {
              final trade = trades[index];
              final pnlColor = trade.netPandL >= 0 ? Colors.greenAccent.shade400 : Colors.redAccent;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(trade.instrument),
                  subtitle: Text(DateFormat.yMMMd().format(trade.buyDate)),
                  trailing: Text('₹${trade.netPandL.toStringAsFixed(2)}', style: TextStyle(color: pnlColor, fontWeight: FontWeight.bold)),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(context: context, isScrollControlled: true, builder: (_) => const DerivativeForm()),
        child: const Icon(Icons.add),
      ),
    );
  }
}