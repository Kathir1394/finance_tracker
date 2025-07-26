import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Your existing model and screen imports
import 'models/transaction.dart';
import 'models/equity.dart';
import 'models/derivative.dart';
import 'models/goal.dart';
import 'screens/dashboard_screen.dart';
import 'screens/transactions_screen.dart';
import 'screens/investments_screen.dart';
import 'screens/planning_screen.dart';
import 'screens/settings_screen.dart';
import 'theme/app_theme.dart';

// Your existing widget imports
import 'widgets/glassmorphic_nav_bar.dart';
import 'widgets/transaction_form.dart';
import 'widgets/equity_form.dart';
import 'widgets/derivative_form.dart';
import 'widgets/goal_form.dart';

// ✅ **Step 1: Import the new background widget**
import 'widgets/common/app_background.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Your Hive registrations remain the same
  if (!Hive.isAdapterRegistered(TransactionAdapter().typeId)) {
    Hive.registerAdapter(TransactionAdapter());
  }
  if (!Hive.isAdapterRegistered(TransactionTypeAdapter().typeId)) {
    Hive.registerAdapter(TransactionTypeAdapter());
  }
  if (!Hive.isAdapterRegistered(EquityAdapter().typeId)) {
    Hive.registerAdapter(EquityAdapter());
  }
  if (!Hive.isAdapterRegistered(DerivativeTradeAdapter().typeId)) {
    Hive.registerAdapter(DerivativeTradeAdapter());
  }
  if (!Hive.isAdapterRegistered(TradeTypeAdapter().typeId)) {
    Hive.registerAdapter(TradeTypeAdapter());
  }
  if (!Hive.isAdapterRegistered(GoalAdapter().typeId)) {
    Hive.registerAdapter(GoalAdapter());
  }

  await Hive.openBox<Transaction>('transactions');
  await Hive.openBox<Equity>('equities');
  await Hive.openBox<DerivativeTrade>('derivatives');
  await Hive.openBox<Goal>('goals');

  runApp(const ProviderScope(child: FinanceUniverseApp()));
}

class FinanceUniverseApp extends StatelessWidget {
  const FinanceUniverseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinanceUniverse',
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

class _MainAppShellState extends State<MainAppShell> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  int _nestedTabIndex = 0;

  late final TabController _investmentsTabController;
  late final TabController _planningTabController;
  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _investmentsTabController = TabController(length: 2, vsync: this);
    _planningTabController = TabController(length: 2, vsync: this);

    _widgetOptions = <Widget>[
      const DashboardScreen(),
      const TransactionsScreen(),
      InvestmentsScreen(tabController: _investmentsTabController),
      PlanningScreen(tabController: _planningTabController),
    ];

    _investmentsTabController.addListener(() {
      if (!_investmentsTabController.indexIsChanging) {
        setState(() => _nestedTabIndex = _investmentsTabController.index);
      }
    });
    _planningTabController.addListener(() {
      if (!_planningTabController.indexIsChanging) {
        setState(() => _nestedTabIndex = _planningTabController.index);
      }
    });
  }

  @override
  void dispose() {
    _investmentsTabController.dispose();
    _planningTabController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 2) _nestedTabIndex = _investmentsTabController.index;
      if (index == 3) _nestedTabIndex = _planningTabController.index;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool showFab = _selectedIndex != 0;

    // ✅ **Step 2: Set the scaffold background to transparent**
    // This allows the AppBackground to be visible.
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Stack(
        children: [
          // ✅ **Step 3: Replace the old gradient Container with the new AppBackground widget**
          const AppBackground(),

          // The rest of your UI remains exactly the same.
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildCustomHeader(context),
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: _widgetOptions,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: GlassmorphicNavBar(
              selectedIndex: _selectedIndex,
              onItemTapped: _onItemTapped,
            ),
          ),
          Positioned(
            bottom: 100,
            right: 20,
            child: AnimatedOpacity(
              opacity: showFab ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: IgnorePointer(
                ignoring: !showFab,
                child: FloatingActionButton(
                  heroTag: 'main_fab',
                  onPressed: () => _onFabTapped(context),
                  child: const Icon(Icons.add),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onFabTapped(BuildContext context) {
    switch (_selectedIndex) {
      case 1:
        showModalBottomSheet(context: context, isScrollControlled: true, builder: (_) => const TransactionForm());
        break;
      case 2:
        if (_nestedTabIndex == 0) {
          showModalBottomSheet(context: context, isScrollControlled: true, builder: (_) => const EquityForm());
        } else {
          showModalBottomSheet(context: context, isScrollControlled: true, builder: (_) => const DerivativeForm());
        }
        break;
      case 3:
        if (_nestedTabIndex == 0) {
            showModalBottomSheet(context: context, isScrollControlled: true, builder: (_) => const GoalForm());
        }
        break;
    }
  }

  Widget _buildCustomHeader(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/images/FinanceUniverse.png', height: 36),
                const SizedBox(width: 8),
                const Flexible(
                  child: Text(
                    'FinanceUniverse',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
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
    );
  }
}