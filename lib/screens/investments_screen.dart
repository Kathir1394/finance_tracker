import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/stock_service.dart';
import '../models/equity.dart';
import '../models/derivative.dart';
import '../widgets/equity_form.dart';
import '../widgets/derivative_form.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

final stockServiceProvider = Provider((ref) => StockService());

class InvestmentsScreen extends ConsumerWidget {
  final TabController tabController;
  const InvestmentsScreen({super.key, required this.tabController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        AppBar(
          title: const Text('Investments'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh Prices',
              onPressed: () async {
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                scaffoldMessenger.showSnackBar(
                  const SnackBar(content: Text('Fetching latest market data...')),
                );
                
                final success = await ref.read(stockServiceProvider).refreshData();
                
                scaffoldMessenger.removeCurrentSnackBar();
                scaffoldMessenger.showSnackBar(
                  SnackBar(content: Text(success ? 'Stock prices updated!' : 'Failed to update prices.')),
                );
              },
            )
          ],
        ),
        TabBar(
          controller: tabController,
          tabs: const [
            Tab(text: 'Portfolio Holdings'),
            Tab(text: 'Trade Logbook'),
          ],
          indicatorColor: Theme.of(context).colorScheme.primary,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.grey,
        ),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: const [
              _PortfolioHoldingsView(),
              _TradeLogbookView(),
            ],
          ),
        ),
      ],
    );
  }
}

class _PortfolioHoldingsView extends StatelessWidget {
  const _PortfolioHoldingsView();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<Equity>('equities').listenable(),
      builder: (context, Box<Equity> box, _) {
        if (box.values.isEmpty) {
          return const Center(child: Text("No equity holdings yet."));
        }
        final equities = box.values.toList();
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          itemCount: equities.length,
          itemBuilder: (context, index) {
            final equity = equities[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text('${equity.ticker} (${equity.companyName})'),
                subtitle: Text('${equity.quantity} shares @ ₹${equity.buyPrice.toStringAsFixed(2)}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => EquityForm(equity: equity),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _TradeLogbookView extends StatelessWidget {
  const _TradeLogbookView();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<DerivativeTrade>('derivatives').listenable(),
      builder: (context, Box<DerivativeTrade> box, _) {
        if (box.values.isEmpty) {
          return const Center(child: Text("No derivative trades logged yet."));
        }
        final trades = box.values.toList();
        trades.sort((a, b) => b.buyDate.compareTo(a.buyDate));

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          itemCount: trades.length,
          itemBuilder: (context, index) {
            final trade = trades[index];
            final pnlColor = trade.netPandL >= 0 ? Colors.greenAccent.shade400 : Colors.redAccent;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(trade.instrument),
                subtitle: Text(DateFormat.yMMMd().format(trade.buyDate)),
                trailing: Text('₹${trade.netPandL.toStringAsFixed(2)}',
                    style: TextStyle(color: pnlColor, fontWeight: FontWeight.bold)),
                onTap: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => DerivativeForm(trade: trade),
                ),
              ),
            );
          },
        );
      },
    );
  }
}