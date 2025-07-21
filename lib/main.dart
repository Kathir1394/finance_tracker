import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/transaction.dart';
import 'models/equity.dart';
import 'models/derivative.dart';
import 'models/goal.dart';
import 'screens/dashboard_screen.dart';
import 'screens/transactions_screen.dart';
import 'screens/investments_screen.dart';
import 'screens/planning_screen.dart';
import 'screens/settings_screen.dart';
import 'theme/app_theme.dart'; // Import the new theme file

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(TransactionTypeAdapter());
  Hive.registerAdapter(EquityAdapter());
  Hive.registerAdapter(DerivativeTradeAdapter());
  Hive.registerAdapter(TradeTypeAdapter());
  Hive.registerAdapter(GoalAdapter());

  await Hive.openBox<Transaction>('transactions');
  await Hive.openBox<Equity>('equities');
  await Hive.openBox<DerivativeTrade>('derivatives');
  await Hive.openBox<Goal>('goals');

  runApp(const FinanceTrackerApp());
}

class FinanceTrackerApp extends StatelessWidget {
  const FinanceTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Tracker',
      // Use the new theme definitions
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const MainAppShell(),
    );
  }
}

class MainAppShell extends StatefulWidget {
  const MainAppShell({super.key});

  @override
  State<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends State<MainAppShell> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    DashboardScreen(),
    TransactionsScreen(),
    InvestmentsScreen(),
    PlanningScreen(),
  ];

  static const List<String> _widgetTitles = <String>[
    'Dashboard',
    'Transactions',
    'Investments',
    'Planning',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_widgetTitles[_selectedIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.swap_horiz), activeIcon: Icon(Icons.swap_horiz_sharp), label: 'Transactions'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), activeIcon: Icon(Icons.show_chart_sharp), label: 'Investments'),
          BottomNavigationBarItem(icon: Icon(Icons.edit_calendar_outlined), activeIcon: Icon(Icons.edit_calendar), label: 'Planning'),
        ],
        currentIndex: _selectedIndex,
        // Theming is now handled by the main theme file
        onTap: _onItemTapped,
      ),
    );
  }
}